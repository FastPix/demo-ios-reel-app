import SwiftUI
import SDWebImageSwiftUI

struct ReelCardView: View {

    let video: ReelVideo
    let isActive: Bool

    @State private var isLiked = false
    @State private var isDisliked = false
    @State private var showCommentsSheet = false
    
    @EnvironmentObject private var profile: UserProfileManager

    var body: some View {

        GeometryReader { geometry in

            ZStack {

                ReelPlayerView(video: video, isActive: isActive)
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .clipped()

                VStack {

                    Spacer()

                    HStack(alignment: .bottom) {
                        
                        WebImage(
                            url: profile.getAvatarURL(UCreaterID: video.creatorID)
                        )
                        .resizable()
                        .indicator(.activity)
                        .scaledToFill()
                        .frame(
                            width: 60,
                            height: 60
                        )
                        .background(
                            Circle()
                                .fill(
                                    Color.white.opacity(0.08)
                                )
                        )
                        .clipShape(
                            Circle()
                        )
                        .overlay {

                            Circle()
                                .stroke(
                                    Color.white.opacity(0.15),
                                    lineWidth: 2
                                )

                        }
                        .shadow(
                            radius: 12
                        )
                        

                        VStack(
                            alignment: .leading,
                            spacing: 8
                        ) {

                            Text(video.creatorName)
                                .font(
                                    .system(
                                        size: 14,
                                        weight: .bold,
                                        design: .monospaced
                                    )
                                )
                                .foregroundColor(.white)

                            Text(video.description)
                                .font(
                                    .system(
                                        size: 10,
                                        design: .monospaced
                                    )
                                )
                                .foregroundColor(
                                    .white.opacity(0.7)
                                )
                        }
                        .padding(12)
                        .background(
                            Color.black.opacity(0.6)
                        )
                        .cornerRadius(12)

                        Spacer()

                        VStack(spacing: 24) {

                            Button {

                                isLiked.toggle()

                                if isLiked {
                                    isDisliked = false
                                }

                            } label: {

                                VStack(spacing: 6) {

                                    Image(
                                        systemName: isLiked
                                        ? "hand.thumbsup.fill"
                                        : "hand.thumbsup"
                                    )
                                    .font(.title2)

                                    Text("Like")
                                        .font(.caption)
                                }
                                .foregroundColor(
                                    isLiked ? .blue : .white
                                )
                            }

                            Button {

                                isDisliked.toggle()

                                if isDisliked {
                                    isLiked = false
                                }


                            } label: {

                                VStack(spacing: 6) {

                                    Image(
                                        systemName: isDisliked
                                        ? "hand.thumbsdown.fill"
                                        : "hand.thumbsdown"
                                    )
                                    .font(.title2)

                                    Text("Dislike")
                                        .font(.caption)
                                }
                                .foregroundColor(
                                    isDisliked ? .red : .white
                                )
                            }

                            Button {

                                showCommentsSheet = true

                            } label: {

                                VStack(spacing: 6) {

                                    Image(systemName: "message")
                                        .font(.title2)

                                    Text("Comment")
                                        .font(.caption)
                                }
                                .foregroundColor(.white)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showCommentsSheet) {

            CommentsBottomSheet()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.ultraThinMaterial)
        }
    }
}
