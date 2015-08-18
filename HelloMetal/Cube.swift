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
    init(device: MTLDevice, commandQ: MTLCommandQueue) {
        // front
        let A = Vertex(x: -1.0, y:  1.0, z:  1.0, r: 1.0, g: 0.0, b: 0.0, a: 1.0, s: 0.25, t: 0.25)
        let B = Vertex(x: -1.0, y: -1.0, z:  1.0, r: 0.0, g: 1.0, b: 0.0, a: 1.0, s: 0.25, t: 0.50)
        let C = Vertex(x:  1.0, y: -1.0, z:  1.0, r: 0.0, g: 0.0, b: 1.0, a: 1.0, s: 0.50, t: 0.50)
        let D = Vertex(x:  1.0, y:  1.0, z:  1.0, r: 0.1, g: 0.6, b: 0.4, a: 1.0, s: 0.50, t: 0.25)
        
        // left
        let E = Vertex(x: -1.0, y:  1.0, z: -1.0, r: 1.0, g: 0.0, b: 0.0, a: 1.0, s: 0.00, t: 0.25)
        let F = Vertex(x: -1.0, y: -1.0, z: -1.0, r: 0.0, g: 1.0, b: 0.0, a: 1.0, s: 0.00, t: 0.50)
        let G = Vertex(x: -1.0, y: -1.0, z:  1.0, r: 0.0, g: 0.0, b: 1.0, a: 1.0, s: 0.25, t: 0.50)
        let H = Vertex(x: -1.0, y:  1.0, z:  1.0, r: 0.1, g: 0.6, b: 0.4, a: 1.0, s: 0.25, t: 0.25)
        
        // right
        let I = Vertex(x:  1.0, y:  1.0, z:  1.0, r: 1.0, g: 0.0, b: 0.0, a: 1.0, s: 0.50, t: 0.25)
        let J = Vertex(x:  1.0, y: -1.0, z:  1.0, r: 0.0, g: 1.0, b: 0.0, a: 1.0, s: 0.50, t: 0.50)
        let K = Vertex(x:  1.0, y: -1.0, z: -1.0, r: 0.0, g: 0.0, b: 1.0, a: 1.0, s: 0.75, t: 0.50)
        let L = Vertex(x:  1.0, y:  1.0, z: -1.0, r: 0.1, g: 0.6, b: 0.4, a: 1.0, s: 0.75, t: 0.25)
        
        // top
        let M = Vertex(x: -1.0, y:  1.0, z: -1.0, r: 1.0, g: 0.0, b: 0.0, a: 1.0, s: 0.25, t: 0.00)
        let N = Vertex(x: -1.0, y:  1.0, z:  1.0, r: 0.0, g: 1.0, b: 0.0, a: 1.0, s: 0.25, t: 0.25)
        let O = Vertex(x:  1.0, y:  1.0, z:  1.0, r: 0.0, g: 0.0, b: 1.0, a: 1.0, s: 0.50, t: 0.25)
        let P = Vertex(x:  1.0, y:  1.0, z: -1.0, r: 0.1, g: 0.6, b: 0.4, a: 1.0, s: 0.50, t: 0.00)
        
        // bottom
        let Q = Vertex(x: -1.0, y: -1.0, z:  1.0, r: 1.0, g: 0.0, b: 0.0, a: 1.0, s: 0.25, t: 0.50)
        let R = Vertex(x: -1.0, y: -1.0, z: -1.0, r: 0.0, g: 1.0, b: 0.0, a: 1.0, s: 0.25, t: 0.75)
        let S = Vertex(x:  1.0, y: -1.0, z: -1.0, r: 0.0, g: 0.0, b: 1.0, a: 1.0, s: 0.50, t: 0.75)
        let T = Vertex(x:  1.0, y: -1.0, z:  1.0, r: 0.1, g: 0.6, b: 0.4, a: 1.0, s: 0.50, t: 0.50)
        
        // back
        let U = Vertex(x:  1.0, y:  1.0, z: -1.0, r: 1.0, g: 0.0, b: 0.0, a: 1.0, s: 0.75, t: 0.25)
        let V = Vertex(x:  1.0, y: -1.0, z: -1.0, r: 0.0, g: 1.0, b: 0.0, a: 1.0, s: 0.75, t: 0.50)
        let W = Vertex(x: -1.0, y: -1.0, z: -1.0, r: 0.0, g: 0.0, b: 1.0, a: 1.0, s: 1.00, t: 0.50)
        let X = Vertex(x: -1.0, y:  1.0, z: -1.0, r: 0.1, g: 0.6, b: 0.4, a: 1.0, s: 1.00, t: 0.25)
        
        var verticesArray:Array<Vertex> = [
        A,B,C   ,A,C,D,     // front
        E,F,G   ,E,G,H,     // left
        I,J,K   ,I,K,L,     // right
        M,N,O   ,M,O,P,     // top
        Q,R,S   ,Q,S,T,     // bottom
        U,V,W   ,U,W,X      // back
        ]
        
        var texture = MetalTexture(resourceName: "cube", ext: "png", mipmaped: true)
        texture.loadTexture(device: device, commandQ: commandQ, flip: true)
        
        super.init(name: "Cube", vertices: verticesArray, device: device, texture: texture.texture)
    }
    
    override func updateWithDelta(delta: CFTimeInterval) {
        super.updateWithDelta(delta)
        
        //var secondsPerMove: Float = 6.0
        //rotationY = sinf(Float(time) * 2.0 * Float(M_PI) / secondsPerMove)
        //rotationY = sinf(Float(time) * 2.0 * Float(M_PI) / secondsPerMove)
    }
}
