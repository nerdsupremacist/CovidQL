
import Foundation
import GraphZahl
import NIO

class World: DetailedAffected {
    private enum CodingKeys: String, CodingKey {
        case affectedCountries
    }

    let affectedCountries: Int

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.affectedCountries = try container.decode(Int.self, forKey: .affectedCountries)
        try super.init(from: decoder)
    }

    func timeline(client: Client) throws -> EventLoopFuture<Timeline> {
        return client.timeline()
    }

    func news(client: Client) -> EventLoopFuture<[NewsStory]> {
        return client.stories().map { $0.articles }
    }
}
