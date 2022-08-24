//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Alexis Schotte on 8/23/22.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    
    @ObservedObject var emojiArtDocument: EmojiArtDocument
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            pallete
        }
        
    }
    
    private var documentBody: some View {
        Color.yellow
    }
    
    private var pallete: some View {
        ScrollingViewEmojis(emojis: emojisTest)
    }
    
 
    var emojisTest = "😆😍🐨🙉🐣🍈🍅🥒🎾🥋🏂🚗🚔🚟🖥📱⏰🔆🅿️🇧🇷🇺🇸🇪🇺"
    
}

struct ScrollingViewEmojis: View {
    
    let emojis: String
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis.map({String($0)}), id:\.self) { emoji in
                    Text(emoji)
                }
            }
        }
    }
    
    
}









struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(emojiArtDocument: EmojiArtDocument())
    }
}
