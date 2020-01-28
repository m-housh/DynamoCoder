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
