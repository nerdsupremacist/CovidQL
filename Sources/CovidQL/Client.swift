
import Foundation
import Vapor
import Cache

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
    private let cache: MemoryStorage<String, Any>?
    private let httpClient: HTTPClient

    var eventLoop: EventLoopGroup {
        return httpClient.eventLoopGroup
    }

    init(ipAddress: String?,
         covidBase: String,
         ipAPIBase: String,
         ipAPIKey: String,
         newsBase: String,
         newsAPIKey: String,
         cache: MemoryStorage<String, Any>?,
         httpClient: HTTPClient) {

        self.ipAddress = ipAddress
        self.covidBase = covidBase
        self.ipAPIBase = ipAPIBase
        self.ipAPIKey = ipAPIKey
        self.newsBase = newsBase
        self.newsAPIKey = newsAPIKey
        self.cache = cache
        self.httpClient = httpClient
    }

    deinit {
        httpClient.shutdown { [httpClient] error in
            _ = httpClient
            guard let error = error else { return }
            print("Error shutting down client \(error)")
        }
    }

    private func get<T: Decodable>(at url: String, expiry: Expiry = .never) -> EventLoopFuture<T> {
        guard let response = try? cache?.object(forKey: url) as? T else {
            return httpClient.get(url: url).decode().always { result in
                guard case .success(let response) = result else { return }
                self.cache?.setObject(response, forKey: url, expiry: expiry)
            }
        }
        return httpClient.eventLoopGroup.future(response)
    }

    private func ip<T: Decodable>(_ path: String, expiry: Expiry = .never) -> EventLoopFuture<T> {
        return get(at: "\(ipAPIBase)/\(path)", expiry: expiry)
    }

    private func covid<T: Decodable>(_ path: String, expiry: Expiry = .never) -> EventLoopFuture<T> {
        return get(at: "\(covidBase)/\(path)", expiry: expiry)
    }

    private func news<T: Decodable>(_ path: String, expiry: Expiry = .never) -> EventLoopFuture<T> {
        return get(at: "\(newsBase)/\(path)", expiry: expiry)
    }
}

extension Client {
    func all() -> EventLoopFuture<World> {
        return covid("v2/all", expiry: .hours(2))
    }

    func countries() -> EventLoopFuture<[Country]> {
        return covid("v2/countries", expiry: .hours(2))
    }

    func continents() -> EventLoopFuture<[Continent]> {
        return covid("v2/continents", expiry: .pseudoDays(1))
    }

    func locateUser() -> EventLoopFuture<GeoLocated?> {
        guard let ipAddress = ipAddress else { return httpClient.eventLoopGroup.future(nil) }
        return ip("ipgeo?apiKey=\(ipAPIKey)&ip=\(ipAddress)", expiry: .pseudoDays(7)).flatMapErrorThrowing { _ in nil }
    }

    func stories() -> EventLoopFuture<News> {
        return news("top-headlines?q=corona&apiKey=\(newsAPIKey)", expiry: .minutes(15))
    }

    func stories(country: String) -> EventLoopFuture<News> {
        return news("top-headlines?q=corona&apiKey=\(newsAPIKey)&country=\(country)", expiry: .minutes(15))
    }

    func country(identifier: Identifier<Country>) -> EventLoopFuture<Country> {
        return covid("v2/countries/\(identifier: identifier)", expiry: .hours(2))
    }

    func continent(identifier: Identifier<Continent>) -> EventLoopFuture<DetailedContinent> {
        return covid("v2/continents/\(identifier: identifier)", expiry: .pseudoDays(1))
    }

    func countries(identifiers: [Identifier<Country>]) -> EventLoopFuture<[Country]> {
        if identifiers.count > 1 {
            return covid("v2/countries/\(identifiers: identifiers)", expiry: .hours(2))
        } else if let identifier = identifiers.first {
            return country(identifier: identifier).map { [$0] }
        } else {
            return eventLoop.future([])
        }
    }

    func historicalData() -> EventLoopFuture<[HistoricalData]> {
        return covid("v2/historical?lastdays=all", expiry: .hours(2))
    }

    func timeline() -> EventLoopFuture<Timeline> {
        return covid("v2/historical/all?lastdays=all", expiry: .hours(2))
    }

    func timeline<T : Identifiable>(for identifier: Identifier<T>) -> EventLoopFuture<TimelineWrapper> {
        return covid("v2/historical/\(identifier: identifier)?lastdays=all", expiry: .hours(2))
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

    fileprivate func decode<T: Decodable>(type: T.Type = T.self) -> EventLoopFuture<T> {
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

extension Expiry {
    // Since a day is technically not a measure of time but a measure of the calendar
    static func pseudoDays(_ days: TimeInterval) -> Expiry {
        return .hours(days * 24)
    }

    static func hours(_ hr: TimeInterval) -> Expiry {
        return .minutes(hr * 60)
    }

    static func minutes(_ min: TimeInterval) -> Expiry {
        return .seconds(min * 60)
    }
}
