import Cryptor
import Foundation

extension String {

    func hmac(algorithm: HMAC.Algorithm, key: String) -> Data {
        let key = CryptoUtils.byteArray(from: key)
        let data: [UInt8] = CryptoUtils.byteArray(from: self)
        let hmac = HMAC(using: HMAC.Algorithm.sha1, key: key).update(byteArray: data)?.final()
        return CryptoUtils.data(from: hmac ?? [])
    }
}
