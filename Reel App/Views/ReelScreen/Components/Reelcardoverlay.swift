import SwiftUI
import SDWebImageSwiftUI
import Combine
import FastPixPlayerSDKTest

// MARK: - ReelCardOverlay

struct ReelCardOverlay: View {

    let video: ReelVideo
    @ObservedObject var pool: PlayerPoolManager
    @EnvironmentObject private var profile: UserProfileManager

    @State private var isLiked = false
    @State private var isDisliked = false
    @State private var showCommentsSheet = false
    @State private var thumbnailVisible = true
    
    @State private var showSettings = false
    
    @State private var activePopup: ActivePopup?
    @State private var showShareSheet = false
    
    var shareURL: URL? {
        URL(string: "https://stream.fastpix.com/\(video.playbackID).m3u8")
    }

    var body: some View {
        
        GeometryReader { geometry in
            ZStack {

                // MARK: Thumbnail placeholder
                // Shown instantly on swipe — fades out once video starts playing.
                // This is what makes the app feel instant even before the player renders.
//                if let thumbStr = video.thumbnail, let thumbURL = URL(string: thumbStr), thumbnailVisible {
//                    WebImage(url: thumbURL)
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: geometry.size.width, height: geometry.size.height)
//                        .clipped()
//                        .transition(.opacity)
//                }

                if pool.isBuffering {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                        .padding()
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(10)
                        .transition(.opacity)
                }
                
                if !pool.isPlaying && !pool.isBuffering {

                    Image(systemName: "play.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.white)
                        .padding(24)
                        .background(
                            Color.black.opacity(0.5)
                        )
                        .clipShape(Circle())
                }
                
                
                VStack {
                    
                    HStack {

                            Spacer()

                       if let vm = pool.settings(for: pool.currentIndex),
                            vm.settings.audioTracks.count > 1
                            {
                                Button {
                                    activePopup = .audio
                                } label: {
                                    Image(systemName: "speaker.wave.2.fill")
                                }
                                
                            }
                        
                        if let vm = pool.settings(for: pool.currentIndex),
                             vm.settings.subtitleTracks.count != 0
                             {
                                Button {
                                    activePopup = .subtitle
                                } label: {
                                    Text("CC")
                                }
                                     
                             }
                        
                        Button {
                            activePopup = .quality
                        } label: {
                            Text("HD")
                        }

                        }
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.top, 60)
                    Spacer()
        
                    if !pool.currentSubtitleText.isEmpty {

                        Text(pool.currentSubtitleText)
                            .font(.headline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(8)
                            .padding(.bottom, 140)
                    }

                    HStack(alignment: .bottom) {

                        WebImage(url: profile.getAvatarURL(UCreaterID: video.creatorID))
                            .resizable()
                            .indicator(.activity)
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .background(Circle().fill(Color.white.opacity(0.08)))
                            .clipShape(Circle())
                            .overlay {
                                Circle()
                                    .stroke(Color.white.opacity(0.15), lineWidth: 2)
                            }
                            .shadow(radius: 12)

                        VStack(alignment: .leading, spacing: 8) {
                            Text(video.creatorName)
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)

                            Text(video.description)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(12)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(12)

                        Spacer()
                        
                        VStack(spacing: 24) {

                            Button {
                                isLiked.toggle()
                                if isLiked { isDisliked = false }
                            } label: {
                                VStack(spacing: 6) {
                                    Image(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                                        .font(.title2)
                                    Text("Like").font(.caption)
                                }
                                .foregroundColor(isLiked ? .blue : .white)
                            }

                            Button {
                                isDisliked.toggle()
                                if isDisliked { isLiked = false }
                            } label: {
                                VStack(spacing: 6) {
                                    Image(systemName: isDisliked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                                        .font(.title2)
                                    Text("Dislike").font(.caption)
                                }
                                .foregroundColor(isDisliked ? .red : .white)
                            }

                            Button { showCommentsSheet = true } label: {
                                VStack(spacing: 6) {
                                    Image(systemName: "message").font(.title2)
                                    Text("Comment").font(.caption)
                                }
                                .foregroundColor(.white)
                            }
                            
                            Button {

                                showShareSheet = true

                            } label: {

                                VStack(spacing: 6) {

                                    Image(systemName: "square.and.arrow.up")
                                        .font(.title2)

                                    Text("Share")
                                        .font(.caption)
                                }
                                .foregroundColor(.white)
                            }
                            
                        }
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 50)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .overlay {

            if activePopup != nil {

                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        activePopup = nil
                    }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {

            if activePopup == nil {
                pool.currentPlayerVC()?.togglePlayPause()
            }
        }
        .overlay(alignment: .topTrailing) {
            
            if activePopup == .audio ,
            
                   let vm = pool.settings(for: pool.currentIndex) {
                    
                    VStack(alignment: .leading,spacing: 0) {
                        
                        ForEach(vm.settings.audioTracks, id: \.id) { track in
                            
                            Button {
                                
                                vm.selectAudio(track)
                                activePopup = nil
                                
                            } label: {
                                
                                HStack {
                                    
                                    Text(track.label)
                                    
                                    Spacer()
                                    
                                    if vm.settings.selectedAudio?.id == track.id {
                                        Image(systemName: "checkmark")
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 10)
                            }
                        }
                    }
                    .padding()
                    .frame(width: 220)
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .padding(.top, 100)
                    .padding(.trailing, 16)
                    .offset(
                        x: -16,
                        y: 60
                    )
                }
            
            
            if activePopup == .subtitle ,
               
                   let vm = pool.settings(for: pool.currentIndex) {
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        Button {
                            
                            vm.selectSubtitle(nil)
                            activePopup = nil
                            
                        } label: {
                            
                            HStack {
                                
                                Text("Off")
                                
                                Spacer()
                                
                                if vm.settings.selectedSubtitle == nil {
                                    Image(systemName: "checkmark")
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 10)
                        }
                        
                        ForEach(vm.settings.subtitleTracks, id: \.id) { track in
                            
                            Button {
                                
                                vm.selectSubtitle(track)

                                activePopup = nil
                                
                            } label: {
                                
                                HStack {
                                    
                                    Text(track.label)
                                    
                                    Spacer()
                                    
                                    if vm.settings.selectedSubtitle?.id == track.id {
                                        Image(systemName: "checkmark")
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 10)
                            }
                        }
                    }
                    .padding()
                    .frame(width: 220)
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .padding(.top, 100)
                    .padding(.trailing, 16)
                    .offset(x: -16, y: 60)
                }
            
            if activePopup == .quality ,
                
                   let vm = pool.settings(for: pool.currentIndex) {
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        ForEach(vm.settings.qualityLevels, id: \.id) { level in
                            
                            Button {
                                vm.selectQuality(level)
                                activePopup = nil
                                
                            } label: {
                                
                                HStack {
                                    
                                    Text(level.label)
                                    
                                    Spacer()
                                    
                                    if vm.settings.selectedQuality?.id == level.id {
                                        
                                        Image(systemName: "checkmark")
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 10)
                            }
                        }
                    }
                    .padding()
                    .frame(width: 220)
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .shadow(radius: 8)
                    .padding(.top, 100)
                    .padding(.trailing, 16)
                    .offset(
                        x: -16,
                        y: 60
                    )
                }
            }
        
        .sheet(isPresented: $showSettings) {

            if let vm = pool.settings(for: pool.currentIndex) {

                ReelSettingsSheet(vm: vm)
            }
        }
        .onChange(of: pool.isBuffering) { _, buffering in
            if !buffering {
                thumbnailVisible = false
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {

            pool.currentPlayerVC()?.togglePlayPause()
        }
        .sheet(isPresented: $showCommentsSheet) {
            CommentsBottomSheet()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.ultraThinMaterial)
        }
        .sheet(isPresented: $showShareSheet) {

            if let shareURL {

                ShareSheet(
                    items: [
                        shareURL
                    ]
                )
            }
        }
        
    }
}
