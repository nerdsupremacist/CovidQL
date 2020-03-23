

import Foundation
import GraphZahl

private let dateFormatter = ISO8601DateFormatter()

extension Date: GraphQLScalar {
    public init(scalar: ScalarValue) throws {
        guard let date = dateFormatter.date(from: try scalar.string()) else {
            throw ScalarTypeError.valueFailedInnerTypeConstraints(scalar, forType: Date.self)
        }
        self = date
    }

    public func encodeScalar() throws -> ScalarValue {
        return try dateFormatter.string(from: self).encodeScalar()
    }
}
