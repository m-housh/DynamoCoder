//
//  File.swift
//  
//
//  Created by Michael Housh on 1/27/20.
//

import Foundation

struct DynamoUnkeyedEncoder: UnkeyedEncodingContainer {

    // the encoder that we are writing to.
    let encoder: _DynamoEncoder

    // the container we are referencing.
    let container: SharedBox<UnkeyedBox>

    private(set) var codingPath: [CodingKey]

    // get our count from the container.
    var count: Int {
        container.withShared { $0.count }
    }

    init(
        referencing encoder: _DynamoEncoder,
        codingPath: [CodingKey],
        wrapping container: SharedBox<UnkeyedBox>)
    {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }

    mutating func encodeNil() throws {
        container.withShared { container in
            container.append(encoder.boxNil())
        }
    }

    mutating func encode<T>(_ value: T) throws where T: Encodable {

        encoder.codingPath.append(DynamoCodingKey(int: count))
        defer { self.encoder.codingPath.removeLast() }

        try self.container.withShared { container in
            container.append(try encoder.box(value))
        }
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {

        codingPath.append(DynamoCodingKey(int: count))
        defer { self.codingPath.removeLast() }

        let shared = SharedBox(KeyedBox())
        self.container.withShared { container in
            container.append(shared)
        }

        let container = DynamoKeyedEncoder<NestedKey>(
            referencing: encoder,
            codingPath: codingPath,
            wrapping: shared
        )

        return KeyedEncodingContainer(container)
    }

    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        codingPath.append(DynamoCodingKey(int: count))
        defer { self.codingPath.removeLast() }

        let shared = SharedBox(UnkeyedBox())
        container.withShared { container in
            container.append(shared)
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
            at: count,
            wrapping: container
        )
    }
}
