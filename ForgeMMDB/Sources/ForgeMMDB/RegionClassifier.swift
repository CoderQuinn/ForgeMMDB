//
//  RegionClassifier.swift
//  ForgeMMDB
//
//  Created by MagicianQuinn on 2026/2/6.
//

import ForgeBase

public final class RegionClassifier: Sendable {
    private let geoIP: GeoIPProvider
    private let geoDomain: GeoDomainProvider

    public init(geoIP: GeoIPProvider, geoDomain: GeoDomainProvider = FastDomainCNMatcher()) {
        self.geoIP = geoIP
        self.geoDomain = geoDomain
    }

    public func countryCode(of ip: FBIPv4) -> CountryCode? {
        geoIP.countryCode(of: ip)
    }

    public func isCN(ip: FBIPv4) -> Bool {
        countryCode(of: ip) == .cn
    }

    public func predictedCountry(of domain: String) -> CountryCode? {
        geoDomain.predictedCountry(of: domain)
    }

    public func isCN(domain: String) -> Bool {
        predictedCountry(of: domain) == .cn
    }
}
