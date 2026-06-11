import SwiftUI

struct ReelFeedViewSection: View {

    @StateObject private var feedVM = FeedViewModel()
    @StateObject private var pool = PlayerPoolManager.shared

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            switch feedVM.loadingState {

            case .idle, .loading:
                LoadingViewSection()

            case .loaded:
                ReelPageView(feedVM: feedVM, pool: pool)
                    .ignoresSafeArea()

            case .empty:
                VStack(spacing: 16) {
                    Image(systemName: "video.slash")
                        .font(.system(size: 48))
                        .foregroundColor(.white.opacity(0.5))
                    Text("No reels yet")
                        .foregroundColor(.white)
                    Text("Upload your first video")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.caption)
                }

            case .error(let message):
                ErrorView(message: message) {
                    feedVM.retry()
                }
            }
        }
        .task {
            await feedVM.loadVideo()
        }

    }
}
