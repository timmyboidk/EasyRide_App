import Foundation

struct AppConfiguration {
    // Assumption: Backend API Base URL. Update this when real URL is known.
    // Docker containers might be mapped to localhost, or a specific cloud IP.
    static let baseURL = "http://localhost:8080" 
}
