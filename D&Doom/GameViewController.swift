//
//  GameViewController.swift
//  D&Doom
//
//  Created by Andrew Meckling on 2016-02-10.
//  Copyright © 2016 Andrew Meckling. All rights reserved.
//

import UIKit
import GLKit
import OpenGLES

func BUFFER_OFFSET( i: Int ) -> UnsafePointer< Void >
{
    let p: UnsafePointer< Void > = nil
    return p.advancedBy( i )
}

let UNIFORM_MODELVIEWPROJECTION_MATRIX = 0
let UNIFORM_NORMAL_MATRIX = 1
var uniforms = [GLint]( count: 2, repeatedValue: 0 )


class GameViewController: GLKViewController
{
    @IBOutlet var mHud: UIView!
    
    @IBOutlet var mAmmoLabel: UILabel!
    
    @IBOutlet var mHealthLabel: UILabel!
    
    @IBOutlet var mWeaponLabel: UILabel!
    
    override func shouldAutorotate() -> Bool
    {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.Landscape
    }

    var program: GLuint = 0
    
    
    //Camera stuff
    var modelViewProjectionMatrix:GLKMatrix4 = GLKMatrix4Identity
    var normalMatrix: GLKMatrix3 = GLKMatrix3Identity
    var rotation: Float = 0.0
    
    var vertexArray: GLuint = 0
    var vertexBuffer: GLuint = 0
    
    var context: EAGLContext? = nil
    var effect: GLKBaseEffect? = nil
    
    deinit
    {
        self.tearDownGL()
        
        if EAGLContext.currentContext() === self.context
        {
            EAGLContext.setCurrentContext( nil )
        }
    }
    
    // Pre-coded actors
    var _PlayerShot = Actor(position: Actor.ActorConstants._origin);
    
    //For creating a projectile.
    //Tap input handling depends on variables set in update, so making this as a struct instead,
    //in which update will handle the projectile creation when toCreate is set to true
    //(where mouseX and mouseY are also set then)
    var toCreateProjectile = false;
    var mouseX : CGFloat = 0.0, mouseY : CGFloat = 0.0;
    
    var _currProjectile = Projectile(); //a null projectile
    
    // Hashtable storing all Lists of Actor types in the game, organized by type.
    var ActorLists : [Array<Actor>] = [];
    var ProjectileList : [Projectile] = [];
    
    //For swipe action.
    var _maxRadius : CGFloat = 0;
    //var _maxTranslationY : CGFloat = 0;
    var _prevTranslationX : CGFloat = 0; //for drawing lines
    var _prevTranslationY : CGFloat = 0;
    var _translationPoints : [CGPoint] = [];
    var _noSwipe = false;
    
    let screenSize : CGRect = UIScreen.mainScreen().bounds;
    var imageSize = CGSize(width: 200, height: 200); //arbitrary initialization
    var _imageView = UIImageView();
    
    //For drawing lines - from http://stackoverflow.com/questions/25229916/how-to-procedurally-draw-rectangle-lines-in-swift-using-cgcontext
    func drawCustomImage(size: CGSize) -> UIImage {
        // Setup our context
        let bounds = CGRect(origin: CGPoint.zero, size: size)
        let opaque = false
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let context = UIGraphicsGetCurrentContext()
        
        // Setup complete, do drawing here
        CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)
        CGContextSetLineWidth(context, 2.0)
        
        CGContextStrokeRect(context, bounds)
        
        CGContextBeginPath(context)
        if(!_noSwipe) {
        //draw each line, as evident from _translationPoints
            for(var i=1; i < _translationPoints.count; i++) {
                CGContextMoveToPoint(context, _translationPoints[i-1].x, _translationPoints[i-1].y);
                CGContextAddLineToPoint(context, _translationPoints[i].x, _translationPoints[i].y);
            }
        }
        //draw min to max - so, diagonally
//        CGContextMoveToPoint(context, CGRectGetMaxX(bounds), CGRectGetMinY(bounds))
//        CGContextAddLineToPoint(context, CGRectGetMinX(bounds), CGRectGetMaxY(bounds))
        CGContextStrokePath(context)
        
        // Drawing complete, retrieve the finished image and cleanup
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.context = EAGLContext( API: .OpenGLES2 )
        
        if self.context == nil
        {
            print("Failed to create ES context")
        }
        ActorLists = [ProjectileList]; //Can assign an array of a subclass to an array of its superclass, apparently
        
        let view = self.view as! GLKView
        view.context = self.context!
        view.drawableDepthFormat = .Format24
        
        mAmmoLabel.text = "107"
        mHealthLabel.text = "77%"
        
        mWeaponLabel.text = "N/A"
        
        //handle tap
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleTapGesture:"));
        tapGesture.numberOfTapsRequired = 1;
        view.addGestureRecognizer(tapGesture);
        
        //handle pan
        let panGesture = UIPanGestureRecognizer(target: self, action: Selector("handlePanGesture:"));
        view.addGestureRecognizer(panGesture);
        
        imageSize = CGSize(width: screenSize.width, height: screenSize.height);
        _imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: imageSize))
        self.view.addSubview(_imageView)
        let image = drawCustomImage(imageSize)
        _imageView.image = image
        
        self.setupGL()
    }
    
    //Tap input event handler
    //For shooting a projectile
    func handleTapGesture(recognizer : UITapGestureRecognizer) {
        let location : CGPoint = recognizer.locationInView(self.view);
        
        //Act set toCreateProjectile to signal that this is to be done.
        toCreateProjectile = true;
        let screenSize : CGRect = UIScreen.mainScreen().bounds;
        
        //mouseX and mouseY, where this is converted from screen to cartesian coords
        mouseX = location.x - screenSize.width / 2;
        mouseY = -location.y + screenSize.height / 2;
        //var newProjectile = Projectile(location.x, location.y, 0, 30);
        //Need model, view, and projection for the projectile.
    }
    func handlePanGesture(recognizer : UIPanGestureRecognizer) {
        if(recognizer.state == UIGestureRecognizerState.Began) {
            _maxRadius = 0;
            //_maxTranslationY = 0;
            _noSwipe = false;
            _translationPoints.removeAll();
        }
        let translation = recognizer.translationInView(self.view);
        let location = recognizer.locationInView(self.view);
        
        //Get furthest X,Y magnitude at the direction moved towards.
        //Actually, just get furthest radius from the origin.
        let radiusVec = GLKVector2Make(Float(translation.x), Float(translation.y));
        let radLength = CGFloat(GLKVector2Length(radiusVec))
        if(radLength > _maxRadius) {
            _maxRadius = radLength;
        }
        
        //cancel gesture if moving backwards from the furthest radius from the origin (as opposed to total translation) by 6px.
        //So yes, you can zigzag a lot if you wanted to.
        if(radLength < _maxRadius - 6) {
            _noSwipe = true;
        }
        
        //draw line
        //ie. create the _translationPoints
        if(!_noSwipe) {
            _translationPoints.append(CGPoint(x: location.x, y: location.y));
        }
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true;
    }
    
    //Jacob: Shake input handler
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            //shake method here
            //Cast spell
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
        if self.isViewLoaded() && (self.view.window != nil)
        {
            self.view = nil
            
            self.tearDownGL()
            
            if EAGLContext.currentContext() === self.context
            {
                EAGLContext.setCurrentContext( nil )
            }
            self.context = nil
        }
    }
    
    override func viewDidLayoutSubviews()
    {
        if !(mHud.subviews.first is UIVisualEffectView)
        {
            let blurEffect = UIBlurEffect( style: .Light )
            let blurEffectView = UIVisualEffectView( effect: blurEffect )
            let vibeEffectView = UIVisualEffectView( effect: UIVibrancyEffect( forBlurEffect: blurEffect ) )
                
            blurEffectView.frame = mHud.bounds
            vibeEffectView.frame = mHud.bounds
                
            blurEffectView.addSubview( vibeEffectView )
            mHud.insertSubview( blurEffectView, atIndex: 0 )
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
    
    func rotated()
    {
        /*if UIDeviceOrientationIsPortrait( UIDevice.currentDevice().orientation )
        {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.oriMask = UIInterfaceOrientationMask.All

            let vc = self.presentingViewController!.storyboard!.instantiateViewControllerWithIdentifier( "MainViewController" ) as! MainViewController
            self.presentViewController( vc, animated: true, completion: nil )
        }*/
    }
    
    // BOILERPLATE

    func setupGL()
    {
        EAGLContext.setCurrentContext( self.context )
        
        self.loadShaders()
        
        self.effect = GLKBaseEffect()
        self.effect!.light0.enabled = GLboolean( GL_TRUE )
        self.effect!.light0.diffuseColor = GLKVector4Make( 1.0, 0.4, 0.4, 1.0 )
        
        glEnable( GLenum( GL_DEPTH_TEST ) )
        
        glGenVertexArraysOES( 1, &vertexArray )
        glBindVertexArrayOES( vertexArray )
        
        glGenBuffers( 1, &vertexBuffer )
        glBindBuffer( GLenum( GL_ARRAY_BUFFER ), vertexBuffer )
        glBufferData( GLenum( GL_ARRAY_BUFFER ), GLsizeiptr( sizeof( GLfloat ) * gCubeVertexData.count ), &gCubeVertexData, GLenum( GL_STATIC_DRAW ) )
        
        glEnableVertexAttribArray( GLuint( GLKVertexAttrib.Position.rawValue ) )
        glVertexAttribPointer( GLuint( GLKVertexAttrib.Position.rawValue ), 3, GLenum( GL_FLOAT ), GLboolean( GL_FALSE ), 24, BUFFER_OFFSET( 0 ) )
        glEnableVertexAttribArray( GLuint( GLKVertexAttrib.Normal.rawValue ) )
        glVertexAttribPointer( GLuint( GLKVertexAttrib.Normal.rawValue ), 3, GLenum( GL_FLOAT ), GLboolean( GL_FALSE ), 24, BUFFER_OFFSET( 12 ) )
        
        glBindVertexArrayOES( 0 )
    }
    
    func tearDownGL()
    {
        EAGLContext.setCurrentContext( self.context )
        
        glDeleteBuffers( 1, &vertexBuffer )
        glDeleteVertexArraysOES( 1, &vertexArray )
        
        self.effect = nil
        
        if program != 0
        {
            glDeleteProgram( program )
            program = 0
        }
    }
    
    // MARK: - GLKView and GLKViewController delegate methods
    
    func update()
    {
        let aspect = fabsf( Float( self.view.bounds.size.width / self.view.bounds.size.height ) )
        let projectionMatrix = GLKMatrix4MakePerspective( GLKMathDegreesToRadians( 160.0 ), aspect, 0.1, 100.0 )
        
        self.effect?.transform.projectionMatrix = projectionMatrix
        
        var baseModelViewMatrix = GLKMatrix4MakeTranslation( 0.0, 0.0, -4.0 )
        baseModelViewMatrix = GLKMatrix4Translate(baseModelViewMatrix, _currProjectile._position.x, _currProjectile._position.y, _currProjectile._position.z); //Added to test projectile...
        //baseModelViewMatrix = GLKMatrix4Rotate( baseModelViewMatrix, rotation, 0.0, 1.0, 0.0 )
        
        // Compute the model view matrix for the object rendered with GLKit
        //var modelViewMatrix = GLKMatrix4MakeTranslation( 0.0, 0.0, -1.5 )
        //modelViewMatrix = GLKMatrix4Rotate( modelViewMatrix, rotation, 1.0, 1.0, 1.0 )
        //modelViewMatrix = GLKMatrix4Multiply( baseModelViewMatrix, modelViewMatrix )
        
        self.effect?.transform.modelviewMatrix = baseModelViewMatrix;
        
        // Compute the model view matrix for the object rendered with ES2
        let scale: Float = 1.5
        //baseModelViewMatrix = GLKMatrix4MakeScale( scale, scale, scale )
        //baseModelViewMatrix = GLKMatrix4Translate( baseModelViewMatrix, 0.0, 0.0, 1.5 )
        baseModelViewMatrix = GLKMatrix4Rotate( baseModelViewMatrix, rotation, 0.0, 1.0, 0.0 )
        //baseModelViewMatrix = GLKMatrix4Multiply( baseModelViewMatrix, modelViewMatrix )
        
        
        normalMatrix = GLKMatrix3InvertAndTranspose( GLKMatrix4GetMatrix3( baseModelViewMatrix ), nil )
        
        modelViewProjectionMatrix = GLKMatrix4Multiply( projectionMatrix, baseModelViewMatrix )
        self.effect?.transform.modelviewMatrix = baseModelViewMatrix;
        
        
        
        rotation += Float( self.timeSinceLastUpdate * 0.5 )
        
        //Test model, view, and projection for projectile
        if(toCreateProjectile) {
            let StartProjectile = Projectile.ActorConstants._origin;
            let screenSize : CGRect = UIScreen.mainScreen().bounds;
            let viewport = UnsafeMutablePointer<Int32>([Int32(0), Int32(screenSize.height - 100), Int32(screenSize.width), Int32(screenSize.height)]);
            let projectile = Projectile(screenX: mouseX, screenY: mouseY, farplaneZ: Int(100), speed: 5, modelView: baseModelViewMatrix, projection: projectionMatrix, viewport: viewport);
        
            //Casting ActorLists[0] as [Projectile], getting the reference of that
            if ((ActorLists[0] as? [Projectile]) != nil) { //creates a copy of the array, due to swift - http://stackoverflow.com/questions/27812433/swift-how-do-i-make-a-exact-duplicate-copy-of-an-array
                ActorLists[0].removeAll();
                ActorLists[0].append(projectile); //adds to its own constructor
            }
            toCreateProjectile = false;
            projectile.printVector("a", vec: projectile._velocity);
            _currProjectile = projectile;
        }
        //ActorLists[0].append(projectile);
        //ProjectileList.append(projectile);
        
        //update line
        let image = drawCustomImage(imageSize)
        _imageView.image = image
        
        //Update all Actors in ActorLists
        for ActorList in ActorLists {
            for actor in ActorList as! [Actor] { //force downcast/unwrap with "as!"
                actor.update(); //actor...
            }
        }
    }
    
    override func glkView( view: GLKView, drawInRect rect: CGRect )
    {
        glClearColor( 0.65, 0.65, 0.65, 1.0 )
        glClear( GLbitfield( GL_COLOR_BUFFER_BIT ) | GLbitfield( GL_DEPTH_BUFFER_BIT ) )
        
        glBindVertexArrayOES( vertexArray )
        
        // Render the object with GLKit
        self.effect?.prepareToDraw()
        
        glDrawArrays( GLenum( GL_TRIANGLES ) , 0, 36 )
        
        // Render the object again with ES2
        glUseProgram( program )
        
        withUnsafePointer( &modelViewProjectionMatrix, {
            glUniformMatrix4fv( uniforms[ UNIFORM_MODELVIEWPROJECTION_MATRIX ], 1, 0, UnsafePointer( $0 ) )
        } )
        
        withUnsafePointer( &normalMatrix, {
            glUniformMatrix3fv( uniforms[ UNIFORM_NORMAL_MATRIX ], 1, 0, UnsafePointer( $0 ) )
        } )
        
        glDrawArrays( GLenum( GL_TRIANGLES ), 0, 36 )
    }
    
    // MARK: -  OpenGL ES 2 shader compilation
    
    func loadShaders() -> Bool
    {
        var vertShader: GLuint = 0
        var fragShader: GLuint = 0
        var vertShaderPathname: String
        var fragShaderPathname: String
        
        // Create shader program.
        program = glCreateProgram()
        
        // Create and compile vertex shader.
        vertShaderPathname = NSBundle.mainBundle().pathForResource( "Shader", ofType: "vsh" )!
        if self.compileShader( &vertShader, type: GLenum( GL_VERTEX_SHADER ), file: vertShaderPathname ) == false
        {
            print( "Failed to compile vertex shader" )
            return false
        }
        
        // Create and compile fragment shader.
        fragShaderPathname = NSBundle.mainBundle().pathForResource( "Shader", ofType: "fsh" )!
        if !self.compileShader( &fragShader, type: GLenum( GL_FRAGMENT_SHADER ), file: fragShaderPathname )
        {
            print( "Failed to compile fragment shader" )
            return false
        }
        
        // Attach vertex shader to program.
        glAttachShader( program, vertShader )
        
        // Attach fragment shader to program.
        glAttachShader( program, fragShader )
        
        // Bind attribute locations.
        // This needs to be done prior to linking.
        glBindAttribLocation( program, GLuint( GLKVertexAttrib.Position.rawValue ), "position" )
        glBindAttribLocation( program, GLuint( GLKVertexAttrib.Normal.rawValue ), "normal" )
        
        // Link program.
        if !self.linkProgram( program )
        {
            print( "Failed to link program: \(program)" )
            
            if vertShader != 0
            {
                glDeleteShader( vertShader )
                vertShader = 0
            }
            if fragShader != 0
            {
                glDeleteShader( fragShader )
                fragShader = 0
            }
            if program != 0
            {
                glDeleteProgram( program )
                program = 0
            }
            
            return false
        }
        
        // Get uniform locations.
        uniforms[ UNIFORM_MODELVIEWPROJECTION_MATRIX ] = glGetUniformLocation( program, "modelViewProjectionMatrix" )
        uniforms[ UNIFORM_NORMAL_MATRIX ] = glGetUniformLocation( program, "normalMatrix" )
        
        // Release vertex and fragment shaders.
        if vertShader != 0
        {
            glDetachShader( program, vertShader )
            glDeleteShader( vertShader )
        }
        if fragShader != 0
        {
            glDetachShader( program, fragShader )
            glDeleteShader( fragShader )
        }
        
        return true
    }
    
    
    func compileShader( inout shader: GLuint, type: GLenum, file: String ) -> Bool
    {
        var status: GLint = 0
        var source: UnsafePointer< Int8 >
        
        do {
            source = try NSString( contentsOfFile: file, encoding: NSUTF8StringEncoding ).UTF8String
            
        } catch {
            print( "Failed to load vertex shader" )
            return false
        }
        
        var castSource = UnsafePointer< GLchar >( source )
        
        shader = glCreateShader( type )
        glShaderSource( shader, 1, &castSource, nil )
        glCompileShader( shader )
        
        //#if defined( DEBUG )
        //        var logLength: GLint = 0
        //        glGetShaderiv( shader, GLenum( GL_INFO_LOG_LENGTH ), &logLength )
        //        if logLength > 0
        //        {
        //            var log = UnsafeMutablePointer< GLchar >( malloc( Int( logLength ) ) )
        //            glGetShaderInfoLog( shader, logLength, &logLength, log )
        //            NSLog( "Shader compile log: \n%s", log )
        //            free( log )
        //        }
        //#endif
        
        glGetShaderiv( shader, GLenum( GL_COMPILE_STATUS ), &status )
        if status == 0
        {
            glDeleteShader( shader )
            return false
        }
        return true
    }
    
    func linkProgram( prog: GLuint ) -> Bool
    {
        var status: GLint = 0
        glLinkProgram( prog )
        
        //#if defined( DEBUG )
        //        var logLength: GLint = 0
        //        glGetShaderiv( shader, GLenum( GL_INFO_LOG_LENGTH ), &logLength )
        //        if logLength > 0
        //        {
        //            var log = UnsafeMutablePointer< GLchar >( malloc( Int( logLength ) ) )
        //            glGetShaderInfoLog( shader, logLength, &logLength, log )
        //            NSLog( "Shader compile log: \n%s", log )
        //            free( log )
        //        }
        //#endif
        
        glGetProgramiv( prog, GLenum( GL_LINK_STATUS ), &status )
        
        return status != 0
    }
    
    func validateProgram( prog: GLuint ) -> Bool
    {
        var logLength: GLsizei = 0
        var status: GLint = 0
        
        glValidateProgram( prog )
        glGetProgramiv( prog, GLenum( GL_INFO_LOG_LENGTH ), &logLength )
        if logLength > 0
        {
            var log: [GLchar] = [GLchar]( count: Int( logLength ), repeatedValue: 0 )
            glGetProgramInfoLog( prog, logLength, &logLength, &log )
            print( "Program validate log: \n\(log)" )
        }
        
        glGetProgramiv( prog, GLenum( GL_VALIDATE_STATUS ), &status )
        
        return status != 0
    }
}

var gCubeVertexData: [GLfloat] = [
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    0.5, -0.5, -0.5,        1.0, 0.0, 0.0,
    0.5, 0.5, -0.5,         1.0, 0.0, 0.0,
    0.5, -0.5, 0.5,         1.0, 0.0, 0.0,
    0.5, -0.5, 0.5,         1.0, 0.0, 0.0,
    0.5, 0.5, -0.5,         1.0, 0.0, 0.0,
    0.5, 0.5, 0.5,          1.0, 0.0, 0.0,
    
    0.5, 0.5, -0.5,         0.0, 1.0, 0.0,
    -0.5, 0.5, -0.5,        0.0, 1.0, 0.0,
    0.5, 0.5, 0.5,          0.0, 1.0, 0.0,
    0.5, 0.5, 0.5,          0.0, 1.0, 0.0,
    -0.5, 0.5, -0.5,        0.0, 1.0, 0.0,
    -0.5, 0.5, 0.5,         0.0, 1.0, 0.0,
    
    -0.5, 0.5, -0.5,        -1.0, 0.0, 0.0,
    -0.5, -0.5, -0.5,      -1.0, 0.0, 0.0,
    -0.5, 0.5, 0.5,         -1.0, 0.0, 0.0,
    -0.5, 0.5, 0.5,         -1.0, 0.0, 0.0,
    -0.5, -0.5, -0.5,      -1.0, 0.0, 0.0,
    -0.5, -0.5, 0.5,        -1.0, 0.0, 0.0,
    
    -0.5, -0.5, -0.5,      0.0, -1.0, 0.0,
    0.5, -0.5, -0.5,        0.0, -1.0, 0.0,
    -0.5, -0.5, 0.5,        0.0, -1.0, 0.0,
    -0.5, -0.5, 0.5,        0.0, -1.0, 0.0,
    0.5, -0.5, -0.5,        0.0, -1.0, 0.0,
    0.5, -0.5, 0.5,         0.0, -1.0, 0.0,
    
    0.5, 0.5, 0.5,          0.0, 0.0, 1.0,
    -0.5, 0.5, 0.5,         0.0, 0.0, 1.0,
    0.5, -0.5, 0.5,         0.0, 0.0, 1.0,
    0.5, -0.5, 0.5,         0.0, 0.0, 1.0,
    -0.5, 0.5, 0.5,         0.0, 0.0, 1.0,
    -0.5, -0.5, 0.5,        0.0, 0.0, 1.0,
    
    0.5, -0.5, -0.5,        0.0, 0.0, -1.0,
    -0.5, -0.5, -0.5,      0.0, 0.0, -1.0,
    0.5, 0.5, -0.5,         0.0, 0.0, -1.0,
    0.5, 0.5, -0.5,         0.0, 0.0, -1.0,
    -0.5, -0.5, -0.5,      0.0, 0.0, -1.0,
    -0.5, 0.5, -0.5,        0.0, 0.0, -1.0
]

