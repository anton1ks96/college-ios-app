//
//  AuthRequestInterceptor.swift
//  college-ios-app
//
//  Created by pc on 18.10.2025.
//

import Foundation
import Alamofire

public nonisolated final class AuthRequestInterceptor: RequestInterceptor {
    private let authService: AuthService
    
    public init(authService: AuthService) {
        self.authService = authService
    }
    
    // MARK: - RequestAdapter
    
    public func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping @Sendable (Result<URLRequest, Error>) -> Void
    ) {
        Task { @Sendable in
            do {
                let token = try await authService.validAccessToken()
                var modifiedRequest = urlRequest
                modifiedRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                completion(.success(modifiedRequest))
            } catch {
                Task { @MainActor in
                    CrashlyticsLogger.logAuthError(
                        error,
                        operation: "request_adaptation"
                    )
                    CrashlyticsLogger.setCustomKeys([
                        "request_url": urlRequest.url?.absoluteString ?? "unknown",
                        "request_method": urlRequest.httpMethod ?? "unknown"
                    ])
                }
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - RequestRetrier
    
    public func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping @Sendable (RetryResult) -> Void
    ) {
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401 else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        Task { @Sendable in
            do {
                _ = try await authService.validAccessToken()
                await MainActor.run {
                    CrashlyticsLogger.recordBreadcrumb("401 retry successful - token refreshed")
                }
                completion(.retry)
            } catch {
                await MainActor.run {
                    CrashlyticsLogger.logAuthError(
                        error,
                        operation: "retry_401_token_refresh"
                    )
                    CrashlyticsLogger.setCustomKeys([
                        "request_url": request.request?.url?.absoluteString ?? "unknown",
                        "response_status": response.statusCode
                    ])
                }
                completion(.doNotRetryWithError(error))
            }
        }
    }
}
