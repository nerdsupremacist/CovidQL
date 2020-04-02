
import Foundation

struct GeoLocated: Decodable {
    enum CodingKeys: String, CodingKey {
        case countryCode = "country_code2"
    }

    let countryCode: String
}
