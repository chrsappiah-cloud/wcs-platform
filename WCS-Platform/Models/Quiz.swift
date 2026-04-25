//
//  Quiz.swift
//  WCS-Platform
//

import Foundation

struct Quiz: Codable, Identifiable, Hashable {
    let id: UUID
    let title: String
    let description: String?
    let maxAttempts: Int
    let timeLimitSeconds: Int?
    let passingScore: Int
    let questions: [Question]
}

struct Question: Codable, Identifiable, Hashable {
    let id: UUID
    let text: String
    let type: QuestionType
    let options: [QuestionOption]
    let correctOptionIndex: Int
    let explanation: String?
}

enum QuestionType: String, Codable, Hashable {
    case multipleChoice
    case trueFalse
}

extension QuestionType {
    var isMultipleChoice: Bool { self == .multipleChoice }
}

struct QuestionOption: Codable, Identifiable, Hashable {
    let id: UUID
    let text: String
}

struct QuizSubmissionRequest: Codable {
    let quizId: UUID
    let answers: [UUID: Int]

    enum CodingKeys: String, CodingKey {
        case quizId
        case answers
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(quizId, forKey: .quizId)
        var answersObject: [String: Int] = [:]
        for (key, value) in answers {
            answersObject[key.uuidString] = value
        }
        try container.encode(answersObject, forKey: .answers)
    }
}

struct QuizSubmissionResult: Codable, Hashable {
    let score: Int
    let total: Int
    let percentage: Double
    let oxfordGrade: OxfordGradeBand
    let isPassed: Bool
    let passedAt: Date?
    let feedback: String?
    let certification: CourseCertificate?
}

enum OxfordGradeBand: String, Codable, Hashable {
    case firstClassHonours = "First Class (70%+)"
    case upperSecond = "Upper Second 2:1 (60-69%)"
    case lowerSecond = "Lower Second 2:2 (50-59%)"
    case thirdClass = "Third Class (40-49%)"
    case fail = "Fail (<40%)"
}

struct CourseCertificate: Codable, Hashable {
    let id: UUID
    let learnerName: String
    let courseTitle: String
    let grade: OxfordGradeBand
    let awardedAt: Date
    let verificationCode: String
}

enum OxfordGrading {
    static func grade(for percentage: Double) -> OxfordGradeBand {
        switch percentage {
        case 70...:
            return .firstClassHonours
        case 60..<70:
            return .upperSecond
        case 50..<60:
            return .lowerSecond
        case 40..<50:
            return .thirdClass
        default:
            return .fail
        }
    }
}
