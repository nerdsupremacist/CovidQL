
import Foundation
import GraphZahl

@propertyWrapper
struct CustomURL: Decodable {
    var wrappedValue: URL

    init(from decoder: Decoder) throws {
        let string = try String(from: decoder)
        guard let url = URL(string: string.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed.union(.urlHostAllowed).union(.urlQueryAllowed)) ?? string) else {
            throw Client.Error.failedDecoding
        }
        self.wrappedValue = url
    }
}

extension CustomURL: GraphQLScalar {
    static var concreteTypeName: String {
        return "URL"
    }

    public init(scalar: ScalarValue) throws {
        // attempt to read a string and read a url from it
        let string = try scalar.string()
        guard let url = URL(string: string.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed.union(.urlHostAllowed).union(.urlQueryAllowed)) ?? string) else {
            throw Client.Error.failedDecoding
        }
        self.wrappedValue = url
    }

    public func encodeScalar() throws -> ScalarValue {
        // delegate encoding to absolute string
        return try wrappedValue.absoluteString.encodeScalar()
    }
}
