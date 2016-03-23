//
//  ViewController.swift
//  D&Doom
//
//  Created by Andrew Meckling on 2016-03-10.
//  Copyright © 2016 Andrew Meckling. All rights reserved.
//

import Foundation
import UIKit
import GLKit
import OpenGLES

class MyViewController : UIViewController, GLKViewDelegate
{
    var mContext : EAGLContext?
    var mLevel : Level?
    var mBiasMatrix = GLKMatrix4()
    
    var mBufferId : GLuint?
    var mTexture : GLuint?
    var mBufferSize : CGSize?
    var mFov : GLfloat = 60

    required init?( coder aDecoder: NSCoder )
    {
        super.init( coder: aDecoder )
    }
    
    override func loadView()
    {
        let glkView = GLKView( frame: UIScreen.mainScreen().bounds )
        glkView.delegate = self
        self.view = glkView
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.mContext = EAGLContext( API: .OpenGLES2 )
        
        if self.mContext == nil
        {
            print("Failed to create ES context")
        }
        
        let view = self.view as! GLKView
        view.context = self.mContext!
        view.drawableDepthFormat = .Format24
        
        mFov = GLKMathDegreesToRadians( 65 )
        
        self.setupGL()
        mLevel = Level( name: "crate" )
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
        if self.isViewLoaded() && (self.view.window != nil)
        {
            self.view = nil
            
            self.tearDownGL()
            
            if EAGLContext.currentContext() === self.mContext
            {
                EAGLContext.setCurrentContext( nil )
            }
            self.mContext = nil
        }
    }
    
    override func viewDidAppear( animated: Bool )
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.oriMask = supportedInterfaceOrientations()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "rotated",
            name: UIDeviceOrientationDidChangeNotification,
            object: nil )
    }
    
    override func viewDidDisappear( animated: Bool )
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.oriMask = UIInterfaceOrientationMask.All
        
        NSNotificationCenter.defaultCenter().removeObserver( self )
    }

    
    // OpenGL
    
    func setupGL()
    {
        EAGLContext.setCurrentContext( self.mContext )
        
        glEnable( GLenum( GL_CULL_FACE ) )
        glEnable( GLenum( GL_DEPTH_TEST ) )
        glClearColor(0.1, 0.1, 0.1, 1.0);
        
        mBiasMatrix = GLKMatrix4Make(0.5, 0, 0, 0, 0, 0.5, 0, 0, 0, 0, 0.5, 0, 0.5, 0.5, 0.5, 1.0);
    }
    
    func tearDownGL()
    {
        if EAGLContext.currentContext() == mContext {
            EAGLContext.setCurrentContext( nil )
        }
        
        mContext = nil
    }

    func update()
    {
        
    }

    func glkView( view: GLKView, drawInRect rect: CGRect )
    {
        glClearColor( 0.65, 0.65, 0.65, 1.0 )
        
        glCullFace( GLenum( GL_BACK ) );
        
        // switch back to the main render buffer
        // this will also restore the viewport
        view.bindDrawable()
        glClear( GLbitfield( GL_COLOR_BUFFER_BIT ) | GLbitfield( GL_DEPTH_BUFFER_BIT ) )
        glEnable( GLenum( GL_DEPTH_TEST ) );
        
        // calculate a perspective matrix for the current view size
        let aspectRatio = rect.size.width / rect.size.height;
        let perspectiveMatrix = GLKMatrix4MakePerspective( mFov, Float( aspectRatio ), 1, 100 );
        
        mLevel?.render( perspectiveMatrix )
    }
}