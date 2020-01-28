//
//  File.swift
//  
//
//  Created by Michael Housh on 1/27/20.
//

import Foundation

/// Used for `superEncoder` operations.
class DynamoReferencingEncoder: _DynamoEncoder {

    // The type of container we are referencing.
    private enum Reference {
        case unkeyed(SharedBox<UnkeyedBox>, Int)
        case keyed(SharedBox<KeyedBox>, String)
    }

    // the encoder that we're referencing.
    let encoder: _DynamoEncoder

    private let reference: Reference

    // Initialize referencing an array container.
    init(
        referencing encoder: _DynamoEncoder,
        at index: Int,
        wrapping container: SharedBox<UnkeyedBox>)
    {
        self.encoder = encoder
        self.reference = .unkeyed(container, index)
        super.init(codingPath: encoder.codingPath)

        codingPath.append(DynamoCodingKey(int: index))
    }

    // Initialize referenciing a keyed container
    init(
        referencing encoder: _DynamoEncoder,
        key: CodingKey,
        wrapping container: SharedBox<KeyedBox>)
    {
        self.encoder = encoder
        self.reference = .keyed(container, key.stringValue)
        super.init(codingPath: encoder.codingPath)

        codingPath.append(key)
    }

    override var canEncodeNewValue: Bool {
        // With a regular encoder, the storage and coding path grow together.
        // A referencing encoder, however, inherits its parents coding path, as well as the key it was created for.
        // We have to take this into account.
        return storage.count == codingPath.count - encoder.codingPath.count - 1
    }

    // MARK: - Deinitialization
    // Finalizes `self` by writing the contents of our storage to the referenced encoder's storage.
    deinit {
        let box: Box
        switch self.storage.count {
        case 0: box = KeyedBox()
        case 1: box = self.storage.popContainer()
        default: fatalError("Referencing encoder deallocated with multiple containers on stack.")
        }

        switch self.reference {
        case let .unkeyed(sharedUnkeyedBox, index):
            sharedUnkeyedBox.withShared { unkeyedBox in
                unkeyedBox.insert(box, at: index)
            }
        case let .keyed(sharedKeyedBox, key):
            sharedKeyedBox.withShared { keyedBox in
                keyedBox[key] = box
            }
        }
    }
}
