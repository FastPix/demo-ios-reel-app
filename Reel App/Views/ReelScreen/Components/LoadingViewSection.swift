import SwiftUI

struct LoadingViewSection: View {

    var body: some View {

        VStack(spacing: 16) {

            ProgressView()
                .progressViewStyle(
                    CircularProgressViewStyle(tint: .white)
                )
                .scaleEffect(1.5)

            Text("Loading reels...")
                .foregroundStyle(.white.opacity(0.8))
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity,
               maxHeight: .infinity)
        .background(Color.black)
    }
}
