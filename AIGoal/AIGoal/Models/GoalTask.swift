//
//  GoalTask.swift
//  AIGoal
//
//  Created by Hitesh Chotaliya on 17/10/26.
//

import Foundation
import SwiftData

@Model
final class GoalTask {
    @Attribute(.unique) var id: UUID
    var title: String
    var milestone: String
    var isCompleted: Bool
    var createdAt: Date

    var goal: Goal?

    init(title: String, milestone: String) {
        self.id = UUID()
        self.title = title
        self.milestone = milestone
        self.isCompleted = false
        self.createdAt = .now
    }
}
