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
    
    @Published private(set) var emojiArt: EmojiArtModel {
        didSet {
            if emojiArt.background != oldValue.background {
                fetchBackgroundImageDataIfNecessary()
            }
        }
    }
    
    @Published var selectedEmojis = Set<Emoji>()
    
    init() {
        emojiArt = EmojiArtModel()
    }
    
    var emojis: [Emoji] {
        emojiArt.emojis
    }
    
    var background: Background {
        emojiArt.background
    }
    
    @Published var backgroundImage: UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    
    enum BackgroundImageFetchStatus {
        case idle, fetching
    }
    
    private func fetchBackgroundImageDataIfNecessary() {
        backgroundImage = nil
        switch emojiArt.background {
        case .url(let url):
            //fetch url
            backgroundImageFetchStatus = .fetching
            DispatchQueue.global(qos: .userInitiated).async {
                let imageData = try? Data(contentsOf: url)
                DispatchQueue.main.async { [weak self] in
                    if self?.emojiArt.background == Background.url(url) {
                        self?.backgroundImageFetchStatus = .idle
                        if imageData != nil {
                            self?.backgroundImage = UIImage(data: imageData!)
                        }
                    }
                }
            }
        case .imageData(let data):
            backgroundImage = UIImage(data: data)
        case .blank:
            break
        }
    }
    
    //MARK: Intents
    
    func setBackground(_ background: Background) {
        emojiArt.background = background
    }
    
    func addEmoji(_ text: String, at location: (x: Int, y: Int), size: CGFloat) {
        emojiArt.addEmoji(text: text, at: location, size: Int(size))
    }
    
    func removeEmoji(_ emoji: Emoji) {
        emojiArt.removeEmoji(emoji)
    }
    
    func moveEmoji(_ emoji: Emoji, by offset: CGSize) {
        if let index = emojis.index(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: Emoji, by scale: CGFloat) {
        if let index = emojis.index(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
        }
    }
}
