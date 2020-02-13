//
//  File.swift
//  
//
//  Created by Michael Housh on 1/27/20.
//

import Foundation

struct DynamoKeyedEncoder<K: CodingKey>: KeyedEncodingContainerProtocol {

//    typealias Key = K
//
//    // the referencing encoder we are writing values into.
//    let encoder: _DynamoEncoder
//
//    // the referencing container that we are writing values into.
//    let container: SharedBox<KeyedBox>
//
//    private(set) var codingPath: [CodingKey]
//
//    init(
//        referencing encoder: _DynamoEncoder,
//        codingPath: [CodingKey],
//        wrapping container: SharedBox<KeyedBox>)
//    {
//        self.encoder = encoder
//        self.codingPath = codingPath
//        self.container = container
//    }
//
//    mutating func encodeNil(forKey key: K) throws {
//        container.withShared { container in
//            container[key.stringValue] = self.encoder.boxNil()
//        }
//    }
//
//    mutating func encode<T>(_ value: T, forKey key: K) throws where T : Encodable {
//        self.encoder.codingPath.append(key)
//        defer { self.encoder.codingPath.removeLast() }
//
//        try self.container.withShared { container in
//            container[key.stringValue] = try self.encoder.box(value)
//        }
//    }
//
//    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
//
//        let shared = SharedBox(KeyedBox())
//
//        self.container.withShared { container in
//            container[key.stringValue] = shared
//        }
//
//        self.codingPath.append(key)
//        defer { self.codingPath.removeLast() }
//
//        let container = DynamoKeyedEncoder<NestedKey>(
//            referencing: encoder,
//            codingPath: codingPath,
//            wrapping: shared
//        )
//
//        return KeyedEncodingContainer(container)
//    }
//
//    mutating func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
//        let shared = SharedBox(UnkeyedBox())
//
//        self.codingPath.append(key)
//        defer { self.codingPath.removeLast() }
//
//        self.container.withShared { container in
//            container[key.stringValue] = shared
//        }
//
//        return DynamoUnkeyedEncoder(
//            referencing: encoder,
//            codingPath: codingPath,
//            wrapping: shared
//        )
//    }
//
//    mutating func superEncoder() -> Encoder {
//        DynamoReferencingEncoder(
//            referencing: encoder,
//            key: DynamoCodingKey.super,
//            wrapping: container
//        )
//    }
//
//    mutating func superEncoder(forKey key: K) -> Encoder {
//        DynamoReferencingEncoder(
//            referencing: encoder,
//            key: key,
//            wrapping: container
//        )
//    }


    typealias Key = K

    let encoder: _DynamoEncoder
    private(set) var codingPath: [CodingKey]
    var container: KeyedAttributeContainer

    // our internal storage that we are writing into.
//    var storage: [String: EncodedAttributeType] = [:]

    init(
        referencing encoder: _DynamoEncoder,
        codingPath: [CodingKey],
        wrapping container: KeyedAttributeContainer)
    {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }

    mutating func encodeNil(forKey key: K) throws {
        self.encoder.codingPath.append(key)
        container[key.stringValue] = .null
//        encoder.storage.popContainer()
//        encoder.storage.push(.keyed(storage))
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
        self.container[key.stringValue] = try encoded.unwrap()

        // pop the keyed container and replace with current state.
//        self.encoder.storage.popContainer()
        // pop the coding path, so we can continue.
//        self.encoder.codingPath.removeLast()
//        self.encoder.storage.push(.keyed(storage))
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {

        self.encoder.codingPath.append(key)
        self.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }

        let container = DynamoKeyedEncoder<NestedKey>(
            referencing: encoder,
            codingPath: codingPath,
            wrapping: KeyedAttributeContainer()
        )

        return KeyedEncodingContainer(container)
    }

    mutating func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        self.encoder.codingPath.append(key)
        self.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }

        let container = UnkeyedAttributeContainer()

        return DynamoUnkeyedEncoder(
            referencing: encoder,
            codingPath: codingPath,
            wrapping: container
        )
    }

    mutating func superEncoder() -> Encoder {
        let key = DynamoCodingKey(string: "super")
        return DynamoReferencingEncoder(
            referencing: encoder,
            key: key,
            wrapping: container
        )
    }

    mutating func superEncoder(forKey key: K) -> Encoder {
        return DynamoReferencingEncoder(
            referencing: encoder,
            key: key,
            wrapping: container
        )
    }
}
