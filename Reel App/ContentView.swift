import SwiftUI

struct ContentView: View {
    
    @State private var selectedTab = 0
    @State private var previousTab = 0
    
    var body: some View {
        
        ReelFeedViewSection()
        
    }
}
