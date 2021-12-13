import Foundation

public enum FileImport {
    static public func getInput() -> String? {
        Self.contents(of: "input")
    }

    static public func getTestInput() -> String? {
        Self.contents(of: "test_input")
    }

    private static func contents(of file: String) -> String? {
        guard let url = Bundle.main.url(forResource: file, withExtension: "txt")
            else { return nil }
        return try? String(contentsOf: url).trimmingCharacters(in: .newlines)
    }
}
