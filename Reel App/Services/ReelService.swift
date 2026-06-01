import Foundation

protocol ReelViewServiceProtocal {
    func fetchVideo() async throws -> [ReelVideo]
}

final class ReelViewService: ReelViewServiceProtocal{
    
    static let shared = ReelViewService()
    private init(){}
    
    // GET request to get Video Data
    func fetchVideo() async throws -> [ReelVideo] {
      
        guard let url = URL(string: Constants.apiBaseUrl)else{
           throw  URLError(.badURL)
        }
        
        var request = URLRequest(url : url)
        
        request.setValue("Basic \(Constants.credentials)", forHTTPHeaderField: "Authorization")
        
        let (data,response) : (Data, URLResponse)
        
        do{
            (data,response) = try await URLSession.shared.data(for: request)

             let jsonString = String(data: data, encoding: .utf8)
            
        }
        catch is CancellationError {
            throw CancellationError()
        }
        catch {
            throw APIError.networkError(error)
        }
        
        // convert into http response
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode{
            //success
            case 200...299 : break
            case 401...403 : throw APIError.unauthorized
            default: throw APIError.serverError(httpResponse.statusCode)
            }
        }
        
        let decoded: VideoListResponse
        do {
            decoded = try JSONDecoder().decode(VideoListResponse.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }

        let videos = decoded.data.compactMap { $0.toReelVideo() }

        return videos
    }
    
}

enum APIError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case unauthorized
    case serverError(Int)
    case noVideosFound

    var errorDescription: String? {
        switch self {
        case .invalidURL:           return "Invalid API URL."
        case .networkError(let e): return "Network error: \(e.localizedDescription)"
        case .decodingError(let e): return "Failed to parse response: \(e.localizedDescription)"
        case .unauthorized:         return "Unauthorized. Check your API credentials."
        case .serverError(let c):   return "Server error with status code \(c)."
        case .noVideosFound:        return "No ready videos found in your FastPix account."
        }
    }
}
