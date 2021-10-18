import Foundation
import Combine
import Swifter

public class Tori: ObservableObject {
    public var credentials: Credentials?
    
    public lazy var onOAuthRedirect = PassthroughSubject<URL, Never>()
    @Published public var authorizationSheetIsPresented = false
    @Published public var authorizationURL: URL? = nil
    @Published public var user: Account?
    
    private(set) lazy var swifter: Swifter? = nil
    
    public static var cancellables: Set<AnyCancellable> = []
    
    public var tokenCredentials: TokenCredentials?
    
    public init(credentials: Credentials? = nil, tokenCredentials: TokenCredentials? = nil, user: Account? = nil) {
        self.credentials = credentials
        
        updateAccount(tokenCredentials: tokenCredentials, account: user)
    }
    
    public var subscriptions: [String: AnyCancellable] = [:]
    
    public func updateAccount(tokenCredentials: TokenCredentials?, account: Account?) {
        self.tokenCredentials = tokenCredentials
        self.user = user
        
        if let credentials = credentials {
            if let accessToken = tokenCredentials?.accessToken, let accessTokenSecret = tokenCredentials?.accessTokenSecret {
                swifter = Swifter(consumerKey: credentials.consumerKey, consumerSecret: credentials.consumerSecret, oauthToken: accessToken, oauthTokenSecret: accessTokenSecret)
            } else {
                swifter = Swifter(consumerKey: credentials.consumerKey, consumerSecret: credentials.consumerSecret)
            }
        }
    }
    
    public func logout() {
        self.tokenCredentials = nil
        self.user = nil
        self.swifter = nil
    }
}

#if canImport(SwiftUI)
import SwiftUI
private struct ToriKey: EnvironmentKey {
  static let defaultValue = Tori()
}

public extension EnvironmentValues {
  var tori: Tori {
    get { self[ToriKey.self] }
    set { self[ToriKey.self] = newValue }
  }
}
#endif
