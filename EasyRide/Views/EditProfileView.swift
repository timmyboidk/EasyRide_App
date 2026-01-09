import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    
    // Image Selection
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    
    init(appState: AppState) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(appState: appState))
    }
    
    var body: some View {
        ZStack {
            Theme.backgroundColor(for: colorScheme).ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
            }
            
            ScrollView {
                VStack(spacing: 24) {
                    // Avatar Section
                    VStack(spacing: 12) {
                        ZStack {
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else if let profileImage = viewModel.profileImage, let url = URL(string: profileImage) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                } placeholder: {
                                    Image(systemName: "person.fill")
                                        .foregroundStyle(.gray)
                                }
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Theme.primaryColor(for: colorScheme).opacity(0.1))
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.largeTitle)
                                            .foregroundColor(.gray)
                                    )
                            }
                            
                            // Edit Icon Overlay
                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                Circle()
                                    .fill(Theme.backgroundColor(for: colorScheme))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Image(systemName: "camera.fill")
                                            .font(.caption)
                                            .foregroundColor(Theme.primaryColor(for: colorScheme))
                                    )
                                    .shadow(radius: 2)
                            }
                            .offset(x: 35, y: 35)
                        }
                        
                        Text(LocalizationUtils.localized("Change_Avatar"))
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 20)
                    
                    // Fields Section
                    VStack(alignment: .leading, spacing: 20) {
                        // Name Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text(LocalizationUtils.localized("Nickname"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            TextField("Name", text: $viewModel.name)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                                )
                        }
                        
                        // Phone (Read Only usually)
                        VStack(alignment: .leading, spacing: 8) {
                            Text(LocalizationUtils.localized("Phone"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Text(viewModel.phoneNumber)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Image(systemName: "lock.fill")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    
                    // Save Button
                    Button(action: saveProfile) {
                        Text(LocalizationUtils.localized("Save"))
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.primaryColor(for: colorScheme))
                            .foregroundColor(Theme.backgroundColor(for: colorScheme))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .disabled(viewModel.isLoading)
                }
            }
        }
        .navigationTitle(LocalizationUtils.localized("Edit_Profile"))
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedItem) {
            Task {
                if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                    await viewModel.uploadAvatar(image: uiImage)
                }
            }
        }
        .alert(isPresented: .constant(viewModel.errorMessage != nil)) {
            Alert(
                title: Text(LocalizationUtils.localized("Error")),
                message: Text(viewModel.errorMessage ?? ""),
                dismissButton: .default(Text(LocalizationUtils.localized("OK"))) {
                    viewModel.errorMessage = nil
                }
            )
        }
    }
    
    private func saveProfile() {
        Task {
            if await viewModel.updateProfile() {
                dismiss()
            }
        }
    }
}
