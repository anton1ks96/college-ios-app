//
//  ScheduleScreen.swift
//  college-ios-app
//

import SwiftUI

struct ScheduleScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
        }
        .navigationTitle("Расписание")
    }
}

#Preview {
    NavigationStack { ScheduleScreen() }
}
