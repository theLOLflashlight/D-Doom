//
//  Enemy.swift
//  D&Doom
//
//  Created by Jacob Lim on 2016-03-22.
//  Copyright © 2016 Andrew Meckling. All rights reserved.
//

import Foundation
import UIKit
import GLKit
import OpenGLES

class Enemy : Actor {
    //AI: Shoot every 3 seconds.
    var _currTimeBeforeShot = ActorConstants._timeBeforeShot;
    var _shotVelocity = 10; //In world coordinates per second
    var _health = 50;
    
    init(health: Int) {
        super.init(position: ActorConstants._origin);
        _health = health;
        //timer ticks once every FPS frames (curr. 60 as of this writing)
        //_timer = NSTimer.scheduledTimerWithTimeInterval(1.0/Double(ActorConstants.FPS), target: self, selector: "update", userInfo: nil, repeats: true);
        //Don't need timer; will just use update()
    }
    
    override func update() {
        //Shoot every _timeBeforeShot seconds.
        if(_currTimeBeforeShot <= 0) {
            //shoot projectile towards player, will need to home in as well
            var vecDir = GLKVector3Subtract(GameViewController.position, self._position);
            vecDir = GLKVector3Normalize(vecDir); //unit vector used to get direction of vector
            let projVelocity = GLKVector3MultiplyScalar(vecDir, 10)

            var mVar = modelVars();
            let projectile = Projectile(position: _position, velocity: projVelocity, mVars:mVar); //constantly updating direction
            //pass modelVars into it
            
            if ((GameViewController.ActorLists[0] as? [Projectile]) != nil) { //creates a copy of the array, due to swift - http://stackoverflow.com/questions/27812433/swift-how-do-i-make-a-exact-duplicate-copy-of-an-array
                //GameViewController.ActorLists[0].removeAll();
                GameViewController.ActorLists[0].append(projectile); //adds to its own constructor
            
            }
            //let _vecOrigin = GLKMathUnproject(Actor.ActorConstants._origin, modelView, projection, viewport, nil);
            
            _currTimeBeforeShot = ActorConstants._timeBeforeShot;
        }
        _currTimeBeforeShot--;
    }
}