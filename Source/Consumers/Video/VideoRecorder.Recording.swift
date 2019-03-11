//
//  VideoRecorder.Recording.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 11/03/2019.
//  Copyright (c) 2019 GORA Studio. https://gora.studio
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

extension VideoRecorder {
    
    final class Recording: _VideoRecording {
        
        let notificationQueue: DispatchQueue = DispatchQueue(label: "VideoRecording.NotificationQueue", qos: .userInteractive)
        
        var _duration: TimeInterval = 0.0
        
        var onDurationChanged: ((TimeInterval) -> Void)?
        
        var _state: Recording.State = .preparing
        
        var onStateChanged: ((Recording.State) -> Void)?
        
        var _error: Swift.Error?
        
        var onError: ((Swift.Error) -> Void)?
        
        var controlable: Controlable {
            return videoRecorder
        }
        
        var videoInfoProvider: VideoInfoProvider {
            return videoRecorder
        }
        
        let videoRecorder: VideoRecorder
        
        init(videoRecorder: VideoRecorder) {
            self.videoRecorder = videoRecorder
        }
    }
}
