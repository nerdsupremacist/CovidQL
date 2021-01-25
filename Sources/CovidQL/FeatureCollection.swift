
import Foundation
import GraphZahl

final class Coordinates: GraphQLObject, Decodable {
    let longitude: Double
    let latitude: Double

    required init(from decoder: Decoder) throws {
        let values = try Array<Double>(from: decoder)
        assert(values.count == 2)
        longitude = values[0]
        latitude = values[1]
    }
}

final class Polygon: GraphQLObject, Decodable {
    let points: [Coordinates]

    init(from decoder: Decoder) throws {
        points = try Array<Array<Coordinates>>(from: decoder).flatMap { $0 }
    }
}

final class MultiPolygon: GraphQLObject, Decodable {
    let polygons: [Polygon]

    init(from decoder: Decoder) throws {
        polygons = try Array<Polygon>(from: decoder)
    }
}

enum GeographicalGeometry: GraphQLUnion, Decodable {
    enum Kind: String, Decodable {
        case polygon = "Polygon"
        case multiPolygon = "MultiPolygon"
    }

    enum CodingKeys: String, CodingKey {
        case type
        case coordinates
    }

    case polygon(Polygon)
    case multiPolygon(MultiPolygon)

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .type)
        switch kind {
        case .polygon:
            self = .polygon(try container.decode(Polygon.self, forKey: .coordinates))
        case .multiPolygon:
            self = .multiPolygon(try container.decode(MultiPolygon.self, forKey: .coordinates))
        }
    }
}

struct FeatureCollection: Decodable {
    enum CodingKeys: String, CodingKey {
        case features
        case id
        case geometry
    }

    let countries: [String : GeographicalGeometry]

    init(from decoder: Decoder) throws {
        var countries = [String : GeographicalGeometry]()

        let container = try decoder.container(keyedBy: CodingKeys.self)
        var features = try container.nestedUnkeyedContainer(forKey: .features)

        while !features.isAtEnd {
            let nestedContainer = try features.nestedContainer(keyedBy: CodingKeys.self)
            let id = try nestedContainer.decode(String.self, forKey: .id)
            let geometry = try nestedContainer.decode(GeographicalGeometry.self, forKey: .geometry)
            countries[id] = geometry
        }

        self.countries = countries
    }
}
