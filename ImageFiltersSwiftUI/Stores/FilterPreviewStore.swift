//
//  FilterPreviewStore.swift
//  ImageFiltersSwiftUI
//
//  Created by Gregory Berngardt on 28.10.2020.
//

import SwiftUI
import Combine

public struct FilteredImageItem: Identifiable {
    public var id: ImageFilter { filter }
    
    public let filter: ImageFilter
    
    /// Полноразмерное изображение. Заполняется только когда выделяется
    public var image: UIImage? = nil
    
    /// Изображение-превью
    public var thumbnail: UIImage? = nil
}

public class FilterPreviewState: ObservableObject {
    @Published public var originalImage: UIImage?
    @Published public var selectedFilter: ImageFilter?
    @Published public var filteredPreviews: [FilteredImageItem] = []
    
    public var selectedFilteredItem: FilteredImageItem? {
        self.filteredPreviews.first { $0.filter == selectedFilter }
    }
    
    init(originalImage: UIImage? = nil, selectedFilter: ImageFilter? = nil, filteredPreviews: [FilteredImageItem] = []) {
        self.originalImage = originalImage
        self.selectedFilter = selectedFilter
        self.filteredPreviews = filteredPreviews
    }
}

public class FilterPreviewStore: ObservableObject {
    @Published public var state: FilterPreviewState
    
//    @Published public var originalImage: UIImage?
//    @Published public var selectedFilter: ImageFilter?
//    @Published public var filteredPreviews: [FilteredImageItem] = []
//
//    public var selectedFilteredItem: FilteredImageItem? {
//        self.filteredPreviews.first { $0.filter == selectedFilter }
//    }
    
    private let filterApplyer = FilterApplyer()
    private var cancelBag: Set<AnyCancellable> = []
    
    private let queue = DispatchQueue(label: "ru.surf.test.FilterPreviewStore", attributes: [.concurrent])
    
    public enum StoreError: Error {
        case filterError
    }
    
    init(state: FilterPreviewState = FilterPreviewState()) {
        self.state = state
        
        if state.originalImage != nil {
            self.state.selectedFilter = .original
        }
        
        self.state.$selectedFilter.sink { selectedFilter in
            let (offset, updatedFilteredItem) = self.state.filteredPreviews.enumerated().first { $0.element.filter == selectedFilter } ?? (nil, nil)
            self.fillFilterPreviewIfNeeded(on: updatedFilteredItem) { result in
                switch result {
                case .success(let image):
                    if let resultOffset = offset {
                        self.state.filteredPreviews[resultOffset].image = image
                    }
                case .failure:
                    fatalError("Filter error!")
                }

            }
        }.store(in: &cancelBag)

        self.state.$originalImage.sink { newImage in
            self.buildPreviewsBased(on: newImage)
            self.state.selectedFilter = .original
        }.store(in: &cancelBag)
    }
        
//    init(originalImage: UIImage? = nil, selectedFilter: ImageFilter? = nil, filteredPreviews: [FilteredImageItem] = []) {
//        self.originalImage = originalImage
//
//        if originalImage != nil {
//            self.selectedFilter = .original
//        } else {
//            self.selectedFilter = selectedFilter
//        }
//
//        self.filteredPreviews = filteredPreviews
//
//        self.$selectedFilter.sink { selectedFilter in
//            let (offset, updatedFilteredItem) = self.filteredPreviews.enumerated().first { $0.element.filter == selectedFilter } ?? (nil, nil)
//            self.fillFilterPreviewIfNeeded(on: updatedFilteredItem) { result in
//                switch result {
//                case .success(let image):
//                    if let resultOffset = offset {
//                        self.filteredPreviews[resultOffset].image = image
//                    }
//                case .failure:
//                    fatalError("Filter error!")
//                }
//
//            }
//        }.store(in: &cancelBag)
//
//        self.$originalImage.sink { newImage in
//            self.buildPreviewsBased(on: newImage)
//            self.selectedFilter = .original
//        }.store(in: &cancelBag)
//    }
    
    /// Из исходного изображения строит массив сущностей `FilteredImageItem` с предзаполнеными превью на основе переданных фильтров
    /// - Parameter image: Исходное изображение
    /// - Parameter filters: Перечень применяемых фильтров
    private func buildPreviewsBased(on image: UIImage?, with filters: [ImageFilter] = ImageFilter.filters) {
        guard let mainImage = image else {
            return
        }
        
        // Предзаполняем превьюшки, для отображения плейсхолдеров
        self.state.filteredPreviews = [
            FilteredImageItem(
                filter: .original, image: image, thumbnail: image
            )
        ] + filters.map { FilteredImageItem(filter: $0) }
                
        queue.async {
            
            // Для каждого элемента фильтра подготавливаем превью
            for (index, filterPreview) in self.state.filteredPreviews.enumerated() {
                let thumbnailImage = self.filterApplyer.apply(
                    filterPreview.filter, to: mainImage,
                    size: Consts.previewSize.applying(.init(scaleX: UIScreen.main.scale, y: UIScreen.main.scale))
                )

                DispatchQueue.main.async {
                    self.state.filteredPreviews[index].thumbnail = thumbnailImage
                }
            }
            
        }
    }
    
    /// Возращает полноразмерное изображение с применением фильтра
    /// - Parameters:
    ///   - filteredImageItem: `FilteredImageItem` с фильтром, который нужно применить
    ///   - completion: Коллбэк с  итоговым изображением
    private func fillFilterPreviewIfNeeded(on filteredImageItem: FilteredImageItem?, completion: @escaping (Result<UIImage, StoreError>) -> Void) {
        guard
            let mainImage = self.state.originalImage,
            let filteredImageItem = filteredImageItem,
            filteredImageItem.image == nil else {
            return
        }

        queue.async {

            if let resImage = self.filterApplyer.apply(filteredImageItem.filter, to: mainImage) {
                DispatchQueue.main.async {
                    completion(.success(resImage))
                }
            } else {
                completion(.failure(.filterError))
            }
        }
    }
}
