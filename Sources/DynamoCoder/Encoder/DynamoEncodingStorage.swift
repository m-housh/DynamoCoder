//
//  DynamoEncodingStorage.swift
//  
//
//  Created by Michael Housh on 1/27/20.
//

import Foundation

struct DynamoEncodingStorage {

    private(set) var containers: [EncodedAttributeContainer] = []

    init() { }

    // used for key/value pairs.
    mutating func pushKeyedContainer() -> KeyedAttributeContainer {
        let container = KeyedAttributeContainer()
//        let container = EncodedAttributeContainer.keyed(KeyedAttributeContainer())
        containers.append(EncodedAttributeContainer.keyed(container))
        return container
    }

    // used for an array or unkeyed container.
    mutating func pushUnkeyedContainer() -> UnkeyedAttributeContainer {
        let container = UnkeyedAttributeContainer()
//        let container = EncodedAttributeContainer.unkeyed(UnkeyedAttributeContainer())
        containers.append(EncodedAttributeContainer.unkeyed(container))
        return container
    }

    // used when at single value level.
    mutating func push(_ container: EncodedAttributeContainer) {
        containers.append(container)
    }

    var count: Int { containers.count }

    var topContainer: EncodedAttributeContainer? { containers.last }

    @discardableResult
    mutating func popContainer() -> EncodedAttributeContainer {
        precondition(!containers.isEmpty,
                     "Empty stack!")
        return containers.popLast()!
    }
}
