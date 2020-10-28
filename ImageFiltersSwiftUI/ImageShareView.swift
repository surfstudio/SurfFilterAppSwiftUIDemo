//
//  ImageShareView.swift
//  ImageFiltersSwiftUI
//
//  Created by Gregory Berngardt on 28.10.2020.
//

import SwiftUI
import LinkPresentation

public struct ImageShareView: UIViewControllerRepresentable {

    let filteredImageItem: FilteredImageItem

    public func makeUIViewController(context: UIViewControllerRepresentableContext<ImageShareView>) -> UIActivityViewController {
        
        let activityItems: [Any] = [filteredImageItem.image, context.coordinator].compactMap { $0 }
        return UIActivityViewController(activityItems: activityItems,
                                        applicationActivities: nil)
    }

    public func updateUIViewController(_ uiViewController: UIActivityViewController,
                                context: UIViewControllerRepresentableContext<ImageShareView>) {

    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(filteredImageItem: filteredImageItem)
    }
    
    final public class Coordinator: NSObject, UIActivityItemSource {
        
        private let filteredImageItem: FilteredImageItem
        
        init(filteredImageItem: FilteredImageItem) {
            self.filteredImageItem = filteredImageItem
        }
        
        public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
            return ""
        }

        public func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
            return nil
        }

        public func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
            guard let thumbnail = filteredImageItem.thumbnail else {
                return nil
            }
            let imageProvider = NSItemProvider(object: thumbnail)
            let metadata = LPLinkMetadata()
            metadata.imageProvider = imageProvider
            metadata.title = "Filtered image"
            metadata.originalURL = URL(fileURLWithPath: filteredImageItem.filter.name.capitalized)
            return metadata
        }
    }
}

