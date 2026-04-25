//
//  APIError.swift
//  WCS-Platform
//

import Foundation

struct WCSAPIError: Error, CustomStringConvertible, LocalizedError {
    let underlying: Error
    let statusCode: Int?
    let body: Data?

    var description: String {
        let bytes = body.map { "\($0.count) bytes" } ?? "nil"
        return "WCSAPIError(status: \(statusCode.map(String.init) ?? "nil"), underlying: \(underlying.localizedDescription), body: \(bytes))"
    }

    var errorDescription: String? { description }
}

struct HTTPStatusError: Error, CustomStringConvertible {
    let status: Int
    var description: String { "HTTPStatusError(\(status))" }
}
