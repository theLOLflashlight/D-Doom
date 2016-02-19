//
//  Projectile.swift
//  D&Doom
//
//  Created by Jacob Lim on 2016-02-18.
//  Copyright © 2016 Andrew Meckling. All rights reserved.
//

import Foundation
import UIKit
import GLKit
import OpenGLES

class Projectile {
    let _origin = GLKVector3Make(0, 0, 0);
    var _velocity : GLKVector3, _position : GLKVector3, _acceleration = GLKVector3Make(0, 0, 0); // in number of seconds
    init(x:Int, y:Int, z:Int, speed:Float, model:GLKMatrix4, projection:GLKMatrix4, viewport:UnsafeMutablePointer<Int32>) {
        //var success : UnsafeMutablePointer<Bool> -> GLKVector3;
        //var success = nil;
        //z would be the far FOV
        let lineVectorDest = GLKMathUnproject(GLKVector3Make(Float(x), Float(y), Float(z)), model, projection, viewport, nil);
        let lineVectorOrigin = GLKMathUnproject(_origin, model, projection, viewport, nil);
        let lineVector = GLKVector3Subtract(lineVectorDest, lineVectorOrigin);
        _position = _origin;
        _velocity = GLKVector3MultiplyScalar(GLKVector3Normalize(lineVector), speed);
    }
    
    //Update projectile position and velocity. Check collisions.
    func update() {
        //Get amount per frame, rather than per second
        let accel_f = GLKVector3DivideScalar(_acceleration, 60);
        _velocity = GLKVector3Add(_velocity, accel_f);
        let velocity_f = GLKVector3DivideScalar(_velocity, 60);
        _position = GLKVector3Add(_position, velocity_f);
        
        checkCollision();
    }
    func checkCollision() {
        
    }
}