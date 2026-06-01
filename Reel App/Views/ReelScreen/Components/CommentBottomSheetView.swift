import SwiftUI

struct CommentsBottomSheet: View {

    var body: some View {

        VStack(spacing: 20) {

            Text("Comments")
                .font(.title2)
                .fontWeight(.bold)

            ScrollView {

                VStack(spacing: 16) {

                        HStack(alignment: .top) {

                            Circle()
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 40, height: 40)

                            VStack(alignment: .leading, spacing: 4) {

                                Text("Dummy User")
                                    .fontWeight(.semibold)

                                Text("sample comment...")
                                    .foregroundColor(.secondary)
                            }

                            Spacer()
                        }
                }
                .padding()
            }

            Spacer()
        }
        .padding(.top, 20)
    }
}
