import SwiftUI

struct ReelFeedViewSection: View {

    let isTabActive: Bool
    @StateObject private var viewModel: ReelsViewModel = ReelsViewModel()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            switch viewModel.loadingState {
            case .idle, .loading:
                LoadingViewSection()
            case .loaded:
                ReelScrollView(viewModel: viewModel)
                
            case .empty:

                VStack {
                    Image(systemName: "video.slash")
                    Text("No reels yet")
                    Text("Upload your first video")
                }
                
            case .error(let message):
                ErrorView(message: message) {
                    viewModel.retry()
                }
            }
        }
        .task {
            await viewModel.loadVideo()
        }
        .onChange(of: isTabActive) { _, active in
            if active {
                viewModel.returnToTop()
            } else {
                viewModel.pauseCurrentVideo()
            }
        }
    }
}
