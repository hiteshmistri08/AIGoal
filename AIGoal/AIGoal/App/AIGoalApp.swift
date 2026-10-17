//
//  AIGoalApp.swift
//  AIGoal
//
//  Created by Hitesh Chotaliya on 17/10/26.
//

import SwiftUI
import SwiftData

@main
struct AIGoalApp: App {
    var body: some Scene {
        WindowGroup {
            DashboardView()
        }
        .modelContainer(
            for: [
                Goal.self,
                GoalTask.self
            ]
        )
    }
}
