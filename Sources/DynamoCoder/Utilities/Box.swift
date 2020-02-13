//
//  Box.swift
//  
//
//  Created by Michael Housh on 1/27/20.
//

import Foundation
import DynamoDB

final class UnkeyedAttributeContainer {

    internal var storage: [EncodedAttributeType] = []

    init() { }

    func push(_ attribute: EncodedAttributeType) {
        storage.append(attribute)
    }

    var output: [EncodedAttributeType] {
        self.storage
    }

    var count: Int {
        storage.count
    }
}

final class KeyedAttributeContainer {

    private var storage: [String: EncodedAttributeContainer] = [:]

    init() { }

    subscript(_ key: String) -> EncodedAttributeContainer? {
        get { storage[key] }
        set { storage[key] = newValue }
    }

    var output: [String: EncodedAttributeContainer] {
        self.storage
    }
}

enum EncodedAttributeContainer {
    case single(EncodedAttributeType)
    case unkeyed(UnkeyedAttributeContainer)
    case keyed(KeyedAttributeContainer)

    func unwrap() throws -> EncodedAttributeType {
        switch self {
        case let .single(attribute): return attribute
        case let .keyed(dictionary): return try .map(dictionary.output.mapValues({ try $0.unwrap() }))
        case let .unkeyed(array): return .list(array.output)
        }
    }
}

enum DecodingAttributeContainer {
    case single(DynamoDB.AttributeValue)
    case unkeyed([DynamoAttributeDict])
    case keyed(DynamoAttributeDict)
    case list([DynamoDB.AttributeValue])

    var isSingleAttribute: Bool {
        switch self {
        case .single: return true
        default: return false
        }
    }

    var attribute: DynamoDB.AttributeValue {
        precondition(self.isSingleAttribute)
        switch self {
        case let .single(encoded): return encoded
        default:
            fatalError()
        }
    }
}

enum EncodedAttributeType {
    case string(String)
    case number(String)
    case stringSet([String])
    case numberSet([String])
    case bool(Bool)
    case null
    case map([String: EncodedAttributeType])
    case list([EncodedAttributeType])

    var attribute: DynamoDB.AttributeValue {
        switch self {
        case let .string(string): return .init(s: string)
        case let .number(number): return .init(n: number)
        case let .stringSet(stringSet): return .init(ss: stringSet)
        case let .numberSet(numberSet): return .init(ns: numberSet)
        case let .bool(bool): return .init(bool: bool)
        case .null: return .init(null: true)
        case let .map(map): return .init(m: map.mapValues { $0.attribute })
        case let .list(list):
            if self.isStringSet(list) {
                return .init(ss: list.map { $0.attribute.s! })
            }
            if self.isNumberSet(list) {
                return .init(ns: list.map { $0.attribute.n! })
            }
            return .init(l: list.map { $0.attribute })
        }
    }

    private var isString: Bool {
        switch self {
        case .string: return true
        default: return false
        }
    }

    private var isNumber: Bool {
        switch self {
        case .number: return true
        default: return false
        }
    }

    private func isStringSet(_ array: [EncodedAttributeType]) -> Bool {
        for item in array {
            if !item.isString {
                return false
            }
        }
        return true
    }

    private func isNumberSet(_ array: [EncodedAttributeType]) -> Bool {
        for item in array {
            if !item.isNumber {
                return false
            }
        }
        return true
    }
}

enum DynamoEncodingError: Error {

    case invalidContainer(message: String?, reality: Any?)
}
