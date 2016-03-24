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
    var damage = 20; //to be set manually
    
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
        var collided = false;
        
        var other : Actor;
        //Or, just can do the very efficient and simple bounding spheres collision.
        //Not sure how to handle model data for other forms of collision at the moment.
        for var ActorList in GameViewController.ActorLists { //if var not specified, "let" is default
            for (var i=0; i<ActorList.count; i++) {
                let actor = ActorList[i]; //force downcast/unwrap with "as!"
                if(GLKVector3Length(GLKVector3Subtract(_position, actor._position)) <= Float(actor._radius + _radius)) {
                    collided = true;
                    other = actor;
                    //handle collision code here, in order to preserve the index of (and thus ability to remove) ActorList elements
                    
                    //destroy enemy, damage player, depending on what kind of projectile it is. Could use homeInOnPlayer if and only if the projectiles are enemy projectiles targeting the player, perhaps. Given that:
                    if(homeInOnPlayer) {
                        //damage player
                        GameViewController.mHealth -= damage;
                    }
                    else {
                        //Checking enemy - kill enemy if it's one
                        //Could make it damage the enemy instead
                        if let enemy = ActorList[i] as? Enemy {
                            enemy._health -= damage;

                            if(enemy._health <= 0) {
                                //Remove enemy as the kill process.
                                ActorList.removeAtIndex(i);
                            }
                        }
                    }
                    break;
                }
            }
        }
    }
    
    //Credit goes to http://stackoverflow.com/questions/15247347/collision-detection-between-a-boundingbox-and-a-sphere-in-libgdx
    //Sphere and bounding box (AABB?) collision
    /*
    public static boolean sphereBBCollides(BoxmVars : modelVars) {
        float dmin = 0;
    
        Vector3 center = sphere.center;
        Vector3 bmin = boundingBox.getMin();
        Vector3 bmax = boundingBox.getMax();
    
        if (center.x < bmin.x) {
            dmin += Math.pow(center.x - bmin.x, 2);
        } else if (center.x > bmax.x) {
            dmin += Math.pow(center.x - bmax.x, 2);
        }
    
        if (center.y < bmin.y) {
            dmin += Math.pow(center.y - bmin.y, 2);
        } else if (center.y > bmax.y) {
            dmin += Math.pow(center.y - bmax.y, 2);
        }
    
        if (center.z < bmin.z) {
            dmin += Math.pow(center.z - bmin.z, 2);
        } else if (center.z > bmax.z) {
            dmin += Math.pow(center.z - bmax.z, 2);
        }
    
        return dmin <= Math.pow(sphere.radius, 2);
    }*/
    
    //Home in on target
    func homingOn(target:GLKVector3) {
        var vecDir = GLKVector3Subtract(target, self._position);
        vecDir = GLKVector3Normalize(vecDir); //unit vector used to get direction of vector
        var projVelocity = GLKVector3MultiplyScalar(vecDir, GLKVector3Length(_velocity))
        _velocity = projVelocity;
    }
}