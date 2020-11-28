
import Foundation
import GraphZahl
import NIO

class Continent: Affected, Identifiable {
    private enum CodingKeys: String, CodingKey {
        case name = "continent"
    }

    static func identifiers(client: Client) -> EventLoopFuture<Set<String>> {
        return client.continents().map { Set($0.map { $0.name }) }
    }

    let name: String

    var identifier: Identifier<Continent> {
        return Identifier(rawValue: name)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        try super.init(from: decoder)
    }

    func details(client: Client) -> EventLoopFuture<DetailedContinent> {
        return client.continent(identifier: identifier)
    }
}

class DetailedContinent: Continent {
    private enum CodingKeys: String, CodingKey {
        case countryIdentifiers = "countries"
    }

    let countryIdentifiers: [Identifier<Country>]

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.countryIdentifiers = try container.decode([Identifier<Country>].self, forKey: .countryIdentifiers)
        try super.init(from: decoder)
    }

    func countries(client: Client) throws -> EventLoopFuture<PagingArray<Country>> {
        return client.countries(identifiers: countryIdentifiers).map { PagingArray(values: $0) }
    }
}
