import SwiftUI

#if os(iOS)
struct ServiceSelectionView: View {
    @State private var viewModel: ServiceSelectionViewModel
    @Environment(AppState.self) private var appState
    @Namespace private var animationNamespace
    @Binding var navigationPath: NavigationPath
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.colorScheme) private var colorScheme
    
    init(appState: AppState, navigationPath: Binding<NavigationPath>) {
        self._viewModel = State(initialValue: ServiceSelectionViewModel(appState: appState))
        self._navigationPath = navigationPath
    }
    
    var body: some View {
        ZStack {
            // Pure white/black background
            Theme.backgroundColor(for: colorScheme).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Charter Type Cards
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(ServiceType.allCases) { serviceType in
                            CharterTypeCardView(
                                serviceType: serviceType,
                                isSelected: viewModel.isServiceSelected(serviceType),
                                estimatedPrice: viewModel.formattedPrice(for: serviceType),
                                isLoading: viewModel.isLoadingPrices,
                                animationNamespace: animationNamespace
                            ) {
                                selectService(serviceType)
                            }
                            .matchedGeometryEffect(
                                id: viewModel.serviceCardId(for: serviceType),
                                in: animationNamespace
                            )
                        }
                    }
                    .padding()
                }
                
                // Floating Action Button
                if viewModel.canProceed {
                    floatingActionButton
                        .padding(.horizontal)
                        .padding(.bottom)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .navigationTitle(LocalizationUtils.localized("Select_Charter_Type"))
        .navigationBarTitleDisplayMode(.inline)
        .alert(LocalizationUtils.localized("Price_Estimation_Error"), isPresented: .constant(viewModel.priceEstimationError != nil)) {
            Button(LocalizationUtils.localized("OK")) {
                viewModel.priceEstimationError = nil
            }
        } message: {
            Text(viewModel.priceEstimationError?.localizedDescription ?? "")
        }
    }
    
    // MARK: - Floating Action Button
    private var floatingActionButton: some View {
        Button(action: proceedToNextStep) {
            Text(LocalizationUtils.localized("Continue"))
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Theme.primaryColor(for: colorScheme))
                .foregroundColor(Theme.backgroundColor(for: colorScheme))
                .cornerRadius(10)
        }
    }
    
    // MARK: - Actions
    private func selectService(_ serviceType: ServiceType) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            if viewModel.isServiceSelected(serviceType) {
                viewModel.deselectService()
            } else {
                viewModel.selectService(serviceType)
            }
        }
        AnimationUtils.hapticMedium()
    }
    
    private func proceedToNextStep() {
        navigationPath.append(BookingStep.tripModeSettings)
    }
}

// MARK: - Charter Type Card View
struct CharterTypeCardView: View {
    let serviceType: ServiceType
    let isSelected: Bool
    let estimatedPrice: String
    let isLoading: Bool
    let animationNamespace: Namespace.ID
    let onTap: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Header with icon and title
                HStack {
                    Image(systemName: serviceType.icon)
                        .font(.title2)
                        .foregroundColor(.primary) // Adaptive color
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(serviceType.displayName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(serviceType.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Selection indicator
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(isSelected ? Theme.primaryColor(for: colorScheme) : .gray)
                }
                .padding()
                
                Divider()
                
                // Details section
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "person.2.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(LocalizationUtils.localized("Passenger_Count"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(serviceType.passengerCount)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                        
                        HStack {
                            Image(systemName: "yensign.circle.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(LocalizationUtils.localized("Estimated_Price"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(estimatedPrice)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                        
                        // Scenarios
                        HStack {
                            Image(systemName: "tag.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 8) {
                                ForEach(serviceType.scenarios, id: \.self) { scenario in
                                    Text(scenario)
                                        .font(.caption2)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.primary.opacity(0.05))
                                        .foregroundColor(.primary)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Theme.backgroundColor(for: colorScheme)) // Strict white/black
                    .shadow(color: Theme.primaryColor(for: colorScheme).opacity(0.1), radius: 4, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Theme.primaryColor(for: colorScheme) : Theme.primaryColor(for: colorScheme).opacity(0.1), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let appState = AppState()
    return NavigationView {
        ServiceSelectionView(appState: appState, navigationPath: .constant(NavigationPath()))
            .environment(appState)
    }
}
#endif
