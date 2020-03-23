
import Foundation

struct IntIsh: Decodable {
    let value: Int

    init(from decoder: Decoder) throws {
        do {
            self.value = try Int(from: decoder)
        } catch {
            self.value = Int(try String(from: decoder))!
        }
    }
}
