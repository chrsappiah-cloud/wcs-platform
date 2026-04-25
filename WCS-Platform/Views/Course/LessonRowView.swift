//
//  LessonRowView.swift
//  WCS-Platform
//

import SwiftUI

struct LessonRowView: View {
    let lesson: Lesson

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.sm, style: .continuous)
                    .fill(DesignTokens.brandMuted)
                    .frame(width: 36, height: 36)
                Image(systemName: iconName)
                    .font(.body.weight(.medium))
                    .foregroundStyle(lesson.isUnlocked ? DesignTokens.brand : .secondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(lesson.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(lesson.isAvailable ? .primary : .secondary)
                    if !lesson.isUnlocked {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                if let subtitle = lesson.subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(metaLine)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer(minLength: 0)

            if lesson.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .symbolRenderingMode(.hierarchical)
            } else {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.quaternary)
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .opacity(lesson.isAvailable ? 1 : 0.45)
    }

    private var iconName: String {
        switch lesson.type {
        case .video: return "play.rectangle.fill"
        case .reading: return "doc.text.fill"
        case .quiz: return "checklist"
        case .assignment: return "paperplane.fill"
        }
    }

    private var metaLine: String {
        switch lesson.type {
        case .video:
            return "Video · \(formatDuration(lesson.durationSeconds))"
        case .reading:
            return "Reading"
        case .quiz:
            return "Graded quiz"
        case .assignment:
            return "Assignment"
        }
    }

    private func formatDuration(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

#Preview {
    List {
        if let lesson = MockCourseCatalog.courses.first?.modules.first?.lessons.first {
            LessonRowView(lesson: lesson)
        }
    }
}
