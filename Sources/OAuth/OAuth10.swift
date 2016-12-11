import Foundation

@available(macOS 10.11, iOS 9.0, tvOS 10.0, watchOS 3.0, *)
public struct OAuth10: CustomStringConvertible {
    public static let unreservedCharacterSet = CharacterSet(charactersIn: "-.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~")

    private let urlRequest: URLRequest

    public var consumerCredential: OAuthCredential
    public var requestCredential: OAuthCredential?
    public var accessCredential: OAuthCredential?

    private var oauthParameters = [String: String]()

    public var realm: String?

    public var consumerKey: String {
        get {
            return self["consumer_key"] ?? consumerCredential.key
        }
        set {
            if newValue != "" {
                self["consumer_key"] = newValue
            } else {
                self["consumer_key"] = nil
            }
        }
    }

    public var token: String? {
        get {
            return self["token"] ?? accessCredential?.key ?? requestCredential?.key
        }
        set {
            self["token"] = newValue
        }
    }

    public var signatureMethod: OAuthSignatureMethod {
        get {
            if let value = OAuthSignatureMethod(rawValue: self["signature_method"] ?? "") {
                return value
            }
            return OAuthSignatureMethod.hmacSha1
        }
        set {
            self["signature_method"] = newValue.rawValue
        }
    }

    public var signature: String {
        return signatureMethod.signature(baseString: signatureBaseString() ?? "", keyString: signatureKeyString())
    }

    public var timestamp: Date {
        get {
            if let timestamp = self["timestamp"] {
                return Date(timeIntervalSince1970: TimeInterval(timestamp)!)
            }
            return Date()
        }
        set {
            self["timestamp"] = Int(newValue.timeIntervalSince1970).description
        }
    }

    public var nonce: Data {
        get {
            if let nonce = self["nonce"] {
                return Data(base64Encoded: nonce) ?? nonce.data(using: String.Encoding.utf8, allowLossyConversion: true)!
            }
            let nonce = UUID().uuidString.data(using: .utf8)!
            return nonce
        }
        set {
            if newValue.count != 0 {
                self["nonce"] = newValue.base64EncodedString()
            } else {
                self["nonce"] = nil
            }
        }
    }

    public var version: String {
        return self["version"]!
    }

    private var computedOAuthParameters: [String: String] {
        var oauthParameters = self.oauthParameters
        if oauthParameters["consumer_key"] == nil {
            oauthParameters["consumer_key"] = consumerCredential.key
        }
        if oauthParameters["token"] == nil {
            if let token = self["token"] ?? accessCredential?.key ?? requestCredential?.key {
                oauthParameters["token"] = token
            }
        }
        if oauthParameters["signature_method"] == nil || OAuthSignatureMethod(rawValue: oauthParameters["signature_method"]!) == nil {
            oauthParameters["signature_method"] = OAuthSignatureMethod.hmacSha1.rawValue
        }
        if oauthParameters["timestamp"] == nil {
            oauthParameters["timestamp"] = Int(timestamp.timeIntervalSince1970).description
        }
        if oauthParameters["nonce"] == nil {
            oauthParameters["nonce"] = nonce.base64EncodedString()
        }
        oauthParameters["version"] = "1.0"
        return oauthParameters
    }

    public var description: String {
        var string = "OAuth"
        var comma = ""
        if let realm = realm {
            string.append(" realm=\(realm)")
            comma = ","
        }
        let oauthParameters = computedOAuthParameters
        for (k, v) in oauthParameters {
            string.append("\(comma) oauth_\(k.addingPercentEncoding(withAllowedCharacters: OAuth10.unreservedCharacterSet)!)=\"\(v.addingPercentEncoding(withAllowedCharacters: OAuth10.unreservedCharacterSet)!)\"")
            comma = ","
        }
        string.append(", oauth_signature=\"\(signatureMethod.signature(baseString: signatureBaseString(oauthParameters)!, keyString: signatureKeyString()).addingPercentEncoding(withAllowedCharacters: OAuth10.unreservedCharacterSet)!)\"")
        return string
    }

    public subscript(_ key: String) -> String? {
        get {
            if key == "version" {
                return "1.0"
            }
            return oauthParameters[key]
        }
        set {
            if key == "version" {
                return
            }
            if let newValue = newValue {
                oauthParameters[key] = newValue
            } else {
                oauthParameters.removeValue(forKey: key)
            }
        }
    }

    private init?() {
        return nil
    }

    public init(urlRequest: URLRequest, consumerCredential: OAuthCredential) {
        self.urlRequest = urlRequest
        self.consumerCredential = consumerCredential
    }

    public init(urlRequest: URLRequest, consumerCredential: OAuthCredential, requestCredential: OAuthCredential) {
        self.urlRequest = urlRequest
        self.consumerCredential = consumerCredential
        self.requestCredential = requestCredential
    }

    public init(urlRequest: URLRequest, consumerCredential: OAuthCredential, accessCredential: OAuthCredential) {
        self.urlRequest = urlRequest
        self.consumerCredential = consumerCredential
        self.accessCredential = accessCredential
    }

    private func signatureBaseString() -> String? {
        return signatureBaseString(computedOAuthParameters)
    }

    private func signatureBaseString(_ oauthParameters: [String: String]) -> String? {
        guard let url = urlRequest.url else {
            return nil
        }
        var string = "\(urlRequest.httpMethod!)&"
        let urlString = url.absoluteString
        var parameters = [String: [String]]()
        for (k, v) in oauthParameters {
            parameters["oauth_\(k)"] = [v]
        }
        if let rangeOfQuery = URLComponents(url: url, resolvingAgainstBaseURL: true)!.rangeOfQuery {
            string.append("\(urlString.replacingCharacters(in: Range(uncheckedBounds: (lower: urlString.index(before: rangeOfQuery.lowerBound), upper: rangeOfQuery.upperBound)), with: "").addingPercentEncoding(withAllowedCharacters: OAuth10.unreservedCharacterSet)!)&")
            for kv in url.query!.components(separatedBy: "&") {
                let kv = kv.components(separatedBy: "=")
                if parameters[kv[0]] != nil {
                    parameters[kv[0]]!.append(kv[1])
                } else {
                    parameters[kv[0]] = [kv[1]]
                }
            }
        } else {
            string.append("\(urlString.addingPercentEncoding(withAllowedCharacters: OAuth10.unreservedCharacterSet)!)&")
        }
        if urlRequest.httpMethod == "POST" && urlRequest.allHTTPHeaderFields?["Content-Type"] == "application/x-www-form-urlencoded" {
            if let data = urlRequest.httpBody {
                for kv in String(data: data, encoding: String.Encoding.utf8)!.components(separatedBy: "&") {
                    let kv = kv.components(separatedBy: "=")
                    if parameters[kv[0]] != nil {
                        parameters[kv[0]]!.append(kv[1])
                    } else {
                        parameters[kv[0]] = [kv[1]]
                    }
                }
            }
        }
        var sortedParameters = parameters.sorted(by: {$0.0 < $1.0})
        var ampersand = ""
        for index in 0..<sortedParameters.count {
            sortedParameters[index].value = sortedParameters[index].value.sorted(by: <)
            let item = sortedParameters[index]
            for v in item.value {
                string.append("\(ampersand)\(item.key.addingPercentEncoding(withAllowedCharacters: OAuth10.unreservedCharacterSet)!)=\(v.addingPercentEncoding(withAllowedCharacters: OAuth10.unreservedCharacterSet)!)".addingPercentEncoding(withAllowedCharacters: OAuth10.unreservedCharacterSet)!)
                ampersand = "&"
            }
        }
        return string
    }

    private func signatureKeyString() -> String {
        var keyString = "\(consumerCredential.secret.addingPercentEncoding(withAllowedCharacters: OAuth10.unreservedCharacterSet)!)&"
        if let tokenSecret = accessCredential?.secret ?? requestCredential?.secret {
            keyString.append(tokenSecret.addingPercentEncoding(withAllowedCharacters: OAuth10.unreservedCharacterSet)!)
        }
        return keyString
    }
}
