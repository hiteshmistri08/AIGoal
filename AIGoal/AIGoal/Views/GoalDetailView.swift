//
//  GoalDetailView.swift
//  AIGoal
//
//  Created by Hitesh Chotaliya on 17/10/26.
//


import SwiftUI
import SwiftData

struct GoalDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var goal: Goal
    @State private var showDeleteConfirmation = false

    private var milestoneGroups: [(key: String, value: [GoalTask])] {
        Dictionary(grouping: goal.tasks, by: \.milestone)
            .sorted { $0.key.localizedStandardCompare($1.key) == .orderedAscending }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 23) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(goal.category.uppercased())
                        .font(.caption.bold())
                        .tracking(1.4)
                        .foregroundStyle(Color.goalPurple)

                    Text(goal.title)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(Color.goalInk)

                    Text(goal.summary)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 18) {
                    ProgressRing(
                        progress: goal.progress,
                        size: 92,
                        lineWidth: 8
                    )

                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(goal.progressPercent)% complete")
                            .font(.title3.bold())

                        Text(
                            "\(goal.completedTasks) of \(goal.tasks.count) actions done"
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                        Label(
                            "Due \(goal.deadline.formatted(date: .abbreviated, time: .omitted))",
                            systemImage: "calendar"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 0)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 22))

                if goal.isCompleted {
                    Label("Goal completed — well done!", systemImage: "checkmark.seal.fill")
                        .font(.headline)
                        .foregroundStyle(.green)
                }

                VStack(alignment: .leading, spacing: 16) {
                    Text("Your action plan")
                        .font(.title2.bold())

                    ForEach(Array(milestoneGroups.enumerated()), id: \.offset) {
                        _, group in

                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(group.key)
                                    .font(.headline)

                                Spacer()

                                Text(
                                    "\(group.value.filter(\.isCompleted).count)/\(group.value.count)"
                                )
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.goalPurple)
                            }

                            ForEach(group.value) { task in
                                TaskRow(task: task)
                            }
                        }
                        .padding(17)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
            }
            .padding(22)
        }
        .background(Color.goalBackground.ignoresSafeArea())
        .navigationTitle("Goal details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .confirmationDialog(
            "Delete this goal?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete goal", role: .destructive) {
                modelContext.delete(goal)
                dismiss()
            }
        } message: {
            Text("This will also delete its saved tasks.")
        }
    }
}

private struct TaskRow: View {
    @Bindable var task: GoalTask

    var body: some View {
        Toggle(isOn: $task.isCompleted) {
            Text(task.title)
                .font(.subheadline)
                .foregroundStyle(
                    task.isCompleted ? .secondary : Color.goalInk
                )
                .strikethrough(task.isCompleted)
        }
        .tint(Color.goalPurple)
        .padding(.vertical, 3)
    }
}
