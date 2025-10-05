////
////  CrashlyticsLogger.swift
////  college-ios-app
////
////  Created by pc on 03.10.2025.
////
//
//import Foundation
//import FirebaseCrashlytics
//
//final class CrashlyticsLogger {
//    
//    // MARK: - Singleton
//    static let shared = CrashlyticsLogger()
//    
//    // MARK: - Private Init
//    private init() {}
//    
//    // MARK: - Logging Methods
//    
//    /// Log a message to Crashlytics
//    /// - Parameter message: The message to log
//    func log(_ message: String) {
//        Crashlytics.crashlytics().log(message)
//    }
//    
//    /// Log a formatted message with parameters
//    /// - Parameters:
//    ///   - format: The format string
//    ///   - args: The arguments for formatting
//    func log(_ format: String, _ args: CVarArg...) {
//        let message = String(format: format, arguments: args)
//        log(message)
//    }
//    
//    /// Record a non-fatal error
//    /// - Parameters:
//    ///   - error: The error to record
//    ///   - userInfo: Additional context (optional)
//    func recordError(_ error: Error, userInfo: [String: Any]? = nil) {
//        let nsError = error as NSError
//        if let info = userInfo {
//            let enrichedError = NSError(
//                domain: nsError.domain,
//                code: nsError.code,
//                userInfo: nsError.userInfo.merging(info) { _, new in new }
//            )
//            Crashlytics.crashlytics().record(error: enrichedError)
//        } else {
//            Crashlytics.crashlytics().record(error: error)
//        }
//    }
//    
//    /// Record a custom non-fatal error with message
//    /// - Parameters:
//    ///   - domain: Error domain
//    ///   - code: Error code
//    ///   - message: Error message
//    ///   - userInfo: Additional context (optional)
//    func recordError(domain: String, code: Int, message: String, userInfo: [String: Any]? = nil) {
//        var info = userInfo ?? [:]
//        info[NSLocalizedDescriptionKey] = message
//        
//        let error = NSError(domain: domain, code: code, userInfo: info)
//        recordError(error)
//    }
//    
//    /// Set a custom key-value pair for crash reports
//    /// - Parameters:
//    ///   - value: The value to set
//    ///   - key: The key to associate with the value
//    func setCustomValue(_ value: Any, forKey key: String) {
//        Crashlytics.crashlytics().setCustomValue(value, forKey: key)
//    }
//    
//    //    func setUserId(_ userId: String) {
//    //        Crashlytics.crashlytics().setUserID(userId)
//    //    }
//    //
//    //    func clearUserId() {
//    //        Crashlytics.crashlytics().setUserID("")
//    //    }
//    
//    // MARK: - Convenience Methods
//    
//    /// Log MetricKit data
//    /// - Parameters:
//    ///   - category: The metric category (e.g., "CPU", "Memory", "Disk")
//    ///   - metrics: Dictionary of metric values
//    func logMetrics(category: String, metrics: [String: Any]) {
//        let metricsString = metrics.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
//        log("MetricKit [\(category)] - \(metricsString)")
//        
//        for (key, value) in metrics {
//            setCustomValue(value, forKey: "metric_\(category.lowercased())_\(key)")
//        }
//    }
//    
//    /// Log a diagnostic event (crash, hang, etc.)
//    /// - Parameters:
//    ///   - type: The diagnostic type (e.g., "Crash", "Hang", "CPU Exception")
//    ///   - details: Diagnostic details
//    func logDiagnostic(type: String, details: [String: Any]) {
//        let detailsString = details.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
//        log("Diagnostic [\(type)] - \(detailsString)")
//        
//        recordError(
//            domain: "com.college.diagnostics",
//            code: diagnosticCode(for: type),
//            message: "MetricKit diagnostic: \(type)",
//            userInfo: details
//        )
//    }
//    
//    // MARK: - Private Helpers
//    
//    private func diagnosticCode(for type: String) -> Int {
//        switch type.lowercased() {
//        case "crash": return 1001
//        case "hang": return 1002
//        case "cpu exception": return 1003
//        case "disk write exception": return 1004
//        case "memory exception": return 1005
//        default: return 1000
//        }
//    }
//}
//
//// MARK: - Convenience Global Functions
//
///// Log a message to Crashlytics
//func logToCrashlytics(_ message: String) {
//    CrashlyticsLogger.shared.log(message)
//}
//
///// Record a non-fatal error to Crashlytics
//func recordErrorToCrashlytics(_ error: Error, userInfo: [String: Any]? = nil) {
//    CrashlyticsLogger.shared.recordError(error, userInfo: userInfo)
//}
