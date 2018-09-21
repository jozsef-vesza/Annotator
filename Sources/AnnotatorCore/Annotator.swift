import Foundation
import SwiftSyntax

enum AnnotatorError: Swift.Error {
    case missingProjectFolder
}

public final class Annotator {
    private let arguments: [String]
    
    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }
    
    public func run() throws {
        guard arguments.count > 0 else {
            throw AnnotatorError.missingProjectFolder
        }
        
        let projectFolder = arguments[1]
        
        let enumerator = FileManager.default.enumerator(atPath: projectFolder)
        let annotator = ExtensionAnnotator()
        
        enumerator?.allObjects
            .filter { element in
                guard let stringValue = element as? String else { return false }
                return URL(fileURLWithPath: stringValue).pathExtension == "swift"
            }
            .forEach { element in
                let filePath = projectFolder.appending("/\(element)")
                let url = URL(fileURLWithPath: filePath)
                do {
                    let sourceFile = try SyntaxTreeParser.parse(url)
                    let annotatedText = annotator.visit(sourceFile)
                    try annotatedText.description.write(toFile: filePath, atomically: true, encoding: .utf8)
                } catch let error {
                    print(error.localizedDescription)
                }
        }
    }
}
