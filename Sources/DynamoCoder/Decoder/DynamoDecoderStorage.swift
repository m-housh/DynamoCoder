//
//  File.swift
//  
//
//  Created by Michael Housh on 1/27/20.
//

import Foundation

struct DynamoDecoderStorage {

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
        return containers.popLast()
    }
}
