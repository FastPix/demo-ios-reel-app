import SwiftUI
import PhotosUI
import AVKit

@available(iOS 16.0, *)
struct UploadView: View {

    @StateObject private var vm = UploadViewModel()

    @State private var selectedItem: PhotosPickerItem?
    @State private var player = AVPlayer()
    @State private var selectedVideoURL: URL?
    
    @State private var videoTitle: String = "Fastpix_Video"
    @State private var videoDiscription: String = "Video Description"
    
    @EnvironmentObject private var profile: UserProfileManager
    
    private var shouldHideUploadForm: Bool {
        selectedVideoURL != nil &&
        vm.isUploading &&
        !vm.uploadCompleted
    }
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    

    var body: some View {

        if #available(iOS 17.0, *) {
            NavigationStack {
                
                ZStack {
                    
                    Color.black
                        .ignoresSafeArea()
                    
                    ScrollView(showsIndicators: false) {
                        
                        VStack(spacing: 24) {
                            
                            if(selectedVideoURL != nil)
                            {
                                HStack{
                                    Button(action:{
                                        selectedVideoURL = nil
                                    }){
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                            .font(.title)
                                    }
                                    Spacer()
                                }
                            }

                            
                            if(selectedVideoURL == nil){
                                HeaderSection()
                            }
                            
                        if(selectedVideoURL == nil)
                            {
                            PhotosPicker(
                                selection: $selectedItem,
                                matching: .videos
                            ) {
                                
                                UploadDropZone()
                            }
                        }
                       
                            if selectedVideoURL != nil {
                                
                                VideoPlayer(player: player)
                                    .frame(height:screenHeight * 0.35)
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 24)
                                    )
                            }
                            
                            if vm.isUploading {
                                
                                VStack(spacing: 12) {
                                    
                                    ProgressView(
                                        value: vm.uploadProgress
                                    )
                                    .tint(.orange)
                                    
                                    Text(
                                        "\(Int(vm.uploadProgress * 100))%"
                                    )
                                    .foregroundStyle(.white)
                                }
                                .padding(.horizontal)
                            }
                            
                            
                            if(selectedVideoURL != nil)
                            {
                                if vm.uploadCompleted {
                                    
                                    Text("Video Upload Completed")
                                        .foregroundStyle(.green)
                                        .fontWeight(.semibold)
                                }
                                
                                if vm.isProcessingVideo {

                                    VStack(spacing: 12) {

                                        ProgressView()

                                        Text("Processing video...")
                                            .foregroundStyle(.white)
                                    }
                                    .padding()
                                }
                                
                            }
                            

                            if selectedVideoURL != nil &&
                               !vm.uploadCompleted &&
                               !shouldHideUploadForm {
                                VStack(alignment: .leading, spacing: 24) {
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Video Title")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.secondary)
                                        
                                        TextField("Enter video title", text: $videoTitle)
                                            .textFieldStyle(.roundedBorder)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Video Description")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.secondary)
                                        
                                        TextField("Enter video description", text: $videoDiscription, axis: .vertical)
                                            .textFieldStyle(.roundedBorder)
                                            .lineLimit(3...6)
                                    }
                                    
                                }
                                .padding(.horizontal)
                            }
                            
                            if selectedVideoURL != nil &&
                               !vm.uploadCompleted &&
                               !shouldHideUploadForm
                            {
                                HStack(spacing: 16) {

                                    Button(action: {
                                        selectedVideoURL = nil
                                    }) {

                                        Text("Cancel")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white.opacity(0.9))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 14)
                                            .background(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(Color.white.opacity(0.12))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 16)
                                                            .stroke(
                                                                Color.white.opacity(0.08),
                                                                lineWidth: 1
                                                            )
                                                    )
                                            )
                                    }

                                    Button(action: {
            
                                        Task{
                                            await vm.uploadVideo(fileURL: selectedVideoURL!,createrID: profile.creatorId,createrName: profile.name,description: videoDiscription,title: videoTitle)
    
                                        }
                                    }) {

                                        HStack(spacing: 8) {

                                            Image(systemName: "arrow.up.circle.fill")

                                            Text("Upload")
                                                .fontWeight(.bold)
                                        }
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(

                                            LinearGradient(
                                                colors: [
                                                    Color.orange,
                                                    Color.orange.opacity(0.85)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .clipShape(
                                            RoundedRectangle(cornerRadius: 16)
                                        )
                                        .shadow(
                                            color: Color.orange.opacity(0.35),
                                            radius: 10,
                                            x: 0,
                                            y: 6
                                        )
                                    }
                                }
                                .padding(.horizontal)

                                
                            }
                           
                            if(selectedVideoURL != nil)
                            {
                                if let sharedURL = vm.sharedURL {

                                    VStack(spacing: 20) {

                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 60))
                                            .foregroundStyle(.green)

                                        Text("Video Ready")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.white)

                                        Text(sharedURL)
                                            .font(.caption)
                                            .foregroundStyle(.gray)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal)

                                        HStack(spacing: 16) {

                                            Button {

                                                UIPasteboard.general.string = sharedURL

                                            } label: {

                                                HStack {

                                                    Image(systemName: "doc.on.doc.fill")

                                                    Text("Copy Link")
                                                        .fontWeight(.semibold)
                                                }
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 14)
                                                .background(Color.orange)
                                                .foregroundStyle(.white)
                                                .clipShape(
                                                    RoundedRectangle(cornerRadius: 14)
                                                )
                                                .shadow(
                                                    color: .orange.opacity(0.4),
                                                    radius: 8,
                                                    x: 0,
                                                    y: 4
                                                )
                                            }

                                            Button {

                                                if let url = URL(string: sharedURL) {

                                                    UIApplication.shared.open(url)
                                                }

                                            } label: {

                                                HStack {

                                                    Image(systemName: "play.fill")

                                                    Text("Preview")
                                                        .fontWeight(.semibold)
                                                }
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 14)
                                                .background(Color.orange)
                                                .foregroundStyle(.white)
                                                .clipShape(
                                                    RoundedRectangle(cornerRadius: 14)
                                                )
                                                .shadow(
                                                    color: .orange.opacity(0.4),
                                                    radius: 8,
                                                    x: 0,
                                                    y: 4
                                                )
                                            }
                                        }
                                    }
                                    .padding(24)
                                    .background(
                                        RoundedRectangle(cornerRadius: 24)
                                            .fill(Color.white.opacity(0.05))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                    )
                                    .padding(.horizontal)
                                }
                            
                            }
                           
                            if let error = vm.uploadError {

                                VStack(spacing: 12) {

                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(.red)
                                        .font(.title2)

                                    Text(error)
                                        .foregroundStyle(.red)
                                        .multilineTextAlignment(.center)
                                }
                                .padding()
                            }
                            
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 40)
                        .frame(maxWidth: 500)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .onChange(of: selectedItem) {
                
                Task {
                    
                    guard let item = selectedItem else {
                        return
                    }
                    
                    do {
                        
                        if let movie = try await item.loadTransferable(
                            type: CustomMovieFile.self
                        ) {
                            
                            selectedVideoURL = movie.url
                            
                            let playerItem = AVPlayerItem(
                                url: movie.url
                            )
                            
                            player.replaceCurrentItem(
                                with: playerItem
                            )
   
                            player.play()
                            
                        }
                        
                    } catch {
                        // show the error
                        
                    }
                }
            }
            
        } else {
            // Fallback on earlier versions
        }
    }
}
