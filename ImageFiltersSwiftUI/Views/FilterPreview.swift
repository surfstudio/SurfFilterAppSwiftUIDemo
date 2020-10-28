//
//  FilterPreview.swift
//  ImageFiltersSwiftUI
//
//  Created by Gregory Berngardt on 26.10.2020.
//

import SwiftUI

struct FilterPreview: View {
    
    @EnvironmentObject var state: FilterPreviewState
        
    @Binding var showingImagePicker: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            // Если полная картинка не готова, то пробуем предзаполнить превьюшкой
            let filteredImage: UIImage? = {
                if let fullImage = state.selectedFilteredItem?.image {
                    return fullImage
                } else {
                    return state.selectedFilteredItem?.thumbnail
                }
            }()
            
            if let selectedImage = filteredImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(Consts.contentCornerRadius)
                    .clipped()
                    .padding(.all, Consts.spacing)
                    .onTapGesture {
                        showingImagePicker.toggle()
                    }
            } else {
                RoundedRectangle(cornerRadius: Consts.contentCornerRadius)
                    .fill(Color("SecondaryColor"))
                    .padding(.all, Consts.spacing)
            }
            
            Spacer()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: Consts.spacing) {
                    ForEach(state.filteredPreviews) { filteredPreview in
                        PreviewItemView(
                            item: filteredPreview,
                            isSelected: filteredPreview.filter == state.selectedFilter,
                            selectedFilter: $state.selectedFilter
                        )
                    }
                }
                .padding([.horizontal, .bottom], Consts.spacing)
            }
        }
    }
}


struct FilterPreview_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            
            FilterPreview(showingImagePicker: .constant(false)).environmentObject(
                FilterPreviewState(
                    originalImage: testImages[2],
                    selectedFilter: .original,
                    filteredPreviews: [
                        FilteredImageItem(
                            filter: .original,
                            image: testImages[2],
                            thumbnail: testImages[2]
                        ),
                        FilteredImageItem(
                            filter: .fade,
                            image: testImages[2]
                        )
                    ]
                )
            )
            .previewDisplayName("Original with processed filters")

            FilterPreview(showingImagePicker: .constant(false)).environmentObject(
                FilterPreviewState(
                    originalImage: testImages[1],
                    selectedFilter: .fade,
                    filteredPreviews: [
                        FilteredImageItem(
                            filter: .original,
                            image: testImages[1],
                            thumbnail: testImages[1]
                        ),
                        FilteredImageItem(
                            filter: .fade,
                            thumbnail: testImages[2]
                        )
                    ]
                )
            )
            .previewDisplayName("Selected filter with processing")

            FilterPreview(showingImagePicker: .constant(false)).environmentObject(
                FilterPreviewState(
                    originalImage: testImages[3],
                    selectedFilter: .fade,
                    filteredPreviews: [
                        FilteredImageItem(
                            filter: .original,
                            thumbnail: testImages[3]
                        ),
                        FilteredImageItem(filter: .fade)
                    ]
                )
            )
            .previewDisplayName("Filter selected and all processing")
            
        }
    }
}
