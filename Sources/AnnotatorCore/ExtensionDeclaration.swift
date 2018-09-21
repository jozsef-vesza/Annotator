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

struct ExtensionDeclaration {
    let className: String
    let protocolName: String
    let closingBraces: String
    let leadingTrivia: Trivia?
    let trailingTrivia: Trivia?
    let methodDeclarationList: MemberDeclBlockSyntax?
    
    var commentString: String {
        return "// MARK: - \(protocolName)"
    }
    
    /**
     Provides an updated leading trivia with annotation when needed.
     
     This property will be nil if the necessary annotation is already present in the leading trivia.
     */
    var updatedLeadingTrivia: Trivia? {
        let commentPiece = TriviaPiece.lineComment(commentString)
        
        guard let existingLeadingTrivia = leadingTrivia else {
            return Trivia.newlines(2).appending(commentPiece).appending(.newlines(1))
        }
        
        let annotationNeeded = existingLeadingTrivia
            .filter { (piece) -> Bool in
                switch piece {
                case .lineComment(commentString): return true
                default: return false
                }
            }
            .count == 0
        
        guard annotationNeeded else { return nil }
        
        return existingLeadingTrivia.appending(commentPiece).appending(.newlines(1))
    }
    
    /**
     Constructs a class extension structure from a code block.
     
     Expected structure:
     ```
     // Existing trivia
     // extension ClassName: ProtocolName {}
     ```
     
     - Parameter node: The class extension code block
     - Returns: `nil` if the node is not a class extension in the specified syntax
     */
    init?(node: CodeBlockItemSyntax) {
        guard
            node.description.contains("extension"),
            node.description.contains(":") else {
                return nil
        }
        
        // Strip existing trivia to get the components of the extension declaration
        let components = node.description
            .components(separatedBy: .newlines)
            .filter { component in
                return component.count > 0 && !component.contains("//")
            }
            .first?
            .components(separatedBy: .whitespaces) ?? []
        
        // Expected format: extension ClassName: ProtocolName {}
        guard components.count == 4 else { return nil }
        
        className = String(components[1].dropLast())
        protocolName = String(components[2])
        closingBraces = components[3]
        leadingTrivia = node.leadingTrivia
        trailingTrivia = node.trailingTrivia
        methodDeclarationList = node.child(at: 0)?.children.compactMap { return $0 as? MemberDeclBlockSyntax }.first
    }
}
