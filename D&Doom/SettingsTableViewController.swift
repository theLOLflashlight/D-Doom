//
//  SettingsTableViewController.swift
//  D&Doom
//
//  Created by Andrew Meckling on 2016-02-23.
//  Copyright © 2016 Andrew Meckling. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class SettingsTableViewController : UITableViewController
{
    var settingMusicOn = false
  
    
    override func viewDidLoad()
    {
        
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor( red: 243.0/255, green: 243.0/255, blue: 243.0/255, alpha: 1 )
        
        //toggleMusic.accessibilityElementCount();
        if !MPlay.playVariable
        {
            togMusic.setOn(false, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var togMusic: UISwitch!
    
    @IBAction func toggleMusic(sender: UISwitch) {
 
        if sender.on
        {
            MPlay.playVariable = true;
        }else
        {
            MPlay.playVariable = false;
        }
       
    }
}
