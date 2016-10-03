// Original codes: http://stackoverflow.com/a/24411522
import CommonCrypto
import Foundation

enum CryptoAlgorithm {
    case md5
    case sha1
    case sha256
    case sha384
    case sha512
    case sha224

    var hmacAlgorithm: CCHmacAlgorithm {
        switch self {
        case .md5:
            return CCHmacAlgorithm(kCCHmacAlgMD5)
        case .sha1:
            return CCHmacAlgorithm(kCCHmacAlgSHA1)
        case .sha224:
            return CCHmacAlgorithm(kCCHmacAlgSHA224)
        case .sha256:
            return CCHmacAlgorithm(kCCHmacAlgSHA256)
        case .sha384:
            return CCHmacAlgorithm(kCCHmacAlgSHA384)
        case .sha512:
            return CCHmacAlgorithm(kCCHmacAlgSHA512)
        }
    }

    var digestLength: Int {
        switch self {
        case .md5:
            return Int(CC_MD5_DIGEST_LENGTH)
        case .sha1:
            return Int(CC_SHA1_DIGEST_LENGTH)
        case .sha224:
            return Int(CC_SHA224_DIGEST_LENGTH)
        case .sha256:
            return Int(CC_SHA256_DIGEST_LENGTH)
        case .sha384:
            return Int(CC_SHA384_DIGEST_LENGTH)
        case .sha512:
            return Int(CC_SHA512_DIGEST_LENGTH)
        }
    }
}

extension String {
    func hmac(algorithm: CryptoAlgorithm, key: String) -> Data {
        let encoding = String.Encoding.ascii
        let str = self.cString(using: encoding)
        let strLen = Int(self.lengthOfBytes(using: encoding))
        let digestLen = algorithm.digestLength
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        let keyStr = key.cString(using: encoding)
        let keyLen = Int(key.lengthOfBytes(using: encoding))
        CCHmac(algorithm.hmacAlgorithm, keyStr!, keyLen, str!, strLen, result)
        let data = Data(bytes: result, count: digestLen)
        result.deallocate(capacity: digestLen)
        return data
    }
}
