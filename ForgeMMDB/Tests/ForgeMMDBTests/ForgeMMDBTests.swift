import Foundation
import Testing
import ForgeBase
@testable import ForgeMMDB

@Test func countryCodePackedBE() {
    let code = CountryCode(packedBE: 0x5553)
    #expect(code?.string == "US")
}

@Test func countryCodeFromString() {
    #expect(CountryCode("cn") == .cn)
    #expect(CountryCode("CN") == .cn)
    #expect(CountryCode("C") == nil)
    #expect(CountryCode("CHN") == nil)
}

@Test func countryCodePresets() {
    #expect(CountryCode(packedBE: 0x434E) == .cn)
    #expect(CountryCode(packedBE: 0x5553) == .us)
    #expect(CountryCode(packedBE: 0x4A50) == .jp)
    #expect(CountryCode(packedBE: 0x4B52) == .kr)
    #expect(CountryCode(packedBE: 0x484B) == .hk)
    #expect(CountryCode(packedBE: 0x5457) == .tw)
    #expect(CountryCode(packedBE: 0x5347) == .sg)

    #expect(CountryCode.cn.string == "CN")
    #expect(CountryCode.us.string == "US")
    #expect(CountryCode.jp.string == "JP")
    #expect(CountryCode.kr.string == "KR")
    #expect(CountryCode.hk.string == "HK")
    #expect(CountryCode.tw.string == "TW")
    #expect(CountryCode.sg.string == "SG")
}

@Test func fastDomainCNMatcher() {
    let matcher = FastDomainCNMatcher()
    #expect(matcher.predictedCountry(of: "example.cn") == .cn)
    #expect(matcher.predictedCountry(of: "example.xn--fiqs8s") == .cn)
    #expect(matcher.predictedCountry(of: "example.com") == nil)
}

@Test func mmdbPathResolverBundle() throws {
    let path = try MMDBPathResolver.resolve(.bundle(resource: "Country", ext: "mmdb"))
    #expect(FileManager.default.fileExists(atPath: path))
}

@Test func mmdbPathResolverAbsolute() throws {
    let tmp = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)
    try Data().write(to: tmp)
    defer { try? FileManager.default.removeItem(at: tmp) }

    let resolved = try MMDBPathResolver.resolve(.absolute(tmp.path))
    #expect(resolved == tmp.path)
}

// MARK: - MMDBReader Tests

@Test func mmdbReaderLoadsSuccessfully() throws {
    // Test that MMDBReader can be initialized with the bundled database
    _ = try MMDBReader(location: .bundle(resource: "Country", ext: "mmdb"))
}

@Test func mmdbReaderIPLookup() throws {
    // Test IP-to-country lookup functionality
    let reader = try MMDBReader(location: .bundle(resource: "Country", ext: "mmdb"))
    
    // Test with various public IPs
    // Note: The actual results depend on the MMDB database content
    // We mainly verify that the lookup mechanism works without crashing
    
    let testIPs = [
        "8.8.8.8",       // Google DNS
        "1.1.1.1",       // Cloudflare DNS
        "180.76.76.76",  // Baidu DNS (CN)
        "114.114.114.114", // 114 DNS (CN)
        "208.67.222.222", // OpenDNS (US)
    ]
    
    for ipStr in testIPs {
        if let ip = FBIPv4Parse.parseDottedDecimal(ipStr[...]) {
            // The lookup should not crash, regardless of result
            _ = reader.countryCode(of: ip)
        }
    }
    
    // Test passes if no crashes occurred
}

@Test func mmdbReaderReturnsValidCountryCode() throws {
    // Test that the MMDBReader interface works correctly
    let reader = try MMDBReader(location: .bundle(resource: "Country", ext: "mmdb"))
    
    // Test with various IPs to ensure no crashes
    let testIPs = [
        "8.8.8.8",
        "1.1.1.1",
        "180.76.76.76",
        "114.114.114.114",
        "208.67.222.222",
        "4.4.4.4",
        "9.9.9.9",
        "192.168.1.1",  // Private IP
        "10.0.0.1",      // Private IP
    ]
    
    for ipStr in testIPs {
        if let ip = FBIPv4Parse.parseDottedDecimal(ipStr[...]) {
            if let country = reader.countryCode(of: ip) {
                // If we get a country code, verify it's valid
                let str = country.string
                #expect(str.count == 2, "Country code should be 2 characters")
                #expect(str.allSatisfy { $0.isASCII && $0.isLetter }, "Country code should be ASCII letters")
            }
            // nil is also a valid result for IPs not in the database
        }
    }
    
    // Test passes if all lookups completed without crashing
    // and any returned country codes are valid
}

// MARK: - RegionClassifier Tests

@Test func regionClassifierWithMockGeoIP() {
    // Test RegionClassifier with a mock GeoIPProvider
    struct MockGeoIP: GeoIPProvider {
        func countryCode(of ip: FBIPv4) -> CountryCode? {
            // Return CN for specific test IP, US for others
            if ip.beValue == FBIPv4(a: 1, b: 2, c: 3, d: 4).beValue {
                return .cn
            }
            return .us
        }
    }
    
    let classifier = RegionClassifier(geoIP: MockGeoIP())
    
    let testIP = FBIPv4(a: 1, b: 2, c: 3, d: 4)
    #expect(classifier.countryCode(of: testIP) == .cn)
    #expect(classifier.isCN(ip: testIP) == true)
    
    let otherIP = FBIPv4(a: 8, b: 8, c: 8, d: 8)
    #expect(classifier.countryCode(of: otherIP) == .us)
    #expect(classifier.isCN(ip: otherIP) == false)
}

@Test func regionClassifierDomainPrediction() throws {
    // Test RegionClassifier domain prediction with mock GeoIPProvider
    struct MockGeoIP: GeoIPProvider {
        func countryCode(of ip: FBIPv4) -> CountryCode? { nil }
    }
    
    let classifier = RegionClassifier(geoIP: MockGeoIP())
    
    // Test CN domain
    #expect(classifier.predictedCountry(of: "example.cn") == .cn)
    #expect(classifier.isCN(domain: "example.cn") == true)
    
    // Test non-CN domain
    #expect(classifier.predictedCountry(of: "example.com") == nil)
    #expect(classifier.isCN(domain: "example.com") == false)
    
    // Test punycode CN domain
    #expect(classifier.predictedCountry(of: "example.xn--fiqs8s") == .cn)
    #expect(classifier.isCN(domain: "example.xn--fiqs8s") == true)
}

@Test func regionClassifierIntegration() throws {
    // Integration test with real MMDBReader
    let reader = try MMDBReader(location: .bundle(resource: "Country", ext: "mmdb"))
    let classifier = RegionClassifier(geoIP: reader)
    
    // Test that classifier delegates correctly to the reader
    // We'll use a mock IP to ensure consistent behavior
    let testIP = FBIPv4(a: 1, b: 1, c: 1, d: 1)
    let readerResult = reader.countryCode(of: testIP)
    let classifierResult = classifier.countryCode(of: testIP)
    
    // Results should match
    #expect(readerResult == classifierResult)
    
    // Test isCN method
    if let country = classifierResult {
        #expect(classifier.isCN(ip: testIP) == (country == .cn))
    } else {
        #expect(classifier.isCN(ip: testIP) == false)
    }
}

