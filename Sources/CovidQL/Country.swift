
import Foundation
import GraphZahl
import NIO

class Country: DetailedAffected, Identifiable {
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

    private enum CodingKeys: String, CodingKey {
        case name = "country"
        case info = "countryInfo"
        case continentIdentifier = "continent"
    }

    static func identifiers(client: Client) -> EventLoopFuture<Set<String>> {
        return client.countries().map { Set($0.map { $0.name }) }
    }

    let name: String
    let info: Info
    let continentIdentifier: Identifier<Continent>

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.info = try container.decode(Info.self, forKey: .info)
        self.continentIdentifier = try container.decode(Identifier<Continent>.self, forKey: .continentIdentifier)
        try super.init(from: decoder)
    }

    var identifier: Identifier<Country> {
        return Identifier(rawValue: name)
    }

    func continent(client: Client) -> EventLoopFuture<DetailedContinent> {
        return client.continent(identifier: continentIdentifier)
    }

    func timeline(client: Client) throws -> EventLoopFuture<Timeline> {
        return client.timeline(for: identifier).map { $0.timeline }
    }

    func news(client: Client) -> EventLoopFuture<[NewsStory]> {
        return client.stories(country: info.iso2 ?? name).map { $0.articles }
    }
}
