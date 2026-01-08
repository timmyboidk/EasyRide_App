import SwiftUI

#if os(iOS)
import UIKit

struct TripConfigurationView: View {
    @State private var viewModel = TripConfigurationViewModel()
    @Environment(\.dismiss) private var dismiss
    @Binding var navigationPath: NavigationPath

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Mode Selector
                    modeSelector

                    // Configuration Content
                    configurationContent
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle(Text("行程配置", bundle: nil))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.showingAddressPicker) {
            // Placeholder for Address Picker UI
            Text("地址选择器")
        }
    }

    // MARK: - Subviews
    private var modeSelector: some View {
        HStack(spacing: 12) {
            ForEach(TripMode.allCases, id: \.self) { mode in
                ModeCard(
                    mode: mode,
                    isSelected: viewModel.selectedMode == mode,
                    action: {
                        withAnimation {
                            viewModel.selectedMode = mode
                        }
                    }
                )
            }
        }
        .padding(6)
        .background(Color.primary.opacity(0.05))
        .cornerRadius(12)
    }

    @ViewBuilder
    private var configurationContent: some View {
        VStack(spacing: 16) {
            AddressInputField(
                title: "上车地点",
                address: $viewModel.pickupAddress,
                placeholder: "请输入上车地点",
                icon: "circle.fill"
            ) {
                viewModel.showingAddressPicker = true
                viewModel.addressPickerType = .pickup
            }

            AddressInputField(
                title: "目的地",
                address: $viewModel.destinationAddress,
                placeholder: "请输入目的地",
                icon: "mappin.and.ellipse"
            ) {
                viewModel.showingAddressPicker = true
                viewModel.addressPickerType = .destination
            }

            // Continue Button
            Button(action: {
                navigationPath.append(BookingStep.valueAddedServicesPayment)
            }) {
                Text("继续", bundle: nil)
                    .fontWeight(.heavy)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primary)
                    .foregroundColor(Color(.systemBackground))
                    .cornerRadius(12)
            }
            .padding(.top)
        }
    }
}

// MARK: - Supporting Views

struct ModeCard: View {
    let mode: TripMode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(mode.displayName)
                .fontWeight(.bold)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.primary : Color.clear)
                .foregroundColor(isSelected ? Color(.systemBackground) : .primary)
                .cornerRadius(8)
        }
    }
}

struct AddressInputField: View {
    let title: String
    @Binding var address: String
    let placeholder: String
    let icon: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Button(action: action) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(.secondary)
                    
                    if address.isEmpty {
                        Text(placeholder)
                            .foregroundColor(.secondary)
                    } else {
                        Text(address)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
        }
    }
}

#Preview {
    // Wrap in NavigationStack for previewing navigation behavior
    NavigationStack {
        TripConfigurationView(navigationPath: .constant(NavigationPath()))
    }
}
#endif
