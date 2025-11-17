//
//  CrashlyticsLogger.swift
//  college-ios-app
//
//  Created by pc on 17.11.2025.
//

import Foundation
import FirebaseCrashlytics

enum CrashlyticsLogger {
    
    // MARK: - Error Logging
    
    static func logError(
        _ error: Error,
        context: String? = nil,
        customKeys: [String: Any]? = nil
    ) {
#if DEBUG
        print("[Crashlytics] Error: \(error)")
        if let context = context {
            print("   Context: \(context)")
        }
        if let customKeys = customKeys {
            print("   Custom Keys: \(customKeys)")
        }
#else
        let crashlytics = Crashlytics.crashlytics()
        
        if let customKeys = customKeys {
            setCustomKeys(customKeys)
        }
        
        if let context = context {
            crashlytics.setCustomValue(context, forKey: "error_context")
        }
        
        crashlytics.record(error: error)
#endif
    }
    
    static func logFatalError(
        _ message: String,
        customKeys: [String: Any]? = nil
    ) {
#if DEBUG
        print("[Crashlytics] Fatal Error: \(message)")
        if let customKeys = customKeys {
            print("   Custom Keys: \(customKeys)")
        }
#else
        let crashlytics = Crashlytics.crashlytics()
        
        if let customKeys = customKeys {
            setCustomKeys(customKeys)
        }
        
        crashlytics.setCustomValue(message, forKey: "fatal_error_message")
        crashlytics.log("FATAL ERROR: \(message)")
        
        let error = NSError(
            domain: "com.college.fatal",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: message]
        )
        crashlytics.record(error: error)
#endif
    }
    
    // MARK: - Network Error Logging
    
    static func logNetworkError(
        _ error: Error,
        endpoint: String,
        method: String = "GET",
        statusCode: Int? = nil
    ) {
        var customKeys: [String: Any] = [
            "network_endpoint": endpoint,
            "network_method": method,
            "error_domain": (error as NSError).domain,
            "error_code": (error as NSError).code
        ]
        
        if let statusCode = statusCode {
            customKeys["http_status_code"] = statusCode
        }
        
        logError(
            error,
            context: "Network request failed: \(method) \(endpoint)",
            customKeys: customKeys
        )
    }
    
    // MARK: - Authentication Error Logging
    
    static func logAuthError(
        _ error: Error,
        operation: String,
        userId: String? = nil
    ) {
        var customKeys: [String: Any] = [
            "auth_operation": operation,
            "error_domain": (error as NSError).domain,
            "error_code": (error as NSError).code
        ]
        
        if let userId = userId {
            customKeys["user_id"] = userId
        }
        
        logError(
            error,
            context: "Authentication failed: \(operation)",
            customKeys: customKeys
        )
    }
    
    // MARK: - Keychain Error Logging
    
    static func logKeychainError(
        operation: String,
        status: OSStatus,
        key: String
    ) {
        let customKeys: [String: Any] = [
            "keychain_operation": operation,
            "keychain_status": status,
            "keychain_key": key
        ]
        
        let error = NSError(
            domain: NSOSStatusErrorDomain,
            code: Int(status),
            userInfo: [NSLocalizedDescriptionKey: "Keychain \(operation) failed with status: \(status)"]
        )
        
        logError(
            error,
            context: "Keychain operation failed: \(operation) for key: \(key)",
            customKeys: customKeys
        )
    }
    
    // MARK: - Data Error Logging
    
    static func logDataError(
        _ error: Error,
        operation: String,
        dataType: String
    ) {
        let customKeys: [String: Any] = [
            "data_operation": operation,
            "data_type": dataType,
            "error_domain": (error as NSError).domain,
            "error_code": (error as NSError).code
        ]
        
        logError(
            error,
            context: "Data \(operation) failed for type: \(dataType)",
            customKeys: customKeys
        )
    }
    
    // MARK: - Custom Keys
    
    static func setCustomKeys(_ keys: [String: Any]) {
#if DEBUG
        print("[Crashlytics] Custom Keys: \(keys)")
#else
        let crashlytics = Crashlytics.crashlytics()
        for (key, value) in keys {
            crashlytics.setCustomValue(value, forKey: key)
        }
#endif
    }
    
    // MARK: - Breadcrumbs
    
    static func recordBreadcrumb(_ message: String) {
#if DEBUG
        print("[Crashlytics] Breadcrumb: \(message)")
#else
        Crashlytics.crashlytics().log(message)
#endif
    }
    
    // MARK: - User Identification
    
    static func setUserIdentifier(_ userId: String?) {
#if DEBUG
        print("[Crashlytics] User ID: \(userId ?? "nil")")
#else
        Crashlytics.crashlytics().setUserID(userId ?? "")
#endif
    }
    
    // MARK: - App State
    
    static func setAppState(
        appVersion: String,
        buildNumber: String,
        environment: String
    ) {
        let keys: [String: Any] = [
            "app_version": appVersion,
            "build_number": buildNumber,
            "environment": environment
        ]
        setCustomKeys(keys)
    }
}
