//
//  MMDBPathResolver.swift
//  ForgeMMDB
//
//  Created by MagicianQuinn on 2026/2/6.
//

import Foundation

enum MMDBPathResolver {
    static func resolve(_ location: MMDBLocation) throws -> String {
        switch location {
        case let .bundle(resource, ext):
            if let url = bundleURL(resource: resource, ext: ext) {
                return url.path
            }
            throw MMDBPathError.resourceNotFound(resource: resource, ext: ext)

        case let .appSupport(appName, file):
            let base = try appSupportDirectory(appName: appName)
            let url = base.appendingPathComponent(file, isDirectory: false)
            try ensureReadable(url)
            return url.path

        case let .appGroup(groupID, file):
            #if canImport(UIKit) || canImport(AppKit)
            guard let base = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: groupID
            ) else {
                throw MMDBPathError.appGroupNotFound(groupID: groupID)
            }
            let url = base.appendingPathComponent(file, isDirectory: false)
            try ensureReadable(url)
            return url.path
            #else
            throw MMDBPathError.appGroupNotFound(groupID: groupID)
            #endif

        case let .absolute(path):
            let url = URL(fileURLWithPath: path)
            try ensureReadable(url)
            return url.path
        }
    }

    private static func bundleURL(resource: String, ext: String) -> URL? {
        let ns = resource as NSString
        let name = ns.lastPathComponent
        let subdir = ns.deletingLastPathComponent
        if subdir.isEmpty {
            return Bundle.module.url(forResource: name, withExtension: ext)
        }
        return Bundle.module.url(forResource: name, withExtension: ext, subdirectory: subdir)
    }

    private static func appSupportDirectory(appName: String) throws -> URL {
        let fm = FileManager.default
        guard let base = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw MMDBPathError.appSupportUnavailable
        }
        let dir = base.appendingPathComponent(appName, isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    private static func ensureReadable(_ url: URL) throws {
        let fm = FileManager.default
        guard fm.fileExists(atPath: url.path) else {
            throw MMDBPathError.fileNotFound(path: url.path)
        }
        guard fm.isReadableFile(atPath: url.path) else {
            throw MMDBPathError.unreadable(path: url.path)
        }
    }
}

enum MMDBPathError: LocalizedError {
    case resourceNotFound(resource: String, ext: String)
    case appSupportUnavailable
    case appGroupNotFound(groupID: String)
    case fileNotFound(path: String)
    case unreadable(path: String)

    var errorDescription: String? {
        switch self {
        case let .resourceNotFound(resource, ext):
            return "MMDB resource not found: \(resource).\(ext)"
        case .appSupportUnavailable:
            return "Application Support directory unavailable"
        case let .appGroupNotFound(groupID):
            return "App Group not found: \(groupID)"
        case let .fileNotFound(path):
            return "MMDB file not found: \(path)"
        case let .unreadable(path):
            return "MMDB file not readable: \(path)"
        }
    }
}
