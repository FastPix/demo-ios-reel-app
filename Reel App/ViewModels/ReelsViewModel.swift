import Foundation
import Combine

@MainActor
final class ReelsViewModel: ObservableObject {

    @Published var currentIndex: Int?
    @Published var currentVideoId: String?
    
    @Published var video: [ReelVideo] = []
    @Published var loadingState: LoadingState = .idle
    @Published var isTabActive: Bool = true
    @Published var scrollToIndex: Int?
    @Published var isRefreshing = false

    private let service: ReelViewServiceProtocal

    init(service: ReelViewServiceProtocal = ReelViewService.shared) {
        self.service = service
    }

    func loadVideo() async {
        guard case .idle = loadingState else { return }
        loadingState = .loading

        do {
            let fetched = try await service.fetchVideo()
            
            if fetched.isEmpty {

                video = []
                currentVideoId = nil
                loadingState = .empty
                return
            }
    
            video = fetched
            currentVideoId = fetched.first?.id
            currentIndex = 0
            isTabActive = true
            loadingState = .loaded
        } catch {
            let message = (error as? APIError)?.errorDescription ?? error.localizedDescription
            loadingState = .error(message)
        }
    }
    
    func refreshVideos() async {

        guard !isRefreshing else { return }

        isRefreshing = true

        defer {
            isRefreshing = false
        }

        do {

            let latestVideos = try await service.fetchVideo()

            pauseCurrentVideo()

            self.video = latestVideos
            self.currentIndex = 0

            resumeCurrentVideo()

        } catch is CancellationError {
            
            // Refresh request cancelled

        } catch {

            // Refresh failed
            
        }
    }
    
    func pauseCurrentVideo() {
        isTabActive = false
    }
 
    func resumeCurrentVideo() {
        isTabActive = true
    }

    func returnToTop() {
        isTabActive = false
        scrollToIndex = 0
        
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 350_000_000)
            currentIndex = 0
            isTabActive = true
            scrollToIndex = nil
        }
    }

    func retry() {
        loadingState = .idle
        Task { await loadVideo() }
    }
}

enum LoadingState {
    case idle
    case loading
    case loaded
    case empty
    case error(String)
}
