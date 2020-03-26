
import Foundation
import GraphZahl
import NIO

class Country: Decodable, GraphQLObject {
    class Info: Decodable, GraphQLObject {
        let iso2: String?
        let iso3: String?
        let flag: ImageURL
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

    func timeline(client: Client) throws -> EventLoopFuture<Timeline> {
        return client.timeline(for: name).map { $0.timeline }
    }
}
