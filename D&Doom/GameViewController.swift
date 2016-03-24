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
import SpriteKit
import AVFoundation

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
    
    
    //For the purposes of this project, statics are a very efficient way
    //with little risk of unexpected modifications.
    static var mAmmo = 107;
    static var mHealth = 100;
    static var mWeapon = "N/A";
    
    //Decided against a PlayerData object as well as the construct of a "RenderContext" or passing each variable to the respective classes.
    //Player data
    /*var Ammo : UILabel! {
        get { return GameViewController.mAmmo; }
        set { GameViewController.mAmmo = newValue;
            mAmmoLabel = newValue;}
    };*/
    //var PlayerData = PlayerData();
    
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
    
    var modelViewMatrix: GLKMatrix4 = GLKMatrix4Identity
    
    //Accessible static var - position
    static var position: GLKVector3 = GLKVector3Make(0, 0.5, 5)
    var direction: GLKVector3 = GLKVector3Make(0,0,0)
    var up: GLKVector3 = GLKVector3Make(0, 1, 0)
    
    
    var currProjectileCoord: UILabel!;
    
    var horizontalMovement: GLKVector3 = GLKVector3Make(0, 0, 0)
    var _baseHorizontalAngle : Float = 0
    var _baseVerticalAngle : Float = 0
    var currhorizontalAngle: Float = 0
    var currverticalAngle: Float = 0
    
    var rotationSpeed: Float = 0.005
    
    var vertexArray: GLuint = 0
    var vertexBuffer: GLuint = 0
    
    var context: EAGLContext? = nil
    var effect: GLKBaseEffect? = nil
    
    var _myBezier = UIBezierPath();
    
    let bezierDuration = Float(1); //duration of bezier on screen (in seconds)
    
    //to track swipe running or not
    var _currBezierDuration = -0.00001; //hard-coded time below 0
    var _currSwipeDrawn = false;
    
    //Timer stuff (especially for enemy AI)
    //var _timer : NSTimer
    
//    @IBAction func cameraRotation(sender: UIPanGestureRecognizer) {
//        
//        let point: CGPoint = sender.translationInView(self.view)
//        
//        horizontalAngle -= Float(point.x) * rotationSpeed
//        
//        verticalAngle += Float(point.y) * rotationSpeed
//        
//        print(horizontalAngle, "h")
//        print(verticalAngle, "v")
//        
//        sender.setTranslation(CGPointMake(0, 0), inView: self.view)
//    }
    @IBAction func MainButton(sender: UIButton) {
        
        themePlayer.pause();
    }
    
    @IBAction func MoveCamera(sender: UIButton) {
        GameViewController.position = GLKVector3Subtract(GameViewController.position, direction)
    }

    
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
    // Made static in order to be accessible by separate classes.
    static var ActorLists : [Array<Actor>] = [];
    static var ProjectileList : [Projectile] = [];
    
    //For swipe action.
    var _maxRadius : CGFloat = 0;
    //var _maxTranslationY : CGFloat = 0;
    var _prevTranslationX : CGFloat = 0; //for drawing lines
    var _prevTranslationY : CGFloat = 0;
    var _translationPoints : [CGPoint] = [];
    var _noSwipe = false;
    var _swipeHit = false;
    
    var screenSize : CGRect = UIScreen.mainScreen().bounds;
    var imageSize = CGSize(width: 200, height: 200); //arbitrary initialization
    var _imageView = UIImageView();
    
    //sound setup
    // Grab the path, make sure to add it to your project!
    let filePath = "footsteps_gravel";
    var sound : NSURL = NSBundle.mainBundle().URLForResource("footsteps_gravel", withExtension: "wav")!;
    //var audioPlayer = AVAudioPlayer()
    var mySound: SystemSoundID = 0;
    public var themePlayer : AVAudioPlayer!;
    var soundPlayer : AVAudioPlayer!;
    var soundPlayer2 : AVAudioPlayer!;
    
    //Make an arraylist keeping track of each audio played, and remove each AVPAudioPlayer from the arraylist as each of them has completed its track, is the plan - though, still have to figure out how to set delegate and such, as to-do.
    //
    var AVAudioPlayers : [AVAudioPlayer] = [];
    
    //For other iOS stuff.
    typealias NSPoint = CGPoint;
    typealias NSUInteger = UInt;
    
    var _lastDate = [NSDate?](count: 64, repeatedValue: nil);
    
    //For drawing Bezier:
    //From http://stackoverflow.com/questions/10458596/bezier-curve-algorithm-in-objective-c
    /* //not used
    func drawBezierFrom(from:NSPoint, to:NSPoint, a:NSPoint, b:NSPoint, color:NSUInteger)
    {
        var qx : Float; var qy : Float;
        var q1 : Float;
        var q2 : Float;
        var q3 : Float;
        var q4 : Float;
        var plotx : Float;
        var ploty : Float;
        var t : Float = 0.0;
    
    while (t <= 1)
    {
        //Split because 'statement was too complex to be solved in a reasonable time' comes up, where it doesn't look nearly like that
        q1 = Float(t*t*t*(-1) + t*t*3
             + t*(-3) + 1);
        q2 = Float(t*t*t*3 + t*t*(-6)
             + t*3);
        q3 = Float(t*t*t*(-3)
             + t*t*3);
        q4 = Float(t*t*t);
    
        qx = Float(q1*from.x
            + q2*a.x
            + q3*to.x
            + q4*b.x);
        qy = Float(q1*from.y
            + q2*a.y
            + q3*to.y
            + q4*b.y);
    
        plotx = round(qx);
        ploty = round(qy);
    
        self.drawPixelColor(color:color, atX:plotx, y:ploty);
    
        t = t + 0.003;
    }
    }*/
    
    //Time since the last iteration of calling this method. Original intention is for running the code, and tracking time independently of frame rate.
    //Each place in code calling this is to use a different Int for 'closest-to-accurate' results (though it would not include the time after retrieving the time and updating the time, so the value would be less, or not include the time spent in retrieving the NSDate before retrieving timeDiff, ie. timeDiff would not include such time).
    func timeSinceLastIter(timePointIndex: Int) -> Double {
        let newTime = NSDate();
        var timeDiff : Double = 0; //this would be the first time; there would be no time before this one occurred.
        if(timePointIndex < _lastDate.count) {
            if(_lastDate[timePointIndex] != nil) { //if an NSDate exists, then do the following
                timeDiff = newTime.timeIntervalSinceDate(_lastDate[timePointIndex]!) //provided misleading error info - where I declared timeDiff resolved an error of 'not matching array type' apparently
            }
        }
        
        //if let timeDiff = newTime.timeIntervalSinceDate(_lastDate[timePointIndex]);
        
        
        //append array elements such that this array would be long enough to store the element at timePointIndex
        if(!(timePointIndex < _lastDate.count)) {
            _lastDate = _lastDate + [NSDate?](count: timePointIndex - (_lastDate.count - 1), repeatedValue: nil);
        }
        _lastDate[timePointIndex] = newTime;
        return timeDiff;
    }
    
    //For drawing lines - from http://stackoverflow.com/questions/25229916/how-to-procedurally-draw-rectangle-lines-in-swift-using-cgcontext
    func drawSwipeLine(size: CGSize) -> UIImage {
        // Setup our context
        let bounds = CGRect(origin: CGPoint.zero, size: size)
        let opaque = false
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let context = UIGraphicsGetCurrentContext()
        
        // Setup complete, do drawing here
        CGContextSetStrokeColorWithColor(context, UIColor.blueColor().CGColor)
        CGContextSetLineWidth(context, 4.0)
        
        CGContextStrokeRect(context, bounds)
        
        CGContextBeginPath(context)
        
        
        let timesinceLast = timeSinceLastIter(0);
        if(!_noSwipe) { //condition to erase line if swipe ended
            //Draw bezier
            //Maybe a cubic bezier curve?
            _myBezier = UIBezierPath()
            let myMicroBezier = UIBezierPath();
            
            //Set control points c0, c1, c2, and c3 for the path myBezierPath()
            var c0, c1, c2, c3 : CGPoint;
            let bezierInterval = 3; //have to make sure this is divisible by 3.
            //myBezier.moveToPoint(CGPoint(x: 0,y: 0));
            if(!(_translationPoints.count < 1)) {
                //initialization
                //c0 = _translationPoints[0]; //adding this because xcode is stupid
                c1 = _translationPoints[0];
                c2 = _translationPoints[0];
                c3 = _translationPoints[0]; //set origin point
                //var currCurvePos = 1;
                
                //draw each line, as evident from _translationPoints
                for(var i=1; i < _translationPoints.count; i++) {
                    //CGContextMoveToPoint(context, _translationPoints[i-1].x, _translationPoints[i-1].y);
                
                    //build bezier curve
                    if(i%(bezierInterval/3) == 0) { //every point, add a new control point to bezier curve
                        //shift all of the control points by one
                        c0 = c1;
                        c1 = c2;
                        c2 = c3;
                        c3 = _translationPoints[i];
                        
                        //draw the c0,c1,c2,c3 bezier curve every 3 additional control points.
                        if(i%(bezierInterval) == 0) { //becomes 0 ... making sometimes a straight line ... maybe the 'last line' being different in how Bezier might handle it? Oh, it's because of the closePath, and that apparently applying to addCurveToPoint ...
                            _myBezier.moveToPoint(c0);
                            _myBezier.addCurveToPoint(c3, controlPoint1: c1, controlPoint2: c2);
                        }
                    }
                    
                    //get values greater than those truncated from dividing by bezierInterval, ie. values greater than the highest value quantized by bezierInterval, and draw normally according to that
                    let highestQuantizedVal = (_translationPoints.count / bezierInterval) * bezierInterval;
                    if(i > highestQuantizedVal) {
                        myMicroBezier.moveToPoint(_translationPoints[i-1]);
                        myMicroBezier.addLineToPoint(_translationPoints[i]);
                    }
                    //CGContextAddLineToPoint(context, _translationPoints[i].x, _translationPoints[i].y);
                }
                
                //draw bezier curve from those control points
                _myBezier.lineWidth = 5;
                //Maybe error occurs when trying to access c0 when c0 would no longer exist, ie. be out of scope?
                //myBezier.addClip();
                //myBezier.closePath() //may be the cause
                UIColor.redColor().setStroke();
                
                //myMicroBezier.lineWidth = 5;
                //UIColor.greenColor().setStroke();
                //myMicroBezier.stroke();
            }
        }
        //Fading swipe effect
        if(_currBezierDuration >= 0 && _currSwipeDrawn) {
            _currBezierDuration -= timesinceLast; //reserving 0 for this
            
            //fade only halfway through the swipe
            let alpha = min(1, Float(_currBezierDuration)/Float(bezierDuration * 0.66));
            UIColor(red: 1,green: 0, blue: 0, alpha:CGFloat(alpha)).setStroke();
            _myBezier.stroke();
            
            if(_currBezierDuration <= 0) {
                _translationPoints.removeAll();
                _currSwipeDrawn = false;
            }
        }
        //draw min to max - so, diagonally
//        CGContextMoveToPoint(context, CGRectGetMaxX(bounds), CGRectGetMinY(bounds))
//        CGContextAddLineToPoint(context, CGRectGetMinX(bounds), CGRectGetMaxY(bounds))
        //CGContextStrokePath(context)
        
        // Drawing complete, retrieve the finished image and cleanup
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    //animation for background color turning brown (due to earthquake)
    var animationProgress : Float = 0.0; //from 0 to 1
    
    func ThemeSound() {
        
        if let path = NSBundle.mainBundle().pathForResource("footsteps_gravel", ofType: "wav") {
            let soundURL = NSURL(fileURLWithPath:path)
            
            var error:NSError?
            do {
                themePlayer = try AVAudioPlayer(contentsOfURL: soundURL);
                themePlayer.prepareToPlay()
                themePlayer.numberOfLoops = -1;
                themePlayer.play()
            }
            catch {
            }
        }

        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.context = EAGLContext( API: .OpenGLES2 )
        
        if self.context == nil
        {
            print("Failed to create ES context")
        }
        GameViewController.ActorLists = [GameViewController.ProjectileList]; //Can assign an array of a subclass to an array of its superclass, apparently
        
        let view = self.view as! GLKView
        view.context = self.context!
        view.drawableDepthFormat = .Format24
        
        //mAmmoLabel.text = GameViewController.mAmmo;
        mHealthLabel.text = "77%"
        
        mWeaponLabel.text = "N/A"
        animationProgress = 1;
        
        //handle tap
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleTapGesture:"));
        tapGesture.numberOfTapsRequired = 1;
        view.addGestureRecognizer(tapGesture);
        
        //handle pan
        let panGesture = UIPanGestureRecognizer(target: self, action: Selector("handlePanGesture:"));
        view.addGestureRecognizer(panGesture);
        
        //play looping sound
        //From http://stackoverflow.com/questions/30873056/ios-swift-2-0-avaudioplayer-is-not-playing-any-sound
        ThemeSound()
        
        currProjectileCoord = UILabel(frame: CGRectMake(screenSize.height/2 - 100, screenSize.width - 27, 500, 21))
        //currProjectileCoord.center = CGPointMake(160, 284)
        //currProjectileCoord.textAlignment = NSTextAlignment.Center
        currProjectileCoord.text = "Projectile Coords"
        self.view.addSubview(currProjectileCoord)
        
        self.setupGL()
    }
    /*func replaySound() {
        AudioServicesPlaySystemSound(mySound);
    }*/
    
    //func playSound(inout soundPlayer? : AVAudioPlayer) {
    //}
    
    func cameraMovement()
    {
        var horizontalAngle = _baseHorizontalAngle + currhorizontalAngle;
        var verticalAngle = _baseVerticalAngle + currverticalAngle;
        
        //for animationProgress of shake
        if(animationProgress > 1) {
            animationProgress = 1;
        }
        if(animationProgress < 1) {
            animationProgress += Float(1.0)/Float(45.0);
            var shakeMag : Float;
            if(animationProgress < 0.70) {
                shakeMag = 0.9 * 0.4;
            }
            else {
                shakeMag = (0.9 - (animationProgress - 0.7) * 0.9 / 0.3) * 0.4; //after reaching 0.7 progress (when sound starts to dwindle), linearly decrease max magnitude to 0
            }
            //modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, Float(arc4random())*shakeMag, Float(arc4random())*shakeMag, 0);
            //GLKVector3Make(position.x + Float(arc4random())*shakeMag, position.y + Float(arc4random())*shakeMag, position.z + Float(arc4random())*shakeMag);
            horizontalAngle += (Float(arc4random()) / Float(UINT32_MAX)) * Float(shakeMag);
            verticalAngle += (Float(arc4random()) / Float(UINT32_MAX)) * Float(shakeMag);
        }
        
        direction = GLKVector3Make(cosf(verticalAngle) * sinf(horizontalAngle),
            sinf(verticalAngle),
            cosf(verticalAngle) * cosf(horizontalAngle));
        
        horizontalMovement = GLKVector3Make(sinf(horizontalAngle - Float(M_PI_2)), 0, cosf(horizontalAngle - Float(M_PI_2)));
        //print("horizontalAngle: \(horizontalAngle); verticalAngle: \(verticalAngle)");
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
        
        
        //Play sound
        if let path = NSBundle.mainBundle().pathForResource("'flyby'", ofType: "wav") {
            let soundURL = NSURL(fileURLWithPath:path)
            
            var error:NSError?
            do {
                soundPlayer = try AVAudioPlayer(contentsOfURL: soundURL);
                soundPlayer.prepareToPlay()
                //No loops
                soundPlayer.play()
            }
            catch {
            }
        }
    }
    
    func handlePanGesture(recognizer : UIPanGestureRecognizer) {
        
        let translation = recognizer.translationInView(self.view); //reusing, if the method could only be called once per recognize ... oh, was due to it being point.
        let location = recognizer.locationInView(self.view);
        
        //Actually, just get furthest radius from the origin.
        let radiusVec = GLKVector2Make(Float(translation.x), Float(translation.y));
        let radLength = CGFloat(GLKVector2Length(radiusVec))
        
        if(recognizer.state == UIGestureRecognizerState.Began) {
            _maxRadius = 0;
            //_maxTranslationY = 0;
            _noSwipe = false;
            _translationPoints.removeAll();
        }
        if(recognizer.state == UIGestureRecognizerState.Ended) {
            _noSwipe = false;
            if(radLength >= 80) { //valid swipe
                var swipeSound : String;
                var swipeSoundExt : String = "mp3";
                if(_swipeHit) {
                    swipeSound = "sword-clash1"
                }
                else {
                    swipeSound = "swipe_whiff";
                }
                if let path = NSBundle.mainBundle().pathForResource(swipeSound, ofType: swipeSoundExt) {
                    let soundURL = NSURL(fileURLWithPath:path)
                    
                    var error:NSError?
                    do {
                        soundPlayer2 = try AVAudioPlayer(contentsOfURL: soundURL);
                        soundPlayer2.prepareToPlay()
                        soundPlayer2.play()
                    }
                    catch {
                    }
                }
                _currBezierDuration = Double(bezierDuration);
                _currSwipeDrawn = true;
            }
        }
        
        
        if(radLength > _maxRadius) {
            _maxRadius = radLength;
        }
        
        //cancel gesture if moving backwards from the furthest radius from the origin (as opposed to total translation) by 6px.
        //So yes, you can zigzag a lot if you wanted to.
        if(radLength < _maxRadius - 6) {
            //_noSwipe = true;
        }
        
        //draw line
        //ie. create the _translationPoints
        if(!_noSwipe) {
            _translationPoints.append(CGPoint(x: location.x, y: location.y));
        }
        //print("radLength: \(radLength); _maxRadius: \(_maxRadius)");
        
        
        
        //let point: CGPoint = recognizer.translationInView(self.view)
        
        
        if(recognizer.state == UIGestureRecognizerState.Began) {
            //_prevHorizontalAngle
            _baseHorizontalAngle += currhorizontalAngle; //had missed the + increment over the previous ...
            _baseVerticalAngle += currverticalAngle;
            //currhorizontalAngle = 0;
            //currverticalAngle = 0;
        }
        currhorizontalAngle = -Float(translation.x) * rotationSpeed;
        currverticalAngle = Float(translation.y) * rotationSpeed;
        
        //print(horizontalAngle, "h")
        //print(verticalAngle, "v")
        
        //recognizer.setTranslation(CGPointMake(0, 0), inView: self.view) //keeps setting it to 0; should just be the value?
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true;
    }
    
    //Jacob: Shake input handler
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake { //just having earthquake for now
            //shake method here
            //Cast spell
            
            animationProgress = 0; //begins the animation of earthquake
            if let path = NSBundle.mainBundle().pathForResource("magic-quake2", ofType: "mp3") {
                let soundURL = NSURL(fileURLWithPath:path)
                
                var error:NSError?
                do {
                    soundPlayer = try AVAudioPlayer(contentsOfURL: soundURL);
                    soundPlayer.prepareToPlay()
                    //No loops
                    soundPlayer.play()
                }
                catch {
                }
            }
            
            //Right now, it simply shakes the camera, but maybe shaking the world instead could be considered?
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
        
        //Update image for lines
        screenSize = UIScreen.mainScreen().bounds;
        imageSize = CGSize(width: screenSize.width, height: screenSize.height);
        _imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: imageSize))
        self.view.addSubview(_imageView)
        let image = drawSwipeLine(imageSize)
        //_imageView.
        _imageView.image = image
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
        //glBufferData( GLenum( GL_ARRAY_BUFFER ), GLsizeiptr( sizeof( GLfloat ) * gCubeVertexData.count ), &gCubeVertexData, GLenum( GL_STATIC_DRAW ) )
        
        glEnableVertexAttribArray( GLuint( GLKVertexAttrib.Position.rawValue ) )
        glVertexAttribPointer( GLuint( GLKVertexAttrib.Position.rawValue ), 3, GLenum( GL_FLOAT ), GLboolean( GL_FALSE ), 0, levelPositions)
        glEnableVertexAttribArray( GLuint( GLKVertexAttrib.Normal.rawValue ) )
        glVertexAttribPointer( GLuint( GLKVertexAttrib.Normal.rawValue ), 3, GLenum( GL_FLOAT ), GLboolean( GL_FALSE ), 24, levelNormals )
        
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
        let projectionMatrix = GLKMatrix4MakePerspective( GLKMathDegreesToRadians( 65.0 ), aspect, 0.1, 100.0 )
        
        //get inverse of seconds per update call
        //(roughly)
        //let timeSinceLastDate = NSDate().timeIntervalSinceDate(_currDate); // aka 'seconds / update'
        let UPS = 1 / timeSinceLastIter(1);

        
        self.effect?.transform.projectionMatrix = projectionMatrix
        
        self.cameraMovement();
        
        //var newPos : GLKVector3;
        
        
        //This were used to orient the matrix.
        modelViewMatrix = GLKMatrix4MakeLookAt(GameViewController.position.x, GameViewController.position.y, GameViewController.position.z,
            GLKVector3Subtract(GameViewController.position, direction).x,
            GLKVector3Subtract(GameViewController.position, direction).y,
            GLKVector3Subtract(GameViewController.position, direction).z,
            up.x, up.y, up.z);
        
        //self.effect?. = UIColor.brownColor().colorWithAlphaComponent(CGFloat(1 - animationProgress)); //set background color
        
        modelViewProjectionMatrix = GLKMatrix4Multiply( projectionMatrix, modelViewMatrix )
        //modelViewMatrix = GLKMatrix4Multiply( baseModelViewMatrix, modelViewMatrix )
        //modelViewProjectionMatrix = GLKMatrix4Multiply( projectionMatrix, modelViewMatrix )
        
        
        self.effect?.transform.modelviewMatrix = modelViewMatrix;
        
        
        
        //Still have to rotate the projectile velocity and vectors to make them facing direction of the camera; currently the projectile's projectile as if the camera were from 0,0,0 to facing towards the center of the screen, unless Unproject takes the view (which would involve the camera angle) into account.
        //Test model, view, and projection for projectile
        if(toCreateProjectile) {
            let StartProjectile = Projectile.ActorConstants._origin;
            let screenSize : CGRect = UIScreen.mainScreen().bounds;
            let viewport = UnsafeMutablePointer<Int32>([Int32(0), Int32(screenSize.height - 100), Int32(screenSize.width), Int32(screenSize.height)]);
            
            //TODO: Set modelVars for projectileModel
            let projectileModel = Actor.modelVars();
            
            let projectile = Projectile(screenX: mouseX, screenY: mouseY, farplaneZ: Int(100), speed: 5, modelView: modelViewMatrix, projection: projectionMatrix, viewport: viewport, mVars: projectileModel);
        
            //Casting ActorLists[0] as [Projectile], getting the reference of that
            if ((GameViewController.ActorLists[0] as? [Projectile]) != nil) { //creates a copy of the array, due to swift - http://stackoverflow.com/questions/27812433/swift-how-do-i-make-a-exact-duplicate-copy-of-an-array
                GameViewController.ActorLists[0].removeAll();
                GameViewController.ActorLists[0].append(projectile); //adds to its own constructor
            }
            toCreateProjectile = false;
            //projectile.printVector("a", vec: projectile._velocity);
            _currProjectile = projectile;
        }
        //GameViewController.ActorLists[0].append(projectile);
        //GameViewController.ProjectileList.append(projectile);
        
        currProjectileCoord.text = "Projectile Pos'n: (\(_currProjectile._position.x),\(_currProjectile._position.y),\(_currProjectile._position.z))";
        
        //update HUD values. Other than reassignment each frame, would have to maybe pass by reference, but that doesn't look possible.
        mAmmoLabel.text = String(GameViewController.mAmmo);
        mHealthLabel.text = String(GameViewController.mHealth) + "%";
        mWeaponLabel.text = GameViewController.mWeapon;
        
        //update line
        let image = drawSwipeLine(imageSize)
        _imageView.image = image
        
        //Update all Actors in ActorLists
        for ActorList in GameViewController.ActorLists {
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
        
        //glDrawArrays( GLenum( GL_TRIANGLES ) , 0, 36 )
        
        // Render the object again with ES2
        glUseProgram( program )
        
        withUnsafePointer( &modelViewProjectionMatrix, {
            glUniformMatrix4fv( uniforms[ UNIFORM_MODELVIEWPROJECTION_MATRIX ], 1, 0, UnsafePointer( $0 ) )
        } )
        
        withUnsafePointer( &normalMatrix, {
            glUniformMatrix3fv( uniforms[ UNIFORM_NORMAL_MATRIX ], 1, 0, UnsafePointer( $0 ) )
        } )
        
        glDrawArrays( GLenum( GL_TRIANGLES ), 0, levelVertices )
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

