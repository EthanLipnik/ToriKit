import Foundation
import Combine
//import Swifter

public class Tori: ObservableObject {
    public var credentials: Credentials
    
    public lazy var onOAuthRedirect = PassthroughSubject<URL, Never>()
    @Published public var authorizationSheetIsPresented = false
    @Published public var authorizationURL: URL? = nil
    @Published public var user: Account?
    
//    private(set) lazy var swifter: Swifter? = nil
    
    public static var cancellables: Set<AnyCancellable> = []
    
    public var tokenCredentials: TokenCredentials?
    
    public init(credentials: Credentials, tokenCredentials: TokenCredentials? = nil, user: Account? = nil) {
        self.credentials = credentials
        
        self.tokenCredentials = tokenCredentials
        self.user = user
        
//        if let accessToken = tokenCredentials?.accessToken, let accessTokenSecret = tokenCredentials?.accessTokenSecret {
//            swifter = Swifter(consumerKey: credentials.consumerKey, consumerSecret: credentials.consumerSecret, oauthToken: accessToken, oauthTokenSecret: accessTokenSecret)
//        } else {
//            swifter = Swifter(consumerKey: credentials.consumerKey, consumerSecret: credentials.consumerSecret)
//        }
    }
    
    public var subscriptions: [String: AnyCancellable] = [:]
}
