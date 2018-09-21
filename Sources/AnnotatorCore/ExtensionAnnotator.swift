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
        // Expected structure:
        // extension ClassName: ProtocolName {}
        guard
            node.description.contains("extension"),
            node.description.contains(":"),
            node.leadingTriviaLength.utf8Length < TriviaPiece.lineComment("// MARK:").sourceLength.utf8Length else {
                return node
        }
        
        let components = node.description.components(separatedBy: " ")
        guard components.count == 4 else { return node }
        
        let className = String(components[1].dropLast())
        let protocolName = String(components[2])
        let closingBraceIsPresent = components[3].contains("}")
        let commentPiece = TriviaPiece.lineComment("// MARK: - \(protocolName)")
        let leadingTrivia = Trivia.newlines(2).appending(commentPiece).appending(.newlines(1))
        let trailingTrivia = (node.trailingTrivia ?? Trivia.zero).appending(.spaces(1))
        
        // MARK: - ProtocolName
        let extensionKeyword = SyntaxFactory.makeExtensionKeyword(
            leadingTrivia: leadingTrivia,
            trailingTrivia: trailingTrivia)
        
        // ClassName
        let typeIdentifier = SyntaxFactory.makeTypeIdentifier(className)
        let protoName = SyntaxFactory.makeTypeIdentifier(protocolName, leadingTrivia: Trivia.spaces(1))
        
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
