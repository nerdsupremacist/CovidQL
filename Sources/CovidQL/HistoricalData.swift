
import Foundation
import NIO
import GraphZahl

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yy"
    return dateFormatter
}()

class Timeline: Decodable, GraphQLObject {
    class DataPoint: GraphQLObject {
        let date: Date
        let value: Int

        init(key: String, value: Int) {
            date = dateFormatter.date(from: key)!
            self.value = value
        }
    }

    enum CodingKeys: String, CodingKey {
        case cases
        case deaths
        case recovered
    }

    let cases: [DataPoint]
    let deaths: [DataPoint]
    let recovered: [DataPoint]

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let cases = try container.decode([String : IntIsh].self, forKey: .cases)
        let deaths = try container.decode([String : IntIsh].self, forKey: .deaths)
        let recovered = try container.decode([String : IntIsh].self, forKey: .recovered)

        self.cases = cases.map { DataPoint(key: $0.key, value: $0.value.value) }
        self.deaths = deaths.map { DataPoint(key: $0.key, value: $0.value.value) }
        self.recovered = recovered.map { DataPoint(key: $0.key, value: $0.value.value) }
    }
}


class TimelineWrapper: Decodable {
    let timeline: Timeline
}

class HistoricalData: Decodable, GraphQLObject {
    @Ignore
    var country: String?

    let timeline: Timeline

    func country(client: Client) throws -> EventLoopFuture<Country> {
        guard let country = country else { throw Client.Error.emptyResponse }
        return client.country(name: country)
    }
}
