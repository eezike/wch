//
//  ViewController.swift
//  WindyCityHacks
//
//  Created by Emeka Ezike on 6/22/19.
//  Copyright © 2019 Emeka Ezike. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBOutlet var scanBtn: UIButton!
    
    var captureSession:AVCaptureSession!
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var result : [String: AnyObject] = [:]
    
    var btnPressed = false
    let group = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.tabBarController?.tabBar.isHidden = true
        scanBtn.addTarget(self, action: #selector(buttonDown), for: .touchDown)
        scanBtn.addTarget(self, action: #selector(buttonUp), for: [.touchUpInside, .touchUpOutside])
        
        start()
    }
    
    @objc func buttonDown(_ sender: UIButton) {
        print("Starting")
        btnPressed = true
    }
    
    @objc func buttonUp(_ sender: UIButton) {
        print("Stoping")
        btnPressed = false
    }
    
    func start(){
        captureSession = AVCaptureSession()
        
        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = deviceDiscoverySession.devices.first else
        {
            print("Failed to get the camera device")
            return
        }
        
        do
        {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture.
            captureSession.startRunning()
            
            // Move the message label and top bar to the front
            view.bringSubviewToFront(scanBtn)
            
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView
            {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }
        }
        catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection)
    {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            //messageLabel.text = "No race code is detected"
            return
        }
        if btnPressed{
            // Get the metadata object.
            let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
            if metadataObj.type == AVMetadataObject.ObjectType.qr
            {
                
                // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
                let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
                qrCodeFrameView?.frame = barCodeObject!.bounds
                qrCodeFrameView!.layer.borderColor = UIColor.green.cgColor
                
                if metadataObj.stringValue != nil
                {
                    let codeData = metadataObj.stringValue!
                    //messageLabel.text = codeData
                    
                    if let foodCode : String = codeData{
                        print(foodCode)
                        group.enter()
                        handleScan(code: foodCode)
                        
                        group.wait()
                        next()
                        
                    }
                    
                }
            }
        }
        
        
        
    }
    
    func next(){
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "scanToItem", sender: ViewController.self)
        }
    }
    
    func handleScan(code: String){
        
        let pdata = ["code" : code] as [String : Any]
        
        do {
            captureSession.stopRunning()
            let jsonData = try JSONSerialization.data(withJSONObject: pdata, options: .prettyPrinted)
            let url = NSURL(string: "https://blooming-gorge-82151.herokuapp.com/api/get_food_data")! //this will need to change
            let request = NSMutableURLRequest(url: url as URL)
            request.httpMethod = "POST"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            let task = URLSession.shared.dataTask(with: request as URLRequest){ data, response, error in
                if error != nil{
                    print("Send Error -> \(error!)")
                    return
                }
                do {
                    self.result = try (JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:AnyObject])!
                    //after response
                    
                    print(self.result["name"] as! String)
                    print(self.result["price"] as! String)
                    
                    self.group.leave()
                    
                    
                } catch {
                    print("Get Error -> \(error)")
                }
                
            }
            task.resume()
        } catch {
            print(error)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let dvc = segue.destination as! ItemViewController
        dvc.result = self.result
    }
    
}

