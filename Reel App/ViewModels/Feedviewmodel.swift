import Foundation
import Combine

@MainActor
final class FeedViewModel: ObservableObject {

    @Published var videos: [ReelVideo] = []
    @Published var loadingState: LoadingState = .idle
    @Published var currentIndex: Int = 0
    @Published var isRefreshing: Bool = false

    private var currentOffset = 0
    private var hasMoreData = true
    private var isLoadingMore = false

    private let service: ReelViewServiceProtocal
    private let pool: PlayerPoolManager

    init(
        service: ReelViewServiceProtocal = ReelViewService.shared,
        pool: PlayerPoolManager = .shared
    ) {
        self.service = service
        self.pool = pool
    }

    func loadVideo() async {
        guard case .idle = loadingState else { return }
        loadingState = .loading

        do {
            let page = try await service.fetchVideo(offset: 1)
            videos = page.videos
            currentOffset = page.pagination.currentOffset
            hasMoreData = videos.count < page.pagination.totalRecords
            currentIndex = 0
            loadingState = videos.isEmpty ? .empty : .loaded
            pool.setVideos(videos)

        } catch {
            let message = (error as? APIError)?.errorDescription ?? error.localizedDescription
            loadingState = .error(message)
        }
    }

    func loadMoreIfNeeded(currentIndex: Int) {
        let threshold = max(0, videos.count - 3)  // Increased threshold for more aggressive prefetch
        guard currentIndex >= threshold else { return }
        Task { await loadMoreVideos() }
    }

    func loadMoreVideos() async {
        guard !isLoadingMore, hasMoreData else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let page = try await service.fetchVideo(offset: currentOffset + 1)
            videos.append(contentsOf: page.videos)
            currentOffset = page.pagination.currentOffset
            hasMoreData = videos.count < page.pagination.totalRecords

            // Keep pool aware of new videos
            pool.setVideos(videos)

        } catch {
            print("Pagination error:", error)
        }
    }

    func didSwipeTo(index: Int) {
        currentIndex = index
        loadMoreIfNeeded(currentIndex: index)
    }

    func refreshVideos() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        pool.pauseAll()

        do {
            let page = try await service.fetchVideo(offset: 1)
            videos = page.videos
            currentOffset = page.pagination.currentOffset
            hasMoreData = videos.count < page.pagination.totalRecords
            currentIndex = 0
            pool.setVideos(videos)

        } catch {
            print("Refresh failed:", error)
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

