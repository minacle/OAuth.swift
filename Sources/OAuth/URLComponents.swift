import Foundation

extension URLComponents {

    var _rangeOfQuery: Range<String.Index>? {
        if #available(iOS 9.0, macOS 10.11, tvOS 10.0, watchOS 3.0, *) {
            return rangeOfQuery
        }
        else if let query = query {
            return string?.range(of: query)
        }
        return nil
    }
}
