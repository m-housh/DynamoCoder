//
//  MetaTypes.swift
//  
//
//  Created by Michael Housh on 1/27/20.
//

import Foundation
import DynamoDB

public typealias DynamoAttributeDict = [String: DynamoDB.AttributeValue]
public typealias DynamoEncodedArray = [DynamoAttributeDict]

protocol OptionalType {
    var isNil: Bool { get }
}

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
