//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Alexis Schotte on 8/23/22.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    @StateObject var paletteStore = PaletteStore(name: "Default")
    
    var body: some Scene {
        DocumentGroup(newDocument: { EmojiArtDocument() }) { config in
            EmojiArtDocumentView(document: config.document)
                .environmentObject(paletteStore)
        }
        
        // Changed to DocumentGroup
//        WindowGroup {
//            EmojiArtDocumentView(document: document)
//                .environmentObject(paletteStore)
//        }
    }
}
