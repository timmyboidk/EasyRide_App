import SwiftUI

#if os(iOS)
import UIKit

// Custom observer to detect orientation changes
class OrientationObserver: ObservableObject {
    @Published var isLandscape = false
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        self.isLandscape = UIDevice.current.orientation.isLandscape
    }
    
    @objc func orientationChanged() {
        self.isLandscape = UIDevice.current.orientation.isLandscape
    }
}

struct OrientationResponsiveDemo: View {
    @StateObject private var orientationObserver = OrientationObserver()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @State private var orientationChanged = false
    
    // Sample data for demonstration
    private let sampleItems = [
        DemoItem(title: "机场接送", subtitle: "快速可靠", icon: "airplane"),
        DemoItem(title: "长途", subtitle: "舒适的旅程", icon: "car.fill"),
        DemoItem(title: "包车服务", subtitle: "高级体验", icon: "star.fill"),
        DemoItem(title: "拼车", subtitle: "环保", icon: "person.2.fill"),
        DemoItem(title: "城市观光", subtitle: "探索城市", icon: "map.fill"),
        DemoItem(title: "商务出行", subtitle: "专业服务", icon: "briefcase.fill")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: orientationObserver.isLandscape ? 16 : 24) {
                        // Header Section
                        headerSection(isLandscape: orientationObserver.isLandscape)
                        
                        // Orientation Information
                        orientationInfoSection(isLandscape: orientationObserver.isLandscape)
                        
                        // Orientation-Adaptive Grid
                        orientationAdaptiveGridSection(isLandscape: orientationObserver.isLandscape)
                        
                        // Content Overflow Demo
                        contentOverflowSection(isLandscape: orientationObserver.isLandscape)
                        
                        // Safe Area Demo
                        safeAreaDemoSection(isLandscape: orientationObserver.isLandscape)
                        
                        // Device Size Adaptation Demo
                        deviceSizeAdaptationSection(isLandscape: orientationObserver.isLandscape)
                    }
                    .padding(orientationObserver.isLandscape ? EdgeInsets(top: 12, leading: 24, bottom: 16, trailing: 24) : EdgeInsets(top: 16, leading: 16, bottom: 24, trailing: 16))
                }
            }
            .navigationTitle("方向响应")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onChange(of: orientationObserver.isLandscape) { _, _ in
                orientationChanged = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    orientationChanged = false
                }
            }
        }
    }
    
    // MARK: - Header Section
    private func headerSection(isLandscape: Bool) -> some View {
        VStack(spacing: 12) {
            Text("方向和设备支持")
                .font(isLandscape ? .title2 : .title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
            
            Text("演示适应方向变化和不同设备尺寸的布局")
                .font(isLandscape ? .subheadline : .body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineLimit(isLandscape ? 1 : 2)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(orientationChanged ? Color.white : Color.clear, lineWidth: 2)
                .animation(.easeInOut(duration: 0.5), value: orientationChanged)
        )
    }
    
    // MARK: - Orientation Information
    private func orientationInfoSection(isLandscape: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("方向信息")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Label(
                        "当前: \(isLandscape ? "横向" : "纵向")",
                        systemImage: isLandscape ? "iphone.landscape" : "iphone"
                    )
                    .foregroundColor(isLandscape ? .green : .blue)
                    
                    Label(
                        "水平: \(horizontalSizeClass == .compact ? "紧凑" : "常规")",
                        systemImage: "arrow.left.and.right"
                    )
                    .foregroundColor(.gray)
                    
                    Label(
                        "垂直: \(verticalSizeClass == .compact ? "紧凑" : "常规")",
                        systemImage: "arrow.up.and.down"
                    )
                    .foregroundColor(.gray)
                }
                .font(.subheadline)
                
                Spacer()
                
                // Orientation indicator
                Image(systemName: isLandscape ? "iphone.landscape" : "iphone")
                    .font(.largeTitle)
                    .foregroundColor(isLandscape ? .green : .blue)
                    .rotationEffect(orientationChanged ? .degrees(360) : .degrees(0))
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: orientationChanged)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
    
    // MARK: - Orientation-Adaptive Grid
    private func orientationAdaptiveGridSection(isLandscape: Bool) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("方向自适应网格")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("网格会根据方向自动调整列数")
                .font(.caption)
                .foregroundColor(.gray)
            
            let columns = isLandscape ?
                [GridItem(.adaptive(minimum: 120))] :
                [GridItem(.adaptive(minimum: 150))]
            
            LazyVGrid(columns: columns, spacing: isLandscape ? 12 : 16) {
                ForEach(sampleItems) { item in
                    OrientationResponsiveCard(item: item, isLandscape: isLandscape)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
    
    // MARK: - Content Overflow Section
    private func contentOverflowSection(isLandscape: Bool) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("内容溢出处理")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("滚动行为会适应方向")
                .font(.caption)
                .foregroundColor(.gray)
            
            // Content that might overflow
            VStack(spacing: 8) {
                ForEach(1...3, id: \.self) { index in
                    HStack {
                        Image(systemName: "text.bubble.fill")
                            .foregroundColor(.white)
                        
                        Text("内容项 \(index) 的文本可能很长，需要根据设备方向进行不同的滚动")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }
            }
            .frame(height: isLandscape ? 150 : 200)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
    
    // MARK: - Safe Area Demo
    private func safeAreaDemoSection(isLandscape: Bool) -> some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 16) {
                Text("安全区域适应")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("布局在两个方向上都尊重安全区域")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("顶部安全区域:")
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(Int(geometry.safeAreaInsets.top))pt")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    
                    HStack {
                        Text("底部安全区域:")
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(Int(geometry.safeAreaInsets.bottom))pt")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    
                    HStack {
                        Text("前导安全区域:")
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(Int(geometry.safeAreaInsets.leading))pt")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    
                    HStack {
                        Text("尾随安全区域:")
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(Int(geometry.safeAreaInsets.trailing))pt")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                }
                .font(.subheadline)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
        }
        .frame(height: 180)
    }
    
    // MARK: - Device Size Adaptation
    private func deviceSizeAdaptationSection(isLandscape: Bool) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("设备尺寸适应")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("UI元素根据设备尺寸进行缩放")
                .font(.caption)
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("设备类别:")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(deviceCategoryText)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                
                HStack {
                    Text("缩放因子:")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(String(format: "%.2f", ResponsiveLayoutUtils.deviceSizeScaleFactor()))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                
                HStack {
                    Text("自适应高度:")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(Int(ResponsiveLayoutUtils.deviceAwareHeight(baseHeight: 100)))pt")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
            }
            .font(.subheadline)
            
            // Demonstration of scaled UI elements
            HStack(spacing: 16) {
                ForEach(1...3, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(
                            width: ResponsiveLayoutUtils.deviceAwareHeight(baseHeight: 50),
                            height: ResponsiveLayoutUtils.deviceAwareHeight(baseHeight: 50)
                        )
                        .overlay(
                            Text("\(index)")
                                .font(.headline)
                                .foregroundColor(.white)
                        )
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Properties
    private var deviceCategoryText: String {
        switch ResponsiveLayoutUtils.ScreenSizeCategory.current {
        case .compact:
            return "紧凑 (iPhone SE, mini)"
        case .regular:
            return "常规 (iPhone standard)"
        case .large:
            return "大 (iPhone Pro Max)"
        case .extraLarge:
            return "特大 (iPad)"
        }
    }
}

// MARK: - Orientation Responsive Card
struct OrientationResponsiveCard: View {
    let item: DemoItem
    let isLandscape: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: item.icon)
                .font(isLandscape ? .body : .title3)
                .foregroundColor(.white)
            
            Text(item.title)
                .font(isLandscape ? .caption : .subheadline)
                .fontWeight(.semibold)
                .lineLimit(1)
                .foregroundColor(.white)
            
            if !isLandscape {
                Text(item.subtitle)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
        }
        .frame(height: isLandscape ? 70 : 90)
        .frame(maxWidth: .infinity)
        .padding(isLandscape ? 8 : 12)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
    }
}

// MARK: - Preview
#Preview("纵向") {
    OrientationResponsiveDemo()
}

#Preview("横向") {
    OrientationResponsiveDemo()
        .previewInterfaceOrientation(.landscapeLeft)
}

#endif
