//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Alexis Schotte on 8/23/22.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    
    //Constants
    let emojiFontSize: CGFloat = 40
    
    typealias Emoji = EmojiArtModel.Emoji
    
    @ObservedObject var document: EmojiArtDocument
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            pallete
        }
    }
    
    private var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.overlay(
                    OptionalImage(uiImage: document.backgroundImage)
                        .scaleEffect(zoomScale)
                        .position(convertFromEmojiCoordinates((0, 0), in: geometry))
                )
                .gesture(doubleTapToZoom(in: geometry.size))
                if document.backgroundImageFetchStatus == .fetching {
                    ProgressView()
                        .scaleEffect(2)
                } else {
                    ForEach(document.emojis) { emoji in
                        Text(emoji.text)
                            .font(.system(size: fontSize(emoji)))
                            .scaleEffect(zoomScale)
                            .position(emojiPosition(emoji, in: geometry))
                    }
                }
            }
            .clipped()
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { providers, location in
                return drop(providers: providers, at: location, in: geometry)
            }
            .gesture(panGesture().simultaneously(with: zoomGesture()))
        }
    }
    
    private var pallete: some View {
        ScrollingViewEmojis(emojis: emojisTest)
            .font(.system(size: emojiFontSize))
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        var found = providers.loadObjects(ofType: URL.self) { url in
            document.setBackground(.url(url.imageURL))
        }
        if !found {
            found = providers.loadObjects(ofType: UIImage.self) { image in
                if let data = image.jpegData(compressionQuality: 1.0) {
                    document.setBackground(.imageData(data))
                }
            }
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                if let emoji = string.first, emoji.isEmoji {
                    document.addEmoji(String(emoji), at: convertToEmojiCoordinates(location, in: geometry), size: emojiFontSize /  zoomScale)
                }
            }
        }
        return found
    }
    
    private func fontSize(_ emoji: Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
    
    private func emojiPosition(_ emoji: Emoji, in geometry: GeometryProxy) -> CGPoint {
        convertFromEmojiCoordinates((emoji.x, emoji.y), in: geometry)
    }
    
    private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int) {
        let center = geometry.frame(in: .local).center
        let location = CGPoint(
            x: (location.x - panOffSet.width  - center.x) / zoomScale,
            y: (location.y - panOffSet.height - center.y) / zoomScale
        )
        return (Int(location.x), Int(location.y))
    }
    
    private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(
            x: CGFloat(location.x) * zoomScale + center.x + panOffSet.width,
            y: CGFloat(location.y) * zoomScale + center.y + panOffSet.height
        )
    }
    
    // Drag the image (panning off)
    @State private var steadyStatePanOffSet: CGSize = CGSize.zero
    @GestureState private var gesturePanOffSet: CGSize = CGSize.zero
    
    private var panOffSet: CGSize {
        // using utility extensions to add CGSize
        (steadyStatePanOffSet + gesturePanOffSet) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffSet) { latestDragGestureValue, gesturePanOffSet, _ in
                gesturePanOffSet = latestDragGestureValue.translation / zoomScale
            }
            .onEnded { finalDragGestureValue in
                steadyStatePanOffSet = steadyStatePanOffSet + (finalDragGestureValue.translation / zoomScale)
            }
    }
    
    @State private var steadyStateZoomScale: CGFloat = 1
    @GestureState private var gestureZoomScale: CGFloat = 1
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }

    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, _ in
                gestureZoomScale = latestGestureScale
            }
            .onEnded { zoom in
                steadyStateZoomScale *= zoom
            }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    zoomToFit(document.backgroundImage, in: size)
                }
            }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0, size.width > 0, size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            steadyStatePanOffSet = .zero
            steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    
 
    var emojisTest = "😆😍🐨🙉🐣🍈🍅🥒🎾🥋🏂🚗🚔🚟🖥📱⏰🔆🅿️🇧🇷🇺🇸🇪🇺🥫🌯🍱🏆🥁🎻"
    
}

struct ScrollingViewEmojis: View {
    
    let emojis: String
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis.map({String($0)}), id:\.self) { emoji in
                    Text(emoji)
                        .onDrag { NSItemProvider(object: emoji as NSString) }
                }
            }
        }
    }
    
    
}









struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
