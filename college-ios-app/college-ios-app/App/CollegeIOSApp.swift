//
//  CollegeIOSApp.swift
//  college-ios-app
//
//  Created by pc on 21.09.2025.
//

import SwiftUI

@main
struct CollegeIOSApp: App {
    @StateObject private var viewModel: ScheduleViewModel = {
        let client = AFHTTPClient(baseURL: AppEnvironment.baseURL)
        let api = ScheduleAPI(client: client)
        let repo = ScheduleRepository(api: api)
        return ScheduleViewModel(repository: repo)
    }()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ScheduleView(viewModel: viewModel)
            }
        }
    }
}
