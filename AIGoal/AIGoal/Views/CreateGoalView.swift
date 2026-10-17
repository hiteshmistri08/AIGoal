//
//  CreateGoalView.swift
//  AIGoal
//
//  Created by Hitesh Chotaliya on 17/10/26.
//

import SwiftUI
import SwiftData

struct CreateGoalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel = GoalGeneratorViewModel()

    @State private var ambition = ""
    @State private var timeframe = "30 days"
    @State private var difficulty = "Moderate"

    private let timeframes = [
        "7 days", "30 days", "90 days", "6 months"
    ]

    private let difficulties = [
        "Easy", "Moderate", "Challenging"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Dream it.")
                            .font(.system(size: 34, weight: .bold))

                        Text("We'll help you make it happen.")
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("YOUR AMBITION")
                            .font(.caption.bold())
                            .tracking(1.2)
                            .foregroundStyle(.secondary)

                        TextEditor(text: $ambition)
                            .frame(minHeight: 120)
                            .padding(10)
                            .scrollContentBackground(.hidden)
                            .background(.white.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .overlay(alignment: .topLeading) {
                                if ambition.isEmpty {
                                    Text(
                                        "e.g. Learn SwiftUI and launch my first app"
                                    )
                                    .foregroundStyle(.tertiary)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 18)
                                    .allowsHitTesting(false)
                                }
                            }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("TIMEFRAME")
                            .font(.caption.bold())
                            .tracking(1.2)
                            .foregroundStyle(.secondary)

                        Picker("Timeframe", selection: $timeframe) {
                            ForEach(timeframes, id: \.self) {
                                Text($0).tag($0)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.white.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("DIFFICULTY")
                            .font(.caption.bold())
                            .tracking(1.2)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 8) {
                            ForEach(difficulties, id: \.self) { item in
                                Button {
                                    difficulty = item
                                } label: {
                                    Text(item)
                                        .font(.subheadline.weight(.medium))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .foregroundStyle(
                                            difficulty == item
                                            ? .white : .primary
                                        )
                                        .background {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(
                                                    difficulty == item
                                                    ? Color.indigo
                                                    : Color.white.opacity(0.8)
                                                )
                                        }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Button {
                        Task {
                            await viewModel.generate(
                                ambition: ambition,
                                timeframe: timeframe,
                                difficulty: difficulty
                            )
                        }
                    } label: {
                        HStack(spacing: 10) {
                            if viewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "sparkles")
                            }

                            Text(
                                viewModel.isLoading
                                ? "Creating your plan..."
                                : "Generate my goal"
                            )
                            .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .foregroundStyle(.white)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color.indigo,
                                    Color(red: 0.48, green: 0.35, blue: 0.85)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 17))
                    }
                    .disabled(
                        ambition.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty || viewModel.isLoading
                    )

                    if let message = viewModel.errorMessage {
                        Label(message, systemImage: "exclamationmark.circle")
                            .font(.subheadline)
                            .foregroundStyle(.red)
                    }

                    if let plan = viewModel.generatedPlan {
                        planPreview(plan)
                    }
                }
                .padding(22)
            }
            .background(Color.goalBackground.ignoresSafeArea())
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func planPreview(_ plan: GoalPlanDTO) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("YOUR AI PLAN", systemImage: "sparkles")
                .font(.caption.bold())
                .tracking(1.1)
                .foregroundStyle(.indigo)

            Text(plan.title)
                .font(.title2.bold())

            Text(plan.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Label(plan.category, systemImage: "tag")
                Spacer()
                Text("\(plan.tasks.count) actions")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            ForEach(
                Array(plan.tasks.prefix(6).enumerated()),
                id: \.offset
            ) { _, task in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "circle")
                        .foregroundStyle(.indigo)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(task.title)
                            .font(.subheadline)

                        Text(task.milestone)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Button {
                save(plan)
            } label: {
                Text("Save my goal")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(.white)
                    .background(Color.indigo)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.04), radius: 15, y: 6)
    }

    private func save(_ plan: GoalPlanDTO) {
        let tasks = plan.tasks.map {
            GoalTask(title: $0.title, milestone: $0.milestone)
        }

        let days: Double
        switch timeframe {
        case "7 days": days = 7
        case "90 days": days = 90
        case "6 months": days = 180
        default: days = 30
        }

        let goal = Goal(
            title: plan.title,
            ambition: ambition,
            summary: plan.summary,
            category: plan.category,
            timeframe: timeframe,
            difficulty: difficulty,
            deadline: Calendar.current.date(
                byAdding: .day,
                value: Int(days),
                to: .now
            ) ?? .now.addingTimeInterval(days * 86400),
            tasks: tasks
        )

        modelContext.insert(goal)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            viewModel.errorMessage =
                "Couldn't save your goal. Please try again."
        }
    }
}
