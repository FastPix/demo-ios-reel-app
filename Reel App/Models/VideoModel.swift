import Foundation

struct VideoListResponse: Decodable {
    
    let success: Bool
    let data: [VideoData]
    let pagination: Pagination
}

struct Pagination: Decodable {
    
    let totalRecords: Int
    let currentOffset: Int
    let offsetCount: Int
}

struct VideoData: Decodable {
    
    let id: String
    let title: String?
    let status: String
    let thumbnail: String?
    let duration: String?
    let aspectRatio: String?
    
    let metadata: VideoMetadata?
    
    let playbackIds: [PlaybackID]?
}

struct VideoMetadata: Decodable {
    
    let creatorID: String?
    let creatorName: String?
    
    let title: String?
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        
        case creatorID = "creator_id"
        case creatorName = "creator_name"
        case title
        case description
    }
}

struct PlaybackID: Decodable {
    
    let id: String
    let accessPolicy: String
}


struct ReelVideo: Identifiable {
    
    let id: String
    
    let playbackID: String
    
    let title: String
    let description: String
    
    let creatorID: String
    let creatorName: String
    
    let thumbnail: String?
    
    let duration: String?
    
    let aspectRatio: String?
}

extension VideoData {

    func toReelVideo() -> ReelVideo? {
        
        guard
            status.lowercased() == "ready",
            let playbackID = playbackIds?.first?.id
        else {
            return nil
        }

        return ReelVideo(
            id: id,
            
            playbackID: playbackID,
            
            title:
                metadata?.title
                ?? title
                ?? "Untitled Video",
            
            description:
                metadata?.description
                ?? "",
            
            creatorID:
                metadata?.creatorID
                ?? "",
            
            creatorName:
                metadata?.creatorName
                ?? "Unknown Creator",
            
            thumbnail: thumbnail,
            
            duration: duration,
            
            aspectRatio: aspectRatio
        )
    }
}
