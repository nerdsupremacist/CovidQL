
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
    private let ipAPIKey: String
    private let newsBase: String
    private let newsAPIKey: String
    private let httpClient: HTTPClient

    var eventLoop: EventLoopGroup {
        return httpClient.eventLoopGroup
    }

    init(ipAddress: String?, covidBase: String, ipAPIBase: String, ipAPIKey: String, newsBase: String, newsAPIKey: String, httpClient: HTTPClient) {
        self.ipAddress = ipAddress
        self.covidBase = covidBase
        self.ipAPIBase = ipAPIBase
        self.ipAPIKey = ipAPIKey
        self.newsBase = newsBase
        self.newsAPIKey = newsAPIKey
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

    func locateUser() -> EventLoopFuture<GeoLocated?> {
        guard let ipAddress = ipAddress else { return httpClient.eventLoopGroup.future(nil) }
        print("IP Address: \(ipAddress)")
        return httpClient.get(url: "\(ipAPIBase)/ipgeo?apiKey=\(ipAPIKey)&ip=\(ipAddress)").decodeOptional()
    }

    func stories() -> EventLoopFuture<News> {
        return httpClient.get(url: "\(newsBase)/top-headlines?q=corona&apiKey=\(newsAPIKey)").decode()
    }

    func stories(country: String) -> EventLoopFuture<News> {
        return httpClient.get(url: "\(newsBase)/top-headlines?q=corona&apiKey=\(newsAPIKey)&country=\(country)").decode()
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
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return flatMapThrowing { response in
            guard let buffer = response.body else {
                throw Client.Error.emptyResponse
            }

            let length = buffer.readableBytes
            do {
                guard let data = try buffer.getJSONDecodable(type, decoder: decoder, at: 0, length: length) else {
                    throw Client.Error.failedDecoding
                }
                return data
            } catch {
                throw error
            }

        }
    }

}
