//
//  Node.swift
//  HelloMetal
//
//  Created by Andrew Bowers on 8/17/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import Foundation
import Metal
import QuartzCore

class Node {
    
    let name: String
    let vertexCount: Int
    var vertexBuffer: MTLBuffer
    
    var bufferProvider: BufferProvider
    
    //var uniformBuffer: MTLBuffer?
    var device : MTLDevice
    
    var positionX:Float = 0.0
    var positionY:Float = 0.0
    var positionZ:Float = 0.0
    
    var rotationX:Float = 0.0
    var rotationY:Float = 0.0
    var rotationZ:Float = 0.0
    
    var scale:Float = 1.0
    
    var time:CFTimeInterval = 0.0
    
    var texture: MTLTexture
    lazy var samplerState: MTLSamplerState? = Node.defaultSampler(self.device)
    
    init(name: String, vertices: Array<Vertex>, device: MTLDevice, texture: MTLTexture) {
        
        // Since Node is an object to draw, you need to provide it with the vertices it contains, a name for convenience, and a device to create buffers and render later on.
        
        // Go through each vertex and form a single buffer with floats
        var vertexData = Array<Float>()
        for vertex in vertices {
            vertexData += vertex.floatBuffer()
        }
        
        // ask the device to create a vertex buffer with the float buffer above
        let dataSize = vertexData.count * sizeofValue(vertexData[0])
        vertexBuffer = device.newBufferWithBytes(vertexData, length: dataSize, options: nil)
        
        // set instance variables
        self.name = name
        self.device = device
        vertexCount = vertices.count
        self.texture = texture
        
        self.bufferProvider = BufferProvider(device: device, inflightBuffersCount: 3, sizeOfUniformsBufffer: sizeof(Float) * Matrix4.numberOfElements() * 2)
    }
    
    func render(commandQueue: MTLCommandQueue, pipelineState: MTLRenderPipelineState, drawable: CAMetalDrawable, parentModelViewMatrix: Matrix4, projectionMatrix: Matrix4, clearColor: MTLClearColor?) {
        
        // this will make the CPU wait in case the semaphore has no free resources
        dispatch_semaphore_wait(bufferProvider.availableBuffersSemaphore, DISPATCH_TIME_FOREVER)
        
        // a renderPassDescriptor configures what texture is being rendered to, what the clear color is, and a bit of other configuration
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .Clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        renderPassDescriptor.colorAttachments[0].storeAction = .Store
        
        // create a command buffer.  Think of a command buffer as the list of render commands that you wish to execute for this frame
        let commandBuffer = commandQueue.commandBuffer()
        // this makes it so that when the GPU finishes rendering, it executes a completion handle to signal the semaphore (and bumps its count back up again)
        commandBuffer.addCompletedHandler { (commandBuffer) -> Void in
            var temp = dispatch_semaphore_signal(self.bufferProvider.availableBuffersSemaphore)
        }
        
        // a command buffer contains one or more render commands.  to create a render command, you use a helper object called a render command encoder
        let renderEncoderOpt = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
        if let renderEncoder = renderEncoderOpt {
            //for now cull mode is used instead of depth buffer
            renderEncoder.setCullMode(MTLCullMode.Front)
            renderEncoder.setRenderPipelineState(pipelineState)
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
            
            // this passes the texture and sample to the shaders
            renderEncoder.setFragmentTexture(texture, atIndex: 0)
            if let samplerState = samplerState {
                renderEncoder.setFragmentSamplerState(samplerState, atIndex: 0)
            }
            
            // converts the current convenience properties (position, rotation, scale) into a model matrix
            var nodeModelMatrix = self.modelMatrix()
            nodeModelMatrix.multiplyLeft(parentModelViewMatrix)
           
            // ask the BufferProvider for the next available buffer
            let uniformBuffer = bufferProvider.nextUniformsBuffer(projectionMatrix, modelViewMatrix: nodeModelMatrix)
            
            // pass uniformBuffer (with copied data) to the vertex shader
            renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, atIndex: 1)
            
            renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: vertexCount/3)
            renderEncoder.endEncoding()
        }
        
        commandBuffer.presentDrawable(drawable)
        commandBuffer.commit()
    }
    
    func modelMatrix() -> Matrix4 {
        var matrix = Matrix4()
        matrix.translate(positionX, y: positionY, z: positionZ)
        matrix.rotateAroundX(rotationX, y: rotationY, z: rotationZ)
        matrix.scale(scale, y: scale, z: scale)
        return matrix
    }
    
    func updateWithDelta(delta: CFTimeInterval) {
        time += delta
    }
    
    // this method generates a simple texture sampler that basically just holds a bunch of flags.  Here you enable "nearest neighbor" filtering, which is the fastes method of filtering (opposed to "linear"), and "clamp tp edge" which instructs Metal how to deal with out of range values
    class func defaultSampler(device: MTLDevice) -> MTLSamplerState {
        var pSamplerDescriptor: MTLSamplerDescriptor? = MTLSamplerDescriptor()
        
        if let sampler = pSamplerDescriptor {
            sampler.minFilter                   = MTLSamplerMinMagFilter.Nearest
            sampler.magFilter                   = MTLSamplerMinMagFilter.Nearest
            sampler.mipFilter                   = MTLSamplerMipFilter.Nearest
            sampler.maxAnisotropy               = 1
            sampler.sAddressMode                = MTLSamplerAddressMode.ClampToEdge
            sampler.tAddressMode                = MTLSamplerAddressMode.ClampToEdge
            sampler.rAddressMode                = MTLSamplerAddressMode.ClampToEdge
            sampler.normalizedCoordinates       = true
            sampler.lodMinClamp                 = 0
            sampler.lodMaxClamp                 = FLT_MAX
        } else {
            println(">> ERROR: Failed creating a sampler descriptor!")
        }
        return device.newSamplerStateWithDescriptor(pSamplerDescriptor!)
    }
    
}
