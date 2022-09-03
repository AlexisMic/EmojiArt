//
//  PaletteEditor.swift
//  EmojiArt
//
//  Created by Alexis Schotte on 9/2/22.
//

import SwiftUI

struct PaletteEditor: View {
    
    @Binding var palette: Palette
    
    var body: some View {
        Form {
            nameText
            addEmojis
            removeEmogis
        }
        .navigationTitle("Edit \(palette.name)")
        .frame(minWidth: 300, minHeight: 350)
    }
    
    private var nameText: some View {
        Section("Name") {
            TextField("Name", text: $palette.name)
        }
    }
    
    @State private var emojiToAdd: String = ""
    
    private var addEmojis: some View {
        Section("Add Emojis") {
            TextField("", text: $emojiToAdd)
                .onChange(of: emojiToAdd) { newEmoji in
                    addEmoji()
                }
        }
    }
    
    @State private var emojiToRemove: String = ""
    
    private var removeEmogis: some View {
        Section("Remove Emojis") {
            let emojis = palette.emojis.withNoRepeatedCharacters.map {String($0)}
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(emojis, id:\.self) { emoji in
                    Text(emoji)
                        .onTapGesture {
                            withAnimation {
                                palette.emojis.removeAll(where: { String($0) == emoji })
                            }
                        }
                }
            }
            .font(.system(size: 32))
        }
    }
    
    private func addEmoji() {
        withAnimation {
            palette.emojis += emojiToAdd
                .filter({ $0.isEmoji})
            .withNoRepeatedCharacters
        }
    }
}

struct PaletteEditor_Previews: PreviewProvider {
    static var previews: some View {
        PaletteEditor(palette: .constant(PaletteStore(name: "Test").palette(at: 2)))
            .previewLayout(.fixed(width: /*@START_MENU_TOKEN@*/300.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/350.0/*@END_MENU_TOKEN@*/))
    }
}
