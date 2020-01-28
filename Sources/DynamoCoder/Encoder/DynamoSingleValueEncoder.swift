//
//  File.swift
//  
//
//  Created by Michael Housh on 1/27/20.
//

import Foundation

extension _DynamoEncoder: SingleValueEncodingContainer {

    func assertCanEncodeValue() {
        precondition(
            canEncodeNewValue,
            "Attempting to encode a value that has already been encoded."
        )
    }

    func encodeNil() throws {
        assertCanEncodeValue()
        storage.push(boxNil())
    }

    func encode(_ value: Bool) throws {
        assertCanEncodeValue()
        storage.push(box(value))
    }

    func encode(_ value: String) throws {
        assertCanEncodeValue()
        storage.push(box(value))
    }

    func encode(_ value: Double) throws {
        assertCanEncodeValue()
        storage.push(box(value))
    }

    func encode(_ value: Float) throws {
        assertCanEncodeValue()
        storage.push(box(value))
    }

    func encode(_ value: Int) throws {
        assertCanEncodeValue()
        storage.push(box(value))
    }

    func encode(_ value: Int8) throws {
        assertCanEncodeValue()
        storage.push(box(value))
    }

    func encode(_ value: Int16) throws {
        assertCanEncodeValue()
        storage.push(box(value))
    }

    func encode(_ value: Int32) throws {
        assertCanEncodeValue()
        storage.push(box(value))
    }

    func encode(_ value: Int64) throws {
        assertCanEncodeValue()
        storage.push(box(value))
    }

    func encode(_ value: UInt) throws {
        assertCanEncodeValue()
        storage.push(box(value))
    }

    func encode(_ value: UInt8) throws {
        assertCanEncodeValue()
        storage.push(box(value))
    }

    func encode(_ value: UInt16) throws {
        assertCanEncodeValue()
        storage.push(box(value))
    }

    func encode(_ value: UInt32) throws {
        assertCanEncodeValue()
        storage.push(box(value))
    }

    func encode(_ value: UInt64) throws {
        assertCanEncodeValue()
        storage.push(box(value))
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        assertCanEncodeValue()
        storage.push(try box(value))
    }
}
