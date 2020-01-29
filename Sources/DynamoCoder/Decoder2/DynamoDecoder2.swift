//
//  File.swift
//  
//
//  Created by Michael Housh on 1/29/20.
//

import Foundation
import DynamoDB

public struct DynamoDecoder2 {

    public func decode<T: Decodable>(
        _ type: T.Type,
        from dictionary: DynamoAttributeDict
    ) throws -> T
    {
        return try _DynamoDecoder2(referencing: .keyed(dictionary)).decode(type)
    }

    public func decode<T: Decodable>(
        _ type: [T].Type,
        from array: DynamoEncodedArray
    ) throws -> [T]
    {
        return try _DynamoDecoder2(referencing: .unkeyed(array)).decode(type)
    }

    public func decode<T: Decodable>(
        _ type: T.Type,
        from attrbute: DynamoDB.AttributeValue
    ) throws -> T
    {
        return try _DynamoDecoder2(referencing: .single(attrbute)).decode(type)
    }
}

struct Decoder2Storage {

    private var containers: [DecodingAttributeContainer] = []

    init() { }

    var topContainer: DecodingAttributeContainer? {
        containers.last
    }

    mutating func push(_ container: DecodingAttributeContainer) {
        containers.append(container)
    }

    @discardableResult
    mutating func popContainer() -> DecodingAttributeContainer? {
//        precondition(!containers.isEmpty,
//                     "Attempting to pop container on empty stack!")
        return containers.popLast()
    }
}

class _DynamoDecoder2: Decoder {

    var codingPath: [CodingKey]

    var userInfo: [CodingUserInfoKey : Any] = [:]
    internal var storage = Decoder2Storage()

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
            let container = DynamoKeyedDecoder2<Key>(
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
            return DynamoUnkeyedDecoder2(
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

extension _DynamoDecoder2: SingleValueDecodingContainer {

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

struct DynamoUnkeyedDecoder2: UnkeyedDecodingContainer {

    var decoder: _DynamoDecoder2
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
        referencing decoder: _DynamoDecoder2,
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

//        decoder.storage.push(.single(attribute))
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
        let container = DynamoKeyedDecoder2<NestedKey>(
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

struct DynamoKeyedDecoder2<K: CodingKey>: KeyedDecodingContainerProtocol {

    typealias Key = K

    var decoder: _DynamoDecoder2
    let container: DynamoAttributeDict
    var codingPath: [CodingKey]

    init(
        referencing decoder: _DynamoDecoder2,
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

        let container = DynamoKeyedDecoder2<NestedKey>(
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
            return DynamoUnkeyedDecoder2(
                referencing: decoder,
                codingPath: decoder.codingPath,
                wrapping: .list(list)
            )
        }

        if let stringSet = attribute.ss {
            return DynamoUnkeyedDecoder2(
                referencing: decoder,
                codingPath: decoder.codingPath,
                wrapping: .list(stringSet.map { DynamoDB.AttributeValue.init(s: $0) })
            )
        }

        if let numberSet = attribute.ns {
            return DynamoUnkeyedDecoder2(
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
