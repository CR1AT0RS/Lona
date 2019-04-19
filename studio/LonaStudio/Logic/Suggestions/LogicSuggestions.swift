//
//  LogicSuggestions.swift
//  LonaStudio
//
//  Created by Devin Abbott on 4/14/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import Foundation
import Logic

extension Bool {
    static func expressionSuggestions(node: LGCSyntaxNode, query: String) -> [LogicSuggestionItem] {
        let trueSuggestion = LogicSuggestionItem(
            title: "true",
            category: "Booleans".uppercased(),
            node: .expression(true.expressionNode)
        )

        let falseSuggestion = LogicSuggestionItem(
            title: "false",
            category: "Booleans".uppercased(),
            node: .expression(false.expressionNode)
        )

        return [trueSuggestion, falseSuggestion].titleContains(prefix: query)
    }
}

extension Int {
    static func expressionSuggestions(node: LGCSyntaxNode, query: String) -> [LogicSuggestionItem] {
        let customSuggestion = LogicSuggestionItem(
            title: "Whole Number: \(query)",
            category: "Numbers".uppercased(),
            node: .expression((Int(query) ?? 0).expressionNode),
            disabled: Int(query) == nil
        )

        return [customSuggestion]
    }
}

extension CGFloat {
    static func expressionSuggestions(node: LGCSyntaxNode, query: String) -> [LogicSuggestionItem] {
        let customSuggestion = LogicSuggestionItem(
            title: "Number: \(query)",
            category: "Numbers".uppercased(),
            node: .expression(CGFloat(Double(query) ?? 0).expressionNode),
            disabled: Double(query) == nil
        )

        return [customSuggestion]
    }
}

extension String {
    static func expressionSuggestions(node: LGCSyntaxNode, query: String) -> [LogicSuggestionItem] {
        let customSuggestion = LogicSuggestionItem(
            title: "String: \"\(query)\"",
            category: "Strings".uppercased(),
            node: .expression(query.expressionNode)
        )

        return [customSuggestion]
    }
}
