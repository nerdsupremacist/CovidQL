
import Foundation
import NIO
import GraphZahl

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yy"
    return dateFormatter
}()

class Timeline: Decodable, GraphQLObject {
    fileprivate struct SingleDataPoint {
        let date: Date
        let value: Int

        init(key: String, value: Int) {
            date = dateFormatter.date(from: key)!
            self.value = value
        }
    }

    class DataPoint: NSObject, GraphQLObject {
        let date: Date
        let value: Int
        let change: Int

        fileprivate init(current: SingleDataPoint, previous: SingleDataPoint?) {
            self.date = current.date
            self.value = current.value
            self.change = current.value - (previous?.value ?? 0)

            super.init()
        }
    }

    class DataPointsCollection: GraphQLObject {
        let connection: PagingArray<DataPoint>

        init(values: [DataPoint]) {
            self.connection = PagingArray(values: values)
        }

        func graph(numberOfPoints: Int = 30) -> [DataPoint] {
            guard numberOfPoints > 0 else { return [] }
            let values = connection.values
            let distanceBetweenPoints = Int(ceil(Double(values.count) / Double(numberOfPoints)))
            return values.indices.filter { (values.count - $0 - 1) % distanceBetweenPoints == 0 }.map { values[$0] }
        }
    }

    enum CodingKeys: String, CodingKey {
        case cases
        case deaths
        case recovered
    }

    let cases: DataPointsCollection
    let deaths: DataPointsCollection
    let recovered: DataPointsCollection

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.cases = try container.decodeDataPoints(forKey: .cases)
        self.deaths = try container.decodeDataPoints(forKey: .deaths)
        self.recovered = try container.decodeDataPoints(forKey: .recovered)
    }
}

extension KeyedDecodingContainer {

    fileprivate func decodeDataPoints(forKey key: K) throws -> Timeline.DataPointsCollection {
        let dictionary = try decodeIfPresent([String : IntIsh].self, forKey: key) ?? [:]
        let values = dictionary
            .map { Timeline.SingleDataPoint(key: $0.key, value: $0.value.value) }
            .sorted { $0.date < $1.date }
            .zipWithPrevious()
            .map { Timeline.DataPoint(current: $0.current, previous: $0.previous) }

        return Timeline.DataPointsCollection(values: values)
    }

}

extension Collection {

    func zipWithPrevious() -> [(previous: Element?, current: Element)] {
        return indices.map { index in
            let before = self.index(index, offsetBy: -1)
            if before < startIndex {
                return (nil, self[index])
            } else {
                return (self[before], self[index])
            }
        }
    }

}

class TimelineWrapper: Decodable {
    let timeline: Timeline
}

class HistoricalData: Decodable, GraphQLObject {
    enum CodingKeys: String, CodingKey {
        case countryIdentifier = "country"
        case timeline
    }

    let countryIdentifier: Identifier<Country>?

    let timeline: Timeline

    func country(client: Client) throws -> EventLoopFuture<Country> {
        guard let countryIdentifier = countryIdentifier else { throw Client.Error.emptyResponse }
        return client.country(identifier: countryIdentifier)
    }
}
