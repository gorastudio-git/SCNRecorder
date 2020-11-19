//
//  ReadWriteLock.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 17.05.2020.
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

public final class ReadWriteLock {

  private var readWriteLock: pthread_rwlock_t

  public init() {
    readWriteLock = pthread_rwlock_t()
    pthread_rwlock_init(&readWriteLock, nil)
  }

  deinit { pthread_rwlock_destroy(&readWriteLock) }

  public func readLock() { pthread_rwlock_rdlock(&readWriteLock) }

  public func writeLock() { pthread_rwlock_wrlock(&readWriteLock) }

  public func unlock() { pthread_rwlock_unlock(&readWriteLock) }

  public func tryRead() -> Bool { pthread_rwlock_tryrdlock(&readWriteLock) == 0 }

  public func tryWrite() -> Bool { pthread_rwlock_trywrlock(&readWriteLock) == 0 }
}

public extension ReadWriteLock {

  @discardableResult
  func readLocked<Result>(_ action: () throws -> Result) rethrows -> Result {
    readLock()
    defer { unlock() }
    return try action()
  }

  @discardableResult
  func writeLocked<Result>(_ action: () throws -> Result) rethrows -> Result {
    writeLock()
    defer { unlock() }
    return try action()
  }
}
