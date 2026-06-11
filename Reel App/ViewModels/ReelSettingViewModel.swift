import Foundation
import FastPixPlayerSDKTest
import AVKit
import Combine

@MainActor
final class ReelSettingsViewModel: ObservableObject {

    @Published var settings = ReelPlaybackSettings()

    weak var playerVC: AVPlayerViewController?

    func attach(playerVC: AVPlayerViewController) {
        self.playerVC = playerVC
        refresh()
    }

    func refresh() {

        guard let playerVC else {
            return
        }

        settings.audioTracks = playerVC.getAudioTracks()
        settings.subtitleTracks = playerVC.getSubtitleTracks()
        settings.qualityLevels = playerVC.getResolutionLevels()

        settings.selectedAudio = playerVC.getCurrentAudioTrack()
        settings.selectedSubtitle = playerVC.getCurrentSubtitleTrack()
        settings.selectedQuality = playerVC.getCurrentResolutionLevel()
    }
}
extension ReelSettingsViewModel {

    func selectAudio(_ track: AudioTrack) {

        guard let playerVC else { return }

        playerVC.setAudioTrack(trackId: track.id)

        settings.selectedAudio = track
    }

    func selectSubtitle(_ track: SubtitleTrack?) {

        guard let playerVC else {
            return
        }

        if let track {

            do {
                
                try playerVC.setSubtitleTrack(trackId: track.id)
                
                settings.selectedSubtitle = track

            } catch {
                
                // error
                
            }

        } else {

            playerVC.disableSubtitles()

            settings.selectedSubtitle = nil
        }
    }

    func selectQuality(_ level: QualityLevel) {

        guard let playerVC else { return }

        if level.isAuto {

            playerVC.resetToAuto()

        } else {

            playerVC.setResolutionLevel(level)
        }

        settings.selectedQuality = level
    }
}
