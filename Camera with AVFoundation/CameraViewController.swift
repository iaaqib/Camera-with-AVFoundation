//
//  CameraViewController.swift
//  Camera with AVFoundation
//
//  Created by Aaqib Hussain on 30/10/2016.
//  Copyright © 2016 Kode Snippets. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    //Receive Key from Menu on which camera to start
    var keyFromMenu : String?
    //Holds the camera layer
    @IBOutlet weak var cameraOverlayView: UIView!
    //Camera Session
    var session: AVCaptureSession?
    //Capturing Image
    var stillImageOutput: AVCaptureStillImageOutput?
    //Capturing Video
    var videoOutput :  AVCaptureMovieFileOutput?
    //Shows preview
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    //Capturing Camera hardware
    var captureDevice:AVCaptureDevice! = nil
    //Capture button outlet for changing image of button
    @IBOutlet weak var captureOutlet: UIButton!
    //Switching to front/back camera
    var camera : Bool = true
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewWillAppear(animated: Bool) {
        
        if let title = self.keyFromMenu{
            
            self.title = title
            if title == "Capture Picture"{
                initiatePictureCamera()
            }
            else{
                initiateVideoCamera()
            }
            
            
            
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Camera Initialization functions
    func initiatePictureCamera(){
        print("Picture Camera is Running")
        session = AVCaptureSession()
        session!.sessionPreset = AVCaptureSessionPresetPhoto
        var input : AVCaptureDeviceInput?
        var error: NSError?
        
        if (camera == false) {
            let videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
            
            
            for device in videoDevices{
                let device = device as! AVCaptureDevice
                if device.position == AVCaptureDevicePosition.Front {
                    captureDevice = device
                    
                    break
                }
            }
        } else {
            captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        }
        
        
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
            
            if error == nil && session!.canAddInput(input) {
                session!.addInput(input)
                
                stillImageOutput = AVCaptureStillImageOutput()
                stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
                
                if session!.canAddOutput(stillImageOutput) {
                    session!.addOutput(stillImageOutput)
                    
                    videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
                    videoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
                    videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                    videoPreviewLayer!.frame = cameraOverlayView.bounds
                    
                    cameraOverlayView.layer.addSublayer(videoPreviewLayer!)
                    
                    session!.startRunning()
                }
            }
            
        }
        catch let err as NSError {
            error = err
            input = nil
            print(error!.localizedDescription)
            
        }
        
    }
    func initiateVideoCamera(){
        print("Video Camera is Running")
       
        session = AVCaptureSession()
        session!.sessionPreset = AVCaptureSessionPresetHigh
        //var captureDevice:AVCaptureDevice! = nil
        var input : AVCaptureDeviceInput?
        var error: NSError?

        if (camera == false) {
            let videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
            
            
            for device in videoDevices{
                let device = device as! AVCaptureDevice
                if device.position == AVCaptureDevicePosition.Front {
                    captureDevice = device
                    break
                }
                
            }
        } else {
            captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        }
        
        
        do {
            
            input = try AVCaptureDeviceInput(device: captureDevice)
            
            if error == nil && session!.canAddInput(input) {
                session!.addInput(input)
                
                self.videoOutput = AVCaptureMovieFileOutput()
                
                if session!.canAddOutput(videoOutput) {
                    session!.addOutput(videoOutput)
                    
                    videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
                    videoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
                    videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                    videoPreviewLayer!.frame = cameraOverlayView.bounds
                    cameraOverlayView.layer.addSublayer(videoPreviewLayer!)
                    
                    session!.startRunning()
                }
            }
            
        }
        catch let err as NSError {
            error = err
            input = nil
            print(error!.localizedDescription)
            
        }
    }
    //MARK: - Change Camera to Front or Back
    @IBAction func switchCamera(sender: UIBarButtonItem) {
  
        self.camera = !camera
        session!.stopRunning()
        videoPreviewLayer!.removeFromSuperlayer()
        initiatePictureCamera()
    
    }
    //MARK: - Capture Video or Picture
    @IBAction func capture(sender: AnyObject) {
        
        if let title = self.keyFromMenu{
        
        if title == "Capture Picture"{
            
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            
            stillImageOutput!.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (sampleBuffer, error) -> Void in
                
                if sampleBuffer != nil {
                    
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                    
                    UIImageWriteToSavedPhotosAlbum(image, self,#selector(CameraViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
                }
                
                
            })
            
            
            
            
        }
        }
            //If not title is Capture Video
        else{
            
            let fileName = "video.mp4";
            let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            let filePath = documentsURL.URLByAppendingPathComponent(fileName)
            
            if self.videoOutput!.recording{
            //Change camera button for video recording
            self.videoOutput!.stopRecording()
                self.captureOutlet.setImage(UIImage(named: "capture"), forState: .Normal)
            self.activityIndicator.hidden = false
            self.activityIndicator.startAnimating()
                
            return
            
            }
            else{
                
            //Change camera button for video recording
            self.captureOutlet.setImage(UIImage(named: "video_record"), forState: .Normal)
            //Start recording
            self.videoOutput!.startRecordingToOutputFileURL(filePath, recordingDelegate: self)
  

            }
            
            
            
            
            
            }
        }
        
    }
    
    //MARK: - Shows alert when image is saved
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        guard error == nil else {
            //Error saving image
            print(error)
            return
        }
        
        //Image saved successfully
        showAlert("Saved", message: "Image Saved to Photos")
        

    }
    //MARK: - Get completed video path
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!){
        
      
        doVideoProcessing(outputFileURL)

        
    }
    
    func doVideoProcessing(outputPath:NSURL){
        
        

        
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(outputPath)
            
            
            
        }) { (success, error) in
            
            
            
            if error == nil{
                
                print("Success:\(success)")
                dispatch_async(dispatch_get_main_queue(),{
                    self.activityIndicator!.stopAnimating()
                    self.showAlert("Saved", message: "Video saved to Photos")
                })
                
                
            }
            else{
                
                dispatch_async(dispatch_get_main_queue(),{
                    self.activityIndicator!.stopAnimating()

                    self.showAlert("Error", message: error!.localizedDescription)
                    
                })
                

                
            }
            
            
        }
        
        
        
        
        
        
        
    }
    func showAlert(title: String, message : String)
    {
    
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let done = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(done)
        self.presentViewController(alert, animated: false, completion: nil)

    
    }

}
