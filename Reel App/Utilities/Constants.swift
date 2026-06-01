import Foundation

enum Constants{
    static let apiBaseUrl = "https://api.fastpix.io/v1/on-demand"
    static let secretKey: String = ProcessInfo.processInfo.environment["SECRET_KEY"] ?? ""
    static let accessToken: String = ProcessInfo.processInfo.environment["ACCESS_TOKEN_ID"] ?? ""
    
    static let credentials = Data("\(accessToken):\(secretKey)".utf8).base64EncodedString()
    
    // Sharebale play back url
    static func playBackUrl(playBackId : String) -> String
    {
        return "https://stream.fastpix.io/\(playBackId).m3u8"
    }
}
