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

final class ExtensionAnnotator: SyntaxRewriter {
    
    override func visit(_ node: ExtensionDeclSyntax) -> DeclSyntax {
        return annotateIfNeeded(node)
    }
    
    func annotateIfNeeded(_ node: ExtensionDeclSyntax) -> ExtensionDeclSyntax {
        guard let protocolName = node.inheritanceClause?.inheritedTypeCollection.first?.description else { return node }
        guard isAnnotationNeeded(node: node) else { return node }
        
        return SyntaxFactory.makeExtensionDecl(attributes: node.attributes,
                                               modifiers: node.modifiers,
                                               extensionKeyword: annotate(node.extensionKeyword, for: protocolName),
                                               extendedType: node.extendedType,
                                               inheritanceClause: node.inheritanceClause,
                                               genericWhereClause: node.genericWhereClause,
                                               members: node.members)
    }
    
    private func annotate(_ extensionKeyword: TokenSyntax, for protocolName: String) -> TokenSyntax {
        let commentPiece = TriviaPiece.lineComment(annotationForProtocol(named: protocolName))
        
        let newLeadingTrivia = extensionKeyword.leadingTrivia.appending(commentPiece).appending(.newlines(1))
        return SyntaxFactory.makeExtensionKeyword(leadingTrivia: newLeadingTrivia,
                                                  trailingTrivia: extensionKeyword.trailingTrivia)
    }
    
    private func isAnnotationNeeded(node: ExtensionDeclSyntax) -> Bool {
        guard let protocolName = node.inheritanceClause?
            .inheritedTypeCollection
            .first?
            .description
            .trimmingCharacters(in: .whitespacesAndNewlines) else {
                return false
        }
        
        guard let leadingTrivia = node.leadingTrivia else { return true }
        
        return leadingTrivia
            .filter { (piece) -> Bool in
                switch piece {
                case .lineComment(annotationForProtocol(named: protocolName)): return true
                default: return false
                }
            }
            .count == 0
    }
    
    private func annotationForProtocol(named protocolName: String) -> String {
        return "// MARK: - \(protocolName)"
    }
}
