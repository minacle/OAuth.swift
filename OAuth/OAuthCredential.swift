import Foundation

public struct OAuthCredential {
    var key: String
    var secret: String

    private init?() {
        return nil
    }

    public init(key: String, secret: String) {
        self.key = key
        self.secret = secret
    }
}
