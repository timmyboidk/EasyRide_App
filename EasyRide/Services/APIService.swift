import Foundation

protocol APIService {
    func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T
    func requestWithoutResponse(_ endpoint: APIEndpoint) async throws
    func uploadImage(_ endpoint: APIEndpoint, imageData: Data) async throws -> String
}

@Observable
class EasyRideAPIService: APIService {
    static let shared = EasyRideAPIService()
    
    private let session: URLSession
    private let baseURL: String
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    // Secure storage for tokens
    private let secureStorage = SecureStorage.shared
    
    init(
        baseURL: String = "https://api.easyride.com",
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
        
        // Configure date formatting
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        
        // No need to load tokens here as SecureStorage handles it
    }
    
    // MARK: - Public API Methods
    
    func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T {
        let urlRequest = try await buildURLRequest(for: endpoint)
        
        do {
            // Check network reachability before making request
            try checkNetworkReachability()
            
            let (data, response) = try await session.data(for: urlRequest)
            try validateResponse(response, data: data)
            
            let decodedResponse = try decoder.decode(T.self, from: data)
            return decodedResponse
            
        } catch let error as EasyRideError {
            // If the error is retryable, try the request with retry logic
            if error.isRetryable {
                return try await requestWithRetry(endpoint)
            }
            throw error
        } catch {
            if error is DecodingError {
                throw EasyRideError.decodingError(error.localizedDescription)
            } else {
                throw EasyRideError.networkError(error.localizedDescription)
            }
        }
    }
    
    func requestWithoutResponse(_ endpoint: APIEndpoint) async throws {
        let urlRequest = try await buildURLRequest(for: endpoint)
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            try validateResponse(response, data: data)
        } catch let error as EasyRideError {
            throw error
        } catch {
            throw EasyRideError.networkError(error.localizedDescription)
        }
    }
    
    func uploadImage(_ endpoint: APIEndpoint, imageData: Data) async throws -> String {
        let urlRequest = try await buildMultipartRequest(for: endpoint, imageData: imageData)
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            try validateResponse(response, data: data)
            
            struct ImageUploadResponse: Codable {
                let imageUrl: String
            }
            
            let uploadResponse = try decoder.decode(ImageUploadResponse.self, from: data)
            return uploadResponse.imageUrl
            
        } catch let error as EasyRideError {
            throw error
        } catch {
            if error is DecodingError {
                throw EasyRideError.decodingError(error.localizedDescription)
            } else {
                throw EasyRideError.networkError(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Authentication Management
    
    func setAuthTokens(accessToken: String, refreshToken: String) {
        secureStorage.storeAccessToken(accessToken)
        secureStorage.storeRefreshToken(refreshToken)
    }
    
    func clearAuthTokens() {
        secureStorage.clearAllTokens()
    }
    
    var isAuthenticated: Bool {
        return secureStorage.getAccessToken() != nil
    }
    
    // MARK: - Private Methods
    
    private func buildURLRequest(for endpoint: APIEndpoint) async throws -> URLRequest {
        guard let url = buildURL(for: endpoint) else {
            throw EasyRideError.invalidRequest("Invalid URL for endpoint")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.httpMethod.rawValue
        request.httpBody = endpoint.body
        
        // Add headers
        for (key, value) in endpoint.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add authentication if required
        if endpoint.requiresAuthentication {
            try await addAuthenticationHeader(to: &request)
        }
        
        return request
    }
    
    private func buildMultipartRequest(for endpoint: APIEndpoint, imageData: Data) async throws -> URLRequest {
        guard let url = buildURL(for: endpoint) else {
            throw EasyRideError.invalidRequest("Invalid URL for endpoint")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.httpMethod.rawValue
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        // Add authentication if required
        if endpoint.requiresAuthentication {
            try await addAuthenticationHeader(to: &request)
        }
        
        return request
    }
    
    private func buildURL(for endpoint: APIEndpoint) -> URL? {
        guard var components = URLComponents(string: baseURL + endpoint.path) else {
            return nil
        }
        
        components.queryItems = endpoint.queryItems
        return components.url
    }
    
    private func addAuthenticationHeader(to request: inout URLRequest) async throws {
        guard let token = secureStorage.getAccessToken() else {
            throw EasyRideError.authenticationRequired
        }
        
        // Check if token needs refresh (simplified check)
        if await shouldRefreshToken() {
            try await refreshAccessToken()
        }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    
    private func shouldRefreshToken() async -> Bool {
        // In a real implementation, you would decode the JWT token
        // and check its expiration time
        // For now, we'll implement a simple check
        return false
    }
    
    private func refreshAccessToken() async throws {
        guard let refreshToken = secureStorage.getRefreshToken() else {
            throw EasyRideError.authenticationRequired
        }
        
        let refreshEndpoint = APIEndpoint.refreshToken(refreshToken: refreshToken)
        let authResponse: AuthResponse = try await request(refreshEndpoint)
        
        setAuthTokens(
            accessToken: authResponse.accessToken,
            refreshToken: authResponse.refreshToken
        )
    }
    
    private func validateResponse(_ response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw EasyRideError.networkError("Invalid response type")
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return // Success
        case 401:
            clearAuthTokens()
            throw EasyRideError.authenticationRequired
        case 403:
            throw EasyRideError.accountSuspended
        case 404:
            throw EasyRideError.orderNotFound
        case 408:
            throw EasyRideError.requestTimeout
        case 422:
            // Try to parse validation errors
            if let errorResponse = try? decoder.decode(ValidationErrorResponse.self, from: data) {
                throw EasyRideError.missingRequiredFields(errorResponse.errors.map { $0.field })
            } else {
                throw EasyRideError.invalidRequest("Validation failed")
            }
        case 429:
            throw EasyRideError.requestTimeout
        case 500...599:
            throw EasyRideError.serverUnavailable
        default:
            throw EasyRideError.from(httpStatusCode: httpResponse.statusCode, data: data)
        }
    }
    
    // MARK: - Token Management
    // Token management is now handled by SecureStorage
}

// MARK: - Error Response Models

struct ValidationErrorResponse: Codable {
    let message: String
    let errors: [ValidationError]
}

struct ValidationError: Codable {
    let field: String
    let message: String
}

// MARK: - Network Reachability Extension

extension EasyRideAPIService {
    private func checkNetworkReachability() throws {
        // In a production app, you would use Network framework
        // to check actual network reachability
        // For now, we'll implement a basic check
        
        // This is a simplified implementation
        // In practice, you'd want to use NWPathMonitor from Network framework
    }
}

// MARK: - Request Retry Logic

extension EasyRideAPIService {
    private func requestWithRetry<T: Codable>(
        _ endpoint: APIEndpoint,
        maxRetries: Int = 3,
        retryDelay: TimeInterval = 1.0
    ) async throws -> T {
        var lastError: Error?
        
        for attempt in 0..<maxRetries {
            do {
                return try await request(endpoint)
            } catch let error as EasyRideError {
                lastError = error
                
                // Only retry for certain types of errors
                if error.isRetryable && attempt < maxRetries - 1 {
                    try await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
                    continue
                } else {
                    throw error
                }
            } catch {
                lastError = error
                throw error
            }
        }
        
        throw lastError ?? EasyRideError.unknownError
    }
}