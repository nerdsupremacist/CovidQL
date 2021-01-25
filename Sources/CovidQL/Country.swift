
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

        var emoji: String? {
            return iso2.map { iso2 in
                return iso2.uppercased().unicodeScalars.reduce("") { result, item in
                    guard let scalar = UnicodeScalar(127397 + item.value) else {
                        return result
                    }
                    return result + String(scalar)
                }
            }
        }
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

    func place(client: Client) -> EventLoopFuture<Int> {
        return client
            .countries()
            .map { $0.filter { $0.info.latitude != 0 || $0.info.longitude != 0 }.sorted { $0.cases > $1.cases } }
            .map { $0.firstIndex { $0.identifier == self.identifier } ?? $0.count }
            .map { $0 + 1 }
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

    func geometry(client: Client) -> EventLoopFuture<GeographicalGeometry?> {
        guard let iso3 = info.iso3 else { return client.eventLoop.future(nil) }
        return client.geometry(for: iso3)
    }
}
