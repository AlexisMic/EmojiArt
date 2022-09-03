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
    
    private func isEmojiSelected(_ emoji: Emoji) -> Bool {
        if document.selectedEmojis.index(matching: emoji) != nil {
            return true
        } else {
            return false
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            PaletteChooser()
        }
    }
    
    @State private var showRemoveEmojiAlert = false
    @State private var backgroundImageAlert: IdentifiableAlert?
    @State private var confirmDeleteEmoji = false

    
    private var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.overlay(
                    OptionalImage(uiImage: document.backgroundImage)
                        .scaleEffect(zoomScale)
                        .position(convertFromEmojiCoordinates((0, 0), in: geometry))
                )
                .gesture(doubleTapToZoom(in: geometry.size))
                .gesture(tapBackground().exclusively(before: doubleTapToZoom(in: geometry.size)))
                if document.backgroundImageFetchStatus == .fetching {
                    ProgressView()
                        .scaleEffect(2)
                } else {
                    ForEach(document.emojis) { emoji in
                        Text(emoji.text)
                            .font(.system(size: fontSize(emoji) * zoomScale(for: emoji)))
                            .background(Circle().stroke(Color.red).opacity(isEmojiSelected(emoji) ? 0.5 : 0))
                            .position(emojiPosition(emoji, in: geometry))
                            .gesture(tapEmoji(emoji).exclusively(before: doubleTapToZoom(in: geometry.size)))
                            .gesture(dragEmojisGesture(emoji))
                            .gesture(longPressGesture(emoji))
                            .alert(isPresented: $showRemoveEmojiAlert) {
                                Alert(
                                    title: Text("Delete Emoji"),
                                    message: Text("Are you sure that you want to delete this emoji?"),
                                    primaryButton: .destructive(Text("Delete")) {
                                        document.removeEmoji(emoji)
                                    },
                                    secondaryButton: .cancel() {}
                                )
                            }
                    }
                }
            }
            .clipped()
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { providers, location in
                return drop(providers: providers, at: location, in: geometry)
            }
            .alert(item: $backgroundImageAlert) { alertToShow in
                alertToShow.alert()
            }
//            .alert(item: $showDropImageAlert) {
//                Alert(title: Text("Bad image"), message: Text("Can't upload this image."), dismissButton: .default(Text("OK")))
//            }
            .gesture(panGesture().simultaneously(with: zoomGesture()))
            .onChange(of: document.backgroundImageFetchStatus) { status in
                switch status {
                case .failed(let url) :
                    imageAlert(url)
//                    showDropImageAlert = true
                default:
                    break
                }
            }
            
        }
    }
    
    private func imageAlert(_ url: URL) {
        backgroundImageAlert = IdentifiableAlert(id: "url"+url.absoluteString) {
            Alert(title: Text("Bad image"), message: Text("Can't upload this image from \(url)."), dismissButton: .default(Text("OK")))
        }
    }
    
    private func tapEmoji(_ emoji: Emoji) -> some Gesture {
        TapGesture(count: 1)
            .onEnded {
                withAnimation {
                    document.selectedEmojis.toggleMembership(of: emoji)
                }
            }
    }
    
    private func longPressGesture(_ emoji: Emoji) -> some Gesture {
        LongPressGesture()
            .onEnded {_ in
                showRemoveEmojiAlert = true
            }
    }
    
    private func tapBackground() -> some Gesture {
        TapGesture(count: 1)
            .onEnded {
                document.selectedEmojis.removeAll()
            }
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
        if isEmojiSelected(emoji) {
            return convertFromEmojiCoordinatesForSelectedEmojis((emoji.x, emoji.y), in: geometry)
        }
        return convertFromEmojiCoordinatesForNonSelectedEmojis((emoji.x, emoji.y), in: geometry)
    }
    
    private func convertFromEmojiCoordinatesForSelectedEmojis(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(
            x: CGFloat(location.x) * zoomScale + center.x + gestureDragEmojisOffset.width,
            y: CGFloat(location.y) * zoomScale + center.y + gestureDragEmojisOffset.height
        )
    }
    
    private func convertFromEmojiCoordinatesForNonSelectedEmojis(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(
            x: CGFloat(location.x) * zoomScale + center.x,
            y: CGFloat(location.y) * zoomScale + center.y
        )
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
    
    // Drag the emoji
    @GestureState private var gestureDragEmojisOffset: CGSize = .zero
    
    private var emojiOffSet: CGSize {
        gestureDragEmojisOffset * zoomScale
    }
    
    private func dragEmojisGesture(_ emoji: Emoji) -> some Gesture {
            return DragGesture()
                .updating($gestureDragEmojisOffset) { latestDragGestureValue, gestureDragEmojisOffset, transition in
                        gestureDragEmojisOffset = latestDragGestureValue.translation / zoomScale
                }
                .onEnded { finalDragGestureValue in
                    let distanceDragged = finalDragGestureValue.translation / zoomScale
                        document.selectedEmojis.forEach { emoji in
                                document.moveEmoji(emoji, by: distanceDragged)
                        }
                }
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
                if document.selectedEmojis.isEmpty {
                    gesturePanOffSet = latestDragGestureValue.translation / zoomScale
                }
            }
            .onEnded { finalDragGestureValue in
                if document.selectedEmojis.isEmpty {
                    steadyStatePanOffSet = steadyStatePanOffSet + (finalDragGestureValue.translation / zoomScale)
                }
            }
    }
    
    @State private var steadyStateZoomScale: CGFloat = 1
    @GestureState private var gestureZoomScale: CGFloat = 1
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * (document.selectedEmojis.isEmpty ? gestureZoomScale : 1)
    }
    
    private func zoomScale(for emoji: Emoji) -> CGFloat {
        if isEmojiSelected(emoji) {
            return steadyStateZoomScale * gestureZoomScale
        } else {
            return zoomScale
        }
    }

    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, _ in
                gestureZoomScale = latestGestureScale
            }
            .onEnded { zoom in
                if document.selectedEmojis.isEmpty {
                    steadyStateZoomScale *= zoom
                    
                } else {
                    document.selectedEmojis.forEach { emoji in
                        document.scaleEmoji(emoji, by: zoom)
                    }
                }
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
}







struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
