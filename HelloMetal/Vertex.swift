//
//  Vertex.swift
//  HelloMetal
//
//  Created by Andrew Bowers on 8/17/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

/*

This is a structure that will store the position and color of each vertetx.  

floatBuffer() is a method that returns the vertex data as an array of floats in strict order

*/

struct Vertex {
    
    var x, y, z: Float      // position data
    var r, g, b, a: Float   // color data
    var s, t: Float         // texture coordinates
    
    func floatBuffer() -> [Float] {
        return [x, y, z, r, g, b, a, s, t]
    }
    
};


