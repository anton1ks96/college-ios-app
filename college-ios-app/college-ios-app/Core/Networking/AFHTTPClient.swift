//
//  AFHTTPClient.swift
//  college-ios-app
//
//  Created by pc on 21.09.2025.
//

import Foundation
import Alamofire

// MARK: - HTTP Method
public enum HTTPMethod: String {
    case get = "GET", post = "POST", put = "PUT", delete = "DELETE"
}

// MARK: - Endpoint
public struct Endpoint {
    public var path: String
    public var method: HTTPMethod
    public var queryItems: [URLQueryItem] = []
    public var headers: [String: String] = [:]
    public var body: Data? = nil
    public var contentType: String? = nil

    public init(
        path: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:],
        body: Data? = nil,
        contentType: String? = nil
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.headers = headers
        self.body = body
        self.contentType = contentType
    }
}

// MARK: - Errors
public enum HTTPError: Error, LocalizedError {
    case invalidURL
    case statusCode(Int, Data?)
    case decoding(Error)
    case url(URLError)
    case cancelled

    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "Неверный URL."
        case .statusCode(let code, _): return "Сервер вернул код \(code)."
        case .decoding(let e): return "Ошибка декодирования: \(e.localizedDescription)"
        case .url(let e): return e.localizedDescription
        case .cancelled: return "Запрос отменён."
        }
    }
}

// MARK: - Protocol
public protocol HTTPClientProtocol {
    func send<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T
    func sendRaw(_ endpoint: Endpoint) async throws -> (Data, HTTPURLResponse)
}

// MARK: - build URL
private struct AFEndpointRequest: URLRequestConvertible {
    let baseURL: URL
    let endpoint: Endpoint
    let timeout: TimeInterval
    let combinedHeaders: [String: String]

    func asURLRequest() throws -> URLRequest {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw HTTPError.invalidURL
        }
        let cleanPath = endpoint.path.hasPrefix("/") ? String(endpoint.path.dropFirst()) : endpoint.path
        components.path = components.path.appending("/").appending(cleanPath)
        if !endpoint.queryItems.isEmpty { components.queryItems = endpoint.queryItems }
        guard let url = components.url else { throw HTTPError.invalidURL }

        var req = URLRequest(url: url, timeoutInterval: timeout)
        req.httpMethod = endpoint.method.rawValue
        endpoint.body.map { req.httpBody = $0 }
        if let ct = endpoint.contentType { req.setValue(ct, forHTTPHeaderField: "Content-Type") }
        combinedHeaders.forEach { key, value in req.setValue(value, forHTTPHeaderField: key) }
        return req
    }
}

final class AFLogger: EventMonitor {
    let queue = DispatchQueue(label: "AFLogger")
    func request(_ request: Request, didCreateTask task: URLSessionTask) {
        #if DEBUG
        debugPrint(request.description)
        #endif
    }
    func request(_ request: DataRequest, didParseResponse response: DataResponse<Data?, AFError>) {
        #if DEBUG
        let code = response.response?.statusCode ?? -1
        debugPrint("⬅️ [\(code)]", request.description)
        if let data = response.data, let text = String(data: data, encoding: .utf8) {
            debugPrint("Response:", text)
        }
        #endif
    }
}

// MARK: - Alamofire client
public final class AFHTTPClient: HTTPClientProtocol {
    private let baseURL: URL
    private let session: Session
    private let decoder: JSONDecoder
    private let defaultHeaders: HTTPHeaders
    private let requestTimeout: TimeInterval

    public init(
        baseURL: URL,
        session: Session? = nil,
        decoder: JSONDecoder = JSONDecoder(),
        defaultHeaders: [String: String] = ["Accept": "application/json"],
        requestTimeout: TimeInterval = 30
    ) {
        self.baseURL = baseURL
        self.decoder = decoder
        self.defaultHeaders = HTTPHeaders(defaultHeaders)
        self.requestTimeout = requestTimeout

        if let session = session {
            self.session = session
        } else {
            let config = URLSessionConfiguration.af.default
            config.timeoutIntervalForRequest = requestTimeout
            let logger = AFLogger()
            self.session = Session(configuration: config, eventMonitors: [logger])
        }
    }

    public func send<T: Decodable>(_ endpoint: Endpoint, as type: T.Type = T.self) async throws -> T {
        let (data, _) = try await sendRaw(endpoint)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw HTTPError.decoding(error)
        }
    }

    public func sendRaw(_ endpoint: Endpoint) async throws -> (Data, HTTPURLResponse) {
        if Task.isCancelled { throw HTTPError.cancelled }

        var headers = defaultHeaders
        endpoint.headers.forEach { headers.add(name: $0.key, value: $0.value) }
        if let ct = endpoint.contentType { headers.add(name: "Content-Type", value: ct) }

        let convertible = AFEndpointRequest(
            baseURL: baseURL,
            endpoint: endpoint,
            timeout: requestTimeout,
            combinedHeaders: headers.dictionary
        )

        let dataTask = session.request(convertible)
            .serializingData()

        do {
            let response = await dataTask.response
            if let error = response.error, error.isExplicitlyCancelledError {
                throw HTTPError.cancelled
            }
            if Task.isCancelled {
                throw HTTPError.cancelled
            }
            guard let http = response.response else {
                throw HTTPError.url(URLError(.badServerResponse))
            }
            if response.error != nil {
                throw HTTPError.statusCode(http.statusCode, response.data)
            }
            guard (200...299).contains(http.statusCode) else {
                throw HTTPError.statusCode(http.statusCode, response.data)
            }
            return (response.data ?? Data(), http)
        } catch {
            if let afErr = error.asAFError {
                if afErr.isExplicitlyCancelledError || error is CancellationError { throw HTTPError.cancelled }
                if case let .sessionTaskFailed(underlyingError) = afErr,
                   let urlErr = underlyingError as? URLError {
                    throw HTTPError.url(urlErr)
                }
            }
            if let urlErr = error as? URLError { throw HTTPError.url(urlErr) }
            if error is CancellationError { throw HTTPError.cancelled }
            throw error
        }
    }
}
