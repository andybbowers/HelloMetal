//
//  BufferProvider.swift
//  HelloMetal
//
//  Created by Andrew Bowers on 8/18/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

/*

BufferProvider will be responsible for creating a pool of buffers, and it'll have a method to get the next available reusable buffer.

*/

import Metal

class BufferProvider: NSObject {
    
    // an Int that will store the number of buffers stored by BufferProvider
    let inflightBuffersCount: Int
    
    // an array that will store the buffers themselves
    private var uniformsBuffers: [MTLBuffer]
    // the index of the next available buffer
    private var availableBufferIndex: Int = 0
    
    init(device:MTLDevice, inflightBuffersCount: Int, sizeOfUniformsBufffer: Int) {
        
        self.inflightBuffersCount = inflightBuffersCount
        uniformsBuffers = [MTLBuffer]()
        
        for i in 0...inflightBuffersCount-1 {
            var uniformsBuffer = device.newBufferWithLength(sizeOfUniformsBufffer, options: nil)
            uniformsBuffers.append(uniformsBuffer)
        }
    }
    
    // method to fetch the next available buffer and copy some data into it
    func nextUniformsBuffer(projectionMatrix: Matrix4, modelViewMatrix: Matrix4) -> MTLBuffer {
        
        // Fetch MTLBuffer from uniformsBuffers array at availableBufferIndex index
        var buffer = uniformsBuffers[availableBufferIndex]
        // get void * pointer from MTLBuffer
        var bufferPointer = buffer.contents()
        
        // copy the passed-in matrices data into the buffer using memcpy
        memcpy(bufferPointer, modelViewMatrix.raw(), sizeof(Float) * Matrix4.numberOfElements())
        memcpy(bufferPointer + sizeof(Float) * Matrix4.numberOfElements(), projectionMatrix.raw(), sizeof(Float) * Matrix4.numberOfElements())
        
        // increment and reset (if at end) availableBufferIndex
        availableBufferIndex++
        if availableBufferIndex == inflightBuffersCount {
            availableBufferIndex = 0
        }
        
        return buffer
    }
}


