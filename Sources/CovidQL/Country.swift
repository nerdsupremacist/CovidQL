
import Foundation
import GraphZahl
import NIO

class Country: Decodable, GraphQLObject {
    class Info: Decodable, GraphQLObject {
        enum CodingKeys: String, CodingKey {
            case iso2, iso3, flag
            case latitude = "lat"
            case longitude = "long"
        }

        let iso2: String?
        let iso3: String?
        let flag: ImageURL
        let latitude: Double?
        let longitude: Double?
    }

    enum CodingKeys: String, CodingKey {
        case name = "country"
        case info = "countryInfo"
        case cases
        case todayCases
        case deaths
        case todayDeaths
        case recovered
        case active
        case critical
        case casesPerOneMillion
        case deathsPerOneMillion
        case updated
    }

    let name: String
    let info: Info
    let cases: Int
    let todayCases: Int
    let deaths: Int
    let todayDeaths: Int
    let recovered: Int
    let active: Int
    let critical: Int
    let casesPerOneMillion: Double?
    let deathsPerOneMillion: Double?
    let updated: Timestamp

    func timeline(client: Client) throws -> EventLoopFuture<Timeline> {
        return client.timeline(for: name).map { $0.timeline }
    }

    func news(client: Client) -> EventLoopFuture<[NewsStory]> {
        return client.stories(country: info.iso2 ?? name).map { $0.articles }
    }
}
