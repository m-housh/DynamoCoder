//
//  File.swift
//  
//
//  Created by Michael Housh on 1/27/20.
//

import Foundation

extension _DynamoEncoder: SingleValueEncodingContainer {

    func assertCanEncode() {
        precondition(canEncodeNewValue,
                     "Attempting to encode when already encoded at this path.")
    }

    func encodeNil() throws {
        assertCanEncode()
        storage.push(.single(.null))
    }

    func encode(_ value: Bool) throws {
        assertCanEncode()
        storage.push(.single(.bool(value)))
    }

    func encode(_ value: String) throws {
        assertCanEncode()
        storage.push(.single(.string(value)))
    }

    func encode(_ value: Double) throws {
        assertCanEncode()
        storage.push(.single(.number("\(value)")))
    }

    func encode(_ value: Float) throws {
        assertCanEncode()
        storage.push(.single(.number("\(value)")))
    }

    func encode(_ value: Int) throws {
        assertCanEncode()
        storage.push(.single(.number("\(value)")))
    }

    func encode(_ value: Int8) throws {
        assertCanEncode()
        storage.push(.single(.number("\(value)")))
    }

    func encode(_ value: Int16) throws {
        assertCanEncode()
        storage.push(.single(.number("\(value)")))
    }

    func encode(_ value: Int32) throws {
        assertCanEncode()
        storage.push(.single(.number("\(value)")))
    }

    func encode(_ value: Int64) throws {
        assertCanEncode()
        storage.push(.single(.number("\(value)")))
    }

    func encode(_ value: UInt) throws {
        assertCanEncode()
        storage.push(.single(.number("\(value)")))
    }

    func encode(_ value: UInt8) throws {
        assertCanEncode()
        storage.push(.single(.number("\(value)")))
    }

    func encode(_ value: UInt16) throws {
        assertCanEncode()
        storage.push(.single(.number("\(value)")))
    }

    func encode(_ value: UInt32) throws {
        assertCanEncode()
        storage.push(.single(.number("\(value)")))
    }

    func encode(_ value: UInt64) throws {
        assertCanEncode()
        storage.push(.single(.number("\(value)")))
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        let depth = self.storage.count
        try value.encode(to: self)
        if !(self.storage.count > depth) {
            // should probably fail / throw error here.
            _ = storage.pushKeyedContainer()
        }
    }

}
