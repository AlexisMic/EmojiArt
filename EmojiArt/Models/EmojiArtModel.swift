//
//  EmojiArtModel.swift
//  EmojiArt
//
//  Created by Alexis Schotte on 8/23/22.
//

import Foundation

struct EmojiArtModel: Codable {
    var background = Background.blank
    var emojis = [Emoji]()
    
    private var uniqueEmojiId = 0
    
    mutating func addEmoji(text: String, at position: (x: Int, y: Int), size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(id: uniqueEmojiId, text: text, at: (x: position.x, y: position.y), size: size))
    }
    
    mutating func removeEmoji(_ emoji: Emoji) {
        emojis.remove(at: emojis.index(matching: emoji)!)
    }
    
    // Save to File
    func json() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    init(json: Data) throws {
        self = try JSONDecoder().decode(EmojiArtModel.self, from: json)
    }
    
    init(url: URL) throws {
        let data = try Data(contentsOf: url)
        self = try EmojiArtModel(json: data)
    }
    
    init() { }
    
    struct Emoji: Identifiable, Hashable, Codable {
        let id: Int
        let text: String
        var x: Int      // from the center
        var y: Int      // from the center
        var size: Int
        
        fileprivate init(id: Int, text: String, at position: (x: Int, y: Int), size: Int) {
            self.id = id
            self.text = text
            self.x = position.x
            self.y = position.y
            self.size = size
            
        }
        
    }
    

}
