//
//  CollegeIOSApp.swift
//  college-ios-app
//
//  Created by pc on 21.09.2025.
//

import SwiftUI

@main
struct CollegeIOSApp: App {

    var body: some Scene {
        WindowGroup {
            let client: HTTPClientProtocol = {
                return AFHTTPClient(baseURL: AppEnvironment.baseURL)
            }()

            let api = ScheduleAPI(client: client)
            let repo = ScheduleRepository(api: api)
            let vm = ScheduleViewModel(repository: repo)

            NavigationStack { }
        }
    }
}
