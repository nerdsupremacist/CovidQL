
import Foundation
import Vapor

class Client {
    enum Error: Swift.Error {
        case emptyResponse
        case failedDecoding
    }

    private let ipAddress: String?
    private let covidBase: String
    private let ipAPIBase: String
    private let httpClient: HTTPClient

    var eventLoop: EventLoopGroup {
        return httpClient.eventLoopGroup
    }

    init(ipAddress: String?, covidBase: String, ipAPIBase: String, httpClient: HTTPClient) {
        self.ipAddress = ipAddress
        self.covidBase = covidBase
        self.ipAPIBase = ipAPIBase
        self.httpClient = httpClient
    }

    deinit {
        try! httpClient.syncShutdown()
    }

    func all() -> EventLoopFuture<World> {
        return httpClient.get(url: "\(covidBase)/all").decode()
    }

    func countries() -> EventLoopFuture<[Country]> {
        return httpClient.get(url: "\(covidBase)/countries").decode()
    }

    func myCountry() -> EventLoopFuture<String?> {
        guard let ipAddress = ipAddress else { return httpClient.eventLoopGroup.future(nil) }
        return httpClient.get(url: "\(ipAPIBase)/\(ipAddress)/country/").flatMapThrowing { response in
            guard let buffer = response.body else {
                throw Client.Error.emptyResponse
            }

            let length = buffer.readableBytes
            return buffer.getString(at: 0, length: length)
        }
    }

    func country(name: String) -> EventLoopFuture<Country?> {
        return httpClient.get(url: "\(covidBase)/countries/\(name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)").decodeOptional()
    }

    func historicalData() -> EventLoopFuture<[HistoricalData]> {
        return httpClient.get(url: "\(covidBase)/v2/historical").decode()
    }

    func timeline() -> EventLoopFuture<Timeline> {
        return httpClient.get(url: "\(covidBase)/v2/historical/all").decode()
    }

    func timeline(for name: String) -> EventLoopFuture<TimelineWrapper> {
        return httpClient.get(url: "\(covidBase)/v2/historical/\(name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)").decode()
    }
}

extension EventLoopFuture where Value == HTTPClient.Response {

    func decodeOptional<T: Decodable>() -> EventLoopFuture<T?> {
        return decode(type: T?.self).flatMapErrorThrowing { _ in nil }
    }

    func decode<T: Decodable>(type: T.Type = T.self) -> EventLoopFuture<T> {
        return flatMapThrowing { response in
            guard let buffer = response.body else {
                throw Client.Error.emptyResponse
            }

            let length = buffer.readableBytes
            guard let data = try buffer.getJSONDecodable(type, at: 0, length: length) else {
                throw Client.Error.failedDecoding
            }

            return data
        }
    }

}
