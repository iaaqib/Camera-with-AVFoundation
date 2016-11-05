//
//  ViewController.swift
//  Camera with AVFoundation
//
//  Created by Aaqib Hussain on 30/10/2016.
//  Copyright © 2016 Kode Snippets. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var keyForCamera : String!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func capturePicture(sender: UIButton) {
    self.keyForCamera = "Capture Picture"
        self.performSegueWithIdentifier("capture", sender: nil)
        
    }

    @IBAction func captureVideo(sender: UIButton) {
        self.keyForCamera = "Capture Video"
        self.performSegueWithIdentifier("capture", sender: nil)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "capture"{
        let destination = segue.destinationViewController as! CameraViewController
            destination.keyFromMenu = self.keyForCamera
        
        
        }
    }
    
    
}

