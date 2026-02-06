import Foundation
import Testing
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
