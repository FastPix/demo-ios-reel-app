import SwiftUI
import AVKit
import UIKit

struct ReelPageView: UIViewControllerRepresentable {

    @ObservedObject var feedVM: FeedViewModel
    @ObservedObject var pool: PlayerPoolManager

    func makeCoordinator() -> Coordinator {
        Coordinator(feedVM: feedVM, pool: pool)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let pvc = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .vertical,
            options: [UIPageViewController.OptionsKey.interPageSpacing: 0]
        )
        pvc.delegate = context.coordinator
        pvc.dataSource = context.coordinator
        pvc.view.backgroundColor = .black

        context.coordinator.pageVC = pvc

        if !feedVM.videos.isEmpty {
            context.coordinator.hasShownFirstPage = true
            let firstVC = context.coordinator.makePageVC(for: 0)
            pvc.setViewControllers([firstVC], direction: .forward, animated: false)
            pool.setActive(0)                       // start playing the first video
        }

        return pvc
    }
    
    func findScrollView(in view: UIView) -> UIScrollView? {
       
        if let sv = view as? UIScrollView { return sv }
        for sub in view.subviews {
            if let found = findScrollView(in: sub) { return found }
        }
        return nil
    }

    func updateUIViewController(_ pvc: UIPageViewController, context: Context) {
         
        let coord = context.coordinator
        guard !feedVM.videos.isEmpty else { return }

        if !coord.hasShownFirstPage {
            coord.hasShownFirstPage = true
            let firstVC = coord.makePageVC(for: 0)
            pvc.setViewControllers([firstVC], direction: .forward, animated: false)
            pool.setActive(0)
        }
    }
}

extension ReelPageView {

    final class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

        weak var feedVM: FeedViewModel?
        weak var pool: PlayerPoolManager?

        weak var pageVC: UIPageViewController?
        var currentIndex: Int = 0
        var hasShownFirstPage = false

        init(feedVM: FeedViewModel, pool: PlayerPoolManager) {
            self.feedVM = feedVM
            self.pool = pool
        }

        func makePageVC(for index: Int) -> ReelPageItemVC {
            let vc = ReelPageItemVC()
            vc.index = index
            vc.video = feedVM?.videos[index]
            vc.pool = pool
            vc.pendingPlayerVC = pool?.playerVC(for: index)   // player for THIS exact index
            return vc
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController
        ) -> UIViewController? {
            guard let current = viewController as? ReelPageItemVC else {
                return nil }
            let prevIndex = current.index - 1
            guard prevIndex >= 0 else { return nil }
            return makePageVC(for: prevIndex)
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController
        ) -> UIViewController? {
            guard let current = viewController as? ReelPageItemVC else {
                return nil }
            let nextIndex = current.index + 1
            guard nextIndex < (feedVM?.videos.count ?? 0) else { return nil }
            return makePageVC(for: nextIndex)
        }

        // Mid-gesture: only PRELOAD the incoming video. Do NOT play it yet.
        func pageViewController(
            _ pageViewController: UIPageViewController,
            willTransitionTo pendingViewControllers: [UIViewController]
        ) {
            guard let pending = pendingViewControllers.first as? ReelPageItemVC else { return }
            pool?.preload(pending.index)
        }

        // Swipe finished: now decide what actually plays.
        func pageViewController(
            _ pageViewController: UIPageViewController,
            didFinishAnimating finished: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool
        ) {
            guard completed,
                  let current = pageViewController.viewControllers?.first as? ReelPageItemVC
            else { return }

            currentIndex = current.index
            pool?.setActive(current.index)
            pool?.preload(current.index + 1)
            pool?.preload(current.index + 2)
            feedVM?.didSwipeTo(index: current.index)
        }
    }
}

final class ReelPageItemVC: UIViewController {

    var index: Int = 0
    var video: ReelVideo?
    weak var pool: PlayerPoolManager?

    var pendingPlayerVC: AVPlayerViewController?

    private var playerVCEmbedded: AVPlayerViewController?
    private var hostingVC: UIHostingController<ReelCardOverlay>?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.clipsToBounds = true

        if let pvc = pendingPlayerVC {
            embedPlayerVC(pvc)
            embedOverlay()
        }
    }

    func embedPlayerVC(_ playerVC: AVPlayerViewController) {
        
        guard playerVCEmbedded !== playerVC else { return }

        playerVCEmbedded?.willMove(toParent: nil)
        playerVCEmbedded?.view.removeFromSuperview()
        playerVCEmbedded?.removeFromParent()

        if playerVC.parent != nil {
            playerVC.willMove(toParent: nil)
            playerVC.view.removeFromSuperview()
            playerVC.removeFromParent()
        }

        playerVCEmbedded = playerVC
        addChild(playerVC)
        playerVC.view.frame = view.bounds
        playerVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        playerVC.view.clipsToBounds = true
        view.insertSubview(playerVC.view, at: 0)
        playerVC.didMove(toParent: self)
    }

    private func embedOverlay() {
        guard let video = video, let pool = pool else { return }

        hostingVC?.willMove(toParent: nil)
        hostingVC?.view.removeFromSuperview()
        hostingVC?.removeFromParent()

        let overlay = ReelCardOverlay(video: video, pool: pool,)
        let hvc = UIHostingController(rootView: overlay)
        hvc.view.backgroundColor = .clear
        addChild(hvc)
        hvc.view.frame = view.bounds
        hvc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(hvc.view)
        hvc.didMove(toParent: self)
        hostingVC = hvc
    }

    // When this page goes away, release its player so it's free to be reused.
    deinit {
        playerVCEmbedded?.willMove(toParent: nil)
        playerVCEmbedded?.view.removeFromSuperview()
        playerVCEmbedded?.removeFromParent()
    }
}
