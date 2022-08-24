//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Alexis Schotte on 8/24/22.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    
    typealias Background = EmojiArtModel.Background
    typealias Emoji = EmojiArtModel.Emoji
    
    @Published private(set) var model: EmojiArtModel
    
    init() {
        model = EmojiArtModel()
    }
    
    var emojis: [Emoji] {
        model.emojis
    }
    
    var background: Background {
        model.background
    }
    
    //MARK: Intents
    
    func setBackground(_ background: Background) {
        model.background = background
    }
    
    func addEmoji(_ text: String, at location: (x: Int, y: Int), size: CGFloat) {
        model.addEmoji(text: text, at: location, size: Int(size))
    }
    
    func moveEmoji(_ emoji: Emoji, by offset: CGSize) {
        if let index = emojis.index(matching: emoji) {
            model.emojis[index].x += Int(offset.width)
            model.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: Emoji, by scale: CGFloat) {
        if let index = emojis.index(matching: emoji) {
            model.emojis[index].size = Int((CGFloat(model.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
        }
    }
}
