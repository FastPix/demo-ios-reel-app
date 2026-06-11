import AVKit
import Combine
import FastPixPlayerSDKTest
import Network


@MainActor
final class PlayerPoolManager: ObservableObject, FastPixQualityDelegate, FastPixSubtitleTrackDelegate {
  
    static let shared = PlayerPoolManager()

    @Published var isBuffering: Bool = false
    @Published var isPlaying: Bool = true
    
    @Published var currentSubtitleText: String = ""

    private final class Entry {
        let playerVC: AVPlayerViewController
        let videoIndex: Int
        var lastUsed: Date
        var shouldBePlaying: Bool = false
        var statusObservation: NSKeyValueObservation?
        var playerArrivalObservation: NSKeyValueObservation?
        
        var qualityLoaded = false

        init(playerVC: AVPlayerViewController, videoIndex: Int) {
            self.playerVC = playerVC
            self.videoIndex = videoIndex
            self.lastUsed = Date()
        }

        deinit {
            statusObservation?.invalidate()
            playerArrivalObservation?.invalidate()
        }
    }
    
    private var settingsStore: [Int: ReelSettingsViewModel] = [:]

    private var cache: [Int: Entry] = [:]
    private let maxEntries = 10

    private var videos: [ReelVideo] = []
    private(set) var currentIndex: Int = -1

    private let monitor = NWPathMonitor()
    private var isOnWifi: Bool = true

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isOnWifi = path.usesInterfaceType(.wifi)
            }
        }
        monitor.start(queue: DispatchQueue(label: "network.monitor"))
    }
    
    func settings(for index: Int) -> ReelSettingsViewModel? {
        let vm = settingsStore[index]
          return vm
    }

    func setVideos(_ videos: [ReelVideo]) {
        self.videos = videos
    }

    func playerVC(for index: Int) -> AVPlayerViewController {
        if let entry = cache[index] {
            entry.lastUsed = Date()
            return entry.playerVC
        }
        let entry = makeEntry(for: index)
        cache[index] = entry
        evictIfNeeded(keeping: index)
        return entry.playerVC
    }

    func preload(_ index: Int) {
        guard index >= 0, index < videos.count else { return }
        _ = playerVC(for: index)
    }

    func setActive(_ index: Int) {
        currentIndex = index
        _ = playerVC(for: index)               // ensure it exists

        for (i, entry) in cache {
            if i == index {
                playWhenReady(entry)
            } else {
                entry.shouldBePlaying = false
                entry.playerVC.pause()
            }
        }
    }

    func pauseAll() {
        cache.values.forEach {
            $0.shouldBePlaying = false
            $0.playerVC.pause()
        }
        isBuffering = false
        isPlaying = false
    }
    
    func currentPlayerVC() -> AVPlayerViewController? {
        cache[currentIndex]?.playerVC
    }

    func resumeCurrent() {
        guard let entry = cache[currentIndex] else { return }
        playWhenReady(entry)
    }

    private func makeEntry(for index: Int) -> Entry {
        let vc = AVPlayerViewController()
        
        vc.qualityDelegate = self
        vc.subtitleTrackDelegate = self
        vc.showsPlaybackControls = false
        vc.isLoopEnabled = true
        vc.isAutoPlayEnabled = false               // never auto-start
        vc.view.backgroundColor = .black
        vc.view.isUserInteractionEnabled = false
        vc.view.isOpaque = true
        vc.view.clipsToBounds = true
        

        let entry = Entry(playerVC: vc, videoIndex: index)

        if index >= 0, index < videos.count {
            let video = videos[index]
            // for subtite "2125094c-db43-4748-90e1-18539f2ccf98"
            vc.prepare(
                playbackID: video.playbackID,
                playbackOptions: PlaybackOptions(streamType: "on-demand")
            )
            applyABRPolicy(to: entry)
            watchForUnwantedPlayback(entry)
        }
        return entry
    }

    private func evictIfNeeded(keeping index: Int) {
        guard cache.count > maxEntries else { return }

        let protected = Set([currentIndex - 1, currentIndex, currentIndex + 1, index])
        let candidates = cache
            .filter { !protected.contains($0.key) }
            .sorted { $0.value.lastUsed < $1.value.lastUsed }

        var toRemove = cache.count - maxEntries
        for (key, entry) in candidates where toRemove > 0 {
            entry.statusObservation?.invalidate()
            entry.playerArrivalObservation?.invalidate()
            entry.playerVC.pause()

            if entry.playerVC.parent != nil {
                entry.playerVC.willMove(toParent: nil)
                entry.playerVC.view.removeFromSuperview()
                entry.playerVC.removeFromParent()
            }
            cache[key] = nil
            toRemove -= 1
        }
    }

    private func playWhenReady(_ entry: Entry) {
        entry.shouldBePlaying = true

        if entry.playerVC.player != nil {
            initializeSettingsIfNeeded(for: entry)
            startPlayback(entry)
            return
        }

        entry.playerArrivalObservation?.invalidate()
        entry.playerArrivalObservation = entry.playerVC.observe(\.player, options: [.new]) {
            [weak self, weak entry] vc, _ in
            guard let self, let entry, vc.player != nil else { return }
            DispatchQueue.main.async {
                entry.playerArrivalObservation?.invalidate()
                entry.playerArrivalObservation = nil
                if entry.videoIndex == self.currentIndex {
                    self.initializeSettingsIfNeeded(for: entry)
                    self.startPlayback(entry)
                }
            }
        }
    }
    
    private func initializeSettingsIfNeeded(for entry: Entry) {

        guard !entry.qualityLoaded else { return }

        guard let player = entry.playerVC.player else { return }

        entry.playerVC.setupQualityManager(delegate: self)

        entry.playerVC.qualityManager?.attach(player: player)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

            entry.playerVC.qualityManager?.loadQualityLevels()

            let vm = ReelSettingsViewModel()

            vm.attach(playerVC: entry.playerVC)

            self.settingsStore[entry.videoIndex] = vm

        }

        entry.qualityLoaded = true
    }

    private func startPlayback(_ entry: Entry) {
        applyABRPolicy(to: entry)
        entry.playerVC.player?.seek(to: .zero)
        entry.playerVC.play()
        isPlaying = true

        observeBuffering(for: entry)
    }

    private func observeBuffering(for entry: Entry) {
        guard let player = entry.playerVC.player else { return }
        entry.statusObservation?.invalidate()
        entry.statusObservation = player.observe(
            \.timeControlStatus,
            options: [.initial, .new]
        ) { [weak self, weak entry] player, _ in
            DispatchQueue.main.async {
                guard let self, let entry else { return }
                if !entry.shouldBePlaying {
                    if player.timeControlStatus != .paused { entry.playerVC.pause() }
                    return
                }
                if entry.videoIndex == self.currentIndex {
                    self.isBuffering = (player.timeControlStatus == .waitingToPlayAtSpecifiedRate)
                    self.isPlaying =
                        (player.timeControlStatus == .playing)
                }
            }
        }
    }

    private func watchForUnwantedPlayback(_ entry: Entry) {
        guard let player = entry.playerVC.player else { return }
        entry.statusObservation?.invalidate()
        entry.statusObservation = player.observe(\.timeControlStatus, options: [.new]) {
            [weak entry] player, _ in
            DispatchQueue.main.async {
                guard let entry, !entry.shouldBePlaying else { return }
                if player.timeControlStatus != .paused {
                    entry.playerVC.pause()
                }
            }
        }
    }

    private func applyABRPolicy(to entry: Entry) {
        guard let item = entry.playerVC.player?.currentItem else { return }
        
        let isActive = (
            entry.videoIndex == currentIndex
        )
        item.preferredPeakBitRate = isOnWifi ? 4_000_000 : 1_500_000
        item.preferredForwardBufferDuration = isActive ? 5 : 2
    }
    
    func onSubtitlesLoaded(tracks: [FastPixPlayerSDKTest.SubtitleTrack]) {
        
    }
    
    func onSubtitleChange(track: FastPixPlayerSDKTest.SubtitleTrack?) {
        
    }
    
    func onSubtitleCueChange(information: SubtitleRenderInfo) {
        let subtitleText = information.text

        DispatchQueue.main.async {

            self.currentSubtitleText = information.text

        }
    }
    
    func onSubtitlesLoadedFailed(error: FastPixPlayerSDKTest.SubtitleTrackError) {
    }
    
    func onQualityLevelsUpdated(levels: [FastPixPlayerSDKTest.QualityLevel]) {
       
    }
    
    func onQualityLevelChanged(selectedLevel: FastPixPlayerSDKTest.QualityLevel) {
        
    }
    
    func onQualityLevelFailed(error: FastPixPlayerSDKTest.QualityLevelError) {
      
    }
    
    func onQualitySwitching(isSwitching: Bool) {
    
    }
}
