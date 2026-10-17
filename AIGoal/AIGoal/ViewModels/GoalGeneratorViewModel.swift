//
//  GoalGeneratorViewModel.swift
//  AIGoal
//
//  Created by Hitesh Chotaliya on 17/10/26.
//

import Foundation
import Combine

@MainActor
final class GoalGeneratorViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var generatedPlan: GoalPlanDTO?
    @Published var errorMessage: String?

    private let service = LocalLLMService()

    func generate(
        ambition: String,
        timeframe: String,
        difficulty: String
    ) async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        generatedPlan = nil

        defer { isLoading = false }

        do {
            generatedPlan = try await service.generatePlan(
                ambition: ambition,
                timeframe: timeframe,
                difficulty: difficulty
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
