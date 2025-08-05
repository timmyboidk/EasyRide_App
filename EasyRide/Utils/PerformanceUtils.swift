import SwiftUI
import MapKit
import Combine

#if canImport(UIKit)
import UIKit

// MARK: - Performance Utilities
struct PerformanceUtils {
    // MARK: - List Performance
    
    /// Recommended batch size for lazy loading
    static let recommendedBatchSize = 20
    
    /// Recommended prefetch distance for lazy loading
    static let recommendedPrefetchDistance = 10
    
    /// Recommended debounce interval for search operations
    static let recommendedDebounceInterval: TimeInterval = 0.3
    
    /// Recommended throttle interval for continuous updates
    static let recommendedThrottleInterval: TimeInterval = 0.2
    
    // MARK: - Map Performance
    
    /// Recommended map annotation clustering distance
    static let mapClusteringDistance: Double = 50
    
    /// Recommended map update throttle interval
    static let mapUpdateThrottleInterval: TimeInterval = 0.5
    
    #if os(iOS)
    /// Recommended map visible region padding
    static let mapVisibleRegionPadding = UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100)
    #endif
    
    /// Calculate optimal map zoom level based on distance between points
    /// - Parameter coordinates: Array of coordinates to display
    /// - Returns: Optimal zoom level as MKCoordinateSpan
    static func optimalMapZoom(for coordinates: [CLLocationCoordinate2D]) -> MKCoordinateSpan {
        guard coordinates.count > 1 else {
            return MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        }
        
        let minLat = coordinates.map { $0.latitude }.min() ?? 0
        let maxLat = coordinates.map { $0.latitude }.max() ?? 0
        let minLon = coordinates.map { $0.longitude }.min() ?? 0
        let maxLon = coordinates.map { $0.longitude }.max() ?? 0
        
        // Add padding to ensure all points are visible
        let latDelta = max((maxLat - minLat) * 1.5, 0.01)
        let lonDelta = max((maxLon - minLon) * 1.5, 0.01)
        
        return MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
    }
    
    // MARK: - Image Performance
    
    /// Recommended image cache size in MB
    static let recommendedImageCacheSizeMB = 50
    
    #if os(iOS)
    /// Recommended image downsampling size for list items
    static let recommendedListImageSize = CGSize(width: 100, height: 100)
    
    /// Downsample an image to improve memory usage
    /// - Parameters:
    ///   - imageData: Raw image data
    ///   - pointSize: Target size in points
    ///   - scale: Screen scale (default: main screen scale)
    /// - Returns: Downsampled UIImage or nil if downsampling fails
    static func downsampleImage(
        imageData: Data,
        to pointSize: CGSize,
        scale: CGFloat = UIScreen.main.scale
    ) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions) else {
            return nil
        }
        
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary
        
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }
        
        return UIImage(cgImage: downsampledImage)
    }
    #endif

    // MARK: - Animation Performance
    
    /// Check if device is low-powered and should use reduced animations
    static var shouldUseReducedAnimations: Bool {
        #if os(iOS)
        // Check for older/lower-powered devices
        let deviceModel = UIDevice.current.model
        var systemInfo = utsname()
        uname(&systemInfo)
        
        // Check if device is older than iPhone X or equivalent
        if deviceModel == "iPhone" {
            // This is a simplified check - in production you'd want a more comprehensive device detection
            let isLowPoweredDevice = ProcessInfo.processInfo.processorCount < 4
            return isLowPoweredDevice || UIAccessibility.isReduceMotionEnabled
        }
        #endif
        
        return false
    }
    
    /// Get appropriate animation duration based on device capabilities
    /// - Parameter baseDuration: Base animation duration
    /// - Returns: Adjusted animation duration
    static func adaptiveAnimationDuration(_ baseDuration: Double) -> Double {
        if shouldUseReducedAnimations {
            return min(baseDuration * 0.7, 0.2) // Cap at 200ms for low-power devices
        }
        return baseDuration
    }
}

// MARK: - Debounced Search Publisher
extension Publishers {
    /// Creates a debounced search publisher to improve search performance
    static func debouncedSearch<T: Collection, U: Equatable>(
        text: Published<String>.Publisher,
        items: T,
        keyPath: KeyPath<T.Element, U>,
        debounceInterval: TimeInterval = PerformanceUtils.recommendedDebounceInterval
    ) -> AnyPublisher<[T.Element], Never> where U: StringProtocol {
        return text
            .debounce(for: .seconds(debounceInterval), scheduler: RunLoop.main)
            .map { searchText in
                guard !searchText.isEmpty else {
                    return Array(items)
                }
                
                return items.filter { item in
                    let value = item[keyPath: keyPath]
                    return value.localizedCaseInsensitiveContains(searchText)
                }
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Optimized List View Modifier
struct OptimizedListModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollDismissesKeyboard(.immediately)
            .scrollIndicators(.automatic)
            .scrollBounceBehavior(.basedOnSize)
    }
}

// MARK: - Optimized Map View Modifier
struct OptimizedMapModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onDisappear {
                // Release map resources when view disappears
                #if os(iOS)
                MKMapView.appearance().removeFromSuperview()
                #endif
            }
    }
}

// MARK: - View Extensions
extension View {
    /// Apply optimizations for list performance
    func optimizedList() -> some View {
        modifier(OptimizedListModifier())
    }
    
    /// Apply optimizations for map performance
    func optimizedMap() -> some View {
        modifier(OptimizedMapModifier())
    }
    
    #if os(iOS)
    /// Apply lazy loading behavior to a view
    func lazyLoad(
        visibleThreshold: CGFloat = 200,
        loadAction: @escaping () -> Void
    ) -> some View {
        self.background(
            GeometryReader { geometry in
                Color.clear.onAppear {
                    if geometry.frame(in: .global).maxY < UIScreen.main.bounds.height + visibleThreshold {
                        loadAction()
                    }
                }
            }
        )
    }
    #endif
}

#if canImport(UIKit)
// MARK: - Image Cache
class ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    
    init() {
        // Set recommended cache size
        cache.totalCostLimit = PerformanceUtils.recommendedImageCacheSizeMB * 1024 * 1024
    }
    
    func set(_ image: UIImage, forKey key: String) {
        let approximateSize = Int(image.size.width * image.size.height * 4) // 4 bytes per pixel (RGBA)
        cache.setObject(image, forKey: key as NSString, cost: approximateSize)
    }
    
    func get(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func clear() {
        cache.removeAllObjects()
    }
}

// MARK: - Cached Async Image
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let url: URL?
    private let scale: CGFloat
    private let transaction: SwiftUI.Transaction
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder
    
    @State private var cachedImage: UIImage?
    @State private var isLoading = false
    
    init(
        url: URL?,
        scale: CGFloat = 1.0,
        transaction: SwiftUI.Transaction = SwiftUI.Transaction(),
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let cachedImage = cachedImage {
                content(Image(uiImage: cachedImage))
            } else {
                if isLoading {
                    placeholder()
                } else {
                    AsyncImage(
                        url: url,
                        scale: scale,
                        transaction: transaction
                    ) { phase in
                        switch phase {
                        case .success(let image):
                            content(image)
                                .onAppear {
                                    if let url = url?.absoluteString {
                                        // Cache the loaded image
                                        if let uiImage = image.asUIImage() {
                                            ImageCache.shared.set(uiImage, forKey: url)
                                            self.cachedImage = uiImage
                                        }
                                    }
                                }
                        case .failure:
                            placeholder()
                        case .empty:
                            placeholder()
                        @unknown default:
                            placeholder()
                        }
                    }
                }
            }
        }
        .onAppear {
            loadCachedImage()
        }
    }
    
    private func loadCachedImage() {
        guard let urlString = url?.absoluteString else { return }
        
        if let cached = ImageCache.shared.get(forKey: urlString) {
            self.cachedImage = cached
            return
        }
        
        isLoading = true
    }
}

// MARK: - Image Extension
extension Image {
    @MainActor
    func asUIImage() -> UIImage? {
        let renderer = ImageRenderer(content: self)
        return renderer.uiImage
    }
}
#endif

// MARK: - Throttled Publisher
extension Publisher where Failure == Never {
    /// Throttle a publisher to improve performance for frequent updates
    func throttled(
        for interval: TimeInterval,
        scheduler: DispatchQueue = DispatchQueue.main,
        latest: Bool = true
    ) -> AnyPublisher<Output, Failure> {
        throttle(for: .seconds(interval), scheduler: scheduler, latest: latest)
            .eraseToAnyPublisher()
    }
}

// MARK: - Preview
#Preview {
    VStack {
        Text("Performance Utilities")
            .font(.headline)
        
        #if canImport(UIKit)
        CachedAsyncImage(
            url: URL(string: "https://picsum.photos/200")
        ) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            ProgressView()
        }
        .frame(width: 100, height: 100)
        .clipShape(Circle())
        #endif
    }
}
#endif
