//
//  File.swift
//  
//
//  Created by Michael Housh on 1/27/20.
//

import Foundation
import DynamoDB

public typealias DynamoAttributeDict = [String: DynamoDB.AttributeValue]
public typealias DynamoEncodedArray = [DynamoAttributeDict]

/// A namespace for number types that we can encode / decode.
protocol DynamoNumber {

    init?(_ string: String)
}

protocol OptionalType {
    var isNil: Bool { get }
}

extension Double: DynamoNumber { }
extension Float: DynamoNumber { }
extension Int: DynamoNumber { }
extension Int8: DynamoNumber { }
extension Int16: DynamoNumber { }
extension Int32: DynamoNumber { }
extension Int64: DynamoNumber { }
extension UInt: DynamoNumber { }
extension UInt8: DynamoNumber { }
extension UInt16: DynamoNumber { }
extension UInt32: DynamoNumber { }
extension UInt64: DynamoNumber { }

extension Optional: OptionalType {

    var isNil: Bool {
        switch self {
        case .none: return true
        case let .some(wrapped):
            if let optional = wrapped as? OptionalType {
                return optional.isNil
            }
            return false
        }
    }
}
