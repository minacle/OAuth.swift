import Foundation

extension CharacterSet {
    
    static var urlUnreservedCharacters: CharacterSet {
        var urlUnreservedCharacters = CharacterSet.alphanumerics
        urlUnreservedCharacters.insert(charactersIn: "-._~")
        return urlUnreservedCharacters
    }
}
