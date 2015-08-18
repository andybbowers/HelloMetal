//
//  ViewController.swift
//  HelloMetal
//
//  Created by Main Account on 10/2/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import UIKit
import Metal
import QuartzCore

class ViewController: UIViewController {

    var device: MTLDevice! = nil
    var metalLayer: CAMetalLayer! = nil
    //var objectToDraw: Triangle!
    var objectToDraw: Cube!
    var pipelineState: MTLRenderPipelineState! = nil
    var commandQueue: MTLCommandQueue! = nil
    
    var projectionMatrix: Matrix4!
    
    var timer: CADisplayLink! = nil
    var lastFrameTimestamp: CFTimeInterval = 0.0
    
    
    
  
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        device = MTLCreateSystemDefaultDevice()
        
        projectionMatrix = Matrix4.makePerspectiveViewAngle(Matrix4.degreesToRad(85.0), aspectRatio: Float(self.view.bounds.size.width / self.view.bounds.size.height), nearZ: 0.01, farZ: 100.0)
        
        
        metalLayer = CAMetalLayer()          // 1
        metalLayer.device = device           // 2
        metalLayer.pixelFormat = .BGRA8Unorm // 3
        metalLayer.framebufferOnly = true    // 4
        metalLayer.frame = view.layer.frame  // 5
        view.layer.addSublayer(metalLayer)   // 6
        
        objectToDraw = Cube(device: device)
        
//        objectToDraw.positionX = 0.0
//        objectToDraw.positionY = 0.0
//        objectToDraw.positionZ = -2.0
//        objectToDraw.rotationZ = Matrix4.degreesToRad(45)
//        objectToDraw.scale = 0.5
        
        commandQueue = device.newCommandQueue()
        
        let defaultLibrary = device.newDefaultLibrary()
        let fragmentProgram = defaultLibrary!.newFunctionWithName("basic_fragment")
        let vertexProgram = defaultLibrary!.newFunctionWithName("basic_vertex")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
        
        var pipelineError : NSError?
        pipelineState = device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor, error: &pipelineError)
        if pipelineState == nil {
            println("Failed to create pipeline state, error \(pipelineError)")
        }
        
        timer = CADisplayLink(target: self, selector: Selector("newFrame:"))
        timer.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func render() {
        
        var worldModelMatrix = Matrix4()
        worldModelMatrix.translate(0.0, y: 0.0, z: -7.0)
        worldModelMatrix.rotateAroundX(Matrix4.degreesToRad(25), y: 0.0, z: 0.0)
        
        var drawable = metalLayer.nextDrawable()
        objectToDraw.render(commandQueue, pipelineState: pipelineState, drawable: drawable, parentModelViewMatrix: worldModelMatrix, projectionMatrix: projectionMatrix, clearColor: nil)
    
    }
    
    func newFrame(displayLink: CADisplayLink) {
        
        if lastFrameTimestamp == 0.0 {
            lastFrameTimestamp = displayLink.timestamp
        }
        
        var elapsed:CFTimeInterval = displayLink.timestamp - lastFrameTimestamp
        lastFrameTimestamp = displayLink.timestamp
        
        gameloop(timeSinceLastUpdate: elapsed)
    }
   
    func gameloop(#timeSinceLastUpdate: CFTimeInterval) {
        objectToDraw.updateWithDelta(timeSinceLastUpdate)
        autoreleasepool {
            self.render()
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}

