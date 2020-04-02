
import Foundation
import GraphZahl

class NewsStory: Decodable, GraphQLObject {
    let source: Source
    let title: String
    let author, overview: String?
    let url: URL
    let image: ImageURL?
    let published: Date
    let content: String?

    enum CodingKeys: String, CodingKey {
        case source, author, title
        case overview = "description"
        case url, content
        case image = "urlToImage"
        case published = "publishedAt"
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
