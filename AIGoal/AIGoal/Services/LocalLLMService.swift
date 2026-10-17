//
//  LocalLLMService.swift
//  AIGoal
//
//  Created by Hitesh Chotaliya on 17/10/26.
//

import Foundation
import Combine
import SwiftLlama


///
/// This uses the SwiftLlama package's streaming completion API. The generation is asynchronous, and the UI can show progress while tokens are produced. The model must already exist locally before inference starts
///

enum GoalGenerationError: LocalizedError {
    case modelMissing
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .modelMissing:
            return "Import a GGUF model in Settings before generating goals."
        case .invalidResponse:
            return "The model returned an invalid plan. Please try again."
        }
    }
}

@MainActor
final class LocalLLMService: ObservableObject {
    @Published private(set) var isGenerating = false

    func generatePlan(
        ambition: String,
        timeframe: String,
        difficulty: String
    ) async throws -> GoalPlanDTO {
        guard let modelURL = ModelStore.currentModelURL else {
            throw GoalGenerationError.modelMissing
        }

        isGenerating = true
        defer { isGenerating = false }

        let llama = LlamaService(
            modelUrl: modelURL,
            config: .init(
                batchSize: 256,
                maxTokenCount: 4096,
                useGPU: true
            )
        )

        let systemPrompt = """
        You are AIGoal, a practical goal planning assistant.

        Turn the user's ambition into a realistic, achievable plan.
        Return ONLY valid JSON. Do not use Markdown or code fences.

        Use exactly this schema:
        {
          "title": "Short goal title",
          "summary": "A concise, actionable goal summary",
          "category": "Personal, Career, Health, Learning, or Finance",
          "tasks": [
            {
              "title": "One concrete action",
              "milestone": "Milestone 1"
            }
          ]
        }

        Requirements:
        - Return 8 to 12 actionable tasks.
        - Group tasks into 3 or 4 milestones.
        - Make tasks specific and easy to verify.
        - Respect the requested timeframe and difficulty.
        - Use concise language.
        - Do not include extra JSON fields.
        """

        let userPrompt = """
        Ambition: \(ambition)
        Timeframe: \(timeframe)
        Difficulty: \(difficulty)

        Create my personalized goal plan.
        """

        let messages = [
            LlamaChatMessage(
                role: .system,
                content: systemPrompt
            ),
            LlamaChatMessage(
                role: .user,
                content: userPrompt
            )
        ]

        let stream = try await llama.streamCompletion(
            of: messages,
            samplingConfig: .init(
                temperature: 0.4,
                seed: UInt32.random(in: 0...UInt32.max)
            )
        )

        var output = ""

        for try await token in stream {
            output += token
        }

        guard let firstBrace = output.firstIndex(of: "{"),
              let lastBrace = output.lastIndex(of: "}"),
              firstBrace <= lastBrace else {
            throw GoalGenerationError.invalidResponse
        }

        let json = String(output[firstBrace...lastBrace])

        guard let data = json.data(using: .utf8) else {
            throw GoalGenerationError.invalidResponse
        }

        let plan: GoalPlanDTO

        do {
            plan = try JSONDecoder().decode(
                GoalPlanDTO.self,
                from: data
            )
        } catch {
            throw GoalGenerationError.invalidResponse
        }

        guard !plan.title.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty,
        !plan.tasks.isEmpty,
        plan.tasks.count <= 30,
        plan.tasks.allSatisfy({
            !$0.title.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty
        }) else {
            throw GoalGenerationError.invalidResponse
        }

        return plan
    }
}
