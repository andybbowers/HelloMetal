//
//  SceneViewController.swift
//  HelloMetal
//
//  Created by Andrew Bowers on 8/18/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import UIKit

class SceneViewController : MetalViewController, MetalViewControllerDelegate {
    
    var worldModelMatrix: Matrix4!
    var objectToDraw: Cube!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        worldModelMatrix = Matrix4()
        
        worldModelMatrix.translate(0.0, y: 0.0, z: -4)
        worldModelMatrix.rotateAroundX(Matrix4.degreesToRad(25), y: 0.0, z: 0.0)
        
        objectToDraw = Cube(device: device)
        self.metalViewControllerDelegate = self
        
    }
    
    //MARK: - MetalViewControllerDelegate
    
    func renderObjects(drawable: CAMetalDrawable) {
        objectToDraw.render(commandQueue, pipelineState: pipelineState, drawable: drawable, parentModelViewMatrix: worldModelMatrix, projectionMatrix: projectionMatrix, clearColor: nil)
    }
    
    func updateLogic(timeSinceLastUpdate: CFTimeInterval) {
        objectToDraw.updateWithDelta(timeSinceLastUpdate)
    }
}
