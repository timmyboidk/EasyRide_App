import SwiftUI
#if os(iOS)
import UIKit

struct OrientationTestView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @State private var items = Array(1...20)
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                GeometryReader { geometry in
                    ScrollView {
                        VStack(spacing: ResponsiveLayoutUtils.deviceSpecificSpacing()) {
                            // Orientation indicator
                            orientationIndicator
                            
                            // Device info
                            deviceInfoCard
                            
                            // Adaptive grid demonstration
                            adaptiveGridDemo
                            
                            // Orientation-specific layouts
                            orientationSpecificDemo
                            
                            // Safe area demonstration
                            safeAreaDemo(geometry: geometry)
                        }
                        .safeAreaAdaptive(additionalBottom: 20)
                    }
                    .orientationAdaptive()
                }
            }
            .navigationTitle("方向测试")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
    
    // MARK: - Orientation Indicator
    private var orientationIndicator: some View {
        VStack(spacing: 8) {
            Text("当前方向")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 16) {
                Label(
                    ResponsiveLayoutUtils.isPortrait() ? "纵向" : "横向",
                    systemImage: ResponsiveLayoutUtils.isPortrait() ? "iphone" : "iphone.landscape"
                )
                .foregroundColor(ResponsiveLayoutUtils.isPortrait() ? .blue : .green)
                
                Label(
                    "尺寸: \(horizontalSizeClass == .compact ? "紧凑" : "常规")",
                    systemImage: "rectangle.3.group"
                )
                .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        .orientationAdaptive()
    }
    
    // MARK: - Device Info Card
    private var deviceInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("设备信息")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("屏幕类别:")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(screenCategoryText)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                
                HStack {
                    Text("间距:")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(Int(ResponsiveLayoutUtils.deviceSpecificSpacing()))pt")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                
                HStack {
                    Text("水平尺寸类别:")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(horizontalSizeClass == .compact ? "紧凑" : "常规")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                
                HStack {
                    Text("垂直尺寸类别:")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(verticalSizeClass == .compact ? "紧凑" : "常规")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
    
    // MARK: - Adaptive Grid Demo
    private var adaptiveGridDemo: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("自适应网格布局")
                .font(.headline)
                .foregroundColor(.white)
            
            let columns = ResponsiveLayoutUtils.orientationAdaptiveColumns(
                for: horizontalSizeClass,
                portraitColumns: ResponsiveLayoutUtils.isCompactHorizontal(horizontalSizeClass) ? 2 : 3,
                landscapeColumns: ResponsiveLayoutUtils.isCompactHorizontal(horizontalSizeClass) ? 3 : 4,
                spacing: ResponsiveLayoutUtils.deviceSpecificSpacing()
            )
            
            LazyVGrid(columns: columns, spacing: ResponsiveLayoutUtils.deviceSpecificSpacing()) {
                ForEach(items.prefix(12), id: \.self) { item in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 60)
                        .overlay(
                            Text("\(item)")
                                .font(.headline)
                                .foregroundColor(.white)
                        )
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        .orientationAdaptive()
    }
    
    // MARK: - Orientation-Specific Demo
    private var orientationSpecificDemo: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("特定方向布局")
                .font(.headline)
                .foregroundColor(.white)
            
            orientationSpecific(
                portrait: {
                    VStack(spacing: 12) {
                        ForEach(1...3, id: \.self) { index in
                            orientationDemoCard(index: index, color: .purple)
                        }
                    }
                },
                landscape: {
                    HStack(spacing: 12) {
                        ForEach(1...3, id: \.self) { index in
                            orientationDemoCard(index: index, color: .orange)
                        }
                    }
                }
            )
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
    
    // MARK: - Safe Area Demo
    private func safeAreaDemo(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("安全区域信息")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("顶部:")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(Int(geometry.safeAreaInsets.top))pt")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                
                HStack {
                    Text("底部:")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(Int(geometry.safeAreaInsets.bottom))pt")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                
                HStack {
                    Text("前导:")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(Int(geometry.safeAreaInsets.leading))pt")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                
                HStack {
                    Text("尾随:")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(Int(geometry.safeAreaInsets.trailing))pt")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Views
    private func orientationDemoCard(index: Int, color: Color) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(color.opacity(0.3))
            .frame(height: 80)
            .overlay(
                VStack(spacing: 4) {
                    Text("卡片 \(index)")
                        .font(.headline)
                        .foregroundColor(color)
                    
                    Text(ResponsiveLayoutUtils.isPortrait() ? "纵向" : "横向")
                        .font(.caption)
                        .foregroundColor(color.opacity(0.8))
                }
            )
    }
    
    // MARK: - Computed Properties
    private var screenCategoryText: String {
        switch ResponsiveLayoutUtils.ScreenSizeCategory.current {
        case .compact:
            return "紧凑"
        case .regular:
            return "常规"
        case .large:
            return "大"
        case .extraLarge:
            return "特大"
        }
    }
}

#Preview {
    OrientationTestView()
}
#endif
