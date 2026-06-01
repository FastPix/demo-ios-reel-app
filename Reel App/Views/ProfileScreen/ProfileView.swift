import SwiftUI
import SDWebImageSwiftUI

struct ProfileView: View {

    @EnvironmentObject var profile: UserProfileManager

    @State private var username = ""


    var body: some View {

        ZStack {

            Color.black
                .ignoresSafeArea()


            VStack {

                Spacer()
                    .frame(height: 80)


                avatarSection


                Spacer()
                    .frame(height: 35)


                inputSection


                Spacer()


            }
            .padding(.horizontal, 28)

        }
        .onAppear {
            username = profile.name
        }

    }
}


extension ProfileView {


    private var avatarSection: some View {

        VStack(
            spacing: 18
        ) {


            WebImage(
                url: profile.avatarURL
            )
            .resizable()
            .indicator(.activity)
            .scaledToFill()
            .frame(
                width: 150,
                height: 150
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
                spacing: 6
            ) {

                Text("User Id")
                    .font(.caption)
                    .foregroundStyle(.gray)


                Text(profile.creatorId)
                    .font(
                        .system(
                            size: 24,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(.white)

            }

        }

    }



    private var inputSection: some View {

        VStack(
            spacing: 24
        ) {


            HStack(
                spacing: 14
            ) {

                Image(
                    systemName: "person"
                )
                .foregroundStyle(.gray)



                TextField(
                    "Enter name",
                    text: $username
                )
                .font(
                    .system(
                        size: 20
                    )
                )
                .foregroundStyle(.white)

            }
            .padding()
            .frame(
                height: 60
            )
            .background(
                RoundedRectangle(
                    cornerRadius: 14
                )
                .fill(
                    Color.white.opacity(0.05)
                )
            )
            .overlay {

                RoundedRectangle(
                    cornerRadius: 14
                )
                .stroke(
                    Color.gray.opacity(0.4)
                )

            }




            Button {

                profile.updateName(
                    username
                )

            } label: {


                Text("Save")
                    .font(
                        .headline
                    )
                    .foregroundStyle(.white)
                    .frame(
                        maxWidth: .infinity
                    )
                    .frame(
                        height: 58
                    )
                    .background(

                        LinearGradient(
                            colors: [
                                .blue,
                                .indigo
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )

                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 16
                        )
                    )

            }

            Spacer()

            Text(
                "Powered By FastPix"
            )
            .font(.footnote)
            .foregroundStyle(.gray)

        }

    }

}
