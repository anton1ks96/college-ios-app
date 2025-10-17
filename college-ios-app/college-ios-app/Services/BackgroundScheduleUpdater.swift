//
//  BackgroundScheduleUpdater.swift
//  college-ios-app
//
//  Created by pc on 03.10.2025.
//

import Foundation
import BackgroundTasks
import WidgetKit

final class BackgroundScheduleUpdater {
    
    // MARK: - Singleton
    static let shared = BackgroundScheduleUpdater()
    
    // MARK: - Constants
    private let taskIdentifier = "com.college.scheduleRefresh"
    
    // MARK: - Private Init
    private init() {}
    
    // MARK: - Registration
    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: taskIdentifier,
            using: nil
        ) { [weak self] task in
            guard let self = self else { return }
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }
    
    // MARK: - Scheduling
    func scheduleAppRefresh() {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: taskIdentifier)
        
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        
        let calendar = Calendar.current
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()),
           let midnight = calendar.date(bySettingHour: 0, minute: 1, second: 0, of: tomorrow) {
            request.earliestBeginDate = midnight
        }
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("[BGTask] Submit failed:", error)
        }
    }
    
    // MARK: - Task Handling
    private func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()
        
        var worker: Task<Bool, Never>?
        task.expirationHandler = {
            worker?.cancel()
        }
        
        worker = Task {
            let success = await performScheduleUpdate()
            WidgetCenter.shared.reloadAllTimelines()
            task.setTaskCompleted(success: success)
            print("[BGTask] Completed:", success)
            return success
        }
    }
    
    // MARK: - Update Logic
    private func performScheduleUpdate() async -> Bool {
        let settingsRepo = UserSettingsRepository()
        guard settingsRepo.hasStoredSettings() else { return true }
        
        let client = AFHTTPClient(baseURL: AppEnvironment.baseURL)
        let api = ScheduleAPI(client: client)
        let repository = ScheduleRepository(api: api)
        
        let group = settingsRepo.selectedGroup
        let subgroup = settingsRepo.selectedSubgroup
        let englishGroup = settingsRepo.selectedEnglishGroup
        
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        guard let end = calendar.date(byAdding: .day, value: 2, to: start) else { return false }
        
        do {
            let events = try await repository.getSchedule(
                group: group,
                subgroup: subgroup,
                englishGroup: englishGroup,
                start: start,
                end: end
            )
            let today = DateFormatters.request.string(from: Date())
            let todayEvents = events.filter { $0.day == today }
            
            WidgetScheduleBridge.shared.saveSchedule(todayEvents)
            WidgetScheduleBridge.shared.setNextScheduledUpdate(Date())
            
            return true
        } catch {
            print("[BGTask] Error:", error)
            return false
        }
    }
}
