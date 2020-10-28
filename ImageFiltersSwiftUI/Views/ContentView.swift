//
//  ContentView.swift
//  ImageFiltersSwiftUI
//
//  Created by Gregory Berngardt on 22.10.2020.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject private var filterPreviewState: FilterPreviewState

    @State private var showingShareSheet: Bool = false
    @State private var showingImagePicker: Bool = false
    
    var body: some View {
        NavigationView {
            if filterPreviewState.originalImage != nil {
                FilterPreview(showingImagePicker: $showingImagePicker)
                    .environmentObject(filterPreviewState)
                    .toolbar {
                        ToolbarItem(placement: .automatic) {
                            Button(action: {
                                showingShareSheet.toggle()
                            }) {
                                if showingShareSheet {
                                    ProgressView()
                                } else {
                                    Label("Share", systemImage: "square.and.arrow.up")}
                            }
                            .disabled(filterPreviewState.selectedFilter == nil)
                            
                        }
                }
                .navigationBarTitle(filterPreviewState.selectedFilter?.name.capitalized ?? "", displayMode: .large)
                .sheet(isPresented: $showingShareSheet) {
                    if let filteredImageItem = filterPreviewState.selectedFilteredItem {
                        ImageShareView(filteredImageItem: filteredImageItem)
                    }
                }
            } else {
                MainPlaceholderView() {
                    showingImagePicker.toggle()
                }
                .ignoresSafeArea()
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(sourceType: .photoLibrary) { image in
                filterPreviewState.originalImage = image
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .environmentObject(
                    FilterPreviewStore(state: FilterPreviewState(originalImage: testImages[0])).state
                )
            ContentView()
                .environmentObject(
                    FilterPreviewStore().state
                )
        }
    }
}
