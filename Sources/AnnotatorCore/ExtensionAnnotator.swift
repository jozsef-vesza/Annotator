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
    
    override func visit(_ node: CodeBlockItemSyntax) -> Syntax {
        guard
            let extensionDeclaration = ExtensionDeclaration(node: node),
            let updatedLeadingTrivia = extensionDeclaration.updatedLeadingTrivia else {
                return node
        }
        
        let closingBraceIsPresent = extensionDeclaration.closingBraces.contains("}")
        let trailingTrivia = (extensionDeclaration.trailingTrivia ?? Trivia.zero).appending(.spaces(1))
        
        // MARK: - ProtocolName
        let extensionKeyword = SyntaxFactory.makeExtensionKeyword(
            leadingTrivia: updatedLeadingTrivia,
            trailingTrivia: trailingTrivia)
        
        // ClassName
        let typeIdentifier = SyntaxFactory.makeTypeIdentifier(extensionDeclaration.className)
        let protoName = SyntaxFactory.makeTypeIdentifier(extensionDeclaration.protocolName,
                                                         leadingTrivia: Trivia.spaces(1),
                                                         trailingTrivia: Trivia.spaces(1))
        
        // ProtocolName
        let protoIdentifier = SyntaxFactory.makeInheritedTypeList([SyntaxFactory.makeInheritedType(
            typeName: protoName,
            trailingComma: nil)])
        
        // ClassName: ProtocolName
        let inheritanceClause = SyntaxFactory.makeTypeInheritanceClause(
            colon: SyntaxFactory.makeColonToken(),
            inheritedTypeCollection: protoIdentifier)
        
        // {}
        let emptyMembersList = SyntaxFactory.makeMemberDeclBlock(
            leftBrace: SyntaxFactory.makeToken(TokenKind.leftBrace, presence: .present),
            members: SyntaxFactory.makeBlankMemberDeclList(),
            rightBrace: SyntaxFactory.makeToken(TokenKind.rightBrace, presence: closingBraceIsPresent ? .present : .missing))
        
        // extension ClassName: ProtocolName {}
        let annotated = SyntaxFactory.makeExtensionDecl(
            attributes: nil,
            modifiers: nil,
            extensionKeyword: extensionKeyword,
            extendedType: typeIdentifier,
            inheritanceClause: inheritanceClause,
            genericWhereClause: nil,
            members: extensionDeclaration.methodDeclarationList ?? emptyMembersList)
        
        return annotated
    }
}
