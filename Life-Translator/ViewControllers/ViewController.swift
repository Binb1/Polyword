//
//  ViewController.swift
//  Life-Translator
//
//  Created by Robin Champsaur on 13/06/2017.
//  Copyright © 2017 Robin Champsaur. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var translateButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var objectText: UITextView!
    @IBOutlet weak var pickerFromTextField: UITextField!
    @IBOutlet weak var focusRectangle: UIView!
    @IBOutlet weak var cameraDesign: UIButton!
    @IBOutlet var flashScreen: UIView!
    @IBOutlet var flashButton: UIButton!
    
    var pictureManager = PictureManager()
    var translator = Translator()
    
    var pickerList = [[ "🇫🇷", "🇬🇧", "🇪🇸", "🇩🇪",  "🇮🇹", "🇵🇱", "🇵🇹", "🇬🇷", "🇺🇸", "🇭🇹", "🇭🇷", "🇨🇿", "🇩🇰", "🇳🇱", "🇫🇮", "🇸🇪", "🇳🇴", "🇮🇱", "🇮🇳", "🇯🇵",
                        "🇰🇷", "🇨🇳", "🇹🇭", "🇻🇳", "🇮🇩", "🇷🇺", "🇷🇸", "🇹🇷",  "🇺🇦", "🇸🇰", "🇸🇮", "🇭🇺", "🇱🇹", "🇷🇴"],
                      ["  →  "],
                      [ "🇫🇷", "🇬🇧", "🇪🇸", "🇩🇪",  "🇮🇹", "🇵🇱", "🇵🇹", "🇬🇷", "🇺🇸", "🇭🇹", "🇭🇷", "🇨🇿", "🇩🇰", "🇳🇱", "🇫🇮", "🇸🇪", "🇳🇴", "🇮🇱", "🇮🇳", "🇯🇵",
                        "🇰🇷", "🇨🇳", "🇹🇭",  "🇻🇳", "🇮🇩", "🇷🇺", "🇷🇸", "🇹🇷",  "🇺🇦", "🇸🇰", "🇸🇮",  "🇭🇺", "🇱🇹", "🇷🇴"]]
    
    var fromLanguage = "🇬🇧"
    var toLanguage = "🇫🇷"
    let defaultSnap = "  Snap something! 📸"
    
    var analyzedObject = ""
    
    var firstLanguageTranslation = ""
    var secondLanguageTranslation = ""
    
    var xScale : CGFloat?
    var yScale : CGFloat?
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var capturePhotoOutput: AVCapturePhotoOutput?
    
    var flashMode:  AVCaptureDevice.FlashMode = .auto
    var cameraUpAndRunning = false
    var timerCameraLaunch: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configurating the UI elements
        uiInitialization()

        //Computing the scales
        self.xScale = self.focusRectangle.transform.a
        self.yScale = self.focusRectangle.transform.d
        
        //Launching app and camera module
        self.checkLaunchCorrect()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Get the token
        translator.getToken()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        defaults.set("0", forKey: "launchCounter")
        let alert = UIAlertController(title: "Tutorial",
                                      message: "Do you want to check out the tutorial to learn how to use the app?",
                                      preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Tutorial", style: UIAlertActionStyle.default, handler: { action in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "tuto") as! TutorialViewController
            self.present(vc, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func uiInitialization() {
        cameraView.layer.cornerRadius = 15
        cameraView.clipsToBounds = true
        
        focusRectangle.clipsToBounds = true
        
        //Translate button
        translateButton.layer.cornerRadius = translateButton.bounds.size.width / 2
        translateButton.clipsToBounds = true
        translateButton.layer.borderWidth = 4
        translateButton.layer.borderColor = UIColor.white.cgColor
        cameraDesign.layer.cornerRadius = cameraDesign.bounds.size.width / 2
        cameraDesign.clipsToBounds = true
        
        //ObjectText
        objectText.layer.cornerRadius = 10
        objectText.layer.borderWidth = 0.5
        objectText.layer.borderColor = UIColor.white.cgColor
        objectText.backgroundColor = UIColor.white
        objectText.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        if #available(iOS 13.0, *) {
            objectText.textColor = UIColor.systemGray6
        } else {
            objectText.textColor = UIColor.black
        }
        objectText.sizeToFit()
        
        //PickerTextField
        pickerFromTextField.text = fromLanguage + "  →  " + toLanguage
        pickerFromTextField.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        pickerFromTextField.layer.borderWidth = 0.5
        pickerFromTextField.layer.cornerRadius = 10
        pickerFromTextField.layer.borderColor = UIColor.gray.cgColor
        if #available(iOS 13.0, *) {
            pickerFromTextField.textColor = UIColor.systemGray6
        } else {
            pickerFromTextField.textColor = UIColor.black
        }
        
        //PickerFrom View
        let pickerFromView = UIPickerView()
        pickerFromView.delegate = self
        pickerFromTextField.inputView = pickerFromView
        
        //Focus rectangle
        focusRectangle.layer.borderWidth = 1
        focusRectangle.layer.borderColor = UIColor.white.cgColor
        
        flashScreen.alpha = 0.0
        view.addSubview(flashScreen)
    }
    
    func checkLaunchCorrect() {
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            self.setupAppAndCamera()
        } else {
            self.requestCameraAccess()
        }
    }
    
    @objc func setupAppAndCamera() {
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            cameraUpAndRunning = true
            let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice!)
                captureSession = AVCaptureSession()
                captureSession?.addInput(input)
                
                // Get an instance of ACCapturePhotoOutput class
                capturePhotoOutput = AVCapturePhotoOutput()
                capturePhotoOutput?.isHighResolutionCaptureEnabled = true
                // Set the output on the capture session
                captureSession?.addOutput(capturePhotoOutput!)
            } catch {
                print(error)
            }
            
            DispatchQueue.main.async { // Correct
                self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession!)
                self.videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.videoPreviewLayer?.frame = self.cameraView.bounds
                self.cameraView.layer.addSublayer(self.videoPreviewLayer!)
                self.captureSession?.startRunning()
            }
        } else {
            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.setupAppAndCamera), userInfo: nil, repeats: false)
        }
    }
    
    func requestCameraAccess() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
            if !granted {
                let message = "You won't be able to use this app without giving it an access to the camera.\n" +
                    "This app won't save any pictures you take or send them anywhere, the pictures" +
                "will only be used to analyze objects."
                let alert = UIAlertController(title: "Warning", message: message, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Activate the camera", style: UIAlertActionStyle.default, handler: { action in
                    UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
                   self.checkLaunchCorrect()
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.setupAppAndCamera()
            }
        })
    }
    
    @IBAction func flashAction(_ sender: Any) {
        if (flashButton.currentImage?.isEqual(UIImage(named: "automatic-flash-symbol")))! {
            print("FLASH OFF")
            flashButton.setImage(UIImage(named: "flash-off"), for: .normal)
            flashMode = .off
        } else if flashButton.currentImage == UIImage(named: "flash-off") {
            print("FLASH ON")
            flashButton.setImage(UIImage(named: "flash-on-indicator"), for: .normal)
            flashMode = .on
        } else {
            print("FLASH AUTO")
            flashButton.setImage(UIImage(named: "automatic-flash-symbol"), for: .normal)
            flashMode = .auto
        }
    }
    
    @IBAction func translateButtonComplement(_ sender: Any) {
        let notFound = "Couldn't find the corresponding object"
        if objectText.text.range(of: fromLanguage) != nil ||
            objectText.text.range(of: defaultSnap) != nil  ||
            objectText.text.range(of: notFound) != nil {
            
            objectText.text = "Analyzing..."
            
            UIView.animate(withDuration: 0.2, animations: {
                self.flashScreen.alpha = 1.0
                self.flashScreen.alpha = 0.0
            })
            translateButtonAction()
        }
    }
    
    func translateButtonAction() {
        
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        if UIDevice.current.userInterfaceIdiom == .pad {
            photoSettings.flashMode = .off
        } else {
            photoSettings.flashMode = flashMode
        }
        
        self.capturePhotoOutput?.capturePhoto(with: photoSettings, delegate: self)
        
    }
    
    @objc func getAnalyzeResult(){
        let tempo = pictureManager.sendAnalyzeResult()
        if tempo == "Couldn't find the corresponding object" {
            objectText.text = "Couldn't find the corresponding object"
        }
        else if tempo == "Analyzing..." {
            objectText.text = tempo
            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.getAnalyzeResult), userInfo: nil, repeats: false)
        }
        else{
            translator.relay(to: translator.convertFlag(flag: fromLanguage), word: tempo, number: 1)
            translator.relay(to: translator.convertFlag(flag: toLanguage), word: tempo, number: 2)
            analyzedObject = tempo
            objectText.text = "  " + fromLanguage + "   " + "Loading...\n" + "  " + toLanguage + "   " + "Loading... "
        }
    }
    
    @objc func getTranslateResult(){
        let tempo = translator.sendTranslateResult(saver: 1)
        let tempoBis = translator.sendTranslateResult(saver: 2)
        
        if tempo == "Loading..." || tempo == "" || tempoBis == "Loading..." || tempoBis == "" {
            Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.getTranslateResult), userInfo: nil, repeats: false)
        }
        else{
            translator.resetTranslation()
            print("A " + tempo)
            print("B " + tempoBis)
            objectText.text = "  " + fromLanguage + "   " + tempo + "\n" + "  " + toLanguage + "   " + tempoBis
        }
    }
    
    //Function to change the bullsey size
    @IBAction func modifyBullsey(_ sender: UIPinchGestureRecognizer) {
        self.focusRectangle.transform = CGAffineTransform(scaleX: sender.scale, y: sender.scale)
        if sender.scale >= self.xScale! {
            self.focusRectangle.transform = CGAffineTransform(scaleX: self.xScale!, y: self.yScale!)
        }
    }
}


extension ViewController : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ captureOutput: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
                     previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                     resolvedSettings: AVCaptureResolvedPhotoSettings,
                     bracketSettings: AVCaptureBracketedStillImageSettings?,
                     error: Error?) {
        // get captured image
        
        // Make sure we get some photo sample buffer
        guard error == nil,
            let photoSampleBuffer = photoSampleBuffer else {
                print("Error capturing photo: \(String(describing: error))")
                return;
        }
        // Convert photo same buffer to a jpeg image data by using // AVCapturePhotoOutput
        guard let imageData =
            AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) else {
                return
        }
        // Initialise a UIImage with our image data
        let capturedImage = UIImage.init(data: imageData , scale: 1.0)
        if let image = capturedImage {
            let cgImage = image.cgImage
            
            let ratioX = image.size.width / self.cameraView.bounds.size.width
            let ratioY = image.size.height / self.cameraView.bounds.size.height
            
            let extractRect = CGRect.init(x: Int((self.focusRectangle.layer.frame.minY * ratioY)),
                                          y: Int((self.focusRectangle.layer.frame.minX * ratioX)),
                                          width: Int(self.focusRectangle.frame.width * ratioX),
                                          height: Int(self.focusRectangle.frame.height * ratioY))
            
            let croppedCGImage: CGImage = cgImage!.cropping(to: extractRect)!
            let uiImage = UIImage(cgImage: croppedCGImage).rotate(radians: .pi/2) // Rotate 90 degrees
            
            if let uiImage = uiImage {
                self.pictureManager.analyzePicture(image: uiImage)
                self.getAnalyzeResult()
                self.getTranslateResult()
            }
        }
    }
}

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
          return 3
      }
      
      func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
          return pickerList[component].count
      }
      
      func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
          fromLanguage = pickerList[0][pickerView.selectedRow(inComponent: 0)]
          toLanguage = pickerList[2][pickerView.selectedRow(inComponent: 2)]
          objectText.text = defaultSnap
          pickerFromTextField.text = fromLanguage + "  →  " + toLanguage
          self.view.endEditing(true)
      }
      
      func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
          return pickerList[component][row]
      }
    
}

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in:UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
    
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        context.rotate(by: CGFloat(radians))
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
