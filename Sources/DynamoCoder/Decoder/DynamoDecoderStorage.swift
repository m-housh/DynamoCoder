//
//  File.swift
//  
//
//  Created by Michael Housh on 1/27/20.
//

import Foundation

struct DynamoDecoderStorage {

    var containers: [Any] = []

    init() { }

    var count: Int { containers.count }

    var topContainer: Any? {
        containers.last
    }

    mutating func push(_ container: Any) {
        containers.append(container)
    }

    @discardableResult
    mutating func popContainer() -> Any? {
        guard !containers.isEmpty else { return nil }
        return containers.removeLast()
    }
}
