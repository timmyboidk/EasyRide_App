import SwiftUI

#if os(iOS)
import UIKit

// MARK: - Responsive Layout Demo
struct ResponsiveLayoutDemo: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    // The AdaptiveGrid requires items that are Identifiable.
    // We'll use the DemoItem struct that's defined in AdaptiveLayoutDemoView.swift
    // and create some sample data.
    let demoItems: [DemoItem] = (1...12).map {
        DemoItem(title: "Item \($0)", subtitle: "Subtitle", icon: "star")
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: ResponsiveLayoutUtils.deviceSpecificSpacing()) {
                    // Demo 1: Adaptive Grid
                    adaptiveGridDemo
                    
                    // Demo 2: Adaptive Stack
                    adaptiveStackDemo
                    
                    // Demo 3: Orientation-Specific Layout
                    orientationSpecificDemo
                    
                    // Demo 4: Device-Specific Spacing
                    deviceSpecificDemo
                }
                .deviceAdaptive()
            }
            .navigationTitle("Responsive Layout Demo")
            .orientationAdaptive()
        }
    }
    
    // MARK: - Adaptive Grid Demo
    private var adaptiveGridDemo: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Adaptive Grid Layout")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Automatically adjusts columns based on size class and orientation")
                .font(.caption)
                .foregroundColor(.secondary)
            
            AdaptiveGrid(
                items: demoItems,
                compactColumns: 2,
                regularColumns: 3,
                spacing: ResponsiveLayoutUtils.deviceSpecificSpacing()
            ) { (item: DemoItem) in
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.3))
                    .frame(height: 60)
                    .overlay(
                        Text(item.title)
                            .font(.headline)
                            .foregroundColor(.blue)
                    )
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Adaptive Stack Demo
    private var adaptiveStackDemo: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Adaptive Stack Layout")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("VStack for compact, HStack for regular size classes")
                .font(.caption)
                .foregroundColor(.secondary)
            
            AdaptiveStack(spacing: ResponsiveLayoutUtils.deviceSpecificSpacing()) {
                ForEach(1...3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.green.opacity(0.3))
                        .frame(height: 80)
                        .overlay(
                            VStack(spacing: 4) {
                                Text("Item \(index)")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                
                                Text(ResponsiveLayoutUtils.isCompactHorizontal(horizontalSizeClass) ? "Compact" : "Regular")
                                    .font(.caption)
                                    .foregroundColor(.green.opacity(0.8))
                            }
                        )
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Orientation-Specific Demo
    private var orientationSpecificDemo: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Orientation-Specific Layout")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Different layouts for portrait vs landscape")
                .font(.caption)
                .foregroundColor(.secondary)
            
            orientationSpecific(
                portrait: {
                    VStack(spacing: 12) {
                        ForEach(1...2, id: \.self) { index in
                            orientationDemoCard(index: index, color: .purple, orientation: "Portrait")
                        }
                    }
                },
                landscape: {
                    HStack(spacing: 12) {
                        ForEach(1...2, id: \.self) { index in
                            orientationDemoCard(index: index, color: .orange, orientation: "Landscape")
                        }
                    }
                }
            )
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Device-Specific Demo
    private var deviceSpecificDemo: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Device-Specific Adaptations")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Screen Category:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(screenCategoryText)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("Device Spacing:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(ResponsiveLayoutUtils.deviceSpecificSpacing()))pt")
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("Size Class:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(horizontalSizeClass == .compact ? "Compact" : "Regular")
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("Orientation:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(ResponsiveLayoutUtils.isPortrait() ? "Portrait" : "Landscape")
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Helper Views
    private func orientationDemoCard(index: Int, color: Color, orientation: String) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(color.opacity(0.3))
            .frame(height: 80)
            .overlay(
                VStack(spacing: 4) {
                    Text("Card \(index)")
                        .font(.headline)
                        .foregroundColor(color)
                    
                    Text(orientation)
                        .font(.caption)
                        .foregroundColor(color.opacity(0.8))
                }
            )
    }
    
    // MARK: - Computed Properties
    private var screenCategoryText: String {
        switch ResponsiveLayoutUtils.ScreenSizeCategory.current {
        case .compact:
            return "Compact"
        case .regular:
            return "Regular"
        case .large:
            return "Large"
        case .extraLarge:
            return "Extra Large"
        }
    }
}

#Preview {
    ResponsiveLayoutDemo()
}

#endif // os(iOS)
