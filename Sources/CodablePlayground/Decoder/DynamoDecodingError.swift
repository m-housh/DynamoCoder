//
//  File.swift
//  
//
//  Created by Michael Housh on 1/27/20.
//

import Foundation

public enum DynamoDecodingError: Error {

    case typeMismatch(codingPath: [CodingKey], expected: Any.Type, reality: Any?)
    case notFound
}
