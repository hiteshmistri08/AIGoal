//
//  DashboardView.swift
//  AIGoal
//
//  Created by Hitesh Chotaliya on 17/10/26.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \Goal.createdAt, order: .reverse)
    private var goals: [Goal]

    @State private var showCreate = false
    @State private var showSettings = false

    private var activeGoals: [Goal] {
        goals.filter { !$0.isCompleted }
    }

    private var overallProgress: Double {
        let tasks = goals.flatMap(\.tasks)
        guard !tasks.isEmpty else { return 0 }

        return Double(tasks.filter(\.isCompleted).count)
            / Double(tasks.count)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 27) {
                    header

                    overviewCard

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your goals")
                                .font(.title2.bold())

                            Text("Small steps. Real progress.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text("\(activeGoals.count) active")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.goalPurple)
                    }

                    if goals.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: 13) {
                            ForEach(goals) { goal in
                                NavigationLink {
                                    GoalDetailView(goal: goal)
                                } label: {
                                    GoalCard(goal: goal)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(22)
            }
            .background(Color.goalBackground.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showCreate) {
                CreateGoalView()
            }
            .sheet(isPresented: $showSettings) {
                ModelSettingsView()
            }
        }
        .tint(Color.goalPurple)
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 5) {
                Text("GOALCRAFT")
                    .font(.caption.bold())
                    .tracking(2.2)
                    .foregroundStyle(Color.goalPurple)

                Text("Grow with purpose.")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.goalInk)
            }

            Spacer()

            Button {
                showSettings = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.goalInk)
                    .frame(width: 46, height: 46)
                    .background(.white)
                    .clipShape(Circle())
            }
            .accessibilityLabel("Model settings")
        }
        .padding(.top, 12)
    }

    private var overviewCard: some View {
        HStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 10) {
                Text("YOUR JOURNEY")
                    .font(.caption.bold())
                    .tracking(1.2)
                    .foregroundStyle(.white.opacity(0.75))

                Text("Progress, not perfection.")
                    .font(.title3.bold())
                    .foregroundStyle(.white)

                Text(
                    "\(goals.filter(\.isCompleted).count) goals completed"
                )
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))

                Button {
                    showCreate = true
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: "plus")
                        Text("New goal")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.goalInk)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .background(.white)
                    .clipShape(Capsule())
                }
                .padding(.top, 4)
            }

            Spacer(minLength: 0)

            ProgressRing(
                progress: overallProgress,
                size: 82,
                lineWidth: 7
            )
            .colorMultiply(.white)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            LinearGradient(
                colors: [
                    Color.goalPurple,
                    Color(red: 0.53, green: 0.43, blue: 0.82)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 27))
    }

    private var emptyState: some View {
        VStack(spacing: 15) {
            Image(systemName: "sparkles")
                .font(.system(size: 35))
                .foregroundStyle(Color.goalPurple)

            Text("Your next chapter starts here")
                .font(.headline)

            Text("Create a goal and let your on-device AI build a plan.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Create your first goal") {
                showCreate = true
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.goalPurple)
        }
        .frame(maxWidth: .infinity)
        .padding(30)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}
