import XCTest
import Foundation
import Dispatch
@testable import OAuth

@available(macOS 10.11, iOS 9.0, tvOS 10.0, watchOS 3.0, *)
class OAuthTests: XCTestCase {
    
    let urlSession = URLSession(configuration: URLSessionConfiguration.default)

    func testRequestToken() {
        let dispatchSemaphore = DispatchSemaphore(value: 0)
        var urlRequest = URLRequest(url: URL(string: "http://term.ie/oauth/example/request_token.php")!)
        urlRequest.httpMethod = "POST"
        let consumerCredential = OAuthCredential(key: "key", secret: "secret")
        let oauth = OAuth10(urlRequest: urlRequest, consumerCredential: consumerCredential)
        urlRequest.setValue(oauth.description, forHTTPHeaderField: "Authorization")
        let task = self.urlSession.dataTask(with: urlRequest) {
            (data: Data?, urlResponse: URLResponse?, error: Error?) in
            if let data = data {
                let string = String(data: data, encoding: String.Encoding.utf8)!
                print(String(data: data, encoding: String.Encoding.utf8)!)
                XCTAssertFalse(string.contains("<hr />"), string.components(separatedBy: "\n")[0])
                XCTAssertEqual(string, "oauth_token=requestkey&oauth_token_secret=requestsecret")
            }
            if let error = error {
                XCTFail(error.localizedDescription)
            }
            dispatchSemaphore.signal()
        }
        task.resume()
        dispatchSemaphore.wait()
    }

    func testAccessToken() {
        let dispatchSemaphore = DispatchSemaphore(value: 0)
        var urlRequest = URLRequest(url: URL(string: "http://term.ie/oauth/example/access_token.php")!)
        urlRequest.httpMethod = "POST"
        let consumerCredential = OAuthCredential(key: "key", secret: "secret")
        let requestCredential = OAuthCredential(key: "requestkey", secret: "requestsecret")
        let oauth = OAuth10(urlRequest: urlRequest, consumerCredential: consumerCredential, requestCredential: requestCredential)
        urlRequest.setValue(oauth.description, forHTTPHeaderField: "Authorization")
        let task = self.urlSession.dataTask(with: urlRequest) {
            (data: Data?, urlResponse: URLResponse?, error: Error?) in
            if let data = data {
                let string = String(data: data, encoding: String.Encoding.utf8)!
                print(String(data: data, encoding: String.Encoding.utf8)!)
                XCTAssertFalse(string.contains("<hr />"), string.components(separatedBy: "\n")[0])
                XCTAssertEqual(string, "oauth_token=accesskey&oauth_token_secret=accesssecret")
            }
            if let error = error {
                XCTFail(error.localizedDescription)
            }
            dispatchSemaphore.signal()
        }
        task.resume()
        dispatchSemaphore.wait()
    }

    func testAPI() {
        let dispatchSemaphore = DispatchSemaphore(value: 0)
        var urlRequest = URLRequest(url: URL(string: "http://term.ie/oauth/example/echo_api.php")!)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = "foo=bar&hoge=piyo".data(using: String.Encoding.utf8)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let consumerCredential = OAuthCredential(key: "key", secret: "secret")
        let accessCredential = OAuthCredential(key: "accesskey", secret: "accesssecret")
        let oauth = OAuth10(urlRequest: urlRequest, consumerCredential: consumerCredential, accessCredential: accessCredential)
        urlRequest.setValue(oauth.description, forHTTPHeaderField: "Authorization")
        let task = self.urlSession.dataTask(with: urlRequest) {
            (data: Data?, urlResponse: URLResponse?, error: Error?) in
            if let data = data {
                let string = String(data: data, encoding: String.Encoding.utf8)!
                print(String(data: data, encoding: String.Encoding.utf8)!)
                XCTAssertFalse(string.contains("<hr />"), string.components(separatedBy: "\n")[0])
                XCTAssertEqual(string, "foo=bar&hoge=piyo")
            }
            if let error = error {
                XCTFail(error.localizedDescription)
            }
            dispatchSemaphore.signal()
        }
        task.resume()
        dispatchSemaphore.wait()
    }

    static var allTests: [(String, (OAuthTests) -> () throws -> Void)] {
        return [
            ("testRequestToken", testRequestToken),
            ("testAccessToken", testAccessToken),
            ("testAPI", testAPI)
        ]
    }
}
