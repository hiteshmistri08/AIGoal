//
//  GoalPlanDTO.swift
//  AIGoal
//
//  Created by Hitesh Chotaliya on 17/10/26.
//

import Foundation

///
/// LLM must return. The app turns it into real SwiftData objects rather than saving raw AI text
///
struct GoalPlanDTO: Codable {
    let title: String
    let summary: String
    let category: String
    let tasks: [GoalTaskDTO]
}

struct GoalTaskDTO: Codable {
    let title: String
    let milestone: String
}
