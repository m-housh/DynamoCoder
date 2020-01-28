//
//  DynamoUnkeyedDecoder.swift
//  
//
//  Created by Michael Housh on 1/27/20.
//

import Foundation
import DynamoDB

struct DynamoUnkeyedDecoder: UnkeyedDecodingContainer {

    let decoder: _DynamoDecoder
    let container: [Any]
    var codingPath: [CodingKey]

    var count: Int? { container.count }

    var isAtEnd: Bool { currentIndex >= count! }

    var currentIndex: Int = 0

    mutating func decodeNil() throws -> Bool {
        guard !self.isAtEnd else {
            throw DynamoDecodingError.notFound
        }

        let item = self.container[currentIndex]

        var returnValue = false
        
        if item is NSNull {
            returnValue = true
        }
        else if let optional = item as? OptionalType, optional.isNil == true {
            returnValue = true
        }

        if returnValue == true {
            self.currentIndex += 1
        }

        return returnValue
    }

    mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        guard !self.isAtEnd else {
            throw DynamoDecodingError.notFound
        }

        let item = self.container[self.currentIndex]

        self.decoder.codingPath.append(DynamoCodingKey(int: currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        let decoded = try self.decoder.unbox(item, as: T.self)!

        currentIndex += 1
        return decoded

    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {

        guard !self.isAtEnd else {
            throw DynamoDecodingError.notFound
        }

        let item = self.container[self.currentIndex]

        guard let dictionary = item as? [String: Any] else {
            throw DynamoDecodingError.typeMismatch(
                codingPath: decoder.codingPath,
                expected: [String: Any].self,
                reality: item
            )
        }

        self.decoder.codingPath.append(DynamoCodingKey(int: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        currentIndex += 1
        let container = DynamoKeyedDecoder<NestedKey>(referencing: decoder, wrapping: dictionary)
        return KeyedDecodingContainer(container)
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard !self.isAtEnd else {
            throw DynamoDecodingError.notFound
        }

        let container = self.container[self.currentIndex]

        guard let array = container as? [Any] else {
            throw DynamoDecodingError.typeMismatch(
                codingPath: decoder.codingPath,
                expected: [Any].self,
                reality: container
            )
        }

        self.decoder.codingPath.append(DynamoCodingKey(int: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }
        
        currentIndex += 1

        return DynamoUnkeyedDecoder(decoder: decoder, container: array, codingPath: decoder.codingPath)
    }

    mutating func superDecoder() throws -> Decoder {
        self.decoder
    }

}
