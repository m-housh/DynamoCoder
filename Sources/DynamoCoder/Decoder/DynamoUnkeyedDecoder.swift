//
//  DynamoUnkeyedDecoder.swift
//  
//
//  Created by Michael Housh on 1/27/20.
//

import Foundation
import DynamoDB

struct DynamoUnkeyedDecoder: UnkeyedDecodingContainer {
    var decoder: _DynamoDecoder
    var container: DecodingAttributeContainer
    var codingPath: [CodingKey]

    var listedAttributes: [DynamoDB.AttributeValue]? {
        switch container {
        case let .list(array): return array
        default: return nil
        }
    }

    var listedDictionaries: [DynamoAttributeDict]? {
        switch container {
        case let .unkeyed(dictionaries): return dictionaries
        default: return nil
        }
    }

    init(
        referencing decoder: _DynamoDecoder,
        codingPath: [CodingKey],
        wrapping container: DecodingAttributeContainer)
    {
        self.decoder = decoder
        self.codingPath = codingPath
        self.container = container
    }

    var count: Int? {
        if let attributes = listedAttributes {
            return attributes.count
        }
        if let dictionaries = listedDictionaries {
            return dictionaries.count
        }
        return nil
    }

    var isAtEnd: Bool {
        currentIndex >= count!
    }

    var currentIndex: Int = 0

    func assertNotAtEnd() throws {
        guard !self.isAtEnd else {
            throw DynamoDecodingError.notFound
        }
    }

    func assertIsList() throws {
        guard self.listedAttributes != nil else {
            throw DynamoDecodingError.typeMismatch(
                codingPath: self.codingPath,
                expected: [DynamoDB.AttributeValue].self,
                reality: container
            )
        }
    }

    func assertIsDictionaries() throws {
        guard self.listedDictionaries != nil else {
            throw DynamoDecodingError.typeMismatch(
                codingPath: self.codingPath,
                expected: [DynamoAttributeDict].self,
                reality: container
            )
        }
    }

    mutating func decodeNil() throws -> Bool {
        try assertNotAtEnd()
        try assertIsList()
        decoder.storage.push(.single(self.listedAttributes![self.currentIndex]))
        defer { self.decoder.storage.popContainer() }
        let decoded = decoder.decodeNil()
        decoder.storage.popContainer()
        if decoded {
            currentIndex += 1
            return true
        }
        return false
    }

    mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        try assertNotAtEnd()

        if listedAttributes != nil {
            let attribute = listedAttributes![currentIndex]
            decoder.storage.push(.single(attribute))
        }
        else {
            let dictionary = listedDictionaries![currentIndex]
            decoder.storage.push(.keyed(dictionary))
        }
        decoder.codingPath.append(DynamoCodingKey(int: currentIndex))
        defer {
            self.decoder.storage.popContainer()
            self.decoder.codingPath.removeLast()
        }
        let decoded = try decoder.decode(type)
        decoder.storage.popContainer()
        currentIndex += 1
        return decoded
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {

        try assertNotAtEnd()
        try assertIsDictionaries()

        let dictionary = listedDictionaries![self.currentIndex]
        self.decoder.codingPath.append(DynamoCodingKey(int: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        currentIndex += 1
        let container = DynamoKeyedDecoder<NestedKey>(
            referencing: decoder,
            codingPath: decoder.codingPath,
            wrapping: dictionary
        )
        return KeyedDecodingContainer(container)

    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw DynamoDecodingError.notFound
    }

    mutating func superDecoder() throws -> Decoder {
        fatalError()
    }

}
