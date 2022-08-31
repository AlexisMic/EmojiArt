//
//  Palette.swift
//  EmojiArt
//
//  Created by Alexis Schotte on 8/30/22.
//

import Foundation

struct Palette: Identifiable, Codable {
    
    var id: Int
    var name: String
    var emojis: String
    
    init(id: Int, name: String, emojis: String) {
        self.id = id
        self.name = name
        self.emojis = emojis
    }
    
}
