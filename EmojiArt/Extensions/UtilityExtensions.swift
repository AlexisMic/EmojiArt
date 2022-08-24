//
//  UtilityExtensions.swift
//  EmojiArt
//
//  Created by Alexis Schotte on 8/24/22.
//

import SwiftUI

extension Collection where Element: Identifiable {
    func index(matching element: Element) -> Self.Index? {
        firstIndex(where: {$0.id == element.id})
    }
}
