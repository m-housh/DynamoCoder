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

    let decoder: _DynamoDecoder

    var container: [String: Any]

    var codingPath: [CodingKey]

    init(
        referencing decoder: _DynamoDecoder,
        wrapping container: [String: Any])
    {
        self.decoder = decoder
        self.codingPath = decoder.codingPath
        self.container = container
    }

    var allKeys: [K] { container.keys.compactMap { Key(stringValue: $0) } }

    func contains(_ key: K) -> Bool {
        container[key.stringValue] != nil
    }

    func decodeNil(forKey key: K) throws -> Bool {
        guard let item = container[key.stringValue] else {
            throw DynamoDecodingError.notFound
        }
        return item is NSNull
    }

    func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T : Decodable {
        guard let attribute = container[key.stringValue] else {
            throw DynamoDecodingError.notFound
        }
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }
        return try self.decoder.unbox(attribute, as: T.self)!
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {

        guard let attribute = container[key.stringValue] else {
            throw DynamoDecodingError.notFound
        }

        guard let dictionary = attribute as? [String: Any] else {
            throw DynamoDecodingError.typeMismatch(
                codingPath: decoder.codingPath,
                expected: [String: Any].self,
                reality: attribute
            )
        }

        self.decoder.codingPath.append(DynamoCodingKey(string: key.stringValue))
        defer { self.decoder.codingPath.removeLast() }

        let container = DynamoKeyedDecoder<NestedKey>(referencing: decoder, wrapping: dictionary)
        return KeyedDecodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        guard let attribute = container[key.stringValue] else {
            throw DynamoDecodingError.notFound
        }

        guard let array = attribute as? [Any] else {
            throw DynamoDecodingError.typeMismatch(
                codingPath: decoder.codingPath,
                expected: [Any].self,
                reality: attribute
            )
        }

        self.decoder.codingPath.append(DynamoCodingKey(string: key.stringValue))
        defer { self.decoder.codingPath.removeLast() }

        return DynamoUnkeyedDecoder(
            decoder: self.decoder,
            container: array,
            codingPath: decoder.codingPath
        )
    }

    func superDecoder() throws -> Decoder {
        return decoder
    }

    func superDecoder(forKey key: K) throws -> Decoder {
        return decoder
    }

}
