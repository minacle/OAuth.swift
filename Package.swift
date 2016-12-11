import PackageDescription

let package = Package(
    name: "OAuth",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/BlueCryptor.git", majorVersion: 0, minor: 8)
    ]
)
