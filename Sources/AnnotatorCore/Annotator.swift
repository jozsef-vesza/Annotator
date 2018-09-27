/// Copyright (c) 2018 József Vesza
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

import Foundation
import SwiftSyntax

struct Config: Codable {
    let projectFolderPath: String
    let excludedFileNames: [String]?
    let excludedSubfolders: [String]?
    
    var excludedFilesRegex: NSRegularExpression? {
        guard let excludedFileNames = excludedFileNames else { return nil }
        let excludedFilesPattern = "(\(excludedFileNames.joined(separator: ":")))"
        guard let regex = try? NSRegularExpression(pattern: "^(/?.*\\/)?\(excludedFilesPattern)") else { return nil }
        return regex
    }
    
    var excludedFoldersRegex: NSRegularExpression? {
        guard let excludedSubfolders = excludedSubfolders else { return nil }
        let excludedFoldersPattern = "(\(excludedSubfolders.joined(separator: ":")))"
        guard let regex = try? NSRegularExpression(pattern: "^(/?\(excludedFoldersPattern)\\/).*") else { return nil }
        return regex
    }
}

enum AnnotatorError: Swift.Error {
    case missingConfigFileParameter
    case missingConfigFile
    case invalidConfigFileFormatError
}

public final class Annotator {
    private let arguments: [String]
    
    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }
    
    public func run() throws {
        guard arguments.count > 0 else {
            print("Please specify config file parameter")
            throw AnnotatorError.missingConfigFileParameter
        }
        
        let configFilePath = arguments[1]
        
        guard FileManager.default.fileExists(atPath: configFilePath),
            let configData = try? Data(contentsOf: URL(fileURLWithPath: configFilePath)) else {
                print("Config file doesn't exist")
                throw AnnotatorError.missingConfigFile
        }
        
        let jsonDecoder = JSONDecoder()
        
        guard let config = try? jsonDecoder.decode(Config.self, from: configData) else {
            print("Unable to parse config file; the JSON might be invalid.")
            throw AnnotatorError.invalidConfigFileFormatError
        }
        
        let projectFolder = config.projectFolderPath
        let annotator = ExtensionAnnotator()
        
        includedFilePaths(in: projectFolder, using: config).forEach { element in
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
    
    private func includedFilePaths(in projectFolder: String, using config: Config) -> [String] {
        guard let enumerator = FileManager.default.enumerator(atPath: projectFolder) else { return [] }
        
        return enumerator.allObjects
            .filter { element in
                guard let stringValue = element as? String else { return false }
                let range = NSRange(stringValue.startIndex ..< stringValue.endIndex, in: stringValue)
                
                let folderMatches = config.excludedFoldersRegex?.matches(in: stringValue, options: [], range: range) ?? []
                guard folderMatches.count == 0 else { return false }
                
                let fileMatches = config.excludedFilesRegex?.matches(in: stringValue, options: [], range: range) ?? []
                guard fileMatches.count == 0 else { return false }
                
                let url = URL(fileURLWithPath: stringValue)
                return url.pathExtension == "swift"
            }
            .compactMap { $0 as? String }
    }
}
