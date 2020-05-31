# SCNRecorder

SCNRecorder allows you to record videos and to capture images from ARSCNView and SCNView without sacrificing performance. It gives you an incredible opportunity to share the media content of your augmented reality app or SceneKit based game.

SCNRecorder supports Metal and OpenGL.

![Sample](/images/sample2.gif?raw=true )

(Don't worry! The bottom line is a part of the content, not the user interface!)

## Requirements

- iOS 11.0+
- Xcode 10.1+
- Swift 4.2+

## Installation

For now, the only available way to install the library is to use CocoaPods.
But the framework has no external dependencies, so you can install it by cloning the repository.

### Installation with CocoaPods

[CocoaPods](http://cocoapods.org/)  is a dependency manager for Swift and Objective-C Cocoa projects, which automates and simplifies the process of using 3rd-party libraries in your projects. See the [Get Started](https://cocoapods.org/#get_started) section for more details.

#### Podfile
```
pod 'SCNRecorder', '~> 1.1'
```

## Usage

Import the SCNRecorder module.

```
import SCNRecorder
```

At `viewDidLoad` it is recomended to prepare a `sceneView` for recording.

```
override func viewDidLoad() {
  super.viewDidLoad()

  do { try sceneView.prepareForRecording() }
  catch { print("Something went wrong during recording preparation: \(error)") }
}
```

And now you can use new functions to capture videos.
```
do { try sceneView.startVideoRecording() }
catch { print("Something went wrong during video-recording preparation: \(error)") }
```
```
sceneView.finishVideoRecording { (videoRecording) in 
  /* Process the captured video. Main thread. */
}
```

For example, you can play the video in a different controller.
```
sceneView.finishVideoRecording { (recording) in
  let controller = AVPlayerViewController()
  controller.player = AVPlayer(url: recording.url)
  self.navigationController?.pushViewController(controller, animated: true)
}
```

To capture an image it is enough to call:
```
do {
  try sceneView.takePhoto { (photo) in
    /* Your photo is now here. Main thread. */
  }
}
catch { print("Something went wrong during photo-capture preparation: \(error)") }
```

Look at the Example project for more details.

### Audio capture

To capture video with audio from `ARSCNView` enable it in the `ARConfiguration`.
```
let configuration = ARWorldTrackingConfiguration()
configuration.providesAudioData = true
sceneView.session.run(configuration)
```

To capture audio from `SCNView` you have to implement it by yourself.
For example:

```
var captureSession: AVCaptureSession?

override func viewDidLoad() {
  super.viewDidLoad()
  
  do { try sceneView.prepareForRecording() }
  catch { print("Something went wrong during recording preparation: \(error)") }
  
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

Thanks to [Fedor Prokhorov](https://github.com/prokhorovxo) for testing and clarifying the public interface of the framework.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
