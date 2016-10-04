# OAuth

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Introduction

```swift
import OAuth
let dispatchSemaphore = DispatchSemaphore(value: 0)
var urlRequest = URLRequest(url: URL(string: "http://term.ie/oauth/example/request_token.php")!)
urlRequest.httpMethod = "POST"
let consumerCredential = OAuthCredential(key: "key", secret: "secret")
let oauth = OAuth10(urlRequest: urlRequest, consumerCredential: consumerCredential)
urlRequest.setValue(oauth.description, forHTTPHeaderField: "Authorization")
let urlSession = URLSession.shared
let task = urlSession.dataTask(with: urlRequest) {
    (data: Data?, urlResponse: URLResponse?, error: Error?) in
    if let data = data {
        print(String(data: data, encoding: String.Encoding.utf8)!)
    }
    dispatchSemaphore.signal()
}
task.resume()
dispatchSemaphore.wait()
```
