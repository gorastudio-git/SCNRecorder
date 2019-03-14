//
//  InternalRecording.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 14/03/2019.
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

protocol InternalRecording: class, Recording {
    
    var notificationQueue: DispatchQueue { get }
    
    var _duration: TimeInterval { get set }
    
    var duration: TimeInterval { get set }
    
    var _state: State { get set }
    
    var state: State { get set }
    
    var _error: Swift.Error? { get set }
    
    var error: Swift.Error? { get set }
    
    var controlable: Controlable { get }
}

extension InternalRecording {
    
    var duration: TimeInterval {
        get {
            var duration: TimeInterval = 0.0
            notificationQueue.sync {
                duration = _duration
            }
            return duration
        }
        set {
            notificationQueue.async { [weak self] in
                guard let `self` = self, self._duration != newValue else {
                    return
                }
                
                self._duration = newValue
                self.onDurationChanged?(newValue)
            }
        }
    }
    
    var state: Self.State {
        get {
            var state: State = .recording
            notificationQueue.sync {
                state = _state
            }
            return state
        }
        set {
            notificationQueue.async { [weak self] in
                guard let `self` = self, self._state != newValue else {
                    return
                }
                
                self._state = newValue
                self.onStateChanged?(newValue)
            }
        }
    }
    
    var error: Swift.Error? {
        get {
            var error: Swift.Error? = nil
            notificationQueue.sync {
                error = _error
            }
            return error
        }
        set {
            notificationQueue.async { [weak self] in
                guard let `self` = self, let error = newValue else {
                    return
                }
                self._error = error
                self.onError?(error)
            }
        }
    }
    
    func resume() {
        controlable.resume { [weak self] (error) in
            self?.error = error
        }
    }
    
    func pause() {
        controlable.pause()
    }
    
    func finish(completionHandler handler: @escaping (_ recording: Self) -> Void) {
        controlable.finish { handler(self) }
    }
    
    func cancel() {
        controlable.cancel()
    }
}
