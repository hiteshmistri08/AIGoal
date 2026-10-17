//
//  Components.swift
//  AIGoal
//
//  Created by Hitesh Chotaliya on 17/10/26.
//

import SwiftUI

extension Color {
    static let goalBackground = Color(
        red: 0.965, green: 0.953, blue: 0.937
    )

    static let goalInk = Color(
        red: 0.16, green: 0.17, blue: 0.25
    )

    static let goalPurple = Color(
        red: 0.39, green: 0.32, blue: 0.78
    )

    static let goalMint = Color(
        red: 0.77, green: 0.88, blue: 0.80
    )
}

struct ProgressRing: View {
    let progress: Double
    var size: CGFloat = 58
    var lineWidth: CGFloat = 6

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.goalPurple.opacity(0.12), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(
                    Color.goalPurple,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))

            Text("\(Int((progress * 100).rounded()))%")
                .font(.system(size: size * 0.22, weight: .bold))
                .foregroundStyle(Color.goalInk)
                .minimumScaleFactor(0.7)
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "Goal progress \(Int((progress * 100).rounded())) percent"
        )
    }
}

struct GoalCard: View {
    let goal: Goal

    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.goalPurple.opacity(0.09))
                    .frame(width: 54, height: 54)

                Image(systemName: iconName)
                    .font(.system(size: 21, weight: .medium))
                    .foregroundStyle(Color.goalPurple)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(goal.category.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.1)
                    .foregroundStyle(.secondary)

                Text(goal.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.goalInk)
                    .lineLimit(2)

                Text(
                    "\(goal.completedTasks) of \(goal.tasks.count) tasks completed"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer(minLength: 4)

            ProgressRing(progress: goal.progress, size: 55, lineWidth: 5)
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.black.opacity(0.025), lineWidth: 1)
        }
    }

    private var iconName: String {
        switch goal.category.lowercased() {
        case "health", "fitness": return "figure.run"
        case "career": return "briefcase"
        case "learning", "education": return "book.closed"
        case "finance": return "chart.line.uptrend.xyaxis"
        default: return "sparkles"
        }
    }
}
