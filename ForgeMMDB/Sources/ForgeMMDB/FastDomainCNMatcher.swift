//
//  FastDomainCNMatcher.swift
//  ForgeMMDB
//
//  Created by MagicianQuinn on 2026/2/6.
//

public final class FastDomainCNMatcher: GeoDomainProvider {

    public init() {}
 
    // simple and fast TLD based country prediction, not accurate.
    public func predictedCountry(of domain: String) -> CountryCode? {
        guard domain.lastIndex(of: ".") != nil, let tld = domain.split(separator: ".").last else { return nil }

        if equalsASCII(tld, "cn") { return .cn }
        if equalsASCII(tld, "xn--fiqs8s") { return .cn }
        if equalsASCII(tld, "xn--55qx5d") { return .cn }
        if equalsASCII(tld, "xn--io0a7i") { return .cn }

        return nil
    }

    private func equalsASCII(_ s: Substring, _ literal: StaticString) -> Bool {
        let a = s.utf8
        guard a.count == literal.utf8CodeUnitCount else { return false }

        var i = a.startIndex
        var p = literal.utf8Start
        while i != a.endIndex {
            let raw1 = a[i]
            let raw2 = p.pointee

            let c1: UInt8
            if raw1 >= 0x41 && raw1 <= 0x5A { // 'A'...'Z'
                c1 = raw1 | 0x20
            } else {
                c1 = raw1
            }

            let c2: UInt8
            if raw2 >= 0x41 && raw2 <= 0x5A { // 'A'...'Z'
                c2 = raw2 | 0x20
            } else {
                c2 = raw2
            }
            if c1 != c2 { return false }
            a.formIndex(after: &i)
            p += 1
        }
        return true
    }
}
