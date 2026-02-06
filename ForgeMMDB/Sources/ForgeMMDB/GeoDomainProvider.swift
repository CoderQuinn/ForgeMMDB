//
//  GeoDomainProvider.swift
//  ForgeMMDB
//
//  Created by MagicianQuinn on 2026/2/6.
//

public protocol GeoDomainProvider: Sendable {
    /// Lightweight prediction (not authoritative).
    func predictedCountry(of domain: String) -> CountryCode?
}

public extension GeoDomainProvider {
    func predictedIsCN(_ domain: String) -> Bool { predictedCountry(of: domain) == .cn }
}
