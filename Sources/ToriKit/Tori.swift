import Foundation
import Combine

public class Tori: ObservableObject {
    public var credentials: Credentials?
    
    public lazy var onOAuthRedirect = PassthroughSubject<URL, Never>()
    @Published public var authorizationSheetIsPresented = false
    @Published public var authorizationURL: URL? = nil
    @Published public var user: Account?
    
    public static var cancellables: Set<AnyCancellable> = []
    
    public var tokenCredentials: TokenCredentials?
    
    public init(credentials: Credentials? = nil, tokenCredentials: TokenCredentials? = nil, user: Account? = nil) {
        self.credentials = credentials
        
        updateAccount(tokenCredentials: tokenCredentials, account: user)
    }
    
    public var subscriptions: [String: AnyCancellable] = [:]
    
    public func updateAccount(tokenCredentials: TokenCredentials?, account: Account?) {
        self.tokenCredentials = tokenCredentials
        self.user = account
    }
    
    public func logout() {
        self.tokenCredentials = nil
        self.user = nil
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
