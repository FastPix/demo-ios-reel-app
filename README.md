# FastPix iOS Reel App - TikTok-style video reels demo (SwiftUI)

[![Platform: iOS](https://img.shields.io/badge/platform-iOS-000000?logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![Swift 5.9+](https://img.shields.io/badge/Swift-5.9%2B-F05138?logo=swift&logoColor=white)](https://swift.org)
[![UI: SwiftUI](https://img.shields.io/badge/UI-SwiftUI-0071E3?logo=swift&logoColor=white)](https://developer.apple.com/xcode/swiftui/)
[![FastPix iOS Player SDK](https://img.shields.io/badge/FastPix-iOS%20Player%20SDK-5D09C7)](https://github.com/FastPix/iOS-player)

A ready-to-run SwiftUI sample app that builds a vertical, auto-playing reel feed on top of the [FastPix iOS Player SDK](https://github.com/FastPix/iOS-player). Use it as a reference for adding professional HLS video playback to your own iOS app.

**Works with:** iOS · SwiftUI · MVVM · Swift Package Manager · FastPix iOS Player SDK (`iOS-player`)

📖 **iOS Player docs:** https://fastpix.com/docs/ios-player/install-fastpix-ios-player &nbsp;·&nbsp; ▶️ **Player SDK:** https://github.com/FastPix/iOS-player &nbsp;·&nbsp; 🚀 **Dashboard:** https://dashboard.fastpix.com

<br />

## What this app demonstrates

Reel App is a reference implementation for integrating FastPix video streaming into an iOS app. It shows:

- **Video streaming** - high-performance HLS playback using the FastPix iOS Player SDK
- **A social-style feed** - full-screen vertical reels with smooth scroll snapping, infinite scroll, auto-play, and looping
- **Lifecycle-aware playback** - automatic pause/resume when switching tabs or backgrounding the app
- **Video metadata** - creator information, titles, and descriptions
- **Robust states** - error handling with retry, plus loading and empty-state screens

The app authenticates to your FastPix account and streams the videos already in it - there is no single hardcoded video.

<br />

## Prerequisites

Before you start, make sure you have:

- **Xcode** 15 or later. Note: the committed project was created with Xcode 26.5 and its deployment target is `IPHONEOS_DEPLOYMENT_TARGET = 26.0`, so as-is you need Xcode 26 and an iOS 26 simulator or device. To run on older iOS, lower the deployment target to iOS 16.0 in the project settings (the app's APIs support iOS 16).
- **macOS** Ventura 13.0 or later (a version supported by your Xcode).
- **Swift** 5.9+.
- A **FastPix account** with a Token ID (Access Token) and Secret Key.

<br />

## Get your FastPix credentials

The app lists and streams the videos in your FastPix workspace, so it authenticates with your account credentials:

1. Sign up or log in to the [FastPix Dashboard](https://dashboard.fastpix.com).
2. Copy your **Token ID** (Access Token) and **Secret Key**.

You will set these as environment variables in Step 3. Never commit real credentials to version control - keep them in the Xcode scheme or a secure secrets store.

<br />

## Clone the repository

```bash
git clone https://github.com/FastPix/demo-ios-reel-app.git
cd demo-ios-reel-app
```

<br />

## Add the Swift Package dependencies

This project uses Swift Package Manager (SPM) for all dependencies. The packages are not bundled in the repository, so add them manually in Xcode.

Open `Reel App.xcodeproj`, then go to **File → Add Package Dependencies** and add each of the following packages:

#### FastPix iOS Player SDK
```
https://github.com/FastPix/iOS-player
```
- Select version **1.0.0** (Up to Next Major)
- Add the `FastPixPlayerSDK` library to the `Reel App` target

#### SDWebImage
```
https://github.com/SDWebImage/SDWebImage
```
- Select version **5.21.7** (Up to Next Major)
- Add the `SDWebImage` library to the `Reel App` target

#### SDWebImageSVGCoder
```
https://github.com/SDWebImage/SDWebImageSVGCoder
```
- Select version **1.8.0** (Up to Next Major)
- Add the `SDWebImageSVGCoder` library to the `Reel App` target

#### SDWebImageSwiftUI
```
https://github.com/SDWebImage/SDWebImageSwiftUI
```
- Select version **3.1.4** (Up to Next Major)
- Add the `SDWebImageSwiftUI` library to the `Reel App` target

> After adding all packages, Xcode will resolve and download them automatically. You can verify all five packages are present under **Package Dependencies** in the Xcode Project Navigator, matching the versions shown above.

<br />

## Configure your FastPix credentials

The app reads credentials from environment variables at runtime via `ProcessInfo`. Set them in your Xcode scheme:

1. Open the project in Xcode
2. Go to **Product → Scheme → Edit Scheme** (or press `⌘ <`)
3. Select the **Run** action → **Arguments** tab
4. Under **Environment Variables**, add:

| Name | Value |
|------|-------|
| `ACCESS_TOKEN_ID` | Your FastPix Token ID |
| `SECRET_KEY` | Your FastPix Secret Key |

<br />

## Build and run

#### Option A: Using Xcode

1. Open `Reel App.xcodeproj` in Xcode
2. Select your target device or simulator (iOS 16.0+)
3. Press **Run** (`⌘R`)

#### Option B: Using Command Line

```bash
# Build for a simulator
xcodebuild -project "Reel App.xcodeproj" \
           -scheme "Reel App" \
           -destination "platform=iOS Simulator,name=iPhone 15" \
           build
 
# Build and run on a connected device (replace DEVICE_UDID)
xcodebuild -project "Reel App.xcodeproj" \
           -scheme "Reel App" \
           -destination "id=DEVICE_UDID" \
           build
```

<br />

## Verify it works

When the build succeeds and your credentials are valid, the app launches into a full-screen, vertically scrolling reel feed that auto-plays looping videos from your FastPix account, with creator avatars and overlays.

If the feed shows "No ready videos found in your FastPix account" or a "Content not Available" error, see [Troubleshooting](#troubleshooting).

<br />

## Tech stack

### Architecture & framework
- **Language**: Swift
- **UI framework**: SwiftUI
- **Architecture pattern**: MVVM
- **Minimum iOS version**: iOS 16.0+

### Libraries & dependencies

- **Video playback**:
  - `FastPixPlayerSDK` (`ios-player` v1.0.0) - FastPix Player SDK via Swift Package Manager

- **Image loading**:
  - `SDWebImage` v5.21.7 - Async image loading
  - `SDWebImageSwiftUI` v3.1.4 - SwiftUI integration for SDWebImage
  - `SDWebImageSVGCoder` v1.8.0 - SVG image decoding (used for DiceBear avatars)

- **Networking**:
  - `URLSession` - Native async/await HTTP client

- **UI**:
  - `SwiftUI` - Declarative UI
  - `AVKit / AVFoundation` - Native video player integration
  - `PhotosUI` - System photo/video library picker

- **State management**:
  - `Combine` - Reactive publishers
  - `@StateObject / @ObservableObject` - SwiftUI observable state
  - `UserDefaults` - Lightweight persistent storage

<br />

## Troubleshooting

### Swift Package resolution fails
**Problem**: Xcode cannot resolve `FastPixPlayerSDK`

**Solution**:
1. Ensure you have internet access and Xcode has permission to access GitHub
2. Go to **File → Packages → Reset Package Caches**
3. Re-resolve packages via **File → Packages → Resolve Package Versions**

### Videos not playing - "Content not Available"
**Problem**: Reel feed shows an error or blank screen

**Solution**:
1. Verify `ACCESS_TOKEN_ID` and `SECRET_KEY` environment variables are set in your Xcode scheme
2. Ensure videos in your FastPix account have `status: ready`
3. Check network connectivity on the device/simulator
4. Re-check that the credentials are active in your [FastPix Dashboard](https://dashboard.fastpix.com) and are not expired or revoked

### Build fails on iOS 15 or earlier
**Problem**: Compiler errors related to `PhotosPicker` or `NavigationStack`

**Solution**:
- Set the deployment target to **iOS 16.0** or higher in Xcode project settings
- Some features (e.g., `onChange` with two-parameter closure) require **iOS 17.0+**; use a device or simulator running iOS 17+

<br />

## Which FastPix repo do I need?

This demo shows the iOS player in a reels UI. For the underlying SDKs and other platforms, use:

| I want to... | Repo |
|---|---|
| Play FastPix video in an iOS app (the SDK this demo uses) | [iOS-player](https://github.com/FastPix/iOS-player) |
| Add playback QoE analytics for AVPlayer (iOS / tvOS) | [iOS-data-avplayer-sdk](https://github.com/FastPix/iOS-data-avplayer-sdk) |
| Play FastPix video on the web | [web-player-component](https://github.com/FastPix/web-player-component) |
| Add resumable uploads in the browser | [web-uploads-sdk](https://github.com/FastPix/web-uploads-sdk) |
| Add a React uploader component | [react-web-uploader](https://github.com/FastPix/react-web-uploader) |

Browse everything in the [FastPix organization](https://github.com/orgs/FastPix/repositories).

<br />

## FAQ

**What does this app do?**
It builds a TikTok-style vertical reel feed for iOS using the FastPix iOS Player SDK. See [What this app demonstrates](#what-this-app-demonstrates).

**What do I need to run it?**
Xcode, macOS, and a FastPix account with a Token ID and Secret Key. See [Prerequisites](#prerequisites).

**Where do I get my Token ID and Secret Key?**
From the FastPix Dashboard. See [Get your FastPix credentials](#get-your-fastpix-credentials).

**Does the app come with sample videos?**
No. It streams the ready videos in your own FastPix account, using the credentials you provide. See [Get your FastPix credentials](#get-your-fastpix-credentials).

**Why is the reel feed empty or showing "No ready videos found"?**
Your account has no videos with `status: ready`, or the credentials are wrong or expired. See [Troubleshooting](#troubleshooting).

**Which iOS versions does it support?**
The app's APIs target iOS 16.0+. The committed project currently sets an iOS 26.0 deployment target; see [Prerequisites](#prerequisites) for how to lower it.

**How do I add FastPix playback to my own app?**
Use the FastPix iOS Player SDK directly. See [Which FastPix repo do I need?](#which-fastpix-repo-do-i-need)

<br />

## Reference documentation

- **FastPix Platform**: [fastpix.com](https://fastpix.com)
- **FastPix Docs**: [fastpix.com/docs](https://fastpix.com/docs)
- **iOS Player SDK - Installation Guide**: [fastpix.com/docs/ios-player/install-fastpix-ios-player](https://fastpix.com/docs/ios-player/install-fastpix-ios-player)
- **iOS Player SDK**: [github.com/FastPix/iOS-player](https://github.com/FastPix/iOS-player)
- **SDWebImage**: [github.com/SDWebImage/SDWebImage](https://github.com/SDWebImage/SDWebImage)
- **SDWebImageSwiftUI**: [github.com/SDWebImage/SDWebImageSwiftUI](https://github.com/SDWebImage/SDWebImageSwiftUI)
- **SDWebImageSVGCoder**: [github.com/SDWebImage/SDWebImageSVGCoder](https://github.com/SDWebImage/SDWebImageSVGCoder)

<br />

## License

Reel App is released under the MIT License.

## Support

For issues or questions:

1. Check the [Troubleshooting](#troubleshooting) section above
2. Review the [FastPix Documentation](https://fastpix.com/docs)
3. Open an issue on [GitHub Issues](https://github.com/FastPix/demo-ios-reel-app/issues)
4. Contact FastPix support at [support@fastpix.com](mailto:support@fastpix.com)
