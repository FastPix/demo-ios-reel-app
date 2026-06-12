# Reel App - FastPix iOS Player SDK Demo
 
A modern iOS demonstration application showcasing the **[FastPix iOS Player SDK](https://github.com/FastPix/iOS-player)**. This app demonstrates how to integrate professional video playback into iOS applications with a TikTok-style reel feed interface.
 
## Overview
 
Reel App is a **reference implementation** for developers looking to integrate FastPix's video streaming into their iOSapplications. It features:
 
- **Video Streaming**: High-performance video playback using the FastPix iOS Player SDK
- **Social-style Feed**: Infinite scroll reel feed similar to popular social media apps
- **Lifecycle-aware Playback**: Automatic pause/resume when switching tabs or backgrounding the app
- **Video Metadata**: Display creator information, titles, and descriptions
 
## Features
 
### Player Features
- Full-screen vertical reel feed with smooth scroll snapping
- Auto-play on scroll with loop enabled
- Error handling and retry support
- Loading and empty state screens
 
 
## Tech Stack
 
### Architecture & Framework
- **Language**: Swift
- **UI Framework**: SwiftUI
- **Architecture Pattern**: MVVM
- **Minimum iOS Version**: iOS 16.0+
 
### Libraries & Dependencies
 
- **Video Playback**:
  - `FastPixPlayerSDK` (`ios-player` v1.0.0) – FastPix Player SDK via Swift Package Manager
 
- **Image Loading**:
  - `SDWebImage` v5.21.7 – Async image loading
  - `SDWebImageSwiftUI` v3.1.4 – SwiftUI integration for SDWebImage
  - `SDWebImageSVGCoder` v1.8.0 – SVG image decoding (used for DiceBear avatars)
 
- **Networking**:
  - `URLSession` – Native async/await HTTP client
 
- **UI**:
  - `SwiftUI` – Declarative UI
  - `AVKit / AVFoundation` – Native video player integration
  - `PhotosUI` – System photo/video library picker
 
- **State Management**:
  - `Combine` – Reactive publishers
  - `@StateObject / @ObservableObject` – SwiftUI observable state
  - `UserDefaults` – Lightweight persistent storage
 
## Prerequisites
 
Before setting up the project, ensure you have:
 
1. **Xcode** 15 or later (latest version recommended)
2. **macOS** Ventura 13.0 or higher
3. **iOS Deployment Target**: iOS 16.0+ (iOS 17.0+ recommended for full feature support)
4. **Swift** 5.9+
5. **FastPix Account** with a valid Token ID and Secret Key
 
## Setup & Configuration
 
### Step 1: Clone the Repository
 
```bash
git clone https://github.com/FastPix/demo-ios-reel-app.git
cd demo-ios-reel-app
```
 
### Step 2: Obtain Required Credentials
 
Before running the project, gather:
 
**FastPix Credentials:**
- Visit your [FastPix Dashboard](https://fastpix.com)
- Copy your **Token ID** (Access Token) and **Secret Key**
 
### Step 3: Configure Environment Variables
 
The app reads credentials from environment variables at runtime via `ProcessInfo`. Set them in your Xcode scheme:
 
1. Open the project in Xcode
2. Go to **Product → Scheme → Edit Scheme** (or press `⌘ <`)
3. Select the **Run** action → **Arguments** tab
4. Under **Environment Variables**, add:
 
| Name | Value |
|------|-------|
| `ACCESS_TOKEN_ID` | Your FastPix Token ID |
| `SECRET_KEY` | Your FastPix Secret Key |
 
### Step 4: Add Swift Package Dependencies
 
This project uses Swift Package Manager (SPM) for all dependencies. Since the packages are not bundled in the repository, you need to add them manually in Xcode.
 
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
 
### Step 5: Build & Run
 
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
 
## Troubleshooting
 
### Swift Package Resolution Fails
**Problem**: Xcode cannot resolve `FastPixPlayerSDK`
 
**Solution**:
1. Ensure you have internet access and Xcode has permission to access GitHub
2. Go to **File → Packages → Reset Package Caches**
3. Re-resolve packages via **File → Packages → Resolve Package Versions**
 
### Videos Not Playing — "Content not Available"
**Problem**: Reel feed shows an error or blank screen
 
**Solution**:
1. Verify `ACCESS_TOKEN_ID` and `SECRET_KEY` environment variables are set in your Xcode scheme
2. Ensure videos in your FastPix account have `status: ready`
3. Check network connectivity on the device/simulator
 
**Solution**:
1. Re-check `ACCESS_TOKEN_ID` and `SECRET_KEY` values in the Xcode scheme environment variables
2. Confirm the credentials are active in your [FastPix Dashboard](https://fastpix.com)
3. Ensure the credentials are not expired or revoked
 
### Build Fails on iOS 15 or Earlier
**Problem**: Compiler errors related to `PhotosPicker` or `NavigationStack`
 
**Solution**:
- Set the deployment target to **iOS 16.0** or higher in Xcode project settings
- Some features (e.g., `onChange` with two-parameter closure) require **iOS 17.0+**; use a device or simulator running iOS 17+
 
**Solution**:
1. The app polls up to 30 times with a 3-second interval (90 seconds total)
2. For large videos, processing may take longer — check the video status directly in your FastPix Dashboard

## Reference Documentation
 
- **FastPix Platform**: [fastpix.io](https://fastpix.com)
- **FastPix Docs**: [fastpix.com/docs](https://fastpix.com/docs)
- **iOS Player SDK – Installation Guide**: [fastpix.com/docs/ios-player/install-fastpix-ios-player](https://fastpix.com/docs/ios-player/install-fastpix-ios-player)
- **iOS Player SDK**: [github.com/FastPix/iOS-player](https://github.com/FastPix/iOS-player)
- **SDWebImage**: [github.com/SDWebImage/SDWebImage](https://github.com/SDWebImage/SDWebImage)
- **SDWebImageSwiftUI**: [github.com/SDWebImage/SDWebImageSwiftUI](https://github.com/SDWebImage/SDWebImageSwiftUI)
- **SDWebImageSVGCoder**: [github.com/SDWebImage/SDWebImageSVGCoder](https://github.com/SDWebImage/SDWebImageSVGCoder)
 
## License
 
Reel App is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.
 
## Support
 
For issues or questions:
 
1. Check the [Troubleshooting](#troubleshooting) section above
2. Review [FastPix Documentation](https://docs.fastpix.com)
3. Open an issue on [GitHub Issues](https://github.com/FastPix/demo-ios-reel-app/issues)
4. Contact FastPix support at [support@fastpix.com](mailto:support@fastpix.com)
