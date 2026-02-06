# ForgeMMDB

Lightweight GeoIP classifier using MaxMind MMDB.

Provides fast country lookup for IPv4 and cheap domain CN prediction.

## Features

- Zero-copy MMDB lookup (libmaxminddb mmap)
- Packed ISO-3166 alpha-2 (UInt16) country code
- Fast .cn / punycode domain prediction
- iOS & macOS Swift Package

## Installation

```swift
.package(url: "https://github.com/CoderQuinn/ForgeMMDB.git", from: "0.1.0")
```

```swift
.product(name: "ForgeMMDB", package: "ForgeMMDB")
```

## Usage

### Default classifier

```swift
import ForgeMMDB

let classifier = try ForgeMMDB.makeDefaultClassifier()

if classifier.isCN(ip: ip) {
	// direct
}
```

### Custom database

```swift
let reader = try MMDBReader(location: .absolute("/path/Country.mmdb"))
```

Supported locations:

- bundle
- app support
- app group
- absolute path

## Notes

- Domain prediction is hint only
- Routing decisions should rely on IP lookup
- Private IP handling belongs to upper layers

## License

ForgeMMDB and bundled libmaxminddb follow their respective LICENSE files.