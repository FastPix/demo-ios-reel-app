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

## Start here

If you are setting up this demo for the first time, follow these steps in order:

1. [Check your macOS version](#1-check-your-macos-version)
2. [Check that Xcode is installed](#2-check-that-xcode-is-installed)
3. [Point the command line at Xcode](#3-point-the-command-line-at-xcode)
4. [Check for an iOS 26 simulator](#4-check-for-an-ios-26-simulator)
5. [Get your FastPix credentials](#5-get-your-fastpix-credentials)
6. [Add a video to your account](#6-add-a-video-to-your-account)
7. [Clone the repository](#7-clone-the-repository)
8. [Add the Swift package dependencies](#8-add-the-swift-package-dependencies)
9. [Configure your FastPix credentials](#9-configure-your-fastpix-credentials)
10. [Build the app](#10-build-the-app)
11. [Run and verify the app](#11-run-and-verify-the-app)

Do not skip the verification commands. If a step's check fails, fix that problem before you continue.

<br />

## Before you begin

Make sure the following are installed on your Mac and ready to use:

| Requirement | Details |
|---|---|
| **macOS** | Ventura 13.0 or later. To run the bundled iOS 26 simulator, you need a macOS version that supports Xcode 26 (macOS 15 Sequoia or later). |
| **Xcode 26 or later** | The full Xcode app from the App Store, not just the standalone Command Line Tools. The committed project targets `IPHONEOS_DEPLOYMENT_TARGET = 26.0`, so it needs Xcode 26. Xcode bundles Swift 5.9+ and Git, so you don't install those separately. |
| **An iOS 26 runtime** | An iOS 26 simulator (bundled with Xcode 26) or a physical device running iOS 26. |
| **A FastPix account** | Free to create at the [FastPix Dashboard](https://dashboard.fastpix.com). |
| **FastPix API credentials** | An Access Token (Token ID) and a Secret Key from your FastPix account. |

> **Supported iOS versions:** The app's APIs target **iOS 16.0 and later**. The committed project sets an iOS 26.0 deployment target, so out of the box it needs Xcode 26 and an iOS 26 simulator or device. To run on an older iOS version (16.0+), lower `IPHONEOS_DEPLOYMENT_TARGET` in the target's **Build Settings**, or see [Build fails on iOS 15 or earlier](#build-fails-on-ios-15-or-earlier).

The app reads your credentials from two environment variables at runtime:

| App environment variable | FastPix credential |
|---|---|
| `ACCESS_TOKEN_ID` | Access Token (Token ID) |
| `SECRET_KEY` | Secret Key |

You obtain both values from the FastPix Dashboard. For details, see the [Basic authentication guide](https://fastpix.com/docs/getting-started/activate-your-account#generate-api-credentials).

> **Security:** Never commit your Access Token or Secret Key to source control. Keep them in your Xcode scheme or a secure secrets store.

<br />

## 1. Check your macOS version

The build tools run on macOS. Confirm your version:

```bash
sw_vers
```

Output is similar to:

```text
ProductName:		macOS
ProductVersion:		26.6.2
BuildVersion:		25G83
```

You need a macOS version that can run Xcode 26. If your macOS is older, update macOS before you continue.

<br />

## 2. Check that Xcode is installed

This demo requires the full Xcode app. The standalone Command Line Tools cannot build an iOS app.

Confirm that Xcode is installed:

```bash
ls -d /Applications/Xcode*.app
```

Expected output:

```text
/Applications/Xcode.app
```

If you see `No matches found`, install **Xcode 26 or later** from the App Store, then continue.

<br />

## 3. Point the command line at Xcode

Even with Xcode installed, the `xcodebuild` command can still point at the Command Line Tools. Check it:

```bash
xcodebuild -version
```

If the command succeeds, the output shows your Xcode version, and you can skip to the next step:

```text
Xcode 26.6
Build version 17F113
```

If instead you see this error, the command line is pointing at the Command Line Tools:

```text
xcode-select: error: tool 'xcodebuild' requires Xcode, but active developer directory '/Library/Developer/CommandLineTools' is a command line tools instance
```

Point the command line at Xcode, and accept the license (both commands need your password):

```bash
sudo xcode-select --switch /Applications/Xcode.app
sudo xcodebuild -license accept
```

Then verify again. Do not continue until `xcodebuild -version` prints a version:

```bash
xcodebuild -version
```

<br />

## 4. Check for an iOS 26 simulator

The project's deployment target is iOS 26.0, so you need an iOS 26 simulator or a device running iOS 26. List the simulators installed on your Mac:

```bash
xcrun simctl list devices available
```

Output is similar to:

```text
-- iOS 26.5 --
    iPhone 17 Pro (...) (Shutdown)
    iPhone 17 (...) (Shutdown)
    iPhone Air (...) (Shutdown)
```

Note a device name that appears under an `-- iOS 26.x --` heading (for example, `iPhone 17`). You use it in [Build the app](#10-build-the-app).

If no `-- iOS 26.x --` section appears, install the runtime in Xcode from **Xcode > Settings > Components** (in earlier versions, **Xcode > Settings > Platforms**), then run the command again.

<br />

## 5. Get your FastPix credentials

The app lists and streams the videos in your FastPix workspace, so it authenticates with your account credentials:

1. Sign up or log in to the [FastPix Dashboard](https://dashboard.fastpix.com).
2. Copy your **Token ID** (Access Token) and **Secret Key**. To generate your Access Token ID and Secret Key, see the [Basic authentication guide](https://fastpix.com/docs/getting-started/activate-your-account#generate-api-credentials).

You set these as environment variables in [Configure your FastPix credentials](#9-configure-your-fastpix-credentials). Never commit real credentials to version control - keep them in the Xcode scheme or a secure secrets store.

<br />

## 6. Add a video to your account

The app does not ship with any bundled video. On launch, it lists the media in *your* FastPix account and plays back only assets that are **`ready`** and have a playback ID. If your account has no ready media, the app shows the empty state "No ready videos found in your FastPix account."

Add at least one video to your account before you run the app:

1. In the [FastPix Dashboard](https://dashboard.fastpix.com), create a media asset by uploading a file or pulling one from a URL. For a quick test, you can use the FastPix sample video URL:

   ```text
   https://static.fastpix.com/fp-sample-video.mp4
   ```

2. Wait for the asset's status to become **`ready`** in the Dashboard. Only ready media appears in the reel feed.

For step-by-step instructions on creating media, see the [FastPix Video on Demand overview](https://fastpix.com/docs/video-on-demand-api/overview).

> **Tip:** Add a few videos so you can scroll through the vertical feed. The app pages through your media 10 at a time.

<br />

## 7. Clone the repository

```bash
git clone https://github.com/FastPix/demo-ios-reel-app.git
cd demo-ios-reel-app
```

<br />

## 8. Add the Swift package dependencies

This project uses Swift Package Manager (SPM) for all dependencies. The packages are not bundled in the repository, so add them manually in Xcode.

Open `Reel App.xcodeproj`, then go to **File → Add Package Dependencies** and add each of the following packages:

#### FastPix iOS Player SDK

```
https://github.com/FastPix/iOS-player
```

- Select version **1.1.2** (Up to Next Major)
- Add the `FastPixPlayerSDKTest` library to the `Reel App` target

  > **Note:** The library product is named `FastPixPlayerSDKTest`, which is the module the app imports (`import FastPixPlayerSDKTest`). Add version **1.1.1 or later** — earlier versions (1.0.0) expose the product under the old name `FastPixPlayerSDK` and won't compile against this app.

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

> After adding all packages, Xcode resolves and downloads them automatically. You can verify the four packages you added are present under **Package Dependencies** in the Xcode Project Navigator, matching the versions shown above. Xcode also pulls in their transitive dependencies (for example, `FastpixVideoDataAVPlayer` and `FastpixiOSVideoDataCore`).

To verify resolution from the command line, run:

```bash
xcodebuild -project "Reel App.xcodeproj" -scheme "Reel App" -resolvePackageDependencies
```

The output lists the resolved packages, including `FastPixPlayerSDKTest`:

```text
Resolved source packages:
  FastPixPlayerSDKTest: https://github.com/FastPix/iOS-player @ 1.1.2
  SDWebImage: https://github.com/SDWebImage/SDWebImage @ 5.21.7
  SDWebImageSwiftUI: https://github.com/SDWebImage/SDWebImageSwiftUI @ 3.1.4
  ...
```

<br />

## 9. Configure your FastPix credentials

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

## 10. Build the app

#### Option A: Using Xcode

1. Open `Reel App.xcodeproj` in Xcode
2. Select an iOS 26 simulator or device as the run destination
3. Press **Run** (`⌘R`)

#### Option B: Using the command line

Replace `iPhone 17` with the device name you noted in [Check for an iOS 26 simulator](#4-check-for-an-ios-26-simulator).

```bash
# Build for a simulator
xcodebuild -project "Reel App.xcodeproj" \
           -scheme "Reel App" \
           -destination "platform=iOS Simulator,name=iPhone 17" \
           build

# Build and run on a connected device (replace DEVICE_UDID)
xcodebuild -project "Reel App.xcodeproj" \
           -scheme "Reel App" \
           -destination "id=DEVICE_UDID" \
           build
```

A successful build ends with:

```text
** BUILD SUCCEEDED **
```

If the build fails with `Missing package product 'FastPixPlayerSDK'` or `No such module 'FastPixPlayerSDKTest'`, see [Troubleshooting](#troubleshooting).

<br />

## 11. Run and verify the app

When the build succeeds and your credentials are valid, the app launches into a full-screen, vertically scrolling reel feed that auto-plays looping videos from your FastPix account, with creator avatars and overlays.

A working app confirms that:

- macOS and Xcode 26 are installed and selected.
- An iOS 26 simulator or device is available.
- The Swift package dependencies resolved, including `FastPixPlayerSDKTest`.
- Your FastPix credentials are set in the scheme.
- The app can authenticate with FastPix and stream your account's ready videos.

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
  - `FastPixPlayerSDKTest` (`iOS-player` v1.1.2) - FastPix Player SDK via Swift Package Manager
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

### Build fails with "Missing package product" or "No such module 'FastPixPlayerSDKTest'"

**Problem**: The build fails with `Missing package product 'FastPixPlayerSDK'` or `No such module 'FastPixPlayerSDKTest'`.

**Solution**:
1. The app imports `FastPixPlayerSDKTest`. Make sure you added the **`FastPixPlayerSDKTest`** library (not `FastPixPlayerSDK`) from the `iOS-player` package, at version **1.1.1 or later**.
2. In Xcode, select the **Reel App** target → **General** → **Frameworks, Libraries, and Embedded Content**, and confirm `FastPixPlayerSDKTest` is listed.
3. If you first added an older version, choose **File → Packages → Update to Latest Package Versions**, then rebuild.

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
Xcode 26, macOS, and a FastPix account with a Token ID and Secret Key. See [Before you begin](#before-you-begin).

**Where do I get my Token ID and Secret Key?**
From the FastPix Dashboard. See [Get your FastPix credentials](#5-get-your-fastpix-credentials).

**Does the app come with sample videos?**
No. It streams the ready videos in your own FastPix account, using the credentials you provide. See [Get your FastPix credentials](#5-get-your-fastpix-credentials).

**Why is the reel feed empty or showing "No ready videos found"?**
Your account has no videos with `status: ready`, or the credentials are wrong or expired. See [Troubleshooting](#troubleshooting).

**Which iOS versions does it support?**
The app's APIs target iOS 16.0+. The committed project currently sets an iOS 26.0 deployment target; see [Build fails on iOS 15 or earlier](#build-fails-on-ios-15-or-earlier) for how to lower it.

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
