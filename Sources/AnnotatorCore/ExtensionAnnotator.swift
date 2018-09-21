//
//  ExtensionAnnotator.swift
//  AnnotatorCore
//
//  Created by József Vesza on 2018. 09. 21..
//

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
        let protoName = SyntaxFactory.makeTypeIdentifier(extensionDeclaration.protocolName, leadingTrivia: Trivia.spaces(1))
        
        // ProtocolName
        let protoIdentifier = SyntaxFactory.makeInheritedTypeList([SyntaxFactory.makeInheritedType(
            typeName: protoName,
            trailingComma: nil)])
        
        // ClassName: ProtocolName
        let inheritanceClause = SyntaxFactory.makeTypeInheritanceClause(
            colon: SyntaxFactory.makeColonToken(),
            inheritedTypeCollection: protoIdentifier)
        
        // {}
        let members = SyntaxFactory.makeMemberDeclBlock(
            leftBrace: SyntaxFactory.makeToken(TokenKind.leftBrace, presence: .present, leadingTrivia: Trivia.spaces(1)),
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
            members: members)
        
        return annotated
    }
}
