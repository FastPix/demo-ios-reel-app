import SwiftUI

struct ContentView: View {

    @State private var selectedTab = 0
    @State private var previousTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {

            Tab("House", systemImage: "house", value: 0) {
                ReelFeedViewSection(isTabActive: selectedTab == 0)
                  
            }

            Tab("upload", systemImage: "plus", value: 1) {
                UploadView()
            }

            Tab("Profile", systemImage: "person.crop.circle", value: 2) {
                ProfileView()
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: selectedTab) { old, _ in
            previousTab = old
        }
    }
}
