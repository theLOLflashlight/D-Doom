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

class Projectile : Actor {
    //var _projectileVar = GLKVector3Make(0, 0, 0);
    //var _vecDest : GLKVector3;
    //var _vecOrigin : GLKVector3;
    
    //x and y are mouse screen coordinates, and z is the depth that this will have, for the current projection and modelview
    init(screenX:CGFloat, screenY:CGFloat, farplaneZ:Int, speed:Float, modelView:GLKMatrix4, projection:GLKMatrix4, viewport:UnsafeMutablePointer<Int32>) {
        let _vecDest = GLKMathUnproject(GLKVector3Make(Float(screenX), Float(screenY), Float(farplaneZ)), modelView, projection, viewport, nil);
        let _vecOrigin = GLKMathUnproject(Actor.ActorConstants._origin, modelView, projection, viewport, nil);
        super.init(position: ActorConstants._origin);
        
        let lineVectorWorld = GLKVector3Subtract(_vecDest, _vecOrigin);
        
        //var success : UnsafeMutablePointer<Bool> -> GLKVector3;
        //var success = nil;
        //z would be the far FOV
        //let lineVector = GLKVector3Subtract(_vecDest, _vecOrigin);
        //printVector(lineVectorDest);
        //printVector(lineVectorOrigin);
        //printVector(lineVector);
        _position = ActorConstants._origin;
        
        //Only normalize if it's not 0 - otherwise it would return nil (and it multiplying speed by 0 won't change the value anyway)
        if(GLKVector3Length(lineVectorWorld) != 0) {
            _velocity = GLKVector3MultiplyScalar(GLKVector3Normalize(lineVectorWorld), speed);
        }
        
        //printVector("lineVectorDest: ", vec: lineVectorDest);
        //printVector("lineVectorOrigin: ", vec: lineVectorOrigin);
        //printVector("Velocity: ", vec: _velocity);
    }
    
    //For debug purposes.
    func printVector(label : String, vec : GLKVector3) {
        print("\(label): (\(vec.x), \(vec.y), \(vec.z))");
    }
    func printVector(vec : GLKVector3) {
        print("(\(vec.x), \(vec.y), \(vec.z))");
    }
    
    //Update projectile position and velocity. Check collisions.
    override func update() {
        //Get amount per frame, rather than per second
        let accel_f = GLKVector3DivideScalar(_acceleration, 60);
        _velocity = GLKVector3Add(_velocity, accel_f);
        //print("\(_velocity.x), \(_velocity.y), \(_velocity.z)");
        let velocity_f = GLKVector3DivideScalar(_velocity, 60);
        //print("\(velocity_f.x), \(velocity_f.y), \(velocity_f.z)");
        //print("\(_position.x), \(_position.y), \(_position.z)");
        _position = GLKVector3Add(_position, velocity_f);
        //print("\(_position.x), \(_position.y), \(_position.z)");
        
        checkCollision();
        printVector("Position: ", vec: _position);
    }
    func checkCollision() {
        
    }
}