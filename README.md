# SCNRecorder

SCNRecorder allows you to record videos and to capture images from ARSCNView and SCNView without sacrificing performance. It gives you an incredible opportunity to share media content of your augmented reality app or SceneKit based game.

## Requirements

- iOS 11.0+
- Xcode 10.1+
- Swift 4.2+

## Installation

For now, the only way to install the library is using CocoaPods.
But the framework has no external dependencies, so you may just install it by cloning repository.

### Installation with CocoaPods

[CocoaPods](http://cocoapods.org/)  is a dependency manager for Swift and Objective-C Cocoa projects, which automates and simplifies the process of using 3rd-party libraries in your projects. See the [Get Started](https://cocoapods.org/#get_started) section for more details.

#### Podfile
```
pod 'SCNRecorder', '~> 1.0'
```

## Usage

At every file where you need the functionality, you need to import the module.

```
import SCNRecorder

```

### Configure view

#### Interface Builder

Using Interface Builder you need to set a class of a scene view to ARSCNRecorderView, SCNRecorderView and choose SCNRecorder as a module. You may inherit from recorder's views and use them instead.

![SCNRecorder IB integration](/images/InterfaceBuilder.png?raw=true )

#### Code

When initializing your ARSCNView or SCNView, you need to use ARSCNRecorderView or SCNRecorderView respectively.

```
let sceneView: ARSCNView = ARSCNRecorderView(...)
```
or 

```
let sceneView: SCNView = SCNRecorderView(...)
```

If your classes inherit ARSCNView or SCNView just inherit from ARSCNRecorderView or SCNRecorderView.

```
class MyArSceneView: ARSCNRecorderView { ... }
```
or

```
class MySceneView: SCNRecorderView { ... }
```

### Preparing recorder

For example if you are going to add an ability to capture videos to a ViewControler with ARSCNView on it, your code will looks like the snippet below.

```
import Foundation
import UIKit
import ARKit
import SCNRecorder

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var recorder: ARSCNRecorder!
    
    var videoRecording: VideoRecording? {
        didSet {
            // You may subscribe to different notifications
            videoRecording?.onDurationChanged = { duration in print(duration) }
            videoRecording?.onStateChanged = { state in print(state) }
            videoRecording?.onError = { error in print(error) }
        }
    } 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recorder = try! ARSCNRecorder(sceneView)
        sceneView.delegate = recorder
        recorder.sceneViewDelegate = self
    }
    
    @IBAction func startVideoRecording(_ sender: Any) {

        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documentsDirectory.appendingPathComponent("video.mov", isDirectory: false)
        
        // Be sure that the file isn't exist
        try? fileManager.removeItem(at: url)

        // You must store a strong reference to a video recording
        videoRecording = try! recorder.createVideoRecording(to: url)
        videoRecording?.resume()
    }
    
    @IBAction func finishVideoRecording(_ sender: Any) {
        videoRecording?.finish(completionHandler: { (recording) in
            // Captured video is ready
            print(recording.url)
        })
    }
}
```

### That's it!

## Author

- [Vladislav Grigoryev](https://github.com/v-grigoriev)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
