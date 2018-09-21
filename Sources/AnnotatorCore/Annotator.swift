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
