# SCNRecorder

SCNRecorder allows you to record videos and to capture images from ARSCNView and SCNView without sacrificing performance. It gives you an incredible opportunity to share media content of your augmented reality app or SceneKit based game.

![Sample](/images/sample.gif?raw=true )

(Don't worry! The bottom line is a part of the content, not the user's interface!)

## Requirements

- iOS 11.0+
- Xcode 10.1+
- Swift 4.2+

## Installation

For now, the only approved way to install the library is using CocoaPods.
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

Using Interface Builder you need to set a class of a scene view to ARSCNRecordableView or SCNRecordableView and choose SCNRecorder as a module. 
You may inherit from the recorder's views and use them instead.

![SCNRecorder IB integration](/images/InterfaceBuilder.png?raw=true )

#### Code

When initializing your ARSCNView or SCNView, you need to add SCNRecorder before the name of an inherited class.
SCNRecorder.ARSCNView and SCNRecorder.SCNView is a shortcut to ARSCNRecordableView and SCNRecordableView respectively.

```
let sceneView: ARSCNView = SCNRecorder.ARSCNView(...)
```
or 

```
let sceneView: SCNView = SCNRecorder.SCNView(...)
```

If your classes inherit from ARSCNView or SCNView just inherit them from SCNRecorder.ARSCNView or SCNRecorder.SCNView.

```
class MyArSceneView: SCNRecorder.ARSCNView { ... }
```
or

```
class MySceneView: SCNRecorder.SCNView { ... }
```

### Preparing recorder

For example, if you are going to add an ability to capture videos to a ViewControler with ARSCNView on it, your code will look like the snippet below.

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
        
        recorder = try! SCNRecorder(sceneView)
    }
    
    @IBAction func startVideoRecording(_ sender: Any) {

        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documentsDirectory.appendingPathComponent("video.mov", isDirectory: false)
        
        // Be sure that the file isn't exist
        try? fileManager.removeItem(at: url)

        // You must store a strong reference to a video recording
        videoRecording = try! recorder.makeVideoRecording(to: url)
        
        // Don't forget to resume recording
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

Look at the Example project for more details.

## Author

- [Vladislav Grigoryev](https://github.com/v-grigoriev)

Thanks to [Fedor Prokhorov](https://github.com/prokhorovxo) for testing and clarifying the public interface of the framework.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
