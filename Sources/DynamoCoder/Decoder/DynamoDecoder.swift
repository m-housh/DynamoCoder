//
//  DynamoDecoder.swift
//  
//
//  Created by Michael Housh on 1/27/20.
//

import Foundation
import DynamoDB

public struct DynamoDecoder {

    public init() { }

    public func decode<T: Decodable>(
        _ type: T.Type,
        from dictionary: DynamoAttributeDict
    ) throws -> T
    {
        return try _DynamoDecoder(referencing: .keyed(dictionary)).decode(type)
    }

    public func decode<T: Decodable>(
        _ type: [T].Type,
        from array: DynamoEncodedArray
    ) throws -> [T]
    {
        return try _DynamoDecoder(referencing: .unkeyed(array)).decode(type)
    }

    public func decode<T: Decodable>(
        _ type: T.Type,
        from attrbute: DynamoDB.AttributeValue
    ) throws -> T
    {
        return try _DynamoDecoder(referencing: .single(attrbute)).decode(type)
    }
}

class _DynamoDecoder: Decoder {

    var codingPath: [CodingKey]

    var userInfo: [CodingUserInfoKey : Any] = [:]
    internal var storage = DynamoDecoderStorage()

    init(
        referencing container: DecodingAttributeContainer,
        codingPath: [CodingKey] = []
    ) {
        self.codingPath = codingPath
        self.storage.push(container)
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let topContainer = self.storage.popContainer()
        let dictionary: DynamoAttributeDict

        // parse the top continer.
        switch topContainer {
        case let .keyed(dict):
            dictionary = dict
        case let .single(attribute):
            guard let dict = attribute.m else {
                throw DynamoDecodingError.typeMismatch(
                    codingPath: self.codingPath,
                    expected: DynamoAttributeDict.self,
                    reality: attribute
                )
            }
            dictionary = dict
        default:
            throw DynamoDecodingError.typeMismatch(
                codingPath: self.codingPath,
                expected: DynamoAttributeDict.self,
                reality: topContainer
            )
        }

        // Build the keyed decoder and return.
        let container = DynamoKeyedDecoder<Key>(
            referencing: self,
            codingPath: self.codingPath,
            wrapping: dictionary
        )
        return KeyedDecodingContainer(container)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        let topContainer = self.storage.popContainer()!
        switch topContainer {
        case .unkeyed, .list:
            return DynamoUnkeyedDecoder(
                referencing: self,
                codingPath: self.codingPath,
                wrapping: topContainer
            )
        case let .single(attribute):
            if let list = attribute.l {
                return DynamoUnkeyedDecoder(
                    referencing: self,
                    codingPath: self.codingPath,
                    wrapping: .list(list)
                )
            }
            else {
                var array: [DynamoDB.AttributeValue]
                if let strings = attribute.ss {
                    array = strings.map { DynamoDB.AttributeValue(s: $0) }
                }
                else if let numbers = attribute.ns {
                    array = numbers.map { DynamoDB.AttributeValue(n: $0) }
                }
                else {
                    throw DynamoDecodingError.typeMismatch(
                        codingPath: codingPath,
                        expected: Array<Decodable>.self,
                        reality: attribute
                    )
                }
                return DynamoUnkeyedDecoder(
                    referencing: self,
                    codingPath: codingPath,
                    wrapping: .list(array))
            }
        default:
            throw DynamoDecodingError.typeMismatch(
                codingPath: self.codingPath,
                expected: DynamoAttributeDict.self,
                reality: topContainer
            )
        }    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        self
    }

}
