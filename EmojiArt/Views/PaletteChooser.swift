//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by Alexis Schotte on 8/31/22.
//

import SwiftUI

struct PaletteChooser: View {
    
    @EnvironmentObject var store: PaletteStore
    @SceneStorage("PaletteChooser.chosenPaletteIndex") private var indexPalette = 0
    @State private var showManagerSheet = false
    @State private var editPalette: Palette?
    
    let emojiFontSize: CGFloat = 40
    var emojiFont: Font { .system(size: emojiFontSize)}
    
    var body: some View {
        let palette = store.palette(at: indexPalette)
        HStack {
            paletteChooserButton
            body(for: palette)
        }
        .clipped()
    }
    
    private var paletteChooserButton: some View {
        Button {
            let maxIndex = store.palettes.count - 1
            if indexPalette < maxIndex {
                withAnimation {
                    indexPalette += 1
                }
            } else {
                withAnimation() {
                    indexPalette = 0
                }
            }
        } label: {
            Image(systemName: "paintpalette")
                .font(emojiFont)
                .padding(.horizontal)
        }
        .contextMenu { contextMenu }
    }
    
    @ViewBuilder
    private var contextMenu: some View {
        AnimatedActionButton(title: "Edit", systemImage: "pencil") {
//            showSheet = true
            editPalette = store.palettes[indexPalette]
        }
        AnimatedActionButton(title: "New", systemImage: "plus") {
            store.insertPalette(name: "New", emojis: "", at: indexPalette)
//            showShet = true
            editPalette = store.palettes[indexPalette]
        }
        AnimatedActionButton(title: "Delete", systemImage: "minus.circle") {
            indexPalette = store.removePalette(at: indexPalette)
        }
        gotoMenu
        AnimatedActionButton(title: "Manager", systemImage: "slider.vertical.3") {
            showManagerSheet = true
        }
    }
    
    private var gotoMenu: some View {
        Menu {
            ForEach (store.palettes) { palette in
                AnimatedActionButton(title: palette.name) {
                    if let index = store.palettes.index(matching: palette) {
                        indexPalette = index
                    }
                }
            }
        } label: {
            Label("Go To", systemImage: "text.insert")
        }
    }
    
    private func body(for palette: Palette) -> some View {
        HStack {
            Text(palette.name)
            ScrollingViewEmojis(emojis: palette.emojis)
                .font(emojiFont)
        }
        .id(palette.id)
        .transition(rollTransition)
//        //Changed the bool showSheet for a optional check
//        .popover(isPresented: $showSheet) {
//            PaletteEditor(palette: $store.palettes[indexPalette])
//        }
        .popover(item: $editPalette) { palette in
            PaletteEditor(palette: $store.palettes[palette])
        }
        .sheet(isPresented: $showManagerSheet) {
            PaletteManager()
        }
    }
    
    private var rollTransition: AnyTransition {
        AnyTransition.asymmetric(insertion: .offset(x: 0, y: emojiFontSize), removal: .offset(x: 0, y: -emojiFontSize))
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
