//
//  ExtensionDeclaration.swift
//  AnnotatorCore
//
//  Created by József Vesza on 2018. 09. 21..
//

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
