//
//  MMDBReader.swift
//  ForgeMMDB
//
//  Created by MagicianQuinn on 2026/2/6.
//

import Foundation
import ForgeBase
import ForgeMMDBBridge

public final class MMDBReader: GeoIPProvider {

    public init(location: MMDBLocation = .bundle(resource: "Country", ext: "mmdb")) throws {
        let path = try MMDBPathResolver.resolve(location)
        let status = forge_mmdb_open(path)
        guard status == 0 else { throw MMDBOpenError(status: status) }
    }

    deinit { forge_mmdb_close() }

    @inline(__always)
    public func countryCode(of ip: FBIPv4) -> CountryCode? {
        CountryCode(packedBE: forge_mmdb_country_ipv4(ip.beValue))
    }
}

public struct MMDBOpenError: LocalizedError, Sendable {
    public let status: Int32

    public var errorDescription: String? {
        "MMDB open failed: status=\(status)"
    }
}
