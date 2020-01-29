//
//  File.swift
//  
//
//  Created by Michael Housh on 1/28/20.
//

import Foundation

struct DynamoUnkeyedEncoder2: UnkeyedEncodingContainer {

    let encoder: _DynamoEncoder2
    private(set) var codingPath: [CodingKey]
    var container: EncodedAttributeContainer

    // internal storage we write values to.
    private var storage: [EncodedAttributeType] = []

    init(
        referencing encoder: _DynamoEncoder2,
        codingPath: [CodingKey],
        wrapping container: EncodedAttributeContainer)
    {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }

    var count: Int {
        storage.count
    }

    mutating func encodeNil() throws {
        _ = encoder.storage.popContainer()
        self.storage.append(.null)
        encoder.storage.push(.unkeyed(storage))
    }

    mutating func encode<T>(_ value: T) throws where T: Encodable {

        encoder.codingPath.append(DynamoCodingKey(int: self.count))
        defer { self.encoder.codingPath.removeLast() }

        // defer encoding to our wrapped encoder.
        let depth = encoder.storage.count
        try value.encode(to: encoder)

        // ensure we encoded a value.
        guard encoder.storage.count > depth else {
            // did not encode a value
            fatalError("UnkeyedContainer - Failed to encode : \(value)")
        }

        // our value will be the top of the stack.
        let encoded = encoder.storage.popContainer()

        // store to our internal storage.
        storage.append(try encoded.unwrap())

        // remove the current unkeyed container and
        // replace with current state.
        _ = self.encoder.storage.popContainer()
        self.encoder.storage.push(.unkeyed(storage))
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError()
    }

    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError()
    }

    mutating func superEncoder() -> Encoder {
        fatalError()
    }

}

struct DynamoKeyedEncoder2<K: CodingKey>: KeyedEncodingContainerProtocol {


    typealias Key = K

    let encoder: _DynamoEncoder2
    var codingPath: [CodingKey]
    var container: EncodedAttributeContainer

    // our internal storage that we are writing into.
    var storage: [String: EncodedAttributeType] = [:]

    init(
        referencing encoder: _DynamoEncoder2,
        codingPath: [CodingKey],
        wrapping container: EncodedAttributeContainer)
    {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }

    mutating func encodeNil(forKey key: K) throws {
        storage[key.stringValue] = .null
        encoder.storage.popContainer()
        encoder.storage.push(.keyed(storage))
    }

    mutating func encode<T>(_ value: T, forKey key: K) throws where T : Encodable {
        self.encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }

        let depth = self.encoder.storage.count
        try value.encode(to: encoder)

        guard self.encoder.storage.count > depth else {
            // fail
            fatalError("Failed to encode value: \(value)")
        }

        let encoded = self.encoder.storage.popContainer()
        self.storage[key.stringValue] = try encoded.unwrap()

        // pop the keyed container and replace with current state.
        self.encoder.storage.popContainer()
        self.encoder.storage.push(.keyed(storage))
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError()
    }

    mutating func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        fatalError()
    }

    mutating func superEncoder() -> Encoder {
        fatalError()
    }

    mutating func superEncoder(forKey key: K) -> Encoder {
        fatalError()
    }
}
