import Foundation
import XCTest

final class LocalizationCoverageTests: XCTestCase {
    func testAllSupportedLocalizationsArePresentWithMatchingKeys() throws {
        let resourcesURL = repositoryRoot
            .appendingPathComponent("ShadeTimerApp", isDirectory: true)
            .appendingPathComponent("Resources", isDirectory: true)

        let fileManager = FileManager.default
        let localeDirectories = try fileManager.contentsOfDirectory(
            at: resourcesURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )
        .filter { $0.pathExtension == "lproj" }
        .map(\.lastPathComponent)
        .sorted()

        XCTAssertEqual(localeDirectories, Self.expectedLocales)

        let baseLocalizations = try loadLocalization(named: "en-US.lproj", in: resourcesURL)
        XCTAssertFalse(baseLocalizations.isEmpty)

        for locale in localeDirectories where locale != "en-US.lproj" {
            let localizedStrings = try loadLocalization(named: locale, in: resourcesURL)
            XCTAssertEqual(
                Set(localizedStrings.keys),
                Set(baseLocalizations.keys),
                "Mismatched localization keys in \(locale)"
            )
        }
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func loadLocalization(named locale: String, in resourcesURL: URL) throws -> [String: String] {
        let stringsURL = resourcesURL
            .appendingPathComponent(locale, isDirectory: true)
            .appendingPathComponent("Localizable.strings", isDirectory: false)

        guard let dictionary = NSDictionary(contentsOf: stringsURL) as? [String: String] else {
            XCTFail("Unable to read localization file at \(stringsURL.path)")
            return [:]
        }

        return dictionary
    }

    private static let expectedLocales = [
        "ar.lproj",
        "ca.lproj",
        "cs.lproj",
        "da.lproj",
        "de.lproj",
        "el.lproj",
        "en-AU.lproj",
        "en-CA.lproj",
        "en-GB.lproj",
        "en-US.lproj",
        "es-ES.lproj",
        "es-MX.lproj",
        "fi.lproj",
        "fr-CA.lproj",
        "fr.lproj",
        "he.lproj",
        "hi.lproj",
        "hr.lproj",
        "hu.lproj",
        "id.lproj",
        "it.lproj",
        "ja.lproj",
        "ko.lproj",
        "ms.lproj",
        "nb.lproj",
        "nl.lproj",
        "pl.lproj",
        "pt-BR.lproj",
        "pt-PT.lproj",
        "ro.lproj",
        "ru.lproj",
        "sk.lproj",
        "sv.lproj",
        "th.lproj",
        "tr.lproj",
        "uk.lproj",
        "vi.lproj",
        "zh-Hans.lproj",
        "zh-Hant.lproj"
    ]
}
