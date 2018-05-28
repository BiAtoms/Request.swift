[![Platform Linux](https://img.shields.io/badge/platform-linux-brightgreen.svg)](#)
[![Platform](https://img.shields.io/cocoapods/p/Request.swift.svg?style=flat)](https://github.com/BiAtoms/Request.swift)
[![Cocoapods Compatible](https://img.shields.io/cocoapods/v/Request.swift.svg)](https://cocoapods.org/pods/Request.swift)
[![Carthage Compatible](https://img.shields.io/badge/carthage-compatible-brightgreen.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/github/license/BiAtoms/Request.swift.svg)](https://github.com/BiAtoms/Request.swift/blob/master/LICENSE)
[![Build Status - Master](https://travis-ci.org/BiAtoms/Request.swift.svg?branch=master)](https://travis-ci.org/BiAtoms/Request.swift)


# Request.swift

A tiny (sync/async) HTTP client written in swift.

## OS
 
Works in linux, iOS, macOS and tvOS

## Example
```swift
client.request("http://example.com", headers: ["Accept": "text/html"]).response { response, error in    
        if let response = response {
            print(response.statusCode)
            print(String(cString: response.body))
        } else {
            print(error)
        }
    }
```

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate Request.swift into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
target '<Your Target Name>' do
    pod 'Request.swift', '~> 2.2'
end
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Request.swift into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "BiAtoms/Request.swift" ~> 2.2
```

Run `carthage update` to build the framework and drag the built `RequestSwift.framework` into your Xcode project.

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. It is in early development, but Request.swift does support its use on supported platforms. 

Once you have your Swift package set up, adding Request.swift as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/BiAtoms/Request.swift.git", from: "2.0.0")
]
```

## Authors

* **Orkhan Alikhanov** - *Initial work* - [OrkhanAlikhanov](https://github.com/OrkhanAlikhanov)

See also the list of [contributors](https://github.com/BiAtoms/Request.swift/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
