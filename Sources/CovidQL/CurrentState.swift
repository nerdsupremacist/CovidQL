
import Foundation
import GraphZahl

class CurrentState: Decodable, GraphQLObject {
    let cases: Int
    let deaths: Int
    let recovered: Int
}
