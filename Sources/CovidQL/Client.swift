
import Foundation
import Vapor

class Client {
    enum Error: Swift.Error {
        case emptyResponse
        case failedDecoding
    }

    private let base: String
    private let httpClient: HTTPClient

    init(base: String, httpClient: HTTPClient) {
        self.base = base
        self.httpClient = httpClient
    }

    deinit {
        try! httpClient.syncShutdown()
    }

    func all() -> EventLoopFuture<CurrentState> {
        return httpClient.get(url: "\(base)/all").decode()
    }

    func countries() -> EventLoopFuture<[Country]> {
        return httpClient.get(url: "\(base)/countries").decode()
    }

    func country(name: String) -> EventLoopFuture<Country?> {
        return httpClient.get(url: "\(base)/countries/\(name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)").decodeOptional()
    }

    func historicalData() -> EventLoopFuture<[HistoricalData]> {
        return httpClient.get(url: "\(base)/v2/historical").decode()
    }

    func timeline(for name: String) -> EventLoopFuture<TimelineWrapper> {
        return httpClient.get(url: "\(base)/v2/historical/\(name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)").decode()
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
