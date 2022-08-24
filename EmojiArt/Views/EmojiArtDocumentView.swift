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
        Text("Hello, world!")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(emojiArtDocument: EmojiArtDocument())
    }
}
