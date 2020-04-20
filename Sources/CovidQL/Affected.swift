
import Foundation
import NIO
import GraphZahl

class Affected: Decodable, GraphQLObject {
    let cases: Int
    let todayCases: Int
    let deaths: Int
    let todayDeaths: Int
    let recovered: Int
    let active: Int
    let critical: Int

    let updated: Timestamp
}

class DetailedAffected: Affected {
    private enum CodingKeys: String, CodingKey {
        case tests
        case casesPerOneMillion
        case deathsPerOneMillion
        case testsPerOneMillion
    }

    let tests: Int
    let casesPerOneMillion: Double?
    let deathsPerOneMillion: Double?
    let testsPerOneMillion: Double?

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.tests = try container.decode(Int.self, forKey: .tests)
        self.casesPerOneMillion = try container.decode(Double?.self, forKey: .casesPerOneMillion)
        self.deathsPerOneMillion = try container.decode(Double?.self, forKey: .deathsPerOneMillion)
        self.testsPerOneMillion =  try container.decode(Double?.self, forKey: .testsPerOneMillion)
        try super.init(from: decoder)
    }
}
