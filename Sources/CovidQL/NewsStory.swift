
import Foundation
import GraphZahl

class NewsStory: Decodable, GraphQLObject {
    let source: Source
    let title: String
    let author, overview: String?

    let url: CustomURL
    let image: ImageURL?
    let content: String?

    enum CodingKeys: String, CodingKey {
        case source, author, title
        case overview = "description"
        case url, content
        case image = "urlToImage"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.source = try container.decode(Source.self, forKey: .source)
        self.title = try container.decode(String.self, forKey: .title)
        self.author = try container.decodeIfPresent(String.self, forKey: .author)
        self.overview = try container.decodeIfPresent(String.self, forKey: .overview)

        self.url = try container.decode(CustomURL.self, forKey: .url)

        self.image = try container.decodeIfPresent(EmptyStringIsNil<ImageURL>.self, forKey: .image)?.wrappedValue
        self.content = try container.decodeIfPresent(String.self, forKey: .content)
    }
}

class Source: Decodable, GraphQLObject {
    let id: String?
    let name: String

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

struct News: Decodable {
    let articles: [NewsStory]
}
