//
//  CountryCode.swift
//  ForgeMMDB
//
//  Created by MagicianQuinn on 2026/2/5.
//

public struct CountryCode: Hashable, Sendable {
    public let rawValue: UInt16

    @inline(__always)
    public init?(packedBE: UInt16) {
        guard packedBE != 0 else { return nil }
        self.rawValue = packedBE
    }

    public var string: String {
        let a = UInt8(rawValue >> 8)
        let b = UInt8(rawValue & 0xff)
        return String(bytes: [a, b], encoding: .ascii) ?? "unknown"
    }
}

public extension CountryCode {
    static let cn = CountryCode(packedBE: 0x434E)!
    static let us = CountryCode(packedBE: 0x5553)!
    static let jp = CountryCode(packedBE: 0x4A50)!
    static let kr = CountryCode(packedBE: 0x4B52)!
    static let hk = CountryCode(packedBE: 0x484B)!
    static let tw = CountryCode(packedBE: 0x5457)!
    static let sg = CountryCode(packedBE: 0x5347)!

    @inline(__always)
    init?(_ iso2: (UInt8, UInt8)) {
        let v = (UInt16(iso2.0) << 8) | UInt16(iso2.1)
        self.init(packedBE: v)
    }

    @inline(__always)
    private static func upperASCII(_ c: UInt8) -> UInt8 {
        (c >= 97 && c <= 122) ? (c - 32) : c
    }

    @inline(__always)
    init?(_ string: String) {
        guard string.utf8.count == 2 else { return nil }
        let u = Array(string.utf8)
        self.init((Self.upperASCII(u[0]), Self.upperASCII(u[1])))
    }
}
