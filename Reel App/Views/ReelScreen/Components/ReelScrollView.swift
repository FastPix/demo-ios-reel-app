import SwiftUI

struct ReelScrollView: View {

    @ObservedObject var viewModel: ReelsViewModel
    
    private func isActive(
        _ video: ReelVideo
    ) -> Bool {

        viewModel.currentVideoId == video.id &&
        viewModel.isTabActive
    }

    var body: some View {
        GeometryReader { geo in
            ScrollViewReader { proxy in
                ScrollView(.vertical) {
                    LazyVStack(spacing: 0) {
                        ForEach(
                            Array(viewModel.video.enumerated()),
                            id: \.element.id
                        ) { _, video in
                            ReelCardView(
                                    video: video,
                                    isActive: isActive(video),
                                )
                            .frame(width: geo.size.width, height: geo.size.height)
                        }
                    }
                    .scrollTargetLayout()
                }
                .refreshable {

                    await Task.detached {
                        await viewModel.refreshVideos()
                    }.value
                }
                .scrollTargetBehavior(.paging)
                .scrollIndicators(.hidden)
                .scrollPosition(
                    id: $viewModel.currentVideoId,anchor: .center
                )
                .ignoresSafeArea()
                .onChange(of: viewModel.scrollToIndex) { _, index in
                    guard let index else { return }
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(index, anchor: .center)
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}
