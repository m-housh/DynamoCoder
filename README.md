# DynamoCoder

![MacOS](https://github.com/m-housh/DynamoCoder/workflows/MacOS/badge.svg?branch=master)
[![codecov](https://codecov.io/gh/m-housh/DynamoCoder/branch/master/graph/badge.svg)](https://codecov.io/gh/m-housh/DynamoCoder)

A custom encoder / decoder for `DynamoDB` attribute types.

This will allow you to convert `Encodable` types to appropriate values appropriate for passing data into `DynamoDB`.  Most encodables
will get converted to `[String: DynamoDB.AttributeValue]` which is typealiased to `DynamoAttributeDict`.  The encoder can
also encode lists of encodables to `[[String: DynamoDB.AttributeValue]]` which is typealiased to `DynamoEcodedArray`.  Or encode a single value as `DynamoDB.AttributeValue`.

The decoder is meant to do the same, however it should decode most `Decodable` types appropriately even if they were encoded by
a different encoder.

## Usage

```swift

import DynamoCoder

struct Person: Codable, Equatable {

    struct Name: Codable, Equatable {
        let first: String
        let last: String
    }
    
    var name: Name
    var age: Int
    var height: Double
}

let andrew = Person(name: Name(first: "Andrew", last: "Jackson"), age: 30, height: 72.5)

// Encode as a `DynamoAttributeDict`.
let encoded = try DynamoEncoder().encode(andrew)

/* encoded to.
[
    "name": DynamoDB.AttributeValue(m: ["first": DynamoDB.AttributeValue(s: "Andrew"),
                                        "last": DynamoDB.AttributeValue(s: "Jackson")]),
    "age": DynamoDB.AttributeValue(n: "30"),
    "height": DynamoDB.AttributeValue(n: "72.5")
]
*/

let decoded = try DynamoDecoder().decode(Person.self, from: encoded)
assert(decoded == andrew) // true

```

When encoding an array of encodables or if you want to encode a single value then you need to pass the type when encoding.

```swift

// An array of encoded Andrew's.
let arrayEncoded = try DynamoEncoder().encode([andrew, andrew, andrew], as: DynamoEncodedArray.self)
let arrayDecoded = try DynamoDecoder().decode([Person].self, from: encoded)

// Encode a single item into a `DynamoDB.AttributeValue`
let attribute = try DynamoEncoder().encode("foo", as: DynamoDB.AttributeValue.self)
// DynamoDB.AttributeValue(s: "foo")

let decodedAttribute = try DynamoDecoder().decode(String.self, from: attribute)
assert(decodedAttribute == "foo")
```
