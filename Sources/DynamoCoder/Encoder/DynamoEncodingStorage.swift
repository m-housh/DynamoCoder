//
//  DynamoEncodingStorage.swift
//  
//
//  Created by Michael Housh on 1/27/20.
//

import Foundation

struct DynamoEncodingStorage {

    var containers: [Box] = []

    mutating func pushKeyedContainer(_ keyedBox: KeyedBox = KeyedBox()) -> SharedBox<KeyedBox> {
        let container = SharedBox(keyedBox)
        containers.append(container)
        return container
    }

    mutating func pushUnkeyedContainer() -> SharedBox<UnkeyedBox> {
        let container = SharedBox(UnkeyedBox())
        containers.append(container)
        return container
    }

    mutating func push(_ container: Box) {
        if let keyed = container as? KeyedBox {
            containers.append(SharedBox(keyed))
        }
        else if let unkeyed = container as? UnkeyedBox {
            containers.append(SharedBox(unkeyed))
        }
        else {
            containers.append(container)
        }
    }

    mutating func popContainer() -> Box {
        precondition(
            !containers.isEmpty,
            "Attempting to pop container on empty stack!"
        )
        return containers.popLast()!
    }

    var topContainer: Box? {
        containers.last
    }

    var count: Int { containers.count }
}
