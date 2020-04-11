
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

extension EmptyStringIsNil: OutputResolvable where Value: OutputResolvable {
    static var additionalArguments: [String : InputResolvable.Type] {
        return Value.additionalArguments
    }

    static func reference(using context: inout Resolution.Context) throws -> GraphQLOutputType {
        return try context.reference(for: Value?.self)
    }

    static func resolve(using context: inout Resolution.Context) throws -> GraphQLOutputType {
        return try context.resolve(type: Value?.self)
    }

    func resolve(source: Any, arguments: [String : Map], context: MutableContext, eventLoop: EventLoopGroup) throws -> EventLoopFuture<Any?> {
        return try wrappedValue?.resolve(source: source, arguments: arguments, context: context, eventLoop: eventLoop) ?? eventLoop.future(nil)
    }
}
