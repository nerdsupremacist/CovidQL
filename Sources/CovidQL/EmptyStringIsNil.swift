
import Foundation
import GraphZahl
import GraphQL
import ContextKit
import NIO

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

extension EmptyStringIsNil: Resolvable where Value: Resolvable { }

extension EmptyStringIsNil: OutputResolvable where Value: OutputResolvable { }

extension EmptyStringIsNil: DelegatedOutputResolvable where Value: OutputResolvable {
    func resolve(source: Any, arguments: [String : Map], context: MutableContext, eventLoop: EventLoopGroup) throws -> some OutputResolvable {
        return wrappedValue
    }
}
