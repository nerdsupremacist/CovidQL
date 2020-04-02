
import Foundation
import GraphZahl

struct ImageURL {
    let url: URL
}

extension ImageURL: GraphQLScalar {

    init(scalar: ScalarValue) throws {
        guard let url = URL(string: try scalar.string()) else {
            throw ScalarTypeError.valueFailedInnerTypeConstraints(scalar, forType: ImageURL.self)
        }

        self.url = url
    }

    func encodeScalar() throws -> ScalarValue {
        return .string(url.absoluteString)
    }

}

extension ImageURL: Decodable {

    init(from decoder: Decoder) throws {
        let string = try String(from: decoder)
        guard let url = URL(string: string.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed.union(.urlHostAllowed).union(.urlQueryAllowed)) ?? string) else {
            throw Client.Error.failedDecoding
        }
        self.url = url
    }

}
