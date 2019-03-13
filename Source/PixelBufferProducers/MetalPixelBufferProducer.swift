//
//  MetalPixelBufferProducer.swift
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
import AVFoundation

#if !targetEnvironment(simulator)

extension MetalPixelBufferProducer {
    
    enum Error: Swift.Error {
        
        case lastDrawable
        
        case framebufferOnly
    }
}

final class MetalPixelBufferProducer: PixelBufferProducer {
    
    static let colorSpaces: [MTLPixelFormat: () -> CGColorSpace?] = [
        .bgra8Unorm_srgb: { CGColorSpace(name: CGColorSpace.sRGB) },
        .bgr10_xr_srgb: { CGColorSpace(name: CGColorSpace.extendedLinearSRGB) }
    ]
    
    static let pixelFormats: [MTLPixelFormat: OSType] = [
        .bgra8Unorm_srgb: kCVPixelFormatType_32BGRA,
        .bgr10_xr_srgb: kCVPixelFormatType_30RGBLEPackedWideGamut
    ]
    
    static let defaultICCData: [MTLPixelFormat: () -> Data?] = [
        .bgra8Unorm_srgb: { ICCData.sRGB.data },
        .bgr10_xr_srgb: { ICCData.extendedLinearSRGB.data }
    ]
    
    static func getPixelFormat(for metalPixelFormat: MTLPixelFormat) -> OSType {
        return pixelFormats[metalPixelFormat] ?? kCVPixelFormatType_32BGRA
    }
    
    static func getColorSpace(for metalPixelFormat: MTLPixelFormat) -> CGColorSpace {
        return colorSpaces[metalPixelFormat]?() ??
               CGColorSpace(name: CGColorSpace.sRGB) ??
               CGColorSpaceCreateDeviceRGB()
    }
    
    static func getICCData(for metalPixelFormat: MTLPixelFormat) -> CFData? {
        return getColorSpace(for: metalPixelFormat).copyICCData() ??
               defaultICCData[metalPixelFormat]?().map({ $0 as CFData })
    }
    
    lazy var recommendedVideoSettings: [String : Any] = {
        return [
            AVVideoWidthKey: metalLayer.drawableSize.width,
            AVVideoHeightKey: metalLayer.drawableSize.height,
            AVVideoCodecKey: AVVideoCodecType.h264
        ]
    }()
    
    lazy var recommendedPixelBufferAttributes: [String : Any] = {
        let pixelFormat = metalLayer.pixelFormat

        var attributes: [String : Any] = [
            kCVPixelBufferWidthKey as String: metalLayer.drawableSize.width,
            kCVPixelBufferHeightKey as String: metalLayer.drawableSize.height,
            kCVPixelBufferPixelFormatTypeKey as String: MetalPixelBufferProducer.getPixelFormat(for: pixelFormat),
            kCVPixelBufferIOSurfacePropertiesKey as String : [:]
        ]
        
        if let iccData = MetalPixelBufferProducer.getICCData(for: pixelFormat) {
            attributes[kCVBufferPropagatedAttachmentsKey as String] = [
                kCVImageBufferICCProfileKey: MetalPixelBufferProducer.getICCData(for: pixelFormat)
            ]
        }
        
        return attributes
    }()
    
    var emptyBufferSize: Int = 0
    
    var emptyBuffer: UnsafeMutableRawPointer?
    
    let metalLayer: CAMetalRecorderLayer
    
    lazy var context: CIContext = {
        return CIContext(mtlDevice: metalLayer.device!)
    }()
    
    init(metalLayer: CAMetalRecorderLayer) {
        self.metalLayer = metalLayer
    }
    
    deinit {
        emptyBuffer.map({ free($0) })
    }
    
    func startWriting() {
        DispatchQueue.main.sync {
            metalLayer.startRecording()
        }
    }
    
    func writeIn(pixelBuffer: inout CVPixelBuffer) throws {
        
        guard let lastDrawable = metalLayer.lastDrawable else {
            throw Error.lastDrawable
        }
        
        let texture = lastDrawable.texture
        guard !texture.isFramebufferOnly else {
            throw Error.framebufferOnly
        }
        
        var errorCode = CVPixelBufferLockBaseAddress(pixelBuffer, [])
        guard errorCode == kCVReturnSuccess else {
            throw PixelBufferProducer.Error.lockBaseAddress(errorCode: errorCode)
        }
        
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            throw PixelBufferProducer.Error.getBaseAddress
        }
        
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        texture.getBytes(baseAddress,
                         bytesPerRow: bytesPerRow,
                         from: MTLRegionMake2D(0,
                                               0,
                                               CVPixelBufferGetWidth(pixelBuffer),
                                               height),
                         mipmapLevel: 0)
        
        guard !isEmpty(baseAddress, size: bytesPerRow * height) else {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
            throw PixelBufferProducer.Error.empty
        }
        
        errorCode = CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
        guard errorCode == kCVReturnSuccess else {
            throw PixelBufferProducer.Error.unlockBaseAddress(errorCode: errorCode)
        }
    }
    
    func stopWriting() {
        DispatchQueue.main.sync {
            metalLayer.stopRecording()
        }
    }
    
    func isEmpty(_ buffer: UnsafeMutableRawPointer, size: Int) -> Bool {
        if emptyBufferSize != size || emptyBuffer == nil {
            emptyBufferSize = size
            emptyBuffer.map({ free($0) })
            emptyBuffer = calloc(size, 1)
        }
        
        guard let emptyBuffer = emptyBuffer else {
            return false
        }
        
        return memcmp(buffer, emptyBuffer, size) == 0
    }
}

#endif
