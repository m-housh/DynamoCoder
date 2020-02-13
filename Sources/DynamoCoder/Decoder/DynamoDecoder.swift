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
        switch topContainer {
        case let .keyed(dictionary):
            let container = DynamoKeyedDecoder<Key>(
                referencing: self,
                codingPath: self.codingPath,
                wrapping: dictionary
            )
            return KeyedDecodingContainer(container)
        default:
            throw DynamoDecodingError.typeMismatch(
                codingPath: self.codingPath,
                expected: DynamoAttributeDict.self,
                reality: topContainer
            )
        }
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        let topContainer = self.storage.popContainer()!
        switch topContainer {
        case .unkeyed:
            return DynamoUnkeyedDecoder(
                referencing: self,
                codingPath: self.codingPath,
                wrapping: topContainer
            )
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

//extension _DynamoDecoder {
//
//    // MARK: - UNBOX
//
//    private func findAttribute(_ value: Any) -> DynamoDB.AttributeValue? {
//        if let attribute = value as? DynamoDB.AttributeValue { return attribute }
//        if let dictionary = value as? [String: DynamoDB.AttributeValue] {
////            guard dictionary.count == 1 else {
////                throw Dyna.tooManyValues
////            }
//            return dictionary.first!.value
//        }
//        if let array = value as? [DynamoDB.AttributeValue] {
//            return array.first
//        }
//
//        return nil
//    }
//
//    func unbox(_ value: Any, as type: Bool.Type) throws -> Bool? {
//        if let bool = value as? Bool { return bool }
//        return findAttribute(value)?.bool
//    }
//
//    func unbox(_ value: Any, as type: String.Type) throws -> String? {
//        if let string = value as? String { return string }
//        return findAttribute(value)?.s
//    }
//
//    func unbox(_ value: Any, as type: Double.Type) throws -> Double? {
//        if let item = value as? Double { return item }
//        guard let numberString = findAttribute(value)?.n else {
//            return value as? Double
//        }
//        return Double(numberString)
//    }
//
//    func unbox(_ value: Any, as type: Float.Type) throws -> Float? {
//        if let item = value as? Float { return item }
//        guard let numberString = findAttribute(value)?.n else {
//            return value as? Float
//        }
//        return Float(numberString)
//    }
//
//    func unbox(_ value: Any, as type: Int.Type) throws -> Int? {
//        if let item = value as? Int { return item }
//        guard let numberString = findAttribute(value)?.n else {
//            return value as? Int
//        }
//        return Int(numberString)
//    }
//
//    func unbox(_ value: Any, as type: Int8.Type) throws -> Int8? {
//        if let item = value as? Int8 { return item }
//        guard let numberString = findAttribute(value)?.n else {
//            return value as? Int8
//        }
//        return Int8(numberString)
//    }
//
//    func unbox(_ value: Any, as type: Int16.Type) throws -> Int16? {
//        if let item = value as? Int16 { return item }
//
//        guard let numberString = findAttribute(value)?.n else {
//            return value as? Int16
//        }
//        return Int16(numberString)
//
//    }
//
//    func unbox(_ value: Any, as type: Int32.Type) throws -> Int32? {
//        if let item = value as? Int32 { return item }
//
//        guard let numberString = findAttribute(value)?.n else {
//            return value as? Int32
//        }
//        return Int32(numberString)
//    }
//
//    func unbox(_ value: Any, as type: Int64.Type) throws -> Int64? {
//        if let item = value as? Int64 { return item }
//
//        guard let numberString = findAttribute(value)?.n else {
//            return value as? Int64
//        }
//        return Int64(numberString)
//    }
//
//    func unbox(_ value: Any, as type: UInt.Type) throws -> UInt? {
//        if let item = value as? UInt { return item }
//
//        guard let numberString = findAttribute(value)?.n else {
//            return value as? UInt
//        }
//        return UInt(numberString)
//    }
//
//    func unbox(_ value: Any, as type: UInt8.Type) throws -> UInt8? {
//        if let item = value as? UInt8 { return item }
//
//        guard let numberString = findAttribute(value)?.n else {
//            return value as? UInt8
//        }
//        return UInt8(numberString)
//    }
//
//    func unbox(_ value: Any, as type: UInt16.Type) throws -> UInt16? {
//        if let item = value as? UInt16 { return item }
//
//        guard let numberString = findAttribute(value)?.n else {
//            return value as? UInt16
//        }
//        return UInt16(numberString)
//    }
//
//    func unbox(_ value: Any, as type: UInt32.Type) throws -> UInt32? {
//        if let item = value as? UInt32 { return item }
//
//        guard let numberString = findAttribute(value)?.n else {
//            return value as? UInt32
//        }
//        return UInt32(numberString)
//    }
//
//    func unbox(_ value: Any, as type: UInt64.Type) throws -> UInt64? {
//        if let item = value as? UInt64 { return item }
//
//        guard let numberString = findAttribute(value)?.n else {
//            return value as? UInt64
//        }
//        return UInt64(numberString)
//    }
//
////    func unboxNumber<N: DynamoNumber>(_ value: Any, as type: N.Type) throws -> N? {
////
////        if let number = value as? N { return number }
////
////        if let string = value as? String {
////            return N.init(string)
////        }
////
////        if let attribute = findAttribute(value), let numString = attribute.n {
////            return N.init(numString)
////        }
////
////        throw DynamoDecodingError.typeMismatch(codingPath: codingPath, expected: N.self, reality: value)
////    }
//
//    func unbox<T>(_ value: Any, as type: T.Type) throws -> T? where T : Decodable {
//        if let item = value as? T { return item }
//
//        // test for number types.
////        if T.self == Double.self {
////            return try unboxNumber(value, as: Int.self) as? T
////        }
////        if T.self == Float.self {
////            return try unboxNumber(value, as: Int.self) as? T
////        }
////        if T.self == Int.self {
////            return try unboxNumber(value, as: Int.self) as? T
////        }
////        if T.self == Int8.self {
////            return try unboxNumber(value, as: Int8.self) as? T
////        }
////        if T.self == Int16.self {
////            return try unboxNumber(value, as: Int16.self) as? T
////        }
////        if T.self == Int32.self {
////            return try unboxNumber(value, as: Int32.self) as? T
////        }
////        if T.self == Int64.self {
////            return try unboxNumber(value, as: Int64.self) as? T
////        }
////        if T.self == UInt.self {
////            return try unboxNumber(value, as: UInt.self) as? T
////        }
////        if T.self == UInt8.self {
////            return try unboxNumber(value, as: UInt8.self) as? T
////        }
////        if T.self == UInt16.self {
////            return try unboxNumber(value, as: UInt16.self) as? T
////        }
////        if T.self == UInt32.self {
////            return try unboxNumber(value, as: UInt32.self) as? T
////        }
////        if T.self == UInt64.self {
////            return try unboxNumber(value, as: UInt64.self) as? T
////        }
//
//        let optionalAttribute = findAttribute(value)
//
//        // Test for if the value we are decoding are dynamo attribute lists or maps and
//        // decode them correctly.
//        if let attribute = optionalAttribute {
//            // unbox a map attribute
//            if let dictionary = attribute.m { // nested codable
//                return try unbox(dictionary, as: type)
//            }
//
//            // unbox a list attribute.
//            if let array = attribute.l { // nested array
//                do {
//                    // this is used / succeeds when array elements hold other dynamo attribute values
//                    return try unbox_(array, as: type) as? T
//                }
//                catch {
//                    // this is used / succeed when array elements are normal decodable types.
//                    return try unbox(array, as: type)
//                }
//            }
//        }
//
//        let unboxed = try unbox_(value, as: type) as? T
//        return unboxed
//    }
//
//    func unbox_<T>(_ values: [Any], as type: [T].Type) throws -> [T] where T: Decodable {
//        return try values.map { try unbox($0, as: T.self)! }
//    }
//
//    func unbox_(_ value: Any, as type: Decodable.Type) throws -> Any? {
//        self.storage.push(value)
//        defer { self.storage.popContainer() }
//
//        let unboxed = try type.init(from: self)
//        return unboxed
//    }
//
////    func unbox(_ type: Bool.Type, from attribute: DynamoDB.AttributeValue) -> Bool? {
////        return attribute.bool
////    }
////
////    func unbox(_ type: String.Type, from attribute: DynamoDB.AttributeValue) -> String? {
////        return attribute.s
////    }
////
////    func unbox<N: DynamoNumber>(_ type: N.Type, from attribute: DynamoDB.AttributeValue) -> N? {
////        guard let numString = attribute.n else { return nil }
////        return N(numString)
////    }
////
////    func unboxNil(from attribute: DynamoDB.AttributeValue) -> Bool {
////        if let isNil = attribute.null {
////            return isNil
////        }
////        return false
////    }
////
////    private func findAttribute(_ value: Any) -> DynamoDB.AttributeValue? {
////        if let attribute = value as? DynamoDB.AttributeValue {
////            return attribute
////        }
////        else if let dictionary = value as? DynamoAttributeDict {
////            return dictionary.first?.value
////        }
////        else if let array = value as? [DynamoDB.AttributeValue] {
////            return array.first
////        }
////
////        return nil
////    }
////
////    func unbox<T>(_ value: Any, as type: T.Type) throws -> T? where T: Decodable {
////
////        if let item = value as? T { return item }
////
////        // decode lists and dictionaries properly
////        if let attribute = findAttribute(value) {
////
////            if let dictionary = attribute.m {
////                return try unbox(dictionary, as: type)
////            }
////
////            if let array = attribute.l {
//////                do {
////                    // used for non-primitive decoding.
////                    return try unbox_(array, as: type) as? T
//////                }
//////                catch {
//////                    // used for primitive decoding
//////                    return try unbox(array, as: type)
//////                }
////            }
////
////            return try unbox(attribute, as: type)
////        }
////
////        return try unbox_(value, as: type) as? T
////    }
////
////    func unbox_<T>(_ values: [Any], as type: [T].Type) throws -> [T] where T: Decodable {
////        return try values.map { try unbox($0, as: T.self)! }
////    }
////
////    func unbox_(_ value: Any, as type: Decodable.Type) throws -> Any? {
////        self.storage.push(value)
////        defer { self.storage.popContainer() }
////
////        return try type.init(from: self)
////    }
////
////    func unbox<T: Decodable>(_ attribute: DynamoDB.AttributeValue, as type: T.Type) throws -> T {
////
////        var decoded: T? = nil
////
////        if T.self == Bool.self {
////             decoded = unbox(Bool.self, from: attribute) as? T
////        }
////        else if T.self == String.self {
////            decoded = unbox(String.self, from: attribute) as? T
////        }
////        else if T.self == Double.self {
////            decoded = unbox(Double.self, from: attribute) as? T
////        }
////        else if T.self == Float.self {
////            decoded = unbox(Float.self, from: attribute) as? T
////        }
////        else if T.self == Int.self {
////            decoded = unbox(Int.self, from: attribute) as? T
////        }
////        else if T.self == Int8.self {
////            decoded = unbox(Int8.self, from: attribute) as? T
////        }
////        else if T.self == Int16.self {
////            decoded = unbox(Int16.self, from: attribute) as? T
////        }
////        else if T.self == Int32.self {
////            decoded = unbox(Int32.self, from: attribute) as? T
////        }
////        else if T.self == Int64.self {
////            decoded = unbox(Int64.self, from: attribute) as? T
////        }
////        else if T.self == UInt.self {
////            decoded = unbox(UInt.self, from: attribute) as? T
////        }
////        else if T.self == UInt8.self {
////            decoded = unbox(UInt8.self, from: attribute) as? T
////        }
////        else if T.self == UInt16.self {
////            decoded = unbox(UInt16.self, from: attribute) as? T
////        }
////        else if T.self == UInt32.self {
////            decoded = unbox(UInt32.self, from: attribute) as? T
////        }
////        else if T.self == UInt64.self {
////            decoded = unbox(UInt64.self, from: attribute) as? T
////        }
////
////        // unboxed a primitive type.
////        if decoded != nil { return decoded! }
////
////        storage.push(attribute)
////        defer { storage.popContainer() }
////
////        return try type.init(from: self)
////
////    }
//}
