//
//  ForgeMMDB.swift
//  ForgeMMDB
//
//  Created by MagicianQuinn on 2026/2/6.
//

import Foundation

public enum MMDBLocation: Sendable {
    case bundle(resource: String, ext: String)
    case appSupport(appName: String, file: String)
    case appGroup(groupID: String, file: String)
    case absolute(String)
}


public enum ForgeMMDB {
    /// Default:
    /// - mmdb: bundled Country.mmdb
    /// - domain predictor: TLD + suffix (cheap)
    public static func makeDefaultClassifier(
        mmdb: MMDBLocation = .bundle(resource: "Country", ext: "mmdb")
    ) throws -> RegionClassifier {
        let reader = try MMDBReader(location: mmdb)
        return RegionClassifier(geoIP: reader)
    }
}
