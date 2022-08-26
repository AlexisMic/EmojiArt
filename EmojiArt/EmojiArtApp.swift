//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Alexis Schotte on 8/23/22.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    let viewModel = EmojiArtDocument()
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: viewModel)
        }
    }
}
