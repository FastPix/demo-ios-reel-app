import Foundation

struct VideoPage {
    let videos: [ReelVideo]
    let pagination: Pagination
}

protocol ReelViewServiceProtocal {
    func fetchVideo(offset: Int) async throws -> VideoPage
}

final class ReelViewService: ReelViewServiceProtocal{
    
    static let shared = ReelViewService()
    private init(){}
    
    // GET request to get Video Data
    func fetchVideo(offset: Int) async throws -> VideoPage {

        guard var components = URLComponents(string: Constants.apiBaseUrl) else {
            throw URLError(.badURL)
        }

        components.queryItems = [
            URLQueryItem(name: "offset", value: "\(offset)"),
            URLQueryItem(name: "limit", value: "10")
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)

        request.setValue(
            "Basic \(Constants.credentials)",
            forHTTPHeaderField: "Authorization"
        )

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode{
            //success
            case 200...299 : break
            case 401...403 : throw APIError.unauthorized
            default: throw APIError.serverError(httpResponse.statusCode)
            }
        }

        let decoded = try JSONDecoder()
            .decode(VideoListResponse.self, from: data)

        let videos = decoded.data.compactMap { $0.toReelVideo() }

        return VideoPage(
            videos: videos,
            pagination: decoded.pagination
        )
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
