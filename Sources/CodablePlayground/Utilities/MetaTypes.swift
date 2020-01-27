//
//  File.swift
//  
//
//  Created by Michael Housh on 1/27/20.
//

import Foundation

/// A namespace for number types that we can encode / decode.
protocol DynamoNumber { }

protocol OptionalType {
    var isNil: Bool { get }
}

extension Double: DynamoNumber { }
extension Float: DynamoNumber { }
extension Decimal: DynamoNumber { }
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