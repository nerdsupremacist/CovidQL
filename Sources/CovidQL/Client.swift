
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
        return httpClient.get(url: "\(covidBase)/v2/all").decode()
    }

    func countries() -> EventLoopFuture<[Country]> {
        return httpClient.get(url: "\(covidBase)/v2/countries").decode()
    }

    func continents() -> EventLoopFuture<[Continent]> {
        return httpClient.get(url: "\(covidBase)/v2/continents").decode()
    }

    func locateUser() -> EventLoopFuture<GeoLocated?> {
        guard let ipAddress = ipAddress else { return httpClient.eventLoopGroup.future(nil) }
        return httpClient.get(url: "\(ipAPIBase)/ipgeo?apiKey=\(ipAPIKey)&ip=\(ipAddress)").decodeOptional()
    }

    func stories() -> EventLoopFuture<News> {
        return httpClient.get(url: "\(newsBase)/top-headlines?q=corona&apiKey=\(newsAPIKey)").decode()
    }

    func stories(country: String) -> EventLoopFuture<News> {
        return httpClient.get(url: "\(newsBase)/top-headlines?q=corona&apiKey=\(newsAPIKey)&country=\(country)").decode()
    }

    func country(identifier: Identifier<Country>) -> EventLoopFuture<Country> {
        return httpClient.get(url: "\(covidBase)/v2/countries/\(identifier: identifier)").decode()
    }

    func continent(identifier: Identifier<Continent>) -> EventLoopFuture<DetailedContinent> {
        return httpClient.get(url: "\(covidBase)/v2/continents/\(identifier: identifier)").decode()
    }

    func countries(identifiers: [Identifier<Country>]) -> EventLoopFuture<[Country]> {
        if identifiers.count > 1 {
            return httpClient.get(url: "\(covidBase)/v2/countries/\(identifiers: identifiers)").decode()
        } else if let identifier = identifiers.first {
            return country(identifier: identifier).map { [$0] }
        } else {
            return eventLoop.future([])
        }
    }

    func historicalData() -> EventLoopFuture<[HistoricalData]> {
        return httpClient.get(url: "\(covidBase)/v2/historical?lastdays=all").decode()
    }

    func timeline() -> EventLoopFuture<Timeline> {
        return httpClient.get(url: "\(covidBase)/v2/historical/all?lastdays=all").decode()
    }

    func timeline<T : Identifiable>(for identifier: Identifier<T>) -> EventLoopFuture<TimelineWrapper> {
        return httpClient
            .get(url: "\(covidBase)/v2/historical/\(identifier: identifier)?lastdays=all")
            .decode()
    }
}

extension String.StringInterpolation {

    fileprivate mutating func appendInterpolation<T : Identifiable>(identifier: Identifier<T>) {
        appendInterpolation(identifier.urlSafe)
    }

    fileprivate mutating func appendInterpolation<T : Identifiable>(identifiers: [Identifier<T>]) {
        appendInterpolation(identifiers.map { $0.urlSafe }.joined(separator: ","))
    }

}

extension Identifier {

    fileprivate var urlSafe: String {
        return rawValue.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
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
