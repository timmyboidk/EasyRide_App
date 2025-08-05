import SwiftUI
import MapKit
#if os(iOS)
import UIKit
#endif

// Simple compilation test for OrderTrackingView and OrderTrackingViewModel
struct OrderTrackingCompilationTest {
    
    func testOrderTrackingViewModelCompilation() {
        let apiService = EasyRideAPIService.shared
        let viewModel = OrderTrackingViewModel(apiService: apiService)
        
        // Test basic properties
        _ = viewModel.isLoading
        _ = viewModel.isMatching
        _ = viewModel.isTrackingActive
        _ = viewModel.canCommunicateWithDriver
        _ = viewModel.statusDisplayText
        _ = viewModel.estimatedArrivalText
    }
    
    func testOrderTrackingViewCompilation() {
        let view = OrderTrackingView(orderId: "test-order-id")
        _ = view.body
    }
    
    func testDriverMatchingAnimationViewCompilation() {
        let view = DriverMatchingAnimationView()
        _ = view.body
    }
    
    func testMapMarkerViewCompilation() {
        let annotation = MapAnnotationItem(
            id: "test",
            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            color: .blue,
            title: "Test"
        )
        let view = MapMarkerView(annotation: annotation)
        _ = view.body
    }
}