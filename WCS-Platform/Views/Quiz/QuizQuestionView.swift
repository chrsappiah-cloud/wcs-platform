//
//  QuizQuestionView.swift
//  WCS-Platform
//

import SwiftUI

struct QuizQuestionView: View {
    @ObservedObject var viewModel: QuizViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            if let question = viewModel.currentQuestion {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text("Question \(viewModel.currentIndex + 1) of \(viewModel.quiz.questions.count)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color(.tertiarySystemFill)))

                    Text(question.text)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                        let selected = viewModel.selections[question.id] == index
                        Button {
                            viewModel.selectOption(index: index)
                        } label: {
                            HStack(alignment: .center, spacing: DesignTokens.Spacing.md) {
                                Text(option.text)
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(.primary)
                                    .multilineTextAlignment(.leading)
                                Spacer(minLength: 0)
                                Group {
                                    if selected {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(DesignTokens.brandAccent)
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundStyle(Color.secondary)
                                    }
                                }
                                .font(.title3)
                                .symbolRenderingMode(.hierarchical)
                            }
                            .padding(DesignTokens.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous)
                                    .fill(selected ? DesignTokens.brandAccentSubtle : Color(.secondarySystemGroupedBackground))
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous)
                                    .strokeBorder(
                                        selected ? DesignTokens.brandAccent.opacity(0.55) : DesignTokens.subtleBorder,
                                        lineWidth: selected ? 1.5 : 1
                                    )
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                HStack(spacing: DesignTokens.Spacing.md) {
                    Button {
                        viewModel.previous()
                    } label: {
                        Text("Back")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.currentIndex == 0)

                    if viewModel.currentIndex == viewModel.quiz.questions.count - 1 {
                        Button {
                            Task { await viewModel.submit() }
                        } label: {
                            Text("Submit")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(DesignTokens.brandAccent)
                        .disabled(!canSubmit(question: question))
                    } else {
                        Button {
                            viewModel.next()
                        } label: {
                            Text("Next")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(DesignTokens.brandAccent)
                        .disabled(viewModel.selections[question.id] == nil)
                    }
                }
            } else {
                ContentUnavailableView("No questions", systemImage: "questionmark.circle", description: Text("This quiz has no items."))
            }

            if viewModel.isSubmitting {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    ProgressView()
                    Text("Submitting…")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }

            if let error = viewModel.lastError {
                Text(error.localizedDescription)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Spacer(minLength: 0)
        }
        .padding(DesignTokens.Spacing.lg)
        .background(Color(.systemGroupedBackground))
    }

    private func canSubmit(question: Question) -> Bool {
        viewModel.selections[question.id] != nil
    }
}

#Preview {
    struct Host: View {
        @StateObject private var vm = QuizViewModel(quiz: MockCourseCatalog.sampleQuiz)
        var body: some View { QuizQuestionView(viewModel: vm) }
    }
    return Host()
}
