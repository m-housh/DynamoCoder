//
//  File.swift
//  
//
//  Created by Michael Housh on 1/27/20.
//

import Foundation

struct DynamoUnkeyedEncoder: UnkeyedEncodingContainer {

//    // the encoder that we are writing to.
//    let encoder: _DynamoEncoder
//
//    // the container we are referencing.
//    let container: SharedBox<UnkeyedBox>
//
//    private(set) var codingPath: [CodingKey]
//
//    // get our count from the container.
//    var count: Int {
//        container.withShared { $0.count }
//    }
//
//    init(
//        referencing encoder: _DynamoEncoder,
//        codingPath: [CodingKey],
//        wrapping container: SharedBox<UnkeyedBox>)
//    {
//        self.encoder = encoder
//        self.codingPath = codingPath
//        self.container = container
//    }
//
//    mutating func encodeNil() throws {
//        container.withShared { container in
//            container.append(encoder.boxNil())
//        }
//    }
//
//    mutating func encode<T>(_ value: T) throws where T: Encodable {
//
//        encoder.codingPath.append(DynamoCodingKey(int: count))
//        defer { self.encoder.codingPath.removeLast() }
//
//        try self.container.withShared { container in
//            container.append(try encoder.box(value))
//        }
//    }
//
//    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
//
//        codingPath.append(DynamoCodingKey(int: count))
//        defer { self.codingPath.removeLast() }
//
//        let shared = SharedBox(KeyedBox())
//        self.container.withShared { container in
//            container.append(shared)
//        }
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
//    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
//        codingPath.append(DynamoCodingKey(int: count))
//        defer { self.codingPath.removeLast() }
//
//        let shared = SharedBox(UnkeyedBox())
//        container.withShared { container in
//            container.append(shared)
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
//            at: count,
//            wrapping: container
//        )
//    }
    let encoder: _DynamoEncoder
    private(set) var codingPath: [CodingKey]
    var container: UnkeyedAttributeContainer

    // internal storage we write values to.
//    private var storage: [EncodedAttributeType] = []

    init(
        referencing encoder: _DynamoEncoder,
        codingPath: [CodingKey],
        wrapping container: UnkeyedAttributeContainer)
    {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }

    var count: Int {
        container.count
    }

    mutating func encodeNil() throws {
//        _ = encoder.storage.popContainer()
        self.container.push(.null)
//        encoder.storage.push(.unkeyed(storage))
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
        container.push(try encoded.unwrap())

        // remove the current unkeyed container and
        // replace with current state.
//        _ = self.encoder.storage.popContainer()
//        self.encoder.storage.push(.unkeyed(storage))
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        self.codingPath.append(DynamoCodingKey(int: count))
        defer { self.codingPath.removeLast() }

        let container = DynamoKeyedEncoder<NestedKey>(
            referencing: encoder,
            codingPath: self.codingPath,
            wrapping: encoder.storage.pushKeyedContainer()
        )

        return KeyedEncodingContainer(container)
    }

    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        self.codingPath.append(DynamoCodingKey(int: count))
        defer { self.codingPath.removeLast() }

        return DynamoUnkeyedEncoder(
            referencing: encoder,
            codingPath: self.codingPath,
            wrapping: encoder.storage.pushUnkeyedContainer()
        )
    }

    mutating func superEncoder() -> Encoder {
        return DynamoReferencingEncoder(
            referencing: encoder,
            at: self.count,
            wrapping: container
        )
    }
}
