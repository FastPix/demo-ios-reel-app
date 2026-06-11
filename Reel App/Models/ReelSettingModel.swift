import Foundation
import FastPixPlayerSDKTest

struct ReelPlaybackSettings {

    var audioTracks: [AudioTrack] = []
    var subtitleTracks: [SubtitleTrack] = []
    var qualityLevels: [QualityLevel] = []

    var selectedAudio: AudioTrack?
    var selectedSubtitle: SubtitleTrack?
    var selectedQuality: QualityLevel?
}

enum ActivePopup {
    case audio
    case subtitle
    case quality
}
