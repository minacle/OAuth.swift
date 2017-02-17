import Foundation

public struct OAuthCredential {

    public var key: String
    public var secret: String

    public init(key: String, secret: String) {
        self.key = key
        self.secret = secret
    }
}
