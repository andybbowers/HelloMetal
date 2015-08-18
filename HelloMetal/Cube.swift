//
//  Cube.swift
//  HelloMetal
//
//  Created by Andrew Bowers on 8/17/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import UIKit
import Metal

class Cube: Node {
    init(device: MTLDevice) {
        let A = Vertex(x: -1.0, y:  1.0, z:  1.0, r: 1.0, g: 0.0, b: 0.0, a: 1.0)
        let B = Vertex(x: -1.0, y: -1.0, z:  1.0, r: 0.0, g: 1.0, b: 0.0, a: 1.0)
        let C = Vertex(x:  1.0, y: -1.0, z:  1.0, r: 0.0, g: 0.0, b: 1.0, a: 1.0)
        let D = Vertex(x:  1.0, y:  1.0, z:  1.0, r: 0.1, g: 0.6, b: 0.4, a: 1.0)
        
        let Q = Vertex(x: -1.0, y:  1.0, z: -1.0, r: 1.0, g: 0.0, b: 0.0, a: 1.0)
        let R = Vertex(x:  1.0, y:  1.0, z: -1.0, r: 0.0, g: 1.0, b: 0.0, a: 1.0)
        let S = Vertex(x: -1.0, y: -1.0, z: -1.0, r: 0.0, g: 0.0, b: 1.0, a: 1.0)
        let T = Vertex(x:  1.0, y: -1.0, z: -1.0, r: 0.1, g: 0.6, b: 0.4, a: 1.0)
        
        var verticesArray:Array<Vertex> = [
        A,B,C   ,A,C,D,     // front
        R,T,S   ,Q,R,S,     // back
            
        Q,S,B   ,Q,B,A,     // left
        D,C,T   ,D,T,R,     // right
            
        Q,A,D   ,Q,D,R,     // top
        B,S,T   ,B,T,C      // bottom
        ]
        
        super.init(name: "Cube", vertices: verticesArray, device: device)
    }
    
    override func updateWithDelta(delta: CFTimeInterval) {
        super.updateWithDelta(delta)
        
        var secondsPerMove: Float = 6.0
        rotationY = sinf(Float(time) * 2.0 * Float(M_PI) / secondsPerMove)
        rotationY = sinf(Float(time) * 2.0 * Float(M_PI) / secondsPerMove)
    }
}
