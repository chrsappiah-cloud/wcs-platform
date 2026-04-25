//
//  MockCourseCatalog.swift
//  WCS-Platform
//

import Foundation

enum MockCourseCatalog {
    nonisolated static let sampleQuiz = Quiz(
        id: UUID(uuidString: "00000001-0000-0000-0000-000000000001")!,
        title: "Foundations check-in",
        description: "Quick knowledge check.",
        maxAttempts: 3,
        timeLimitSeconds: 300,
        passingScore: 1,
        questions: [
            Question(
                id: UUID(uuidString: "00000002-0000-0000-0000-000000000001")!,
                text: "What is the primary goal of spaced repetition?",
                type: .multipleChoice,
                options: [
                    QuestionOption(id: UUID(), text: "Cramming the night before"),
                    QuestionOption(id: UUID(), text: "Reviewing on expanding intervals"),
                    QuestionOption(id: UUID(), text: "Skipping practice tests"),
                ],
                correctOptionIndex: 1,
                explanation: "Spacing reviews strengthens long-term retention."
            ),
            Question(
                id: UUID(uuidString: "00000002-0000-0000-0000-000000000002")!,
                text: "Active recall is more effective than passive re-reading.",
                type: .trueFalse,
                options: [
                    QuestionOption(id: UUID(), text: "True"),
                    QuestionOption(id: UUID(), text: "False"),
                ],
                correctOptionIndex: 0,
                explanation: nil
            ),
        ]
    )

    nonisolated static let sampleAssignment = Assignment(
        id: UUID(uuidString: "00000003-0000-0000-0000-000000000001")!,
        title: "Reflection: your learning plan",
        description: "Write 200–400 words on how you will apply this week’s concepts.",
        dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
        maxAttempts: 1,
        isSubmitted: false,
        submission: nil
    )

    nonisolated static let courses: [Course] = {
        let courseIdA = UUID(uuidString: "10000000-0000-0000-0000-000000000001")!
        let moduleIdA = UUID(uuidString: "20000000-0000-0000-0000-000000000001")!
        let lessonVideo = UUID(uuidString: "30000000-0000-0000-0000-000000000001")!
        let lessonReading = UUID(uuidString: "30000000-0000-0000-0000-000000000002")!
        let lessonQuiz = UUID(uuidString: "30000000-0000-0000-0000-000000000003")!
        let lessonAssignment = UUID(uuidString: "30000000-0000-0000-0000-000000000004")!

        let moduleA = Module(
            id: moduleIdA,
            title: "Week 1 — Foundations",
            description: "Orientation, study design, and practice.",
            order: 1,
            isAvailable: true,
            isUnlocked: true,
            lessons: [
                Lesson(
                    id: lessonVideo,
                    title: "How high performers study",
                    subtitle: "Video · 10 min",
                    type: .video,
                    videoURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
                    durationSeconds: 596,
                    isCompleted: false,
                    isAvailable: true,
                    isUnlocked: true,
                    reading: nil,
                    quiz: nil,
                    assignment: nil
                ),
                Lesson(
                    id: lessonReading,
                    title: "Course handbook",
                    subtitle: "Reading · 5 min",
                    type: .reading,
                    videoURL: nil,
                    durationSeconds: 12,
                    isCompleted: false,
                    isAvailable: true,
                    isUnlocked: true,
                    reading: ReadingContent(markdown: "## Welcome\n\nTrack progress from the **Programs** tab. Complete each unit in order—quizzes grade instantly in mock mode.\n\n### What you’ll build\n- Focus habits\n- Retrieval practice\n- Self-paced mastery"),
                    quiz: nil,
                    assignment: nil
                ),
                Lesson(
                    id: lessonQuiz,
                    title: "Week 1 quiz",
                    subtitle: "Graded assessment",
                    type: .quiz,
                    videoURL: nil,
                    durationSeconds: 10,
                    isCompleted: false,
                    isAvailable: true,
                    isUnlocked: true,
                    reading: nil,
                    quiz: sampleQuiz,
                    assignment: nil
                ),
                Lesson(
                    id: lessonAssignment,
                    title: "Apply it",
                    subtitle: "Instructor graded",
                    type: .assignment,
                    videoURL: nil,
                    durationSeconds: 45,
                    isCompleted: false,
                    isAvailable: true,
                    isUnlocked: true,
                    reading: nil,
                    quiz: nil,
                    assignment: sampleAssignment
                ),
            ]
        )

        let courseIdB = UUID(uuidString: "10000000-0000-0000-0000-000000000002")!
        let moduleIdB = UUID(uuidString: "20000000-0000-0000-0000-000000000002")!
        let lessonB1 = UUID(uuidString: "30000000-0000-0000-0000-000000000010")!
        let lessonB2 = UUID(uuidString: "30000000-0000-0000-0000-000000000011")!

        let moduleB = Module(
            id: moduleIdB,
            title: "Module 1 — Decisions under uncertainty",
            description: "Framing problems and communicating insights.",
            order: 1,
            isAvailable: true,
            isUnlocked: true,
            lessons: [
                Lesson(
                    id: lessonB1,
                    title: "From data to decision",
                    subtitle: "Video · 8 min",
                    type: .video,
                    videoURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
                    durationSeconds: 15,
                    isCompleted: false,
                    isAvailable: true,
                    isUnlocked: true,
                    reading: nil,
                    quiz: nil,
                    assignment: nil
                ),
                Lesson(
                    id: lessonB2,
                    title: "Knowledge check",
                    subtitle: "Practice quiz",
                    type: .quiz,
                    videoURL: nil,
                    durationSeconds: 5,
                    isCompleted: false,
                    isAvailable: true,
                    isUnlocked: true,
                    reading: nil,
                    quiz: Quiz(
                        id: UUID(uuidString: "00000001-0000-0000-0000-000000000099")!,
                        title: "Quick check",
                        description: nil,
                        maxAttempts: 5,
                        timeLimitSeconds: 120,
                        passingScore: 1,
                        questions: [
                            Question(
                                id: UUID(),
                                text: "A confidence interval communicates uncertainty about a parameter estimate.",
                                type: .trueFalse,
                                options: [
                                    QuestionOption(id: UUID(), text: "True"),
                                    QuestionOption(id: UUID(), text: "False"),
                                ],
                                correctOptionIndex: 0,
                                explanation: nil
                            ),
                        ]
                    ),
                    assignment: nil
                ),
            ]
        )

        return [
            Course(
                id: courseIdA,
                title: "Learning How to Learn",
                subtitle: "Evidence-based study skills",
                description: "Build durable memory, manage procrastination, and design practice like top open-course programs: structured modules, clear outcomes, graded checks, and authentic assignments.",
                thumbnailURL: "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1200&q=80",
                coverURL: "https://images.unsplash.com/photo-1523240795612-9a054b0db644?w=1600&q=80",
                durationSeconds: 3600,
                price: 49.99,
                isEnrolled: false,
                isOwned: false,
                isUnlockedBySubscription: true,
                rating: 4.8,
                reviewCount: 1284,
                organizationName: "World Class Scholars",
                level: "Introductory",
                effortDescription: "2–4 hrs/week",
                spokenLanguages: ["English"],
                modules: [moduleA]
            ),
            Course(
                id: courseIdB,
                title: "Decision Science Essentials",
                subtitle: "Think clearly with data",
                description: "A compact program on framing decisions, interpreting evidence, and communicating tradeoffs—mirroring the syllabus + assessment cadence of flagship online programs.",
                thumbnailURL: "https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=1200&q=80",
                coverURL: "https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=1600&q=80",
                durationSeconds: 2100,
                price: nil,
                isEnrolled: false,
                isOwned: false,
                isUnlockedBySubscription: true,
                rating: 4.6,
                reviewCount: 612,
                organizationName: "WCS Analytics Studio",
                level: "Intermediate",
                effortDescription: "3–5 hrs/week",
                spokenLanguages: ["English"],
                modules: [moduleB]
            ),
        ]
    }()

    nonisolated static func displayTitle(for courseId: UUID) -> String {
        courses.first { $0.id == courseId }?.title ?? "Continue program"
    }

    nonisolated static func thumbnailURL(for courseId: UUID) -> URL? {
        guard let raw = courses.first(where: { $0.id == courseId })?.thumbnailURL else { return nil }
        return URL(string: raw)
    }

    nonisolated static func findQuiz(id: UUID) -> Quiz? {
        for course in courses {
            for module in course.modules {
                for lesson in module.lessons {
                    if let quiz = lesson.quiz, quiz.id == id {
                        return quiz
                    }
                }
            }
        }
        return nil
    }
}
