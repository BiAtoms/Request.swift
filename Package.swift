import PackageDescription

let package = Package(
    name: "RequestSwift",
    dependencies: [
        .Package(url: "https://github.com/BiAtoms/Socket.swift.git", majorVersion: 2, minor: 0)
    ]
)
