import SwiftUI
import AVKit
import FastPixPlayerSDKTest

struct ReelPlayerView: UIViewControllerRepresentable {

    let video: ReelVideo
    let isActive: Bool

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject {
        var isPrepared = false
        var pendingPlay = false
        var observation: NSKeyValueObservation?

        func waitForPlayer(_ playerVC: AVPlayerViewController, then play: Bool) {
            pendingPlay = play
            observation?.invalidate()
            observation = playerVC.observe(\.player, options: [.new]) { [weak self] vc, _ in
                guard let self, let player = vc.player else { return }
                self.observation?.invalidate()
                DispatchQueue.main.async {
                    if self.pendingPlay {
                        playerVC.play()
                       
                    } else {
                        player.pause()
                    }
                }
            }
        }

        deinit { observation?.invalidate() }
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerVC = AVPlayerViewController()
        playerVC.showsPlaybackControls = false
        playerVC.view.backgroundColor = .black
        playerVC.view.isOpaque = true
        playerVC.view.layer.backgroundColor = UIColor.black.cgColor
       
        return playerVC
    }

    func updateUIViewController(_ playerVC: AVPlayerViewController, context: Context) {

        if isActive {
            if !context.coordinator.isPrepared {
                context.coordinator.isPrepared = true
                
                playerVC.isAutoPlayEnabled = false
                playerVC.isLoopEnabled = true
                playerVC.prepare(
                    playbackID: video.playbackID,
                    playbackOptions: PlaybackOptions(streamType: "on-demand")
                )

                if playerVC.player != nil {
                    playerVC.play()
                } else {
                    context.coordinator.waitForPlayer(playerVC, then: true)
                }
            } else {
                playerVC.play()
            }

        } else {
            // Update pending flag so if player loads while inactive, it stays paused
            context.coordinator.pendingPlay = false

            if context.coordinator.isPrepared {
                playerVC.pause()
                playerVC.player?.seek(to: .zero)
            }
        }
    }
}
