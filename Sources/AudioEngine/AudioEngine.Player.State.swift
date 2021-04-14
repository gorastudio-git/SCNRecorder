//
//  AudioEngine.Player.State.swift
//  Example
//
//  Created by Vladislav Grigoryev on 20.12.2020.
//  Copyright © 2020 GORA Studio. https://gora.studio
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
import AVFoundation

@available(iOS 13.0, *)
extension AudioEngine.Player {

  public enum State: Equatable {

    case playing

    case paused

    case stopped

    var isPlaying: Bool { self == .playing }

    var isPaused: Bool { self == .paused }

    var isStopped: Bool { self == .stopped }

    func getPosition(_ player: AudioEngine.Player) -> AVAudioFramePosition {
      guard let playerNode = player.playerNode else { return player.position }

      return self == .playing
        ? playerNode.lastRenderTime.flatMap { playerNode.playerTime(forNodeTime: $0).map { max($0.sampleTime, 0) }} ?? 0
        : player.position
    }

    func attach(_ player: AudioEngine.Player) -> Self {
      guard let playerNode = player.playerNode else { return .stopped }

      switch self {
      case .stopped:
        let position = player.position
        let length = player.length
        guard position < length else { return .stopped }
        let frameCount = AVAudioFrameCount(length - position)
        player.schedule(playerNode, at: position, frameCount: frameCount)
        playerNode.prepare(withFrameCount: frameCount)
        return .paused
      case .playing, .paused:
        return self
      }
    }

    func play(_ player: AudioEngine.Player) -> Self {
      guard let playerNode = player.playerNode else { return .stopped }

      switch self {

      case .playing:
        return self

      case .paused:
        guard player.willStart?() ?? false else { return self }
        playerNode.play()
        return .playing

      case .stopped:
        guard player.willStart?() ?? false else { return self }
        var position = player.position
        if position >= player.length {
          DispatchQueue.main.async { player.position = 0 }
          position = 0
        }

        player.schedule(playerNode, at: position)
        playerNode.play()
        return .playing
      }
    }

    func pause(_ player: AudioEngine.Player) -> Self {
      guard let playerNode = player.playerNode else { return .stopped }

      switch self {
      case .playing:
        playerNode.pause()
        return .paused
      case .paused, .stopped:
        return self
      }
    }

    func stop(_ player: AudioEngine.Player) -> Self {
      guard let playerNode = player.playerNode else { return .stopped }

      switch self {
      case .playing, .paused:
        DispatchQueue.main.async { player.position = 0 }
        playerNode.stop()
        return .stopped
      case .stopped: return self
      }
    }

    func seek(_ player: AudioEngine.Player, by time: TimeInterval) -> Self {
      seek(player, from: getPosition(player), by: time)
    }

    func seek(_ player: AudioEngine.Player, to time: TimeInterval) -> Self {
      seek(player, from: 0, by: time)
    }

    func seek(
      _ player: AudioEngine.Player,
      from position: AVAudioFramePosition,
      by time: TimeInterval
    ) -> Self {
      seek(player, to: position + AVAudioFramePosition(time * player.sampleRate))
    }

    func seek(_ player: AudioEngine.Player, to position: AVAudioFramePosition) -> Self {
      guard let playerNode = player.playerNode else { return .stopped }

      let seekPosition = min(max(position, 0), player.length)
      DispatchQueue.main.async { player.position = seekPosition }

      playerNode.stop()
      guard seekPosition < player.length else { return .stopped }

      switch self {

      case .playing:
        player.schedule(playerNode, at: seekPosition)
        playerNode.play()
        return self

      case .paused:
        player.schedule(playerNode, at: seekPosition)
        return self

      case .stopped:
        return self
      }
    }

    func playbackFinished(_ player: AudioEngine.Player, segment: Int) -> Self {
      guard player.segment == segment else { return self }
      guard let playerNode = player.playerNode else { return .stopped }
      playerNode.stop()

      switch self {
      case .playing:
        guard player.loop else {
          DispatchQueue.main.async { player.position = player.length }
          return .stopped
        }

        DispatchQueue.main.async { player.position = 0 }
        player.schedule(playerNode, at: 0)
        playerNode.play()
        return self

      case .paused:
        DispatchQueue.main.async { player.position = player.length }
        return .stopped

      case .stopped:
        return self
      }
    }
  }
}
