import SwiftUI
import SDWebImageSVGCoder

@main
struct Reel_App: App {
    
    
    init() {

        let svgCoder = SDImageSVGCoder.shared

        SDImageCodersManager.shared.addCoder(
            svgCoder
        )
    }

    @StateObject private var profile =
          UserProfileManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(profile)
        }
    }
}
