//
//  File.swift
//  
//
//  Created by Michael Housh on 1/27/20.
//

import Foundation
import DynamoDB

struct DynamoKeyedDecoder<K: CodingKey>: KeyedDecodingContainerProtocol {



    typealias Key = K

    var decoder: _DynamoDecoder
    let container: DynamoAttributeDict
    var codingPath: [CodingKey]

    init(
        referencing decoder: _DynamoDecoder,
        codingPath: [CodingKey],
        wrapping container: DynamoAttributeDict)
    {
        self.decoder = decoder
        self.codingPath = codingPath
        self.container = container
    }

    var allKeys: [K] {
        container.keys.compactMap { Key(stringValue: $0) }
    }

    func contains(_ key: K) -> Bool {
        self.container[key.stringValue] != nil
    }

    func assertHasKey(_ key: Key) throws {
        guard self.contains(key) else {
            throw DynamoDecodingError.notFound
        }
    }

    func decodeNil(forKey key: K) throws -> Bool {
        try assertHasKey(key)
        decoder.storage.push(.single(self.container[key.stringValue]!))
        let decoded = decoder.decodeNil()
        decoder.storage.popContainer()
        return decoded
    }

    func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T : Decodable {
       try assertHasKey(key)
        decoder.storage.push(.single(self.container[key.stringValue]!))
        decoder.codingPath.append(key)
        defer {
            self.decoder.storage.popContainer()
            self.decoder.codingPath.removeLast()
        }
        return try decoder.decode(type)
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {

        try assertHasKey(key)
        guard let dictionary = self.container[key.stringValue]!.m else {
            throw DynamoDecodingError.typeMismatch(
                codingPath: decoder.codingPath,
                expected: DynamoAttributeDict.self,
                reality: self.container[key.stringValue]
            )
        }

        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }

        let container = DynamoKeyedDecoder<NestedKey>(
            referencing: decoder,
            codingPath: decoder.codingPath,
            wrapping: dictionary
        )

        return KeyedDecodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        try assertHasKey(key)
        let attribute = self.container[key.stringValue]!

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        if let list = attribute.l {
            return DynamoUnkeyedDecoder(
                referencing: decoder,
                codingPath: decoder.codingPath,
                wrapping: .list(list)
            )
        }

        if let stringSet = attribute.ss {
            return DynamoUnkeyedDecoder(
                referencing: decoder,
                codingPath: decoder.codingPath,
                wrapping: .list(stringSet.map { DynamoDB.AttributeValue.init(s: $0) })
            )
        }

        if let numberSet = attribute.ns {
            return DynamoUnkeyedDecoder(
                referencing: decoder,
                codingPath: decoder.codingPath,
                wrapping: .list(numberSet.map { DynamoDB.AttributeValue.init(s: $0) })
            )
        }

        throw DynamoDecodingError.typeMismatch(
            codingPath: decoder.codingPath,
            expected: [DynamoDB.AttributeValue].self,
            reality: attribute
        )
    }

    func superDecoder() throws -> Decoder {
        fatalError()
    }

    func superDecoder(forKey key: K) throws -> Decoder {
        fatalError()
    }
}
