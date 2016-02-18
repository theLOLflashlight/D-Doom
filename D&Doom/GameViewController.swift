//
//  GameViewController.swift
//  D&Doom
//
//  Created by Andrew Meckling on 2016-02-10.
//  Copyright © 2016 Andrew Meckling. All rights reserved.
//

import UIKit

class GameViewController: UIViewController
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
    
    func makeViewBlurry( target: UIView )
    {
        let blurEffect = UIBlurEffect( style: .Light )
        let blurEffectView = UIVisualEffectView( effect: blurEffect )
        let vibeEffectView = UIVisualEffectView( effect: UIVibrancyEffect( forBlurEffect: blurEffect ) )
        
        blurEffectView.frame = target.bounds
        vibeEffectView.frame = target.bounds
        
        blurEffectView.addSubview( vibeEffectView )
        target.insertSubview( blurEffectView, atIndex: 0 )
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        mAmmoLabel.text = "107"
        mHealthLabel.text = "77%"
        
        mWeaponLabel.text = "N/A"
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews()
    {
        if ( !(mHud.subviews.first is UIVisualEffectView) )
        {
            makeViewBlurry( mHud )
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
        return
        if UIDeviceOrientationIsPortrait( UIDevice.currentDevice().orientation )
        {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.oriMask = UIInterfaceOrientationMask.All

            let vc = self.presentingViewController!.storyboard!.instantiateViewControllerWithIdentifier( "MainViewController" ) as! MainViewController
            self.presentViewController( vc, animated: true, completion: nil )
        }
    }



}

