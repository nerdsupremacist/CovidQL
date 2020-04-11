
import Foundation
import GraphZahl

@propertyWrapper
struct EmptyStringIsNil<Value: Decodable> : Decodable {
    var wrappedValue: Value?

    init(from decoder: Decoder) throws {
        let string = try Optional<String>(from: decoder)
        if string == "" {
            wrappedValue = nil
        } else {
            wrappedValue = try Optional<Value>(from: decoder)
        }
    }
}
