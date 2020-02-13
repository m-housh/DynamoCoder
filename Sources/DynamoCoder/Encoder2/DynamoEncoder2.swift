//
//  File.swift
//  
//
//  Created by Michael Housh on 1/28/20.
//

import Foundation

//public struct DynamoEncoder2 {

//    public func encode<T: Encodable>(_ encodable: T) throws -> DynamoAttributeDict {
//        let output = try self.output(encodable)
//
//        switch output {
//        case let .dictionary(dictionary): return dictionary
//        default:
//            fatalError("Invalid return type: \(output)")
//        }
//    }
//
//    public func encode<T: Encodable>(_ encodable: [T]) throws -> DynamoEncodedArray {
//        let output = try self.output(encodable)
//
//        switch output {
//        case let .array(array): return array
//        default:
//            fatalError("Invalid return type: \(output)")
//        }
//    }
//
//    public func convert<T: Encodable>(_ encodable: T) throws -> DynamoDB.AttributeValue {
//        let encoder = _DynamoEncoder2()
//        try encodable.encode(to: encoder)
//
//        let topContainer = encoder.storage.popContainer()
//
//        switch topContainer {
//        case let .keyed(dictionary):
//            return .init(m: dictionary.mapValues { $0.attribute })
//        case let .single(attribute):
//            return attribute.attribute
//        case let .unkeyed(array):
//            return EncodedAttributeType.list(array).attribute
//        }
//    }
//
//    private func output<T: Encodable>(_ encodable: T) throws -> EncodedOutput {
//        let encoder = _DynamoEncoder2()
//        try encodable.encode(to: encoder)
//
//        let topContainer = encoder.storage.popContainer()
//
//        switch topContainer {
//        case let .keyed(dictionary):
//            return .dictionary(dictionary.mapValues { $0.attribute })
//        case let .unkeyed(array):
//            return .array(array.compactMap { $0.attribute.m })
//        default:
//            fatalError("Invalid return type")
//        }
//    }
//
//    public enum EncodedOutput {
//        case array(DynamoEncodedArray)
//        case dictionary(DynamoAttributeDict)
//    }
//}


//struct DynamoEncoder2Storage {
//
//    private(set) var containers: [EncodedAttributeContainer] = []
//
//    init() { }
//
//    // used for key/value pairs.
//    mutating func pushKeyedContainer() -> EncodedAttributeContainer {
//        let container = EncodedAttributeContainer.keyed([:])
//        containers.append(container)
//        return container
//    }
//
//    // used for an array or unkeyed container.
//    mutating func pushUnkeyedContainer() -> EncodedAttributeContainer {
//        let container = EncodedAttributeContainer.unkeyed([])
//        containers.append(container)
//        return container
//    }
//
//    // used when at single value level.
//    mutating func push(_ container: EncodedAttributeContainer) {
//        containers.append(container)
//    }
//
//    var count: Int { containers.count }
//
//    var topContainer: EncodedAttributeContainer? { containers.last }
//
//    @discardableResult
//    mutating func popContainer() -> EncodedAttributeContainer {
//        precondition(!containers.isEmpty,
//                     "Empty stack!")
//        return containers.popLast()!
//    }
//}
//
//class _DynamoEncoder2: Encoder {
//
//    var codingPath: [CodingKey]
//    var userInfo: [CodingUserInfoKey : Any] = [:]
//
//    var storage = DynamoEncoder2Storage()
//
//    init(codingPath: [CodingKey] = []) {
//        self.codingPath = codingPath
//    }
//
//    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
//        let keyedContainer = DynamoKeyedEncoder<Key>(
//            referencing: self,
//            codingPath: self.codingPath,
//            wrapping: storage.pushKeyedContainer()
//        )
//        return KeyedEncodingContainer(keyedContainer)
//    }
//
//    func unkeyedContainer() -> UnkeyedEncodingContainer {
//        return DynamoUnkeyedEncoder(
//            referencing: self,
//            codingPath: self.codingPath,
//            wrapping: storage.pushUnkeyedContainer()
//        )
//    }
//
//    func singleValueContainer() -> SingleValueEncodingContainer {
//        self
//    }
//
//    /// Returns whether we can encode a value for this coding path.
//    var canEncodeNewValue: Bool {
//
//        // We can only encode one value per coding path.
//        storage.count == codingPath.count
//    }
//}
//
//extension _DynamoEncoder2: SingleValueEncodingContainer {
//
//    func assertCanEncode() {
//        precondition(canEncodeNewValue,
//                     "Attempting to encode when already encoded at this path")
//    }
//
//    func encodeNil() throws {
//        assertCanEncode()
//        storage.push(.single(.null))
//    }
//
//    func encode(_ value: Bool) throws {
//        assertCanEncode()
//        storage.push(.single(.bool(value)))
//    }
//
//    func encode(_ value: String) throws {
//        assertCanEncode()
//        storage.push(.single(.string(value)))
//    }
//
//    func encode(_ value: Double) throws {
//        assertCanEncode()
//        storage.push(.single(.number("\(value)")))
//    }
//
//    func encode(_ value: Float) throws {
//        assertCanEncode()
//        storage.push(.single(.number("\(value)")))
//    }
//
//    func encode(_ value: Int) throws {
//        assertCanEncode()
//        storage.push(.single(.number("\(value)")))
//    }
//
//    func encode(_ value: Int8) throws {
//        assertCanEncode()
//        storage.push(.single(.number("\(value)")))
//    }
//
//    func encode(_ value: Int16) throws {
//        assertCanEncode()
//        storage.push(.single(.number("\(value)")))
//    }
//
//    func encode(_ value: Int32) throws {
//        assertCanEncode()
//        storage.push(.single(.number("\(value)")))
//    }
//
//    func encode(_ value: Int64) throws {
//        assertCanEncode()
//        storage.push(.single(.number("\(value)")))
//    }
//
//    func encode(_ value: UInt) throws {
//        assertCanEncode()
//        storage.push(.single(.number("\(value)")))
//    }
//
//    func encode(_ value: UInt8) throws {
//        assertCanEncode()
//        storage.push(.single(.number("\(value)")))
//    }
//
//    func encode(_ value: UInt16) throws {
//        assertCanEncode()
//        storage.push(.single(.number("\(value)")))
//    }
//
//    func encode(_ value: UInt32) throws {
//        assertCanEncode()
//        storage.push(.single(.number("\(value)")))
//    }
//
//    func encode(_ value: UInt64) throws {
//        assertCanEncode()
//        storage.push(.single(.number("\(value)")))
//    }
//
//    func encode<T>(_ value: T) throws where T : Encodable {
//        let depth = self.storage.count
//        try value.encode(to: self)
//        if !(self.storage.count > depth) {
//            // should probably fail / throw error here.
//            _ = storage.pushKeyedContainer()
//        }
//    }
//
//}
