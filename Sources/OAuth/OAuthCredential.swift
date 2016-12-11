import Foundation

public struct OAuthCredential {
    var key: String
    var secret: String

    public init(key: String, secret: String) {
        self.key = key
        self.secret = secret
    }
}
