//
//  RegionClassifier.swift
//  ForgeMMDB
//
//  Created by MagicianQuinn on 2026/2/6.
//

import ForgeBase

public final class RegionClassifier: Sendable {
    private let geoIP: GeoIPProvider

    public init(geoIP: GeoIPProvider) {
        self.geoIP = geoIP
    }

    public func countryCode(of ip: FBIPv4) -> CountryCode? {
        geoIP.countryCode(of: ip)
    }

    public func isCN(ip: FBIPv4) -> Bool {
        countryCode(of: ip) == .cn
    }
    
}
