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

    // default to a dict, so callers don't always have to pass the return value.
    public func encode<T>(
        _ encodable: T
    ) throws -> DynamoAttributeDict
        where T: Encodable
    {
        return try encode(encodable, as: DynamoAttributeDict.self)

    }

    public func encode<T>(
        _ encodable: T,
        as type: DynamoAttributeDict.Type = DynamoAttributeDict.self
    ) throws -> DynamoAttributeDict
        where T: Encodable
    {

        let encoder = _DynamoEncoder()
        try encodable.encode(to: encoder)
        let topContainer = encoder.storage.popContainer()

        if let keyedContainer = topContainer as? SharedBox<KeyedBox> {
            return keyedContainer.unbox().convert()
        }

        fatalError("Invalid top container, expected keyed container: \(topContainer)")
    }

    public func encode<T>(
        _ encodable: [T],
        as type: DynamoEncodedArray.Type = DynamoEncodedArray.self
    ) throws -> DynamoEncodedArray
        where T: Encodable
    {

        let encoder = _DynamoEncoder()
        try encodable.encode(to: encoder)
        let topContainer = encoder.storage.popContainer()

        if let unKeyedContainer = topContainer as? SharedBox<UnkeyedBox> {
            return try unKeyedContainer.unbox().convert()
        }
        else if let keyedContainer = topContainer as? SharedBox<KeyedBox> {
            return [keyedContainer.unbox().convert()]
        }

        fatalError("Invalid top container, expected unkeyed container: \(topContainer)")
    }

    public func encode<T>(
        _ encodable: T,
        as type: DynamoDB.AttributeValue.Type = DynamoDB.AttributeValue.self
    ) throws -> DynamoDB.AttributeValue
        where T: Encodable
    {

        let encoder = _DynamoEncoder()
        try encodable.encode(to: encoder)
        let topContainer = encoder.storage.popContainer()
        return topContainer.attribute
    }
}

class _DynamoEncoder: Encoder {

    var codingPath: [CodingKey]
    var storage: DynamoEncodingStorage
    var userInfo: [CodingUserInfoKey : Any] = [:]

    init(
        codingPath: [CodingKey] = [])
    {
        self.codingPath = codingPath
        self.storage = DynamoEncodingStorage()
    }

    /// Returns whether we can encode a value for this coding path.
    var canEncodeNewValue: Bool {

        // We can only encode one value per coding path.
        storage.count == codingPath.count
    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {

        var topContainer: SharedBox<KeyedBox>

        if canEncodeNewValue {
            topContainer = storage.pushKeyedContainer()
        }
        else {
            guard let container = storage.topContainer as? SharedBox<KeyedBox> else {
                preconditionFailure(
                    "Attempting to push new keyed encoder when already encoded at this path."
                )
            }
            topContainer = container
        }

        let container = DynamoKeyedEncoder<Key>(
            referencing: self,
            codingPath: self.codingPath,
            wrapping: topContainer
        )
        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {

        var topContainer: SharedBox<UnkeyedBox>

        if canEncodeNewValue {
            topContainer = storage.pushUnkeyedContainer()
        }
        else {
            guard let container = storage.topContainer as? SharedBox<UnkeyedBox> else {
                preconditionFailure(
                    "Attempting to push new unkeyed encoder when already encoded at this path."
                )
            }
            topContainer = container
        }

        return DynamoUnkeyedEncoder(
            referencing: self,
            codingPath: self.codingPath,
            wrapping: topContainer
        )
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        self
    }
}

extension _DynamoEncoder {
    // MARK: - BOX

    // Boxes values to be able to be pushed onto storage stack.
    func box(_ value: String) -> Box {
        StringBox(value)
    }

    func box(_ value: DynamoNumber) -> Box {
        NumberBox(value)
    }

    func box(_ bool: Bool) -> Box {
        BoolBox(bool)
    }

    func boxNil() -> Box {
        NullBox()
    }

    func box<T>(_ value: T) throws -> Box where T: Encodable {

        if T.self == String.self, let string = value as? String {
            return box(string)
        }
        else if let number = value as? DynamoNumber {
            return box(number)
        }
        else if T.self == Bool.self, let bool = value as? Bool {
            return box(bool)
        }

        // Decode non-primitive types.

        let depth = self.storage.count
        try value.encode(to: self)

        // the top container should be a new container
        guard storage.count > depth else {
            return KeyedBox()
        }

        return storage.popContainer()
    }
}
