import SwiftUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var user: User?
    
    // Form fields
    @Published var name: String = ""
    @Published var phoneNumber: String = ""
    @Published var profileImage: String?
    
    private let apiService: APIService
    private let appState: AppState
    
    init(apiService: APIService = EasyRideAPIService.shared, appState: AppState) {
        self.apiService = apiService
        self.appState = appState
        
        // Initialize with current user data if available
        if let currentUser = appState.currentUser {
            self.user = currentUser
            self.name = currentUser.name
            self.phoneNumber = currentUser.phoneNumber ?? ""
            self.profileImage = currentUser.profileImage
        }
    }
    
    func fetchProfile() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedUser: User = try await apiService.request(.getUserProfile)
            self.user = fetchedUser
            self.name = fetchedUser.name
            self.phoneNumber = fetchedUser.phoneNumber ?? ""
            self.profileImage = fetchedUser.profileImage
            
            // Update global app state
            appState.currentUser = fetchedUser
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func updateProfile() async -> Bool {
        guard let currentUser = user else { return false }
        
        isLoading = true
        errorMessage = nil
        
        let updatedUser = User(
            userId: currentUser.userId,
            phoneNumber: phoneNumber,
            nickname: name,
            role: currentUser.role,
            accessToken: currentUser.accessToken,
            profileImage: profileImage,
            preferredLanguage: currentUser.preferredLanguage,
            createdAt: currentUser.createdAt,
            isVerified: currentUser.isVerified
        )
        
        do {
            // Note: APIEndpoint.updateUserProfile expects a User object. 
            // Ideally backend should return the updated user.
            let result: User = try await apiService.request(.updateUserProfile(updatedUser))
            self.user = result
            appState.currentUser = result
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func uploadAvatar(image: UIImage) async {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            errorMessage = "Invalid image data"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Assuming the endpoint returns the new URL string
            let newUrlString: String = try await apiService.uploadImage(.uploadProfileImage(imageData), imageData: imageData)
            self.profileImage = newUrlString
            
            // Immediately verify the update by fetching profile or manually updating if needed
            // For now, we assume we need to save the profile with the new URL
            // OR the backend updates it automatically on upload. 
            // Let's assume the upload endpoint handles the persistence on the user object side usually.
            
            // Refresh profile to get consistent state
            await fetchProfile()
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
