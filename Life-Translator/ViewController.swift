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
import GoogleMobileAds
import AVFoundation


class ViewController: UIViewController, ARSCNViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, GADInterstitialDelegate {
    
    @IBOutlet var fullView: UIView!
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
    var defaultSnap = "  Snap something! 📸"
    
    var analyzedObject = ""
    
    var firstLanguageTranslation = ""
    var secondLanguageTranslation = ""
    
    var xScale : CGFloat?
    var yScale : CGFloat?
    
    var interstitial: GADInterstitial!
    var counter = 0;
    var displayAds = true
    var fiveLaunch: Int!
    
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
        
        //Creating and loading the ad
        interstitial = createAndLoadInterstitial()
        
        //Launching app and camera module
        self.checkLaunchCorrect()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        //Get the token
        translator.getToken()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let defaults = UserDefaults.standard
        if let launchCounter = defaults.string(forKey: "launchCounter") {
            defaults.set(Int(launchCounter)! + 1, forKey: "launchCounter")
            fiveLaunch = Int(launchCounter)
        }
        else {
            let defaults = UserDefaults.standard
            defaults.set("0", forKey: "launchCounter")
            let alert = UIAlertController(title: "Tutorial",
                                          message: "Do you want to check out the tutorial to learn how to use the app?",
                                          preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Tutorial", style: UIAlertActionStyle.default, handler: { action in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "tuto") as! Tutorial
                self.present(vc, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        if let stringOne = defaults.string(forKey: "adDisplay") {
            if stringOne == "false"{
                displayAds = false;
            }
        }
    }
    
    /**
     Function checking if the access to the camera was given.
     If so, it will setup the camera environnement with the function setupAddAndCamera(),
     otherwise, it will ask for the camera access again.
     */
    func checkLaunchCorrect() {
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            self.setupAppAndCamera()
        } else {
            self.requestCameraAccess()
        }
    }
    
    /**
     Function setting up the camera environnement and the in-app purchase products.
     */
    @objc func setupAppAndCamera() {
        //Checking if the camera access is athorized
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
            
            //Configuring and launching the capture session
            DispatchQueue.main.async {
                self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession!)
                self.videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.videoPreviewLayer?.frame = self.fullView.bounds
                self.cameraView.layer.addSublayer(self.videoPreviewLayer!)
                self.captureSession?.startRunning()
            }
            
            //Setting up the in-app purchase products
            IAPHandler.shared.fetchAvailableProducts()
            IAPHandler.shared.purchaseStatusBlock = {[weak self] (type) in
                guard let strongSelf = self else{ return }
                if type == .purchased {
                    let alertView = UIAlertController(title: "", message: type.message(), preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                        
                    })
                    alertView.addAction(action)
                    strongSelf.present(alertView, animated: true, completion: nil)
                }
            }
        } else {
            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.setupAppAndCamera), userInfo: nil, repeats: false)
        }
    }
    
    /**
     Function requesting the camera access to the user.
     */
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
    
    /**
     Function creating and loading an interstitial ad
     
     - Returns: The intersitial ad created
     */
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: firstAdID)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    /**
     Function triggered when an interstitial ad is dismissed.
     A new interstitial ad is be loaded.
     */
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }
    
    /**
     Function initializing the different UI elements
     */
    func uiInitialization() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            flashButton.isHidden = true
        }
        focusRectangle.clipsToBounds = true
        translateButton.layer.cornerRadius = translateButton.bounds.size.width / 2
        translateButton.clipsToBounds = true
        translateButton.layer.borderWidth = 4
        translateButton.layer.borderColor = UIColor.white.cgColor
        cameraDesign.layer.cornerRadius = cameraDesign.bounds.size.width / 2
        cameraDesign.clipsToBounds = true
        
        objectText.layer.cornerRadius = 10
        objectText.layer.borderWidth = 0.5
        objectText.layer.borderColor = UIColor.gray.cgColor
        objectText.sizeToFit()
        
        pickerFromTextField.text = fromLanguage + "  →  " + toLanguage
        pickerFromTextField.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        pickerFromTextField.layer.borderWidth = 0.5
        pickerFromTextField.layer.cornerRadius = 10
        pickerFromTextField.layer.borderColor = UIColor.gray.cgColor
        
        let pickerFromView = UIPickerView()
        pickerFromView.delegate = self
        pickerFromTextField.inputView = pickerFromView
        
        focusRectangle.clipsToBounds = true
        focusRectangle.layer.borderWidth = 1
        focusRectangle.layer.borderColor = UIColor.white.cgColor
        
        flashScreen.alpha = 0.0
        view.addSubview(flashScreen)
    }
    
    /**
     Function needed to create a pickerView component (the language selection scroll in the app)
     
     - Returns: The number of fields of the pickerView component
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    /**
     Function needed to create a pickerView component
     
     - Returns the number of fields of one of the rows of the pickerView component
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerList[component].count
    }
    
    /**
     Function initializing my pickerView component
     */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        fromLanguage = pickerList[0][pickerView.selectedRow(inComponent: 0)]
        toLanguage = pickerList[2][pickerView.selectedRow(inComponent: 2)]
        objectText.text = defaultSnap
        pickerFromTextField.text = fromLanguage + "  →  " + toLanguage
        self.view.endEditing(true)
    }
    
    /**
     Function needed to create a pickerView component
     
     - Returns: the elements in the pickerView component depending on the row and the component given in parameter
     */
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerList[component][row]
    }
    
    /**
     Function called when clicking on the flash button.
     It changes the flash mode and the flash icon depending on the previous mode
     */
    @IBAction func flashAction(_ sender: Any) {
        if (flashButton.currentImage?.isEqual(UIImage(named: "automatic-flash-symbol")))! {
            flashButton.setImage(UIImage(named: "flash-off"), for: .normal)
            flashMode = .off
        } else if flashButton.currentImage == UIImage(named: "flash-off") {
            flashButton.setImage(UIImage(named: "flash-on-indicator"), for: .normal)
            flashMode = .on
        } else {
            flashButton.setImage(UIImage(named: "automatic-flash-symbol"), for: .normal)
            flashMode = .auto
        }
    }
    
    /**
     Function called when clicking on the camera button.
     It will display an on-screen flash animation before launching the translateButtonAction() function
     in order to anazlyze the image, before translating it into the chosen languages.
     */
    @IBAction func translateButtonComplement(_ sender: Any) {
        let notFound = "Couldn't find the corresponding object"
        //Checking that the application is not already analyzing an image or translating some text
        if objectText.text.range(of: fromLanguage) != nil ||
            objectText.text.range(of: defaultSnap) != nil ||
            objectText.text.range(of: notFound) != nil {
            
            objectText.text = "Analyzing..."
            
            //On-screen flash animation
            UIView.animate(withDuration: 0.2, animations: {
                self.flashScreen.alpha = 1.0
                self.flashScreen.alpha = 0.0
            })
            translateButtonAction()
        }
    }
    
    /**
     Function used to modify the bullsey size on the screen
     */
    @IBAction func modifyBullsey(_ sender: UIPinchGestureRecognizer) {
        self.focusRectangle.transform = CGAffineTransform(scaleX: sender.scale, y: sender.scale)
        if sender.scale >= self.xScale! {
            self.focusRectangle.transform = CGAffineTransform(scaleX: self.xScale!, y: self.yScale!)
        }
    }
    
    /**
     Function taking a picture of what's on screen and launching the image
     analyzing process.
     */
    func translateButtonAction() {
        //Checking if ads should be displayed
        let defaults = UserDefaults.standard
        if let stringOne = defaults.string(forKey: "adDisplay") {
            if stringOne == "false"{
                displayAds = false;
            }
        }
        
        // Get an instance of AVCapturePhotoSettings class
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        //Disabling the flaash on iPad
        if UIDevice.current.userInterfaceIdiom == .pad {
            photoSettings.flashMode = .off
        } else {
            photoSettings.flashMode = flashMode
        }
        // Call capturePhoto method by passing the photo settings and a
        // delegate implementing AVCapturePhotoCaptureDelegate
        self.capturePhotoOutput?.capturePhoto(with: photoSettings, delegate: self)
        
        //Checking if an ad should be displayed and display it if needed.
        if counter%7 == 0 && displayAds {
            if (fiveLaunch > 7 || (fiveLaunch < 7 && counter != 0)){
                if self.interstitial.isReady {
                    self.interstitial.present(fromRootViewController: self)
                } else {
                    print("Ad wasn't ready")
                }
            }
        }
        counter += 1;
    }
    
    /**
     Function getting the results of the picture analyze and setting the different text fields accordingly
     */
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
    
    /**
     Function getting the translation results and setting the different text fields accordingly
     */
    @objc func getTranslateResult(){
        let tempo = translator.sendTranslateResult(saver: 1)
        let tempoBis = translator.sendTranslateResult(saver: 2)
        
        if tempo == "Loading..." || tempo == "" || tempoBis == "Loading..." || tempoBis == "" {
            Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.getTranslateResult), userInfo: nil, repeats: false)
        }
        else{
            translator.resetTranslation()
            objectText.text = "  " + fromLanguage + "   " + tempo + "\n" + "  " + toLanguage + "   " + tempoBis
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
            let extractRect = CGRect.init(x: Int(self.focusRectangle.layer.frame.minY * ratioX),
                                          y: Int(self.focusRectangle.layer.frame.minX * ratioY),
                                          width: Int(self.focusRectangle.frame.width * ratioX),
                                          height: Int(self.focusRectangle.frame.height * ratioY))
            let croppedCGImage: CGImage = cgImage!.cropping(to: extractRect)!
            let uiImage = UIImage(cgImage: croppedCGImage)
            self.pictureManager.analyzePicture(image: uiImage)
            self.getAnalyzeResult()
            self.getTranslateResult()
        }
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
}
