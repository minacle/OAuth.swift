import Foundation

public enum OAuthSignatureMethod: String {
    case hmacSha1 = "HMAC-SHA1"
    case plaintext = "PLAINTEXT"

    internal func signature(baseString: String, keyString: String) -> String {
        switch self {
        case .hmacSha1:
            return baseString.hmac(algorithm: .sha1, key: keyString).base64EncodedString()
        case .plaintext:
            return keyString
        }
    }
}
