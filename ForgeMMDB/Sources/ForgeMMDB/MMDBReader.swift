//
//  MMDBReader.swift
//  ForgeMMDB
//
//  Created by MagicianQuinn on 2026/2/6.
//

import Foundation
import Dispatch
import ForgeBase
import ForgeMMDBBridge

public final class MMDBReader: GeoIPProvider, @unchecked Sendable {

    /// Serializes all access to the underlying C MMDB bridge, which uses global mutable state.
    private static let mmdbQueue = DispatchQueue(label: "ForgeMMDB.MMDBReader.mmdbQueue")

    public init(location: MMDBLocation = .bundle(resource: "Country", ext: "mmdb")) throws {
        let path = try MMDBPathResolver.resolve(location)
        let status = MMDBReader.mmdbQueue.sync {
            forge_mmdb_open(path)
        }
        guard status == 0 else { throw MMDBOpenError(status: status) }
    }

    deinit {
        MMDBReader.mmdbQueue.sync {
            forge_mmdb_close()
        }
    }

    @inline(__always)
    public func countryCode(of ip: FBIPv4) -> CountryCode? {
        let packed = MMDBReader.mmdbQueue.sync {
            forge_mmdb_country_ipv4(ip.beValue)
        }
        return CountryCode(packedBE: packed)
    }
}

public struct MMDBOpenError: LocalizedError, Sendable {
    public let status: Int32

    public var errorDescription: String? {
        "MMDB open failed: status=\(status)"
    }
}
