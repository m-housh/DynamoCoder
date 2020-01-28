//
//  DynamoSingleValueDecoder.swift
//  
//
//  Created by Michael Housh on 1/27/20.
//

import Foundation
import DynamoDB

extension _DynamoDecoder: SingleValueDecodingContainer {

    func expectNonNil() throws {
        guard !decodeNil() else {
            throw DynamoDecodingError.notFound
        }
    }

    func decodeNil() -> Bool {
        if let attribute = storage.topContainer as? DynamoDB.AttributeValue {
            if let null = attribute.null { return null }
            return false
        }
        return storage.topContainer is NSNull
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        try expectNonNil()
        return try self.unbox(self.storage.topContainer!, as: Bool.self)!
    }

    func decode(_ type: String.Type) throws -> String {
        try expectNonNil()
        guard self.storage.topContainer != nil else {
            throw DynamoDecodingError.notFound
        }
        return try self.unbox(self.storage.topContainer!, as: String.self)!
    }

    func decode(_ type: Double.Type) throws -> Double {
        try expectNonNil()
        return try self.unbox(self.storage.topContainer!, as: Double.self)!
    }

    func decode(_ type: Float.Type) throws -> Float {
        try expectNonNil()
        return try self.unbox(self.storage.topContainer!, as: Float.self)!
    }

    func decode(_ type: Int.Type) throws -> Int {
        try expectNonNil()
        return try self.unbox(self.storage.topContainer!, as: Int.self)!
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        try expectNonNil()
        return try self.unbox(self.storage.topContainer!, as: Int8.self)!
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        try expectNonNil()
        return try self.unbox(self.storage.topContainer!, as: Int16.self)!
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        try expectNonNil()
        return try self.unbox(self.storage.topContainer!, as: Int32.self)!
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        try expectNonNil()
        return try self.unbox(self.storage.topContainer!, as: Int64.self)!
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        try expectNonNil()
        return try self.unbox(self.storage.topContainer!, as: UInt.self)!
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        try expectNonNil()
        return try self.unbox(self.storage.topContainer!, as: UInt8.self)!
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        try expectNonNil()
        return try self.unbox(self.storage.topContainer!, as: UInt16.self)!
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        try expectNonNil()
        return try self.unbox(self.storage.topContainer!, as: UInt32.self)!
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        try expectNonNil()
        return try self.unbox(self.storage.topContainer!, as: UInt64.self)!
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        try expectNonNil()
        return try self.unbox(self.storage.topContainer!, as: T.self)!
    }

}
