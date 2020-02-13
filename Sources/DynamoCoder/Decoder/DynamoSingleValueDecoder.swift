//
//  DynamoSingleValueDecoder.swift
//  
//
//  Created by Michael Housh on 1/27/20.
//

import Foundation
import DynamoDB

extension _DynamoDecoder: SingleValueDecodingContainer {
    func assertTopContainer() throws -> DynamoDB.AttributeValue {
        let topContainer = storage.topContainer!
        if !(topContainer.isSingleAttribute) {
            throw DynamoDecodingError.typeMismatch(
                codingPath: codingPath,
                expected: EncodedAttributeType.self,
                reality: storage.topContainer
            )
        }
        return topContainer.attribute
    }

    public func decodeNil() -> Bool {
        do {
            let attribute = try assertTopContainer()
            return attribute.null ?? true
        }
        catch {
            return false
        }
    }

    public func decode(_ type: Bool.Type) throws -> Bool {
        let topContainer = try assertTopContainer()
        storage.popContainer()
        guard let bool = topContainer.bool else {
            throw DynamoDecodingError.typeMismatch(
                codingPath: codingPath,
                expected: Bool.self,
                reality: topContainer
            )
        }
        return bool
    }

    public func decode(_ type: String.Type) throws -> String {
        let topContainer = try assertTopContainer()
        storage.popContainer()
        guard let string = topContainer.s else {
            throw DynamoDecodingError.typeMismatch(
                codingPath: codingPath,
                expected: String.self,
                reality: topContainer
            )
        }
        return string
    }

    public func decode(_ type: Double.Type) throws -> Double {
        let topContainer = try assertTopContainer()
        storage.popContainer()
        guard let numberString = topContainer.n else {
            throw DynamoDecodingError.typeMismatch(
                codingPath: codingPath,
                expected: Double.self,
                reality: topContainer
            )
        }
        guard let double = Double(numberString) else {
            // this should be a better error.
            throw DynamoDecodingError.notFound
        }
        return double
    }

    public func decode(_ type: Float.Type) throws -> Float {
        let topContainer = try assertTopContainer()
        storage.popContainer()
        guard let numberString = topContainer.n else {
            throw DynamoDecodingError.typeMismatch(
                codingPath: codingPath,
                expected: Float.self,
                reality: topContainer
            )
        }
        guard let float = Float(numberString) else {
            // this should be a better error.
            throw DynamoDecodingError.notFound
        }
        return float
    }

    public func decode(_ type: Int.Type) throws -> Int {
        let topContainer = try assertTopContainer()
        storage.popContainer()
        guard let numberString = topContainer.n else {
            throw DynamoDecodingError.typeMismatch(
                codingPath: codingPath,
                expected: Int.self,
                reality: topContainer
            )
        }
        guard let number = Int(numberString) else {
            // this should be a better error.
            throw DynamoDecodingError.notFound
        }
        return number
    }

    public func decode(_ type: Int8.Type) throws -> Int8 {
        let topContainer = try assertTopContainer()
        storage.popContainer()
        guard let numberString = topContainer.n else {
            throw DynamoDecodingError.typeMismatch(
                codingPath: codingPath,
                expected: Int8.self,
                reality: topContainer
            )
        }
        guard let number = Int8(numberString) else {
            // this should be a better error.
            throw DynamoDecodingError.notFound
        }
        return number
    }

    public func decode(_ type: Int16.Type) throws -> Int16 {
        let topContainer = try assertTopContainer()
        storage.popContainer()
        guard let numberString = topContainer.n else {
            throw DynamoDecodingError.typeMismatch(
                codingPath: codingPath,
                expected: Int16.self,
                reality: topContainer
            )
        }
        guard let number = Int16(numberString) else {
            // this should be a better error.
            throw DynamoDecodingError.notFound
        }
        return number
    }

    public func decode(_ type: Int32.Type) throws -> Int32 {
        let topContainer = try assertTopContainer()
        storage.popContainer()
        guard let numberString = topContainer.n else {
            throw DynamoDecodingError.typeMismatch(
                codingPath: codingPath,
                expected: Int32.self,
                reality: topContainer
            )
        }
        guard let number = Int32(numberString) else {
            // this should be a better error.
            throw DynamoDecodingError.notFound
        }
        return number
    }

    public func decode(_ type: Int64.Type) throws -> Int64 {
        let topContainer = try assertTopContainer()
        storage.popContainer()
        guard let numberString = topContainer.n else {
            throw DynamoDecodingError.typeMismatch(
                codingPath: codingPath,
                expected: Int64.self,
                reality: topContainer
            )
        }
        guard let number = Int64(numberString) else {
            // this should be a better error.
            throw DynamoDecodingError.notFound
        }
        return number
    }

    public func decode(_ type: UInt.Type) throws -> UInt {
        let topContainer = try assertTopContainer()
        storage.popContainer()
        guard let numberString = topContainer.n else {
            throw DynamoDecodingError.typeMismatch(
                codingPath: codingPath,
                expected: UInt.self,
                reality: topContainer
            )
        }
        guard let number = UInt(numberString) else {
            // this should be a better error.
            throw DynamoDecodingError.notFound
        }
        return number
    }

    public func decode(_ type: UInt8.Type) throws -> UInt8 {
        let topContainer = try assertTopContainer()
        storage.popContainer()
        guard let numberString = topContainer.n else {
            throw DynamoDecodingError.typeMismatch(
                codingPath: codingPath,
                expected: UInt8.self,
                reality: topContainer
            )
        }
        guard let number = UInt8(numberString) else {
            // this should be a better error.
            throw DynamoDecodingError.notFound
        }
        return number
    }

    public func decode(_ type: UInt16.Type) throws -> UInt16 {
        let topContainer = try assertTopContainer()
        storage.popContainer()
        guard let numberString = topContainer.n else {
            throw DynamoDecodingError.typeMismatch(
                codingPath: codingPath,
                expected: UInt16.self,
                reality: topContainer
            )
        }
        guard let number = UInt16(numberString) else {
            // this should be a better error.
            throw DynamoDecodingError.notFound
        }
        return number
    }

    public func decode(_ type: UInt32.Type) throws -> UInt32 {
        let topContainer = try assertTopContainer()
        storage.popContainer()
        guard let numberString = topContainer.n else {
            throw DynamoDecodingError.typeMismatch(
                codingPath: codingPath,
                expected: UInt32.self,
                reality: topContainer
            )
        }
        guard let number = UInt32(numberString) else {
            // this should be a better error.
            throw DynamoDecodingError.notFound
        }
        return number
    }

    public func decode(_ type: UInt64.Type) throws -> UInt64 {
        let topContainer = try assertTopContainer()
        storage.popContainer()
        guard let numberString = topContainer.n else {
            throw DynamoDecodingError.typeMismatch(
                codingPath: codingPath,
                expected: UInt64.self,
                reality: topContainer
            )
        }
        guard let number = UInt64(numberString) else {
            // this should be a better error.
            throw DynamoDecodingError.notFound
        }
        return number
    }

    public func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        // decode non-primitive types
        return try type.init(from: self)
    }

}
