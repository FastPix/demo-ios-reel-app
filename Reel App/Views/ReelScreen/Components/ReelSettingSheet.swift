import SwiftUI
import FastPixPlayerSDKTest
import Combine

struct ReelSettingsSheet: View {

    @ObservedObject var vm: ReelSettingsViewModel

    var body: some View {

        NavigationView {

            List {

                qualitySection

                audioSection

                subtitleSection
            }
            .navigationTitle("Playback Settings")
        }
    }
}
private extension ReelSettingsSheet {

    var qualitySection: some View {

        Section("Video Quality") {

            ForEach(vm.settings.qualityLevels, id: \.id) { level in

                Button {

                    vm.selectQuality(level)

                } label: {

                    HStack {

                        Text(level.label)

                        Spacer()

                        if vm.settings.selectedQuality?.id == level.id {

                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
    }
}

private extension ReelSettingsSheet {

    var audioSection: some View {

        Section("Audio") {

            ForEach(vm.settings.audioTracks, id: \.id) { track in

                Button {

                    vm.selectAudio(track)

                } label: {

                    HStack {

                        Text(track.label)

                        Spacer()

                        if vm.settings.selectedAudio?.id == track.id {

                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
    }
}

private extension ReelSettingsSheet {

    var subtitleSection: some View {

        Section("Subtitles") {

            Button {

                vm.selectSubtitle(nil)

            } label: {

                HStack {

                    Text("Off")

                    Spacer()

                    if vm.settings.selectedSubtitle == nil {

                        Image(systemName: "checkmark")
                    }
                }
            }

            ForEach(vm.settings.subtitleTracks, id: \.id) { track in

                Button {
                    vm.selectSubtitle(track)

                } label: {

                    HStack {

                        Text(track.label)

                        Spacer()

                        if vm.settings.selectedSubtitle?.id == track.id {

                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
    }
}
