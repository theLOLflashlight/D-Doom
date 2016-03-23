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
    
    var homeInOnPlayer = false;
    
    //x and y are mouse screen coordinates, and z is the depth that this will have, for the current projection and modelview
    init() {
        super.init(position: ActorConstants._origin);
    }
    init(screenX:CGFloat, screenY:CGFloat, farplaneZ:Int, speed:Float, modelView:GLKMatrix4, projection:GLKMatrix4, viewport:UnsafeMutablePointer<Int32>, mVars:modelVars) {
        let _vecDest = GLKMathUnproject(GLKVector3Make(Float(screenX), Float(screenY), Float(farplaneZ)), modelView, projection, viewport, nil);
        let _vecOrigin = GLKMathUnproject(Actor.ActorConstants._origin, modelView, projection, viewport, nil);
        super.init(position: ActorConstants._origin);
        
        let lineVectorWorld = GLKVector3Subtract(_vecDest, _vecOrigin);
        //var success : UnsafeMutablePointer<Bool> -> GLKVector3;
        //var success = nil;
        //z would be the far FOV
        _position = ActorConstants._origin;
        
        //Only normalize if it's not 0 - otherwise it would return nil (and it multiplying speed by 0 won't change the value anyway)
        print("args: (\(screenX), \(screenY), \(farplaneZ))");
        printVector("vecDest: ", vec: lineVectorWorld);
        printVector("lineVectorWorld: ", vec: lineVectorWorld);
        if(GLKVector3Length(lineVectorWorld) != 0) {
            _velocity = GLKVector3MultiplyScalar(GLKVector3Normalize(lineVectorWorld), speed);
        }
        printVector("velocity: ", vec: _velocity);
    }
    init(position:GLKVector3, velocity:GLKVector3, mVars:modelVars) {
        super.init(position: ActorConstants._origin);
        _velocity = velocity;
        _modelVars = mVars;
    }
    
    func setModel(mVars:modelVars) {
        //copy the struct
        _modelVars = mVars;
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
        let velocity_f = GLKVector3DivideScalar(_velocity, 60);        _position = GLKVector3Add(_position, velocity_f);
        //print("\(_position.x), \(_position.y), \(_position.z)");
        
        if(homeInOnPlayer) {
            homingOn(GameViewController.position);
        }
        
        checkCollision();
        //printVector("Position: ", vec: _position);
    }
    func checkCollision() {
        //check z coordinate matching any other enemies
        //then do a 2D collision detection ...
        //though that may involve using a buffer ...
    }
    
    //Home in on target
    func homingOn(target:GLKVector3) {
        var vecDir = GLKVector3Subtract(target, self._position);
        vecDir = GLKVector3Normalize(vecDir); //unit vector used to get direction of vector
        var projVelocity = GLKVector3MultiplyScalar(vecDir, GLKVector3Length(_velocity))
        _velocity = projVelocity;
    }
}