//
//  MainViewController.swift
//  D&Doom
//
//  Created by Andrew Meckling on 2016-02-10.
//  Copyright © 2016 Andrew Meckling. All rights reserved.
//

import UIKit

class MainViewController: UIViewController
{
    override func shouldAutorotate() -> Bool
    {
        return true
    }
    
    @IBOutlet var mPlayButton: UIButton!
    
    @IBOutlet var mOptionButton: UIButton!
    
    @IBOutlet var mCharacterbutton: UIButton!
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.AllButUpsideDown
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let filepath = NSBundle.mainBundle().pathForResource("BGT1", ofType: "gif");
        let gif = NSData(contentsOfFile: filepath!);
        
        let BGP = UIWebView(frame: view.frame);
        BGP.loadData(gif!, MIMEType: "image/gif", textEncodingName: String(), baseURL: NSURL());
        BGP.userInteractionEnabled = false;
        self.view.insertSubview(BGP, atIndex: 0)
        
        let filter = UIWebView();
        filter.frame = self.view.frame;
        filter.backgroundColor = UIColor.blackColor()
        filter.alpha = 0.05
        self.view.addSubview(filter)
        
        mPlayButton.translatesAutoresizingMaskIntoConstraints = true;
        //let loginBtn = UIButton(frame: CGRectMake(40, 260, 240, 40))
        mPlayButton.frame = CGRectMake(40, 660, 230, 70)
        mPlayButton.layer.borderColor = UIColor.blackColor().CGColor
        mPlayButton.layer.borderWidth = 2
        mPlayButton.titleLabel!.font = UIFont.systemFontOfSize(50)
        mPlayButton.tintColor = UIColor.blackColor()
        mPlayButton.setTitle("Play", forState: UIControlState.Normal)
        self.view.addSubview(mPlayButton)
        
        
        mOptionButton.translatesAutoresizingMaskIntoConstraints = true;
        //let mOptionButton = UIButton(frame: CGRectMake(40, 330, 240, 40))
        mOptionButton.frame = CGRectMake(400, 660, 230, 70)
        mOptionButton.layer.borderColor = UIColor.blackColor().CGColor
        mOptionButton.layer.borderWidth = 2
        mOptionButton.titleLabel!.font = UIFont.systemFontOfSize(50)
        mOptionButton.tintColor = UIColor.blackColor()
        mOptionButton.setTitle("Options", forState: UIControlState.Normal)
        self.view.addSubview(mOptionButton)
        
        
        mCharacterbutton.translatesAutoresizingMaskIntoConstraints = true;
        //let CharacterBtn = UIButton(frame: CGRectMake(40, 400, 240, 40))
        mCharacterbutton.frame = CGRectMake(750, 660, 230, 70)
        mCharacterbutton.layer.borderColor = UIColor.blackColor().CGColor
        mCharacterbutton.layer.borderWidth = 2
        mCharacterbutton.titleLabel!.font = UIFont.systemFontOfSize(50)
        mCharacterbutton.tintColor = UIColor.blackColor()
        mCharacterbutton.setTitle("Charactet", forState: UIControlState.Normal)
        self.view.addSubview(mCharacterbutton)
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func update()
    {
        
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
        return
        if UIDeviceOrientationIsLandscape( UIDevice.currentDevice().orientation )
        {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.oriMask = UIInterfaceOrientationMask.All
            
            let vc = self.presentingViewController!.storyboard!.instantiateViewControllerWithIdentifier( "GameViewController" ) as! GameViewController
            self.presentViewController( vc, animated: true, completion: nil )
        }
    }



}

