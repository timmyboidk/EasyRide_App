import SwiftUI

#if os(iOS)
struct ServiceSelectionView: View {
    @State private var viewModel: ServiceSelectionViewModel
    @Environment(AppState.self) private var appState
    @Namespace private var animationNamespace
    @Binding var navigationPath: NavigationPath
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    init(appState: AppState, navigationPath: Binding<NavigationPath>) {
        self._viewModel = State(initialValue: ServiceSelectionViewModel(appState: appState))
        self._navigationPath = navigationPath
        
        // Customize Navigation Bar appearance for dark theme
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
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
        .navigationTitle(Text("选择包车类型", bundle: nil))
        .navigationBarTitleDisplayMode(.inline)
        .alert("价格估算错误", isPresented: .constant(viewModel.priceEstimationError != nil)) {
            Button("确定") {
                viewModel.priceEstimationError = nil
            }
        } message: {
            Text(viewModel.priceEstimationError?.localizedDescription ?? "")
        }
    }
    
    // MARK: - Floating Action Button
    private var floatingActionButton: some View {
        Button(action: proceedToNextStep) {
            Text("继续", bundle: nil)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .foregroundColor(.black)
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
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Header with icon and title
                HStack {
                    Image(systemName: serviceType.icon)
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(serviceType.displayName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text(serviceType.description)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Selection indicator
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(isSelected ? .white : .gray)
                }
                .padding()
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                // Details section
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "person.2.fill")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("乘客人数", bundle: nil)
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                            Text(serviceType.passengerCount)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                        
                        HStack {
                            Image(systemName: "yensign.circle.fill")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("预估价格", bundle: nil)
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                            Text(estimatedPrice)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                        
                        // Scenarios
                        HStack {
                            Image(systemName: "tag.fill")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 8) {
                                ForEach(serviceType.scenarios, id: \.self) { scenario in
                                    Text(scenario)
                                        .font(.caption2)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.gray.opacity(0.2))
                                        .foregroundColor(.white)
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
                    .fill(Color.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.white : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
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
