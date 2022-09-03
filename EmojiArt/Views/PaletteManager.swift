//
//  PaletteManager.swift
//  EmojiArt
//
//  Created by Alexis Schotte on 9/2/22.
//

import SwiftUI

struct PaletteManager: View {
    
    @EnvironmentObject var store: PaletteStore
    @Environment(\.presentationMode) var presentationMode
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.palettes.indices, id:\.self) { index in
                    NavigationLink(destination: PaletteEditor(palette: $store.palettes[index])) {
                        VStack(alignment: .leading) {
                            Text(store.palettes[index].name)
                            Text(store.palettes[index].emojis)
                        }
                        .gesture(editMode == .active ? tap : nil)
                    }
                }
                .onDelete { indexSet in
                    store.palettes.remove(at: indexSet.first!)
                }
                .onMove { indexSet, newPosition in
                    store.palettes.move(fromOffsets: indexSet, toOffset: newPosition)
                }
//                // Prof solution with his utility extensions
    //                ForEach (store.palettes) { palette in
    //                    NavigationLink(destination: PaletteEditor(palette: $store.palettes[palette])) {
    //                        VStack(alignment: .leading) {
    //                            Text(palette.name)
    //                            Text(palette.emojis)
    //                        }
    //                    }
    //                }
            }
            .navigationTitle("Manage Palettes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    // this UIDevice verifies the device. In this case it doesn't show the button if it's an ipad
                    if UIDevice.current.userInterfaceIdiom != .pad {
                        Button("Close") {
                            // This isPresented verification is not necessary, but remains as example of how to use it
                            if presentationMode.wrappedValue.isPresented {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    } else {
                        EmptyView()
                    }
                }
            }
            .environment(\.editMode, $editMode)
        }
    }
    
    private var tap: some Gesture {
        TapGesture(count: 1)
            .onEnded {
                print("tapped")
            }
    }
}

struct PaletteManager_Previews: PreviewProvider {
    static var previews: some View {
        PaletteManager()
            .previewDevice("iPhone 8")
            .environmentObject(PaletteStore(name: "Test"))
    }
}
