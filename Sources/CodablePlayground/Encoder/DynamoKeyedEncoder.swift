//
//  File.swift
//  
//
//  Created by Michael Housh on 1/27/20.
//

import Foundation

struct DynamoKeyedEncoder<K: CodingKey>: KeyedEncodingContainerProtocol {

    typealias Key = K

    // the referencing encoder we are writing values into.
    let encoder: _DynamoEncoder

    // the referencing container that we are writing values into.
    let container: SharedBox<KeyedBox>

    private(set) var codingPath: [CodingKey]

    init(
        referencing encoder: _DynamoEncoder,
        codingPath: [CodingKey],
        wrapping container: SharedBox<KeyedBox>)
    {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }

    mutating func encodeNil(forKey key: K) throws {
        container.withShared { container in
            container[key.stringValue] = self.encoder.boxNil()
        }
    }

    mutating func encode<T>(_ value: T, forKey key: K) throws where T : Encodable {
        self.encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }

        try self.container.withShared { container in
            container[key.stringValue] = try self.encoder.box(value)
        }
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {

        let shared = SharedBox(KeyedBox())

        self.container.withShared { container in
            container[key.stringValue] = shared
        }

        self.codingPath.append(key)
        defer { self.codingPath.removeLast() }

        let container = DynamoKeyedEncoder<NestedKey>(
            referencing: encoder,
            codingPath: codingPath,
            wrapping: shared
        )

        return KeyedEncodingContainer(container)
    }

    mutating func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        let shared = SharedBox(UnkeyedBox())

        self.codingPath.append(key)
        defer { self.codingPath.removeLast() }

        self.container.withShared { container in
            container[key.stringValue] = shared
        }

        return DynamoUnkeyedEncoder(
            referencing: encoder,
            codingPath: codingPath,
            wrapping: shared
        )
    }

    mutating func superEncoder() -> Encoder {
        DynamoReferencingEncoder(
            referencing: encoder,
            key: DynamoCodingKey.super,
            wrapping: container
        )
    }

    mutating func superEncoder(forKey key: K) -> Encoder {
        DynamoReferencingEncoder(
            referencing: encoder,
            key: key,
            wrapping: container
        )
    }

}
