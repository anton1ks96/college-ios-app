//
//  LargeScheduleWidgetView.swift
//  ScheduleWidget
//
//  Created by pc on 03.10.2025.
//

import SwiftUI

struct LargeScheduleWidgetView: View {
    let events: [ScheduleEvent]
    
    var body: some View {
        VStack {
            Text("Large Widget")
                .font(.title2)
            Text("Coming soon...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
