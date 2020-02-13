//
//  File.swift
//  
//
//  Created by Michael Housh on 1/27/20.
//

import XCTest
import DynamoDB
@testable import DynamoCoder

final class DynamoDecoderTests: XCTestCase {

    let decoder = DynamoDecoder()

    func testOptionalType() {

        let optional: Optional<String?> = .some(nil)
        XCTAssertTrue(optional.isNil)

        let optional2: Optional<String?> = .some("foo")
        XCTAssertFalse(optional2.isNil)
    }

    func testSimpleDecoding() throws {
        do {
            struct Simple: Codable, Equatable {
                let string = "foo"
                let int = 1
                let double = 20.05
                let optionalString: String? = "some"
                let optionalNil: String? = nil
                let bool = true
                let int8 = Int8(exactly: 8.0)!
                let int16 = Int16(exactly: 16.0)!
                let int32 = Int32(exactly: 32.0)!
                let int64 = Int64(exactly: 64.0)!
                let uInt = UInt(exactly: 1.0)!
                let uInt8 = UInt8(exactly: 8.0)!
                let uInt16 = UInt16(exactly: 16.0)!
                let uInt32 = UInt32(exactly: 32.0)!
                let uInt64 = UInt64(exactly: 64.0)!
                let float = Float(exactly: 10.0)!
                let dict: [String: Int] = ["foo": 1, "bar": 2]
            }

            let dictionary = try DynamoEncoder().encode(Simple())
            let decoded = try decoder.decode(Simple.self, from: dictionary)

            XCTAssertEqual(decoded, Simple())

            struct NestedSimple: Codable, Equatable {
                let simple = Simple()
                let dictionary = ["simple": Simple()]
            }

            let nestedEncoded = try DynamoEncoder().encode(NestedSimple())
            let nestedDecoded = try decoder.decode(NestedSimple.self, from: nestedEncoded)
            XCTAssertEqual(nestedDecoded, NestedSimple())
        }
        catch {
            print("error: \(error)")
            throw error
        }
    }

    func testArrayDecoding() throws {
        struct TestModel: Codable, Equatable {
            let strings = ["foo", "bar"]
            let numbers = [1, 2, 3, 4]
            let doubles = [1.0, 2.0, 2.5]
            let emptyStrings: [String] = []
            let int8 = [Int8(exactly: 8.0)!]
            let int16 = [Int16(exactly: 16.0)!]
            let int32 = [Int32(exactly: 32.0)!]
            let int64 = [Int64(exactly: 64.0)!]
            let uInt = [UInt(exactly: 1.0)!]
            let uInt8 = [UInt8(exactly: 8.0)!]
            let uInt16 = [UInt16(exactly: 16.0)!]
            let uInt32 = [UInt32(exactly: 32.0)!]
            let uInt64 = [UInt64(exactly: 64.0)!]
            let float = [Float(exactly: 10.0)!]
        }

        do {
            let encoded = try DynamoEncoder().encode(TestModel())
            let decoded = try decoder.decode(TestModel.self, from: encoded)

            XCTAssertEqual(decoded, TestModel())

            let multiEncoded = try DynamoEncoder().encode([TestModel(), TestModel(),  TestModel()])
            let multiDecoded = try decoder.decode([TestModel].self, from: multiEncoded)

            XCTAssertEqual(multiDecoded, [TestModel(), TestModel(),  TestModel()])
        }
        catch {
            print("error: \(error)")
            throw error
        }

    }

    func testSimpleNestedCodable() throws {
        struct Foo: Codable, Equatable {
            let name = "Foo"
        }

        struct Bar: Codable, Equatable {
            let foo = Foo()
            let number = 1
        }

        let encoded = try DynamoEncoder().encode(Bar())
        let decoded = try decoder.decode(Bar.self, from: encoded)

        XCTAssertEqual(decoded, Bar())
    }

    func testWithCustomDecodable() throws {
        struct TestCustom: Codable, Equatable {
            let foo: String
            let bar: String

            init(foo: String = "Foo", bar: String = "Bar") {
                self.foo = foo
                self.bar = bar
            }

            enum CodingKeys: String, CodingKey {
                case bar = "BarKey"
                case foo = "FooKey"
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let fooString = try container.decode(String.self, forKey: .foo)
                let barString = try container.decode(String.self, forKey: .bar)
                self.init(foo: fooString, bar: barString)
            }

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(foo, forKey: .foo)
                try container.encode(bar, forKey: .bar)
            }
        }

        let encoded = try DynamoEncoder().encode(TestCustom(foo: "Bar", bar: "Foo"))
        let decoded = try decoder.decode(TestCustom.self, from: encoded)
        XCTAssertEqual(decoded, TestCustom(foo: "Bar", bar: "Foo"))
    }

    func testSingleValueDecoding() {
//        let decoder = DynamoDecoder()
        XCTAssertEqual(try decoder.decode(Bool.self, from: DynamoDB.AttributeValue(bool: false)), false)
        XCTAssertEqual(try decoder.decode(String.self, from: DynamoDB.AttributeValue(s: "foo")), "foo")
        XCTAssertEqual(try decoder.decode(Int.self, from: DynamoDB.AttributeValue(n: "1")), 1)
        XCTAssertEqual(try decoder.decode(Float.self, from: DynamoDB.AttributeValue(n: "1.0")), 1.0)
        XCTAssertEqual(try decoder.decode(Double.self, from: DynamoDB.AttributeValue(n: "4.56")), 4.56)
        XCTAssertEqual(try decoder.decode(Int8.self, from: DynamoDB.AttributeValue(n: "10")), 10)
        XCTAssertEqual(try decoder.decode(Int16.self, from: DynamoDB.AttributeValue(n: "11")), 11)
        XCTAssertEqual(try decoder.decode(Int32.self, from: DynamoDB.AttributeValue(n: "12")), 12)
        XCTAssertEqual(try decoder.decode(Int64.self, from: DynamoDB.AttributeValue(n: "13")), 13)
        XCTAssertEqual(try decoder.decode(UInt8.self, from: DynamoDB.AttributeValue(n: "13")), 13)
        XCTAssertEqual(try decoder.decode(UInt32.self, from: DynamoDB.AttributeValue(n: "13")), 13)
        XCTAssertEqual(try decoder.decode(UInt64.self, from: DynamoDB.AttributeValue(n: "13")), 13)
        XCTAssertEqual(try decoder.decode(UInt16.self, from: DynamoDB.AttributeValue(n: "13")), 13)
        XCTAssertEqual(try decoder.decode(UInt.self, from: DynamoDB.AttributeValue(n: "13")), 13)
        XCTAssertEqual(try decoder.decode(Optional<Int>.self, from: DynamoDB.AttributeValue(null: true)), .none)
        XCTAssertEqual(try decoder.decode(Optional<Int>.self, from: DynamoDB.AttributeValue(null: false)), .none)

        // Errors for invalid types
        XCTAssertThrowsError(try decoder.decode(Bool.self, from: DynamoDB.AttributeValue(s: "foo")))
        XCTAssertThrowsError(try decoder.decode(String.self, from: DynamoDB.AttributeValue(n: "1")))
        XCTAssertThrowsError(try decoder.decode(Int.self, from: DynamoDB.AttributeValue(s: "1")))
        XCTAssertThrowsError(try decoder.decode(Float.self, from: DynamoDB.AttributeValue(s: "1.0")))
        XCTAssertThrowsError(try decoder.decode(Double.self, from: DynamoDB.AttributeValue(s: "4.56")))
        XCTAssertThrowsError(try decoder.decode(Int8.self, from: DynamoDB.AttributeValue(s: "10")))
        XCTAssertThrowsError(try decoder.decode(Int16.self, from: DynamoDB.AttributeValue(s: "11")))
        XCTAssertThrowsError(try decoder.decode(Int32.self, from: DynamoDB.AttributeValue(s: "12")))
        XCTAssertThrowsError(try decoder.decode(Int64.self, from: DynamoDB.AttributeValue(s: "13")))
        XCTAssertThrowsError(try decoder.decode(UInt8.self, from: DynamoDB.AttributeValue(s: "13")))
        XCTAssertThrowsError(try decoder.decode(UInt32.self, from: DynamoDB.AttributeValue(s: "13")))
        XCTAssertThrowsError(try decoder.decode(UInt64.self, from: DynamoDB.AttributeValue(s: "13")))
        XCTAssertThrowsError(try decoder.decode(UInt16.self, from: DynamoDB.AttributeValue(s: "13")))
        // Invalid number types.
        XCTAssertThrowsError(try decoder.decode(UInt.self, from: DynamoDB.AttributeValue(n: "foo")))
        XCTAssertThrowsError(try decoder.decode(Int.self, from: DynamoDB.AttributeValue(n: "foo")))
        XCTAssertThrowsError(try decoder.decode(Float.self, from: DynamoDB.AttributeValue(n: "foo")))
        XCTAssertThrowsError(try decoder.decode(Double.self, from: DynamoDB.AttributeValue(n: "foo")))
        XCTAssertThrowsError(try decoder.decode(Int8.self, from: DynamoDB.AttributeValue(n: "foo")))
        XCTAssertThrowsError(try decoder.decode(Int16.self, from: DynamoDB.AttributeValue(n: "foo")))
        XCTAssertThrowsError(try decoder.decode(Int32.self, from: DynamoDB.AttributeValue(n: "foo")))
        XCTAssertThrowsError(try decoder.decode(Int64.self, from: DynamoDB.AttributeValue(n: "foo")))
        XCTAssertThrowsError(try decoder.decode(UInt8.self, from: DynamoDB.AttributeValue(n: "foo")))
        XCTAssertThrowsError(try decoder.decode(UInt32.self, from: DynamoDB.AttributeValue(n: "foo")))
        XCTAssertThrowsError(try decoder.decode(UInt64.self, from: DynamoDB.AttributeValue(n: "foo")))
        XCTAssertThrowsError(try decoder.decode(UInt16.self, from: DynamoDB.AttributeValue(n: "foo")))
        XCTAssertThrowsError(try decoder.decode(UInt.self, from: DynamoDB.AttributeValue(n: "foo")))
    }

    func testKeyedDecoding() throws {
        struct TestCodable: Codable, Equatable {
            let foo: String = "Foo"
        }

        let input: DynamoAttributeDict = [
            "string": .init(s: "foo"),
            "bool": .init(bool: false),
            "int": .init(n: "\(Int(1))"),
            "double": .init(n: "\(Double(1.0))"),
            "float": .init(n: "\(Float(exactly: 13.0)!)"),
            "int8": .init(n: "\(Int8(exactly: 8.0)!)"),
            "int16": .init(n: "\(Int16(exactly: 16.0)!)"),
            "int32": .init(n: "\(Int32(exactly: 32.0)!)"),
            "int64": .init(n: "\(Int64(exactly: 64.0)!)"),
            "uInt": .init(n: "\(UInt(exactly: 1.0)!)"),
            "uInt8": .init(n: "\(UInt8(exactly: 8.0)!)"),
            "uInt16": .init(n: "\(UInt16(exactly: 16.0)!)"),
            "uInt32": .init(n: "\(UInt32(exactly: 32.0)!)"),
            "uInt64": .init(n: "\(UInt64(exactly: 64.0)!)"),
            "dict": .init(m: ["foo": .init(n: "1"), "bar": .init(n: "2")]),
//            "nestedDict": ["foo": ["bing": "bam"], "bar": ["baz": "boom"]],
//            "codable": TestCodable(),
            "stringArray": .init(ss: ["foo", "bar", "baz", "boom"]),
//            "nestedArrays": .init(l: [.init(l: ["bar", "baz"]), .init(l: ["bing", "boom"])])
        ]
        let keyedDecoder = try _DynamoDecoder(referencing: .keyed(input)).container(keyedBy: DynamoCodingKey.self)
        XCTAssertEqual(keyedDecoder.allKeys.count, 16)
        XCTAssert(keyedDecoder.contains(.string("string")))
        XCTAssertEqual(try keyedDecoder.decode(String.self, forKey: .string("string")), "foo")
        XCTAssertEqual(try keyedDecoder.decode(Bool.self, forKey: .string("bool")), false)
        XCTAssertEqual(try keyedDecoder.decode(Int.self, forKey: .string("int")), 1)
        XCTAssertEqual(try keyedDecoder.decode(Double.self, forKey: .string("double")), 1.0)
        XCTAssertEqual(try keyedDecoder.decode(Float.self, forKey: .string("float")), 13.0)
        XCTAssertEqual(try keyedDecoder.decode(Int8.self, forKey: .string("int8")), 8)
        XCTAssertEqual(try keyedDecoder.decode(Int16.self, forKey: .string("int16")), 16)
        XCTAssertEqual(try keyedDecoder.decode(Int32.self, forKey: .string("int32")), 32)
        XCTAssertEqual(try keyedDecoder.decode(Int64.self, forKey: .string("int64")), 64)
        XCTAssertEqual(try keyedDecoder.decode(UInt.self, forKey: .string("uInt")), 1)
        XCTAssertEqual(try keyedDecoder.decode(UInt8.self, forKey: .string("uInt8")), 8)
        XCTAssertEqual(try keyedDecoder.decode(UInt16.self, forKey: .string("uInt16")), 16)
        XCTAssertEqual(try keyedDecoder.decode(UInt32.self, forKey: .string("uInt32")), 32)
        XCTAssertEqual(try keyedDecoder.decode(UInt64.self, forKey: .string("uInt64")), 64)
//        XCTAssertEqual(try keyedDecoder.decode([String: Int].self, forKey: .string("dict")), ["foo": 1, "bar": 2])
//        XCTAssertEqual(try keyedDecoder.decode([String: [String: String]].self, forKey: .string("nestedDict")), ["foo": ["bing": "bam"], "bar": ["baz": "boom"]])
//        XCTAssertEqual(try keyedDecoder.decode(TestCodable.self, forKey: .string("codable")), TestCodable())
//        XCTAssertEqual(try keyedDecoder.decode([String].self, forKey: .string("stringArray")), ["foo", "bar", "baz", "boom"])
//        XCTAssertEqual(try keyedDecoder.decode([[String]].self, forKey: .string("nestedArrays")), [["foo"], ["bar", "baz"], ["bing", "boom"]])

        // Invalid key
        XCTAssertThrowsError(try keyedDecoder.decode(String.self, forKey: .string("foo")))
        XCTAssertThrowsError(try keyedDecoder.decode(Bool.self, forKey: .string("foo")))
        XCTAssertThrowsError(try keyedDecoder.decode(Double.self, forKey: .string("foo")))
        XCTAssertThrowsError(try keyedDecoder.decode(Float.self, forKey: .string("foo")))
        XCTAssertThrowsError(try keyedDecoder.decode(Int.self, forKey: .string("foo")))
        XCTAssertThrowsError(try keyedDecoder.decode(Int8.self, forKey: .string("foo")))
        XCTAssertThrowsError(try keyedDecoder.decode(Int16.self, forKey: .string("foo")))
        XCTAssertThrowsError(try keyedDecoder.decode(Int32.self, forKey: .string("foo")))
        XCTAssertThrowsError(try keyedDecoder.decode(Int64.self, forKey: .string("foo")))
        XCTAssertThrowsError(try keyedDecoder.decode(UInt.self, forKey: .string("foo")))
        XCTAssertThrowsError(try keyedDecoder.decode(UInt8.self, forKey: .string("foo")))
        XCTAssertThrowsError(try keyedDecoder.decode(UInt16.self, forKey: .string("foo")))
        XCTAssertThrowsError(try keyedDecoder.decode(UInt32.self, forKey: .string("foo")))
        XCTAssertThrowsError(try keyedDecoder.decode(UInt64.self, forKey: .string("foo")))
        XCTAssertThrowsError(try keyedDecoder.decode(TestCodable.self, forKey: .string("foo")))

//        XCTAssertFalse(try keyedDecoder.decodeNil(forKey: .string("string")))
//        XCTAssertThrowsError(try keyedDecoder.decodeNil(forKey: .string("foo")))
    }

    func testUnkeyedDecodingWithListInput() {
        let list: [DynamoDB.AttributeValue] = [.init(null: true), .init(s: "foo"), .init(s: "bar")]
        var decoder = try! _DynamoDecoder(referencing: .list(list)).unkeyedContainer() as? DynamoUnkeyedDecoder
        XCTAssertNil(decoder!.listedDictionaries)
        XCTAssertEqual(decoder!.count, 3)
        XCTAssertEqual(decoder!.currentIndex, 0)
        XCTAssert(try! decoder!.decodeNil())
        XCTAssertEqual(decoder!.currentIndex, 1)
        XCTAssertFalse(try! decoder!.decodeNil())
        XCTAssertEqual(decoder!.currentIndex, 1)
        XCTAssertThrowsError(try decoder!.assertIsDictionaries())
        XCTAssertEqual(try! decoder!.decode(String.self), "foo")
        XCTAssertEqual(decoder!.currentIndex, 2)
        XCTAssertEqual(try! decoder!.decode(String.self), "bar")
        XCTAssertEqual(decoder!.currentIndex, 3)
        XCTAssertThrowsError(try decoder!.decode(String.self))
    }

    func testUnkeyedDecoderWithDictionaryInput() {
        let unkeyed: [DynamoAttributeDict] = [["foo": .init(s: "bar"), "null": .init(null: true)]]
        var decoder = try! _DynamoDecoder(referencing: .unkeyed(unkeyed)).unkeyedContainer() as? DynamoUnkeyedDecoder
        XCTAssertNil(decoder!.listedAttributes)
        XCTAssertEqual(decoder!.count, 1)
        XCTAssertThrowsError(try decoder!.assertIsList())
        XCTAssertNoThrow(try decoder!.assertIsDictionaries())
        let decoded = try! decoder!.decode([String: Optional<String>].self)
        XCTAssertEqual(decoded["foo"], "bar")
        XCTAssertNil(decoded["null"]!)

        let invalidTopContainer = _DynamoDecoder(referencing: .single(.init(s: "foo")))
        let invalidUnkeyed = DynamoUnkeyedDecoder(referencing: invalidTopContainer, codingPath: [], wrapping: .single(.init(s: "foo")))
        XCTAssertNil(invalidUnkeyed.count)
    }

    func testUnkeyedDecoder() throws {
//        let input: [Any] = [
//            "foo",
//            false,
//            1,
//            3.0,
//            Float(exactly: 13.0)!,
//            Int8(exactly: 8.0)!,
//            Int16(exactly: 16.0)!,
//            Int32(exactly: 32.0)!,
//            Int64(exactly: 64.0)!,
//            UInt(exactly: 1.0)!,
//            UInt8(exactly: 8.0)!,
//            UInt16(exactly: 16.0)!,
//            UInt32(exactly: 32.0)!,
//            UInt64(exactly: 64.0)!,
//            ["foo": 1, "bar": 2],
//            ["foo": ["bing": "bam"], "bar": ["baz": "boom"]]
//        ]
//
//        do {
//            let topDecoder = _DynamoDecoder(referencing: input)
//            var unkeyedDecoder = try topDecoder.unkeyedContainer() as! DynamoUnkeyedDecoder
//            XCTAssertEqual(try unkeyedDecoder.decode(String.self), "foo")
//            XCTAssertEqual(try unkeyedDecoder.decode(Bool.self), false)
//            XCTAssertEqual(try unkeyedDecoder.decode(Int.self), 1)
//            XCTAssertEqual(try unkeyedDecoder.decode(Double.self), 3.0)
//            XCTAssertEqual(try unkeyedDecoder.decode(Float.self), 13.0)
//            XCTAssertEqual(try unkeyedDecoder.decode(Int8.self), 8)
//            XCTAssertEqual(try unkeyedDecoder.decode(Int16.self), 16)
//            XCTAssertEqual(try unkeyedDecoder.decode(Int32.self), 32)
//            XCTAssertEqual(try unkeyedDecoder.decode(Int64.self), 64)
//            XCTAssertEqual(try unkeyedDecoder.decode(UInt.self), 1)
//            XCTAssertEqual(try unkeyedDecoder.decode(UInt8.self), 8)
//            XCTAssertEqual(try unkeyedDecoder.decode(UInt16.self), 16)
//            XCTAssertEqual(try unkeyedDecoder.decode(UInt32.self), 32)
//            XCTAssertEqual(try unkeyedDecoder.decode(UInt64.self), 64)
//            XCTAssertEqual(try unkeyedDecoder.decode([String: Int].self), ["foo": 1, "bar": 2])
//            XCTAssertEqual(try unkeyedDecoder.decode([String: [String: String]].self), ["foo": ["bing": "bam"], "bar": ["baz": "boom"]])
//            // throws when done decoding all it's items.
//            XCTAssertThrowsError(try unkeyedDecoder.decode(String.self))
//
//            XCTAssertNotNil(try! unkeyedDecoder.superDecoder() as? _DynamoDecoder)
//
//        }
//        catch {
//            print("error: \(error)")
//            throw error
//        }

    }

    func testUnkeyedContainerDecodeNil() throws {
//        let optionalStrings: [Any?] = ["Foo", nil, NSNull()]
//        var unkeyed2 = try _DynamoDecoder(referencing: optionalStrings).unkeyedContainer()
//        XCTAssertNotNil(try unkeyed2.decode(String?.self))
//        XCTAssertNil(try unkeyed2.decode(String?.self))
//        XCTAssertNil(try unkeyed2.decode(String?.self))
//
//        var unkeyed3 = try _DynamoDecoder(referencing: optionalStrings).unkeyedContainer()
//        XCTAssertFalse(try unkeyed3.decodeNil())
//        _ = try unkeyed3.decode(String?.self)
//        XCTAssert(try unkeyed3.decodeNil())
//        XCTAssert(try unkeyed3.decodeNil())
//        XCTAssertThrowsError(try unkeyed3.decodeNil())
    }

    func testUnkeyedDecoderNestedKeyedContainer() throws {
//        let data: [Any] = [
//            ["foo": "bar"],
//            "foo"
//        ]
//        var unkeyed = try _DynamoDecoder(referencing: data).unkeyedContainer()
//        _ = try unkeyed.nestedContainer(keyedBy: DynamoCodingKey.self)
//        // error because next type is a string not a dictionary.
//        XCTAssertThrowsError(try unkeyed.nestedContainer(keyedBy: DynamoCodingKey.self))
//        _ = try unkeyed.decode(String.self)
//        // error because we're out of range.
//        XCTAssertThrowsError(try unkeyed.nestedContainer(keyedBy: DynamoCodingKey.self))

    }

    func testUnkeyedDecoderNestedUnKeyedContainer() throws {
//        let data: [Any] = [
//            ["foo", "bar"],
//            "foo"
//        ]
//        var unkeyed = try _DynamoDecoder(referencing: data).unkeyedContainer()
//        _ = try unkeyed.nestedUnkeyedContainer()
//        // error because next type is a string not a dictionary.
//        XCTAssertThrowsError(try unkeyed.nestedUnkeyedContainer())
//        _ = try unkeyed.decode(String.self)
//        // error because we're out of range.
//        XCTAssertThrowsError(try unkeyed.nestedUnkeyedContainer())

    }

    func testKeyedDecoderNestedKeyedContainer() throws {
//        let data: [String: Any] = [
//            "foo": ["bar", "baz"],
//            "bing": "boom"
//        ]
//        let keyed = try _DynamoDecoder(referencing: data).container(keyedBy: DynamoCodingKey.self)
//        _ = try keyed.nestedUnkeyedContainer(forKey: .string("foo"))
//        XCTAssertThrowsError(try keyed.nestedUnkeyedContainer(forKey: .string("bing")))
//        XCTAssertThrowsError(try keyed.nestedUnkeyedContainer(forKey: .string("invalid")))
    }

    func testKeyedDecoderNestedUnKeyedContainer() throws {
//        let data: [String: Any] = [
//            "foo": ["bar": "baz"],
//            "bing": "boom"
//        ]
//        let keyed = try _DynamoDecoder(referencing: data).container(keyedBy: DynamoCodingKey.self)
//        _ = try keyed.nestedContainer(keyedBy: DynamoCodingKey.self, forKey: .string("foo"))
//        XCTAssertThrowsError(try keyed.nestedContainer(keyedBy: DynamoCodingKey.self, forKey: .string("bing")))
//        XCTAssertThrowsError(try keyed.nestedContainer(keyedBy: DynamoCodingKey.self, forKey: .string("invalid")))
//
//        XCTAssertNotNil(try keyed.superDecoder() as? _DynamoDecoder)
//        XCTAssertNotNil(try keyed.superDecoder(forKey: .string("foo")) as? _DynamoDecoder)
    }

    func testDecodeData() throws {
        struct Simple: Codable, Equatable {
            let string = "foo"
            let int = 1
            let double = 20.05
            let optionalString: String? = "some"
            let optionalNil: String? = nil
            let bool = true
            let int8 = Int8(exactly: 8.0)!
            let int16 = Int16(exactly: 16.0)!
            let int32 = Int32(exactly: 32.0)!
            let int64 = Int64(exactly: 64.0)!
            let uInt = UInt(exactly: 1.0)!
            let uInt8 = UInt8(exactly: 8.0)!
            let uInt16 = UInt16(exactly: 16.0)!
            let uInt32 = UInt32(exactly: 32.0)!
            let uInt64 = UInt64(exactly: 64.0)!
            let float = Float(exactly: 10.0)!
            let dict: [String: Int] = ["foo": 1, "bar": 2]
        }

        let encoded = try DynamoEncoder().encode(Simple())
        let decoded = try decoder.decode(Simple.self, from: encoded)
        XCTAssertEqual(decoded, Simple())

        let arrayEncoded = try DynamoEncoder().encode([Simple(), Simple(), Simple()])
        let decodedArray = try decoder.decode([Simple].self, from: arrayEncoded)
        XCTAssertEqual(decodedArray, [Simple(), Simple(), Simple()])

//        let simpleData = try DynamoEncoder().encode(1, as: DynamoDB.AttributeValue.self)
//        XCTAssertEqual(try DynamoDecoder().decode(Int.self, from: simpleData), 1)
    }

    func testDecodingListOfEncodables() throws {
        struct Name: Codable {
            let first: String = "foo"
            let last: String = "bar"
        }

        let encoded = try DynamoEncoder().encode([Name(), Name()])
        let decoded = try decoder.decode([Name].self, from: encoded)
        XCTAssertEqual(decoded.count, 2)

        struct Person: Codable {
            let names: [Name] = [Name(), Name()]
        }

        let pencoded = try DynamoEncoder().encode(Person())
        let pdecodded = try decoder.decode(Person.self, from: pencoded)
        XCTAssertEqual(pdecodded.names.count, 2)
//
//        let converted = try DynamoConverter().convert(Person())
//        let cDecoded = try DynamoDecoder().decode(Person.self, from: converted)
//        XCTAssertEqual(cDecoded.names.count, 2)
    }

    func testAssertTopContainer() {
        let invalidSingleDecoder = _DynamoDecoder(referencing: .keyed(.init()))
        XCTAssertThrowsError(try invalidSingleDecoder.assertTopContainer())
        XCTAssertFalse(invalidSingleDecoder.decodeNil())
    }

    func testInvalidTopContainerThrowsError() {
        let invalidKeyedContainer = _DynamoDecoder(referencing: .unkeyed([]))
        XCTAssertThrowsError(try invalidKeyedContainer.container(keyedBy: DynamoCodingKey.self))

        let invalidUnkeyedContainer = _DynamoDecoder(referencing: .keyed(.init()))
        XCTAssertThrowsError(try invalidUnkeyedContainer.unkeyedContainer())
    }
}
