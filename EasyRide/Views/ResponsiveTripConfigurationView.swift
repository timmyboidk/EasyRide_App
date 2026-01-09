import SwiftUI

#if os(iOS)
import UIKit

// MARK: - Supporting Types (Defined to resolve scope errors)
enum ResponsiveTripMode: CaseIterable {
    case freeRoute
    case customRoute

    var displayName: String {
        switch self {
        case .freeRoute: return LocalizationUtils.localized("Free_Route_Display")
        case .customRoute: return LocalizationUtils.localized("Custom_Route_Display")
        }
    }

    var description: String {
        switch self {
        case .freeRoute: return LocalizationUtils.localized("Free_Route_Desc")
        case .customRoute: return LocalizationUtils.localized("Custom_Route_Desc")
        }
    }
}

struct ResponsiveTripStop: Identifiable {
    let id = UUID()
    let location: ResponsiveLocation
}

struct ResponsiveLocation {
    let address: String
}

struct ResponsiveTripConfigurationView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var selectedMode: ResponsiveTripMode = .freeRoute
    @State private var pickupAddress: String = ""
    @State private var destinationAddress: String = ""
    @State private var scheduledTime = Date()
    @State private var passengerCount = 1
    @State private var notes = ""
    @State private var isNotesExpanded = false
    @State private var customStops: [ResponsiveTripStop] = []

    @Binding var navigationPath: NavigationPath

    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundColor(for: colorScheme).ignoresSafeArea()
                GeometryReader { geometry in
                    ScrollView {
                        AdaptiveLayoutContainer { sizeClass in
                            VStack(spacing: ResponsiveLayoutUtils.adaptiveSpacing(for: sizeClass)) {
                                // Mode Selector
                                modeSelector

                                // Configuration Content
                                configurationContent

                                // Continue Button
                                continueButton
                            }
                            .adaptivePadding(
                                sizeClass,
                                compact: EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20),
                                regular: EdgeInsets(top: 24, leading: 32, bottom: 24, trailing: 32)
                            )
                        }
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .orientationAdaptive()
                }
            }
            .navigationTitle(LocalizationUtils.localized("Trip_Config"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizationUtils.localized("Cancel")) {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Mode Selector
    private var modeSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizationUtils.localized("Trip_Type"))
                .font(.headline)
                .foregroundColor(.primary)

            AdaptiveStack(spacing: ResponsiveLayoutUtils.adaptiveSpacing(for: horizontalSizeClass, compact: 12, regular: 16)) {
                ForEach(ResponsiveTripMode.allCases, id: \.self) { mode in
                    ResponsiveModeCard(
                        mode: mode,
                        isSelected: selectedMode == mode,
                        horizontalSizeClass: horizontalSizeClass
                    ) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedMode = mode
                        }
                    }
                }
            }
        }
        .padding(ResponsiveLayoutUtils.adaptiveSpacing(for: horizontalSizeClass))
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }

    // MARK: - Configuration Content
    private var configurationContent: some View {
        VStack(spacing: ResponsiveLayoutUtils.adaptiveSpacing(for: horizontalSizeClass)) {
            switch selectedMode {
            case .freeRoute:
                freeRouteConfiguration
            case .customRoute:
                customRouteConfiguration
            }
        }
    }

    // MARK: - Free Route Configuration
    private var freeRouteConfiguration: some View {
        VStack(spacing: ResponsiveLayoutUtils.adaptiveSpacing(for: horizontalSizeClass, compact: 16, regular: 20)) {
            // Address inputs in adaptive layout
            if ResponsiveLayoutUtils.isCompactHorizontal(horizontalSizeClass) {
                LazyVStack(spacing: 16) {
                    addressInputs
                }
            } else {
                LazyHStack(spacing: 24) {
                    addressInputs
                }
            }

            // Time and passenger controls
            AdaptiveStack(spacing: ResponsiveLayoutUtils.adaptiveSpacing(for: horizontalSizeClass)) {
                scheduledTimePicker
                passengerStepper
            }

            // Notes section
            notesSection
        }
    }

    // MARK: - Custom Route Configuration
    private var customRouteConfiguration: some View {
        VStack(spacing: ResponsiveLayoutUtils.adaptiveSpacing(for: horizontalSizeClass, compact: 16, regular: 20)) {
            // Pickup location
            ResponsiveAddressInputField(
                title: LocalizationUtils.localized("Pickup_Location"),
                address: $pickupAddress,
                placeholder: LocalizationUtils.localized("Enter_Departure_Address"),
                icon: "location.circle.fill",
                horizontalSizeClass: horizontalSizeClass
            ) {
                // Handle address picker
            }

            // Custom stops and map in adaptive layout
            if ResponsiveLayoutUtils.isCompactHorizontal(horizontalSizeClass) {
                LazyVStack(spacing: 16) {
                    customStopsSection
                    mapPreviewSection
                }
            } else {
                LazyHStack(alignment: .top, spacing: 24) {
                    customStopsSection
                        .frame(maxWidth: .infinity)
                    mapPreviewSection
                        .frame(maxWidth: .infinity)
                }
            }

            // Controls
            AdaptiveStack(spacing: ResponsiveLayoutUtils.adaptiveSpacing(for: horizontalSizeClass)) {
                passengerStepper
                notesSection
            }
        }
    }

    // MARK: - Address Inputs
    private var addressInputs: some View {
        Group {
            ResponsiveAddressInputField(
                title: LocalizationUtils.localized("Pickup_Location"),
                address: $pickupAddress,
                placeholder: LocalizationUtils.localized("Enter_Departure_Address"),
                icon: "location.circle.fill",
                horizontalSizeClass: horizontalSizeClass
            ) {
                // Handle pickup address picker
            }

            ResponsiveAddressInputField(
                title: LocalizationUtils.localized("Destination"),
                address: $destinationAddress,
                placeholder: LocalizationUtils.localized("Enter_Destination"),
                icon: "location.fill",
                horizontalSizeClass: horizontalSizeClass
            ) {
                // Handle destination address picker
            }
        }
    }

    // MARK: - Scheduled Time Picker
    private var scheduledTimePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizationUtils.localized("Departure_Time"))
                .adaptiveFont(horizontalSizeClass, compactSize: .headline, regularSize: .title3)
                .foregroundColor(.primary)

            DatePicker(
                LocalizationUtils.localized("Select_Time"),
                selection: $scheduledTime,
                in: Date()...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.compact)
        }
        .padding(ResponsiveLayoutUtils.adaptiveSpacing(for: horizontalSizeClass))
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }

    // MARK: - Passenger Stepper
    private var passengerStepper: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizationUtils.localized("Passenger_Count"))
                .adaptiveFont(horizontalSizeClass, compactSize: .headline, regularSize: .title3)
                .foregroundColor(.primary)

            HStack {
                Text("\(passengerCount)" + LocalizationUtils.localized("Passenger_Unit"))
                    .font(.body)
                    .foregroundColor(.primary)

                Spacer()

                HStack(spacing: 16) {
                    Button(action: {
                        if passengerCount > 1 {
                            passengerCount -= 1
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundColor(passengerCount > 1 ? .primary : .gray)
                    }
                    .disabled(passengerCount <= 1)

                    Text("\(passengerCount)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .frame(minWidth: 30)
                        .foregroundColor(.primary)

                    Button(action: {
                        if passengerCount < 8 {
                            passengerCount += 1
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(passengerCount < 8 ? .primary : .gray)
                    }
                    .disabled(passengerCount >= 8)
                }
            }
        }
        .padding(ResponsiveLayoutUtils.adaptiveSpacing(for: horizontalSizeClass))
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }

    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(LocalizationUtils.localized("Notes"))
                    .adaptiveFont(horizontalSizeClass, compactSize: .headline, regularSize: .title3)
                    .foregroundColor(.primary)

                Spacer()

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isNotesExpanded.toggle()
                    }
                }) {
                    Image(systemName: isNotesExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
            }

            if isNotesExpanded {
                TextField(
                    LocalizationUtils.localized("Trip_Notes_Placeholder"),
                    text: $notes,
                    axis: .vertical
                )
                .textFieldStyle(.plain)
                .padding(12)
                .background(Theme.primaryColor(for: colorScheme).opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .foregroundColor(.primary)
            }
        }
        .padding(ResponsiveLayoutUtils.adaptiveSpacing(for: horizontalSizeClass))
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }

    // MARK: - Custom Stops Section
    private var customStopsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(LocalizationUtils.localized("Route_Stops"))
                    .adaptiveFont(horizontalSizeClass, compactSize: .headline, regularSize: .title3)
                    .foregroundColor(.primary)

                Spacer()

                Button(action: {
                    // Add new stop
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .font(.caption)
                        Text(LocalizationUtils.localized("Add_Stop_Label"))
                            .font(.caption)
                    }
                    .foregroundColor(.primary)
                }
            }

            if customStops.isEmpty {
                // Empty state
                RoundedRectangle(cornerRadius: 12)
                    .fill(Theme.primaryColor(for: colorScheme).opacity(0.1))
                    .frame(height: ResponsiveLayoutUtils.isCompactHorizontal(horizontalSizeClass) ? 80 : 120)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "plus.circle.dashed")
                                .font(.title3)
                                .foregroundColor(.gray)
                            Text(LocalizationUtils.localized("Add_First_Stop"))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
            } else {
                // Stops list with adaptive layout
                LazyVStack(spacing: 8) {
                    ForEach(customStops.indices, id: \.self) { index in
                        ResponsiveCustomStopRow(
                            stop: customStops[index],
                            index: index,
                            horizontalSizeClass: horizontalSizeClass
                        )
                    }
                }
            }
        }
        .padding(ResponsiveLayoutUtils.adaptiveSpacing(for: horizontalSizeClass))
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }

    // MARK: - Map Preview Section
    private var mapPreviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizationUtils.localized("Route_Preview"))
                .adaptiveFont(horizontalSizeClass, compactSize: .headline, regularSize: .title3)
                .foregroundColor(.primary)

            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.3))
                .frame(height: ResponsiveLayoutUtils.isCompactHorizontal(horizontalSizeClass) ? 200 : 300)
                .overlay(
                    VStack(spacing: 12) {
                        Image(systemName: "map.fill")
                            .font(.title)
                            .foregroundColor(.primary)

                        Text(LocalizationUtils.localized("Map_Preview_Title"))
                            .adaptiveFont(horizontalSizeClass, compactSize: .headline, regularSize: .title2)
                            .foregroundColor(.primary)

                        if !customStops.isEmpty {
                            VStack(spacing: 4) {
                                Text(String(format: LocalizationUtils.localized("Stop_Count_Format"), customStops.count))
                                    .font(.caption)
                                    .foregroundColor(.gray)

                                Text("~30 " + LocalizationUtils.localized("Minutes"))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        } else {
                            Text(LocalizationUtils.localized("Add_Stop_To_See_Route"))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
        }
        .padding(ResponsiveLayoutUtils.adaptiveSpacing(for: horizontalSizeClass))
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }

    // MARK: - Continue Button
    private var continueButton: some View {
        Button(action: {
            // Handle continue action
            navigationPath.append("valueAddedServices")
        }) {
            HStack {
                Text(LocalizationUtils.localized("Continue_Arrow"))
                    .adaptiveFont(horizontalSizeClass, compactSize: .headline, regularSize: .title3)
                    .foregroundColor(Color(.systemBackground))

                Image(systemName: "arrow.right")
                    .font(.headline)
                    .foregroundColor(Color(.systemBackground))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, ResponsiveLayoutUtils.adaptiveSpacing(for: horizontalSizeClass, compact: 16, regular: 20))
            .background(Theme.primaryColor(for: colorScheme))
            .cornerRadius(12)
        }
        .padding(.top, 8)
    }
}

// MARK: - Supporting Views (Defined to resolve scope issue)
struct ResponsiveModeCard: View {
    let mode: ResponsiveTripMode
    let isSelected: Bool
    let horizontalSizeClass: UserInterfaceSizeClass?
    let action: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: mode == .freeRoute ? "location.north.line.fill" : "map.fill")
                    .font(.title2)
                    .foregroundColor(isSelected ? Color(.systemBackground) : .primary)

                Text(mode.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? Color(.systemBackground) : .primary)

                Text(mode.description)
                    .font(.caption2)
                    .foregroundColor(isSelected ? Color(.systemBackground).opacity(0.8) : .secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, ResponsiveLayoutUtils.adaptiveSpacing(for: horizontalSizeClass, compact: 16, regular: 20))
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Theme.primaryColor(for: colorScheme) : Theme.primaryColor(for: colorScheme).opacity(0.1))
            )
        }
        .buttonStyle(.plain)
        .orientationAdaptive()
    }
}

struct ResponsiveAddressInputField: View {
    let title: String
    @Binding var address: String
    let placeholder: String
    let icon: String
    let horizontalSizeClass: UserInterfaceSizeClass?
    let onTap: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .adaptiveFont(horizontalSizeClass, compactSize: .headline, regularSize: .title3) // Removed 'for:'
                .foregroundColor(.primary)

            Button(action: onTap) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(.primary)
                        .frame(width: 24)

                    Text(address.isEmpty ? placeholder : address)
                        .font(.body)
                        .foregroundColor(address.isEmpty ? .secondary : .primary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(ResponsiveLayoutUtils.adaptiveSpacing(for: horizontalSizeClass))
                .background(Theme.primaryColor(for: colorScheme).opacity(0.1))
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
    }
}

struct ResponsiveCustomStopRow: View {
    let stop: ResponsiveTripStop
    let index: Int
    let horizontalSizeClass: UserInterfaceSizeClass?
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 12) {
            // Drag handle
            Image(systemName: "line.3.horizontal")
                .foregroundColor(.gray)

            // Stop info
            VStack(alignment: .leading, spacing: 4) {
                Text(stop.location.address)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .foregroundColor(.primary)

                Text("停靠点 \(index + 1) • 15 " + LocalizationUtils.localized("Minutes"))
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            // Edit button
            Button(action: {}) {
                Image(systemName: "pencil")
                    .font(.caption)
                    .foregroundColor(.primary)
            }

            // Delete button
            Button(action: {}) {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, ResponsiveLayoutUtils.adaptiveSpacing(for: horizontalSizeClass, compact: 12, regular: 16))
        .background(Theme.primaryColor(for: colorScheme).opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    ResponsiveTripConfigurationView(navigationPath: .constant(NavigationPath()))
}

#endif
