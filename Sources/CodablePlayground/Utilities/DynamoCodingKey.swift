//
//  DynamoCodingKey.swift
//  
//
//  Created by Michael Housh on 1/27/20.
//

import Foundation

/// Common `CodingKey` used for internal operations.
enum DynamoCodingKey: CodingKey {

    case string(String)
    case int(Int)

    var stringValue: String {
        switch self {
        case let .string(string): return string
        case let .int(int): return int.description
        }
    }

    init(int: Int) {
        self = .int(int)
    }

    init(string: String) {
        self = .string(string)
    }

    init?(stringValue: String) {
        self = .string(stringValue)
    }

    var intValue: Int? {
        switch self {
        case let .int(int): return int
        case .string(_): return nil
        }
    }

    init?(intValue: Int) {
        self = .int(intValue)
    }

    static let `super` = DynamoCodingKey(string: "super")
}
