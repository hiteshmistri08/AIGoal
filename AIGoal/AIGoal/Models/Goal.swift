//
//  Goal.swift
//  AIGoal
//
//  Created by Hitesh Chotaliya on 17/10/26.
//

import Foundation
import SwiftData

@Model
final class Goal {
    @Attribute(.unique) var id: UUID
    var title: String
    var ambition: String
    var summary: String
    var category: String
    var timeframe: String
    var difficulty: String
    var createdAt: Date
    var deadline: Date

    @Relationship(deleteRule: .cascade, inverse: \GoalTask.goal)
    var tasks: [GoalTask] = []

    init(
        title: String,
        ambition: String,
        summary: String,
        category: String,
        timeframe: String,
        difficulty: String,
        deadline: Date,
        tasks: [GoalTask] = []
    ) {
        self.id = UUID()
        self.title = title
        self.ambition = ambition
        self.summary = summary
        self.category = category
        self.timeframe = timeframe
        self.difficulty = difficulty
        self.createdAt = .now
        self.deadline = deadline
        self.tasks = tasks
    }

    var completedTasks: Int {
        tasks.filter(\.isCompleted).count
    }

    var progress: Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(completedTasks) / Double(tasks.count)
    }

    var progressPercent: Int {
        Int((progress * 100).rounded())
    }

    var isCompleted: Bool {
        !tasks.isEmpty && tasks.allSatisfy(\.isCompleted)
    }
}
