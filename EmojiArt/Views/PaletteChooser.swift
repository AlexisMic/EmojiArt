//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by Alexis Schotte on 8/31/22.
//

import SwiftUI

struct PaletteChooser: View {
    
    @EnvironmentObject var store: PaletteStore
    @State private var indexPalette = 0
    let emojiFontSize: CGFloat = 40
    var emojiFont: Font { .system(size: emojiFontSize)}
    
    var body: some View {
        let palette = store.palette(at: indexPalette)
        HStack {
            paletteChooserButton
            ScrollingViewEmojis(emojis: palette.emojis)
                .font(emojiFont)
        }
    }
    
    private var paletteChooserButton: some View {
        Button {
            let maxIndex = store.palettes.count - 1
            if indexPalette < maxIndex {
                indexPalette += 1
            } else {
                indexPalette = 0
            }
        } label: {
            Image(systemName: "paintpalette")
                .font(emojiFont)
                .padding(.horizontal)
        }

    }
}

struct ScrollingViewEmojis: View {
    
    let emojis: String
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis.withNoRepeatedCharacters.map({String($0)}), id:\.self) { emoji in
                    Text(emoji)
                        .onDrag { NSItemProvider(object: emoji as NSString) }
                }
            }
        }
    }
}

struct PaletteChooser_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooser()
    }
}
