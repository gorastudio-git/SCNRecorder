# SCNRecorder

[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/gorastudio/SCNRecorder/master/LICENSE.md)
![Platforms](https://img.shields.io/cocoapods/p/SCNRecorder.svg)
![Swift](https://img.shields.io/badge/swift-5.2-red.svg)
[![Cocoapods compatible](https://img.shields.io/cocoapods/v/SCNRecorder.svg)](https://cocoapods.org/pods/SCNRecorder)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

SCNRecorder allows you to record videos and to capture images from ARSCNView and SCNView without sacrificing performance. It gives you an incredible opportunity to share the media content of your augmented reality app or SceneKit based game.

SCNRecorder supports Metal and OpenGL.

![Sample](/images/sample2.gif?raw=true )

## Requirements

- iOS 11.0+
- Xcode 11.5+
- Swift 4.2+

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org/)  is a dependency manager for Swift and Objective-C Cocoa projects, which automates and simplifies the process of using 3rd-party libraries in your projects. See the [Get Started](https://cocoapods.org/#get_started) section for more details.

#### Podfile

```ruby
pod 'SCNRecorder', '~> 1.1'
```

### Carthage

```ruby
github "gorastudio/SCNRecorder"
```

## Usage

Import the SCNRecorder module.

```swift
import SCNRecorder
```

At `viewDidLoad` it is recomended to prepare a `sceneView` for recording.

```swift
@IBOutlet var sceneView: SCNView!

override func viewDidLoad() {
  super.viewDidLoad()
  sceneView.prepareForRecording()
}
```

And now you can use new functions to capture videos.

```swift
try sceneView.startVideoRecording()
```

```swift
sceneView.finishVideoRecording { (videoRecording) in 
  /* Process the captured video. Main thread. */
  let controller = AVPlayerViewController()
  controller.player = AVPlayer(url: recording.url)
  self.navigationController?.pushViewController(controller, animated: true)
}
```

To capture an image it is enough to call:

```swift
try sceneView.takePhoto { (photo) in
  /* Your photo is now here. Main thread. */
}
```

Look at the Example project for more details.

### Audio capture

#### ARSCNView

To capture video with audio from `ARSCNView` enable audio in the `ARConfiguration`.

```swift
let configuration = ARWorldTrackingConfiguration()
configuration.providesAudioData = true
sceneView.session.run(configuration)
```

#### SCNView

To capture audio from `SCNView` you have to implement it by yourself.

```swift
var captureSession: AVCaptureSession?

override func viewDidLoad() {
  super.viewDidLoad()
  sceneView.prepareForRecording()
  
  guard let recorder = sceneView.recorder else { return }
  let captureSession = AVCaptureSession()
  
  guard let captureDevice = AVCaptureDevice.default(for: .audio) else { return }
  
  do {
    let captureInput = try AVCaptureDeviceInput(device: captureDevice)
    
    guard captureSession.canAddInput(captureInput) else { return }
    captureSession.addInput(captureInput)
  }
  catch { print("Can't create AVCaptureDeviceInput: \(error)")}
  
  guard captureSession.canAddRecorder(recorder) else { return }
  captureSession.addRecorder(recorder)
  
  captureSession.startRunning()
  self.captureSession = captureSession
}
```

### That's it!

Look at the Example project for more details.

## Author

- [Vladislav Grigoryev](https://github.com/v-grigoriev)

Thanks to [Fedor Prokhorov](https://github.com/prokhorovxo) and [Dmitry Yurlov](https://github.com/demonukg) for testing and clarifying the public interface of the framework.

Thanks to  for testing and clarifying the public interface of the framework.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE.md) file for details
