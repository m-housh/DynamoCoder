//
//  DynamoEncoder.swift
//  
//
//  Created by Michael Housh on 1/27/20.
//

import Foundation
import DynamoDB

public struct DynamoEncoder {

    public init() { }
    
    public func encode<T: Encodable>(_ encodable: T) throws -> DynamoAttributeDict {
        let output = try self.output(encodable)

        switch output {
        case let .dictionary(dictionary): return dictionary
        default:
            fatalError("Invalid return type: \(output)")
        }
    }

    public func encode<T: Encodable>(_ encodable: [T]) throws -> DynamoEncodedArray {
        let output = try self.output(encodable)

        switch output {
        case let .array(array): return array
        default:
            fatalError("Invalid return type: \(output)")
        }
    }

    public func convert<T: Encodable>(_ encodable: T) throws -> DynamoDB.AttributeValue {
        let encoder = _DynamoEncoder()
        try encodable.encode(to: encoder)

        let topContainer = encoder.storage.popContainer()

        switch topContainer {
        case let .keyed(dictionary):
            return .init(m: try dictionary.output.mapValues { try $0.unwrap().attribute })
        case let .single(attribute):
            return attribute.attribute
        case let .unkeyed(array):
            return EncodedAttributeType.list(array.output).attribute
        }
    }

    private func output<T: Encodable>(_ encodable: T) throws -> EncodedOutput {
        let encoder = _DynamoEncoder()
        try encodable.encode(to: encoder)

        let topContainer = encoder.storage.popContainer()

        switch topContainer {
        case let .keyed(dictionary):
            return .dictionary(try dictionary.output.mapValues({ try $0.unwrap().attribute }))
        case let .unkeyed(array):
            return .array(array.output.compactMap { $0.attribute.m })
        default:
            fatalError("Invalid return type")
        }
    }

    private enum EncodedOutput {
        case array(DynamoEncodedArray)
        case dictionary(DynamoAttributeDict)
    }
}

class _DynamoEncoder: Encoder {

    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey : Any] = [:]

    var storage = DynamoEncodingStorage()

    init(codingPath: [CodingKey] = []) {
        self.codingPath = codingPath
    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let keyedContainer = DynamoKeyedEncoder<Key>(
            referencing: self,
            codingPath: self.codingPath,
            wrapping: storage.pushKeyedContainer()
        )
        return KeyedEncodingContainer(keyedContainer)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        return DynamoUnkeyedEncoder(
            referencing: self,
            codingPath: self.codingPath,
            wrapping: storage.pushUnkeyedContainer()
        )
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        self
    }

    /// Returns whether we can encode a value for this coding path.
    var canEncodeNewValue: Bool {
        // We can only encode one value per coding path.
        storage.count == codingPath.count
    }
}
