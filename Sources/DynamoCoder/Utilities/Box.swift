//
//  Box.swift
//  
//
//  Created by Michael Housh on 1/27/20.
//

import Foundation
import DynamoDB

protocol Box {
    var attribute: DynamoDB.AttributeValue { get }
}

protocol SharedBoxProtocol {
    associatedtype SharedBox: Box
    func unbox() -> SharedBox
}

typealias UnkeyedBox = [Box]
typealias KeyedBox = [String: Box]

extension UnkeyedBox: Box {

    var attribute: DynamoDB.AttributeValue {
        if let stringBoxes = self as? [StringBox] {
            return .init(ss: stringBoxes.map { $0.unboxed })
        }
        if let numberBoxes = self as? [AnyNumberBox] {
            return .init(ns: numberBoxes.map { $0.description })
        }
        return .init(l: self.map { $0.attribute })
    }

    func convert() throws -> [[String: DynamoDB.AttributeValue]] {
        self.map { box in
            if let shared = box as? SharedBox<KeyedBox> {
                return shared.unbox().convert()
            }
            else if let keyed = box as? KeyedBox {
                return keyed.convert()
            }

            fatalError("Invalid item in array.")
        }
    }
}

extension KeyedBox: Box {

    var attribute: DynamoDB.AttributeValue {
        .init(m: self.mapValues { $0.attribute })
    }

    func convert() -> [String: DynamoDB.AttributeValue] {
        self.mapValues { $0.attribute }
    }
}

// Used when encoding multi-value items.
class SharedBox<Unboxed: Box>: Box {

    private(set) var unboxed: Unboxed

    init(_ unboxed: Unboxed) {
        self.unboxed = unboxed
    }

    // Called to update the `unboxed` value in the shared container.
    func withShared<T>(_ body: (inout Unboxed) throws -> T) rethrows -> T {
        return try body(&unboxed)
    }

    func unbox() -> Unboxed {
        return unboxed
    }

    var attribute: DynamoDB.AttributeValue {
        unboxed.attribute
    }
}

protocol AnyNumberBox: Box, CustomStringConvertible { }

struct NumberBox<Number>: AnyNumberBox {

    let unboxed: Number

    init(_ unboxed: Number) {
        self.unboxed = unboxed
    }

    // Dynamo expects numbers to be strings.
    var attribute: DynamoDB.AttributeValue {
        return .init(n: self.description)
    }

    var description: String { "\(unboxed)" }

}

struct StringBox: Box {

    let unboxed: String

    init(_ unboxed: String) {
        self.unboxed = unboxed
    }

    var attribute: DynamoDB.AttributeValue {
        return .init(s: unboxed)
    }
}

struct NullBox: Box {

    var attribute:  DynamoDB.AttributeValue {
        .init(null: true)
    }
}

struct BoolBox: Box {

    let unboxed: Bool

    init(_ unboxed: Bool) {
        self.unboxed = unboxed
    }

    var attribute: DynamoDB.AttributeValue {
        .init(bool: unboxed)
    }
}

enum EncodedAttributeContainer {
    case single(EncodedAttributeType)
    case unkeyed([EncodedAttributeType])
    case keyed([String: EncodedAttributeType])

    func unwrap() throws -> EncodedAttributeType {
        switch self {
        case let .single(attribute): return attribute
        case let .keyed(dictionary): return .map(dictionary)
        case let .unkeyed(array): return .list(array)
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
