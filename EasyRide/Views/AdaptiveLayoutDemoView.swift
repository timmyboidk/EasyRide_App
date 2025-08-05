import SwiftUI

#if os(iOS)
import UIKit

struct AdaptiveLayoutDemoView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

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
                    VStack(spacing: 24) {
                        // Header Section
                        headerSection

                        // Size Class Information
                        sizeClassInfoSection

                        // Adaptive Grid Demo
                        adaptiveGridSection

                        // Adaptive Stack Demo
                        adaptiveStackSection

                        // Responsive Cards Demo
                        responsiveCardsSection

                        // Device-Specific Spacing Demo
                        deviceSpecificSection
                    }
                    .adaptivePadding(
                        horizontalSizeClass,
                        compact: EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
                        regular: EdgeInsets(top: 24, leading: 32, bottom: 24, trailing: 32)
                    )
                }
            }
            .navigationTitle("自适应布局演示")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .navigationViewStyle(.stack) // Ensures consistent behavior across devices
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("响应式布局系统")
                .adaptiveFont(
                    horizontalSizeClass,
                    compactSize: .title2,
                    regularSize: .largeTitle
                )
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)

            Text("演示适应尺寸类别和设备方向的自适应布局")
                .adaptiveFont(
                    horizontalSizeClass,
                    compactSize: .body,
                    regularSize: .title3
                )
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }

    // MARK: - Size Class Information
    private var sizeClassInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("当前尺寸类别")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            HStack {
                VStack(alignment: .leading) {
                    Text("水平: \(sizeClassDescription(horizontalSizeClass))")
                    Text("垂直: \(sizeClassDescription(verticalSizeClass))")
                }
                .font(.subheadline)
                .foregroundColor(.gray)

                Spacer()

                Image(systemName: ResponsiveLayoutUtils.isCompactHorizontal(horizontalSizeClass) ? "iphone" : "ipad")
                    .font(.title2)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }

    // MARK: - Adaptive Grid Section
    private var adaptiveGridSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("自适应网格布局")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Text(ResponsiveLayoutUtils.isCompactHorizontal(horizontalSizeClass) ?
                 "紧凑的水平尺寸类别使用LazyVStack" :
                 "常规的水平尺寸类别使用LazyHStack")
                .font(.caption)
                .foregroundColor(.gray)

            // Using the adaptive grid function from ResponsiveLayoutUtils
            ResponsiveLayoutUtils.adaptiveGridFunction(
                items: Array(sampleItems.prefix(4)),
                horizontalSizeClass: horizontalSizeClass,
                spacing: ResponsiveLayoutUtils.adaptiveSpacing(for: horizontalSizeClass)
            ) { item in
                ServiceCard(item: item)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }

    // MARK: - Adaptive Stack Section
    private var adaptiveStackSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("自适应堆栈布局")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Text("根据尺寸类别在VStack和HStack之间自动切换")
                .font(.caption)
                .foregroundColor(.gray)

            AdaptiveStack(spacing: ResponsiveLayoutUtils.adaptiveSpacing(for: horizontalSizeClass)) {
                ForEach(Array(sampleItems.prefix(3))) { item in
                    CompactServiceCard(item: item)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }

    // MARK: - Responsive Cards Section
    private var responsiveCardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("响应式卡片宽度")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Text("卡片会根据可用的屏幕空间调整其宽度")
                .font(.caption)
                .foregroundColor(.gray)

            LazyVGrid(
                columns: ResponsiveLayoutUtils.adaptiveGridColumns(
                    for: horizontalSizeClass,
                    compactColumns: 1,
                    regularColumns: 2
                ),
                spacing: ResponsiveLayoutUtils.adaptiveSpacing(for: horizontalSizeClass)
            ) {
                ForEach(Array(sampleItems.prefix(4))) { item in
                    ResponsiveCard(item: item)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }

    // MARK: - Device-Specific Section
    private var deviceSpecificSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("特定于设备的适配")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 8) {
                Text("屏幕尺寸类别: \(screenSizeCategoryDescription)")
                Text("设备间距: \(Int(ResponsiveLayoutUtils.deviceSpecificSpacing()))pt")
                Text("已应用自适应填充")
            }
            .font(.subheadline)
            .foregroundColor(.gray)
        }
        .deviceAdaptive() // Uses device-specific padding
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }

    // MARK: - Helper Methods
    private func sizeClassDescription(_ sizeClass: UserInterfaceSizeClass?) -> String {
        switch sizeClass {
        case .compact:
            return "紧凑"
        case .regular:
            return "常规"
        case .none:
            return "未指定"
        @unknown default:
            return "未知"
        }
    }

    private var screenSizeCategoryDescription: String {
        switch ResponsiveLayoutUtils.ScreenSizeCategory.current {
        case .compact:
            return "紧凑 (iPhone SE, 12 mini)"
        case .regular:
            return "常规 (iPhone 12, 13)"
        case .large:
            return "大 (iPhone Pro Max)"
        case .extraLarge:
            return "特大 (iPad)"
        }
    }
}

// MARK: - Preview
#Preview("紧凑尺寸类别") {
    AdaptiveLayoutDemoView()
        .environment(\.horizontalSizeClass, .compact)
        .environment(\.verticalSizeClass, .regular)
}

#Preview("常规尺寸类别") {
    AdaptiveLayoutDemoView()
        .environment(\.horizontalSizeClass, .regular)
        .environment(\.verticalSizeClass, .regular)
}
#endif
