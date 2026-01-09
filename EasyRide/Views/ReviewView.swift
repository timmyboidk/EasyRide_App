import SwiftUI

struct ReviewView: View {
    let orderId: String
    let driverId: String
    let driverName: String
    var onSubmitConfig: () -> Void
    
    @StateObject private var viewModel = ReviewViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Theme.backgroundColor(for: colorScheme).ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                Text(LocalizationUtils.localized("Rate_Your_Trip"))
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                Text(LocalizationUtils.localized("How_was_your_trip_with") + " \(driverName)?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Stars
                HStack(spacing: 12) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= viewModel.rating ? "star.fill" : "star")
                            .font(.system(size: 40))
                            .foregroundColor(.yellow)
                            .onTapGesture {
                                viewModel.rating = star
                            }
                    }
                }
                .padding(.vertical, 20)
                
                // Comment
                TextField(LocalizationUtils.localized("Review_Placeholder"), text: $viewModel.comment, axis: .vertical)
                    .lineLimit(3...6)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                Spacer()
                
                // Submit Button
                Button(action: {
                    Task {
                        await viewModel.submitReview(driverId: driverId, orderId: orderId)
                        if viewModel.isSubmitted {
                            onSubmitConfig()
                        }
                    }
                }) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text(LocalizationUtils.localized("Submit_Review"))
                                .fontWeight(.bold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.primaryColor(for: colorScheme))
                    .foregroundColor(Theme.backgroundColor(for: colorScheme))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                .disabled(viewModel.isLoading)
            }
        }
    }
}
