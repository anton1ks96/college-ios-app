////
////  MetricsManager.swift
////  college-ios-app
////
////  Created by pc on 03.10.2025.
////
//
//import Foundation
//import MetricKit
//
//final class MetricsManager: NSObject {
//    
//    // MARK: - Singleton
//    static let shared = MetricsManager()
//    
//    // MARK: - Private Properties
//    private var isStarted = false
//    
//    // MARK: - Private Init
//    private override init() {
//        super.init()
//    }
//    
//    // MARK: - Public Methods
//    
//    func start() {
//        guard !isStarted else { return }
//        
//        MXMetricManager.shared.add(self)
//        isStarted = true
//    }
//    
//    func stop() {
//        guard isStarted else { return }
//        
//        MXMetricManager.shared.remove(self)
//        isStarted = false
//    }
//}
//
//// MARK: - MXMetricManagerSubscriber
//
//extension MetricsManager: MXMetricManagerSubscriber {
//    
//    /// Called when new metric payloads are available (typically once per day)
//    func didReceive(_ payloads: [MXMetricPayload]) {
//        for payload in payloads {
//            processMetricPayload(payload)
//        }
//    }
//    
//    /// Called when diagnostic payloads are available (crashes, hangs, exits)
//    func didReceive(_ payloads: [MXDiagnosticPayload]) {
//        for payload in payloads {
//            processDiagnosticPayload(payload)
//        }
//    }
//}
//
//// MARK: - Metric Processing
//
//private extension MetricsManager {
//    
//    func processMetricPayload(_ payload: MXMetricPayload) {
//        if let cpuMetrics = payload.cpuMetrics {
//            processCPUMetrics(cpuMetrics)
//        }
//        
//        if let memoryMetrics = payload.memoryMetrics {
//            processMemoryMetrics(memoryMetrics)
//        }
//        
//        if let diskMetrics = payload.diskIOMetrics {
//            processDiskMetrics(diskMetrics)
//        }
//        
//        if let displayMetrics = payload.displayMetrics {
//            processDisplayMetrics(displayMetrics)
//        }
//        
//        if let networkMetrics = payload.networkTransferMetrics {
//            processNetworkMetrics(networkMetrics)
//        }
//        
//        if let applicationTimeMetrics = payload.applicationTimeMetrics {
//            processApplicationTimeMetrics(applicationTimeMetrics)
//        }
//        
//        if let launchMetrics = payload.applicationLaunchMetrics {
//            processLaunchMetrics(launchMetrics)
//        }
//        
//        if let exitMetrics = payload.applicationExitMetrics {
//            processExitMetrics(exitMetrics)
//        }
//        
//        if let responsivenessMetrics = payload.applicationResponsivenessMetrics {
//            processResponsivenessMetrics(responsivenessMetrics)
//        }
//    }
//    
//    func processCPUMetrics(_ metrics: MXCPUMetric) {
//        let cpuTime = metrics.cumulativeCPUTime.value
//        
//        CrashlyticsLogger.shared.logMetrics(category: "CPU", metrics: [
//            "cumulative_time_seconds": cpuTime
//        ])
//        
//        if cpuTime > 60 {
//            CrashlyticsLogger.shared.recordError(
//                domain: "com.college.performance",
//                code: 2001,
//                message: "High CPU usage detected",
//                userInfo: ["cpu_time_seconds": cpuTime]
//            )
//        }
//    }
//    
//    func processMemoryMetrics(_ metrics: MXMemoryMetric) {
//        let peakMemory = metrics.peakMemoryUsage.value
//        let avgMemory = metrics.averageSuspendedMemory.averageMeasurement.value
//        
//        CrashlyticsLogger.shared.logMetrics(category: "Memory", metrics: [
//            "peak_mb": peakMemory,
//            "avg_suspended_mb": avgMemory
//        ])
//        
//        if peakMemory > 200 {
//            CrashlyticsLogger.shared.recordError(
//                domain: "com.college.performance",
//                code: 2002,
//                message: "High memory usage detected",
//                userInfo: ["peak_memory_mb": peakMemory]
//            )
//        }
//    }
//    
//    func processDiskMetrics(_ metrics: MXDiskIOMetric) {
//        let writes = metrics.cumulativeLogicalWrites.value
//        
//        CrashlyticsLogger.shared.logMetrics(category: "Disk", metrics: [
//            "writes_mb": writes
//        ])
//        
//        if writes > 100 {
//            CrashlyticsLogger.shared.recordError(
//                domain: "com.college.performance",
//                code: 2003,
//                message: "High disk writes detected",
//                userInfo: ["disk_writes_mb": writes]
//            )
//        }
//    }
//    
//    func processDisplayMetrics(_ metrics: MXDisplayMetric) {
//    }
//    
//    func processNetworkMetrics(_ metrics: MXNetworkTransferMetric) {
//    }
//    
//    func processApplicationTimeMetrics(_ metrics: MXAppRunTimeMetric) {
//    }
//    
//    func processLaunchMetrics(_ metrics: MXAppLaunchMetric) {
//        CrashlyticsLogger.shared.log("Launch metrics collected")
//    }
//    
//    func processExitMetrics(_ metrics: MXAppExitMetric) {
//        let fgAbnormal = metrics.foregroundExitData.cumulativeAbnormalExitCount
//        let bgAbnormal = metrics.backgroundExitData.cumulativeAbnormalExitCount
//        
//        CrashlyticsLogger.shared.logMetrics(category: "Exit", metrics: [
//            "fg_normal": metrics.foregroundExitData.cumulativeNormalAppExitCount,
//            "bg_normal": metrics.backgroundExitData.cumulativeNormalAppExitCount,
//            "fg_abnormal": fgAbnormal,
//            "bg_abnormal": bgAbnormal
//        ])
//        
//        if fgAbnormal > 0 {
//            CrashlyticsLogger.shared.recordError(
//                domain: "com.college.diagnostics",
//                code: 1006,
//                message: "Abnormal foreground exits detected",
//                userInfo: ["count": fgAbnormal]
//            )
//        }
//        
//        if bgAbnormal > 0 {
//            CrashlyticsLogger.shared.recordError(
//                domain: "com.college.diagnostics",
//                code: 1007,
//                message: "Abnormal background exits detected",
//                userInfo: ["count": bgAbnormal]
//            )
//        }
//    }
//    
//    func processResponsivenessMetrics(_ metrics: MXAppResponsivenessMetric) {
//        CrashlyticsLogger.shared.log("Responsiveness metrics collected")
//    }
//}
//
//// MARK: - Diagnostic Processing
//
//private extension MetricsManager {
//    
//    func processDiagnosticPayload(_ payload: MXDiagnosticPayload) {
//        if let crashes = payload.crashDiagnostics {
//            for crash in crashes {
//                processCrashDiagnostic(crash)
//            }
//        }
//        
//        if let hangs = payload.hangDiagnostics {
//            for hang in hangs {
//                processHangDiagnostic(hang)
//            }
//        }
//        
//        if let diskExceptions = payload.diskWriteExceptionDiagnostics {
//            for exception in diskExceptions {
//                processDiskWriteException(exception)
//            }
//        }
//        
//        if let cpuExceptions = payload.cpuExceptionDiagnostics {
//            for exception in cpuExceptions {
//                processCPUException(exception)
//            }
//        }
//    }
//    
//    func processCrashDiagnostic(_ diagnostic: MXCrashDiagnostic) {
//        var diagnosticInfo: [String: Any] = [
//            "signal": String(describing: diagnostic.signal)
//        ]
//        
//        if let terminationReason = diagnostic.terminationReason {
//            diagnosticInfo["termination_reason"] = terminationReason
//        }
//        
//        if let virtualMemoryInfo = diagnostic.virtualMemoryRegionInfo {
//            diagnosticInfo["virtual_memory"] = virtualMemoryInfo
//        }
//        
//        diagnosticInfo["has_callstack"] = true
//        
//        CrashlyticsLogger.shared.logDiagnostic(type: "Crash", details: diagnosticInfo)
//    }
//    
//    func processHangDiagnostic(_ diagnostic: MXHangDiagnostic) {
//        let duration = diagnostic.hangDuration.value
//        
//        var diagnosticInfo: [String: Any] = [
//            "duration_ms": duration
//        ]
//        
//        diagnosticInfo["has_callstack"] = true
//        
//        CrashlyticsLogger.shared.logDiagnostic(type: "Hang", details: diagnosticInfo)
//    }
//    
//    func processDiskWriteException(_ diagnostic: MXDiskWriteExceptionDiagnostic) {
//        let writes = diagnostic.totalWritesCaused.value
//        
//        var diagnosticInfo: [String: Any] = [
//            "total_writes_mb": writes
//        ]
//        
//        diagnosticInfo["has_callstack"] = true
//        
//        CrashlyticsLogger.shared.logDiagnostic(type: "Disk Write Exception", details: diagnosticInfo)
//    }
//    
//    func processCPUException(_ diagnostic: MXCPUExceptionDiagnostic) {
//        let cpuTime = diagnostic.totalCPUTime.value
//        
//        var diagnosticInfo: [String: Any] = [
//            "total_cpu_time_seconds": cpuTime
//        ]
//        
//        diagnosticInfo["has_callstack"] = true
//        
//        CrashlyticsLogger.shared.logDiagnostic(type: "CPU Exception", details: diagnosticInfo)
//    }
//}
