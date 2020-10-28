//
//  PreviewItemView.swift
//  ImageFiltersSwiftUI
//
//  Created by Gregory Berngardt on 28.10.2020.
//

import SwiftUI

struct PreviewItemView: View {
    
    var item: FilteredImageItem
    var isSelected: Bool
    @Binding var selectedFilter: ImageFilter?
    
    var body: some View {
        if let previewImage = item.thumbnail {
            if isSelected {
                Image(uiImage: previewImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: Consts.previewSize.width, height: Consts.previewSize.height)
                    .cornerRadius(Consts.cardCornerRadius)
                    .clipped()
                    .opacity(0.5)
                    .overlay(
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .padding(5)
                                    .foregroundColor(.black)
                                    .opacity(0.3)
                            }
                        }
                    )
                    .transition(.opacity)
                    .animation(.easeInOut)
            } else {
                Image(uiImage: previewImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: Consts.previewSize.width, height: Consts.previewSize.height)
                    .cornerRadius(Consts.cardCornerRadius)
                    .clipped()
                    .onTapGesture {
                        withAnimation {
                            selectedFilter = item.filter
                        }
                }
            }
        } else {
            RoundedRectangle(cornerRadius: Consts.cardCornerRadius)
                .fill(Color("SecondaryColor"))
                .frame(width: Consts.previewSize.width, height: Consts.previewSize.height)
                .overlay(ProgressView())
        }
    }
}

struct PreviewItemView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewItemView(
            item: FilteredImageItem(filter: .chrome),
            isSelected: false,
            selectedFilter: .constant(nil)
        )
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Loading state")
        
        PreviewItemView(
            item: FilteredImageItem(filter: .chrome, thumbnail: testImages[0]),
            isSelected: false,
            selectedFilter: .constant(nil)
        )
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Filled state")

        PreviewItemView(
            item: FilteredImageItem(filter: .chrome, thumbnail: testImages[0]),
            isSelected: true,
            selectedFilter: .constant(nil)
        )
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Filled & selected state")
    }
}
