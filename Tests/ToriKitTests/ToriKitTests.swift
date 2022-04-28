import XCTest
@testable import ToriKit

final class ToriKitTests: XCTestCase {
    
    func createCredentials() {
        let tori = Tori(credentials: .init(consumerKey: "", consumerSecret: "", callback: ""))
    }
}
