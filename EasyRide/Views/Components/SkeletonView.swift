import SwiftUI

#if os(iOS)
import UIKit

// MARK: - Skeleton View
/// A view that displays a loading skeleton with shimmer effect
struct SkeletonView: View {
    let shape: SkeletonShape
    let size: CGSize
    let cornerRadius: CGFloat

    @State private var isAnimating = false

    init(
        shape: SkeletonShape = .rectangle,
        size: CGSize,
        cornerRadius: CGFloat = 8
    ) {
        self.shape = shape
        self.size = size
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        AnyShape(shape.swiftUIShape(cornerRadius: cornerRadius))
            .fill(Color(UIColor.systemGray5))
            .frame(width: size.width, height: size.height)
            .overlay(
                AnyShape(shape.swiftUIShape(cornerRadius: cornerRadius))
                    .fill(
                        LinearGradient(
                            gradient: Gradient(
                                colors: [
                                    Color(UIColor.systemGray5),
                                    Color(UIColor.systemGray4),
                                    Color(UIColor.systemGray5)
                                ]
                            ),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .mask(
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(
                                        colors: [
                                            .clear,
                                            .white.opacity(0.9),
                                            .clear
                                        ]
                                    ),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .rotationEffect(.degrees(70))
                            .offset(x: isAnimating ? size.width * 2 : -size.width)
                    )
            )
            .animation(
                Animation
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
            .accessibilityLabel("Loading")
    }
}

// MARK: - Skeleton Shape Types
enum SkeletonShape {
    case rectangle
    case circle
    case ellipse

    func swiftUIShape(cornerRadius: CGFloat) -> some Shape {
        switch self {
        case .rectangle:
            return AnyShape(RoundedRectangle(cornerRadius: cornerRadius))
        case .circle:
            return AnyShape(Circle())
        case .ellipse:
            return AnyShape(Ellipse())
        }
    }
}

// MARK: - Skeleton Card View
/// A pre-configured skeleton view for cards
struct SkeletonCardView: View {
    let height: CGFloat

    init(height: CGFloat = 200) {
        self.height = height
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            SkeletonView(
                shape: .rectangle,
                size: CGSize(width: 120, height: 20),
                cornerRadius: 4
            )

            // Content
            SkeletonView(
                shape: .rectangle,
                size: CGSize(width: CGFloat.infinity, height: 80),
                cornerRadius: 8
            )

            HStack {
                // Footer left
                SkeletonView(
                    shape: .rectangle,
                    size: CGSize(width: 80, height: 16),
                    cornerRadius: 4
                )

                Spacer()

                // Footer right
                SkeletonView(
                    shape: .rectangle,
                    size: CGSize(width: 60, height: 16),
                    cornerRadius: 4
                )
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Skeleton List View
/// A pre-configured skeleton view for lists
struct SkeletonListView: View {
    let rows: Int
    let rowHeight: CGFloat

    init(rows: Int = 5, rowHeight: CGFloat = 60) {
        self.rows = rows
        self.rowHeight = rowHeight
    }

    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<rows, id: \.self) { index in
                SkeletonRowView(height: rowHeight)
                    .animation(
                        .easeInOut(duration: 0.5).delay(Double(index) * 0.05),
                        value: index
                    )
            }
        }
    }
}

// MARK: - Skeleton Row View
/// A pre-configured skeleton view for list rows
struct SkeletonRowView: View {
    let height: CGFloat

    var body: some View {
        HStack(spacing: 12) {
            // Leading circle (avatar/icon)
            SkeletonView(
                shape: .circle,
                size: CGSize(width: height * 0.7, height: height * 0.7)
            )

            VStack(alignment: .leading, spacing: 8) {
                // Title
                SkeletonView(
                    shape: .rectangle,
                    size: CGSize(width: 150, height: 16),
                    cornerRadius: 4
                )

                // Subtitle
                SkeletonView(
                    shape: .rectangle,
                    size: CGSize(width: 100, height: 12),
                    cornerRadius: 4
                )
            }

            Spacer()

            // Trailing element
            SkeletonView(
                shape: .rectangle,
                size: CGSize(width: 40, height: 20),
                cornerRadius: 4
            )
        }
        .padding(.horizontal)
        .frame(height: height)
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - Skeleton Grid View
/// A pre-configured skeleton view for grids
struct SkeletonGridView: View {
    let columns: Int
    let rows: Int
    let spacing: CGFloat

    init(columns: Int = 2, rows: Int = 2, spacing: CGFloat = 16) {
        self.columns = columns
        self.rows = rows
        self.spacing = spacing
    }

    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns),
            spacing: spacing
        ) {
            ForEach(0..<(columns * rows), id: \.self) { index in
                SkeletonCardView()
                    .animation(
                        .easeInOut(duration: 0.5).delay(Double(index) * 0.05),
                        value: index
                    )
            }
        }
        .padding(.horizontal)
    }
}

// Helper to erase the concrete shape type
struct AnyShape: Shape {
    private let _path: @Sendable (CGRect) -> Path

    init<S: Shape>(_ wrapped: S) {
        _path = { rect in
            wrapped.path(in: rect)
        }
    }

    func path(in rect: CGRect) -> Path {
        _path(rect)
    }
}


// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        Text("Skeleton Views")
            .font(.headline)

        SkeletonCardView()
            .padding(.horizontal)

        SkeletonListView(rows: 3)

        SkeletonGridView(columns: 2, rows: 1)
    }
}
#endif
