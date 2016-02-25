//
//  Actor.swift
//  D&Doom
//
//  Created by Jacob Lim on 2016-02-20.
//  Copyright © 2016 Andrew Meckling. All rights reserved.
//

import Foundation
import UIKit
import GLKit
import OpenGLES

class Actor {
    
    //Following idiom as stated from http://stackoverflow.com/questions/25918628/how-to-define-static-constant-in-a-class-in-swift
    struct ActorConstants {
        static let _origin = GLKVector3Make(0, 0, 0);        
    }
    
    var _position = GLKVector3Make(0, 0, 0);
    var _velocity = GLKVector3Make(0, 0, 0);
    var _acceleration = GLKVector3Make(0, 0, 0); // in number of seconds
    
    init(position: GLKVector3) {
        _position = position;
    }
    
    func update() {
        
    }
}