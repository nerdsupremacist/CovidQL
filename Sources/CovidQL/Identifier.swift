
import Foundation
import NIO
import GraphZahl

protocol Identifiable: ConcreteResolvable {
    static func identifiers(client: Client) -> EventLoopFuture<Set<String>>
}

struct Identifier<Value: Identifiable>: RawRepresentable, Hashable, Codable {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension Identifier: GraphQLEnum {

    static var concreteTypeName: String {
        return Value.concreteTypeName + "Identifier"
    }

    static func cases(using context: inout Resolution.Context) throws -> [String : Identifier<Value>] {
        let identifiers = try Value.identifiers(client: try context.viewerContext()).wait()
        return Dictionary(uniqueKeysWithValues: identifiers.map { ($0.folding(options: .diacriticInsensitive, locale: .current), Identifier(rawValue: $0)) })
    }

}
