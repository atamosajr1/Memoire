import UIKit
import AVFoundation
import Photos

class RecordingViewController: UIViewController {
    
    @IBOutlet var vwCountdown: UIView!
    @IBOutlet var vwRecord: UIView!
    @IBOutlet var lblCountdown: UILabel!
    @IBOutlet var lblNowRecording: UILabel!
    @IBOutlet var vwGradient: UIView!
    @IBOutlet var vwRecordGradient: UIView!
    @IBOutlet var imgRecordStatus: UIImageView!
    @IBOutlet var imgRetake: UIImageView!
    @IBOutlet var lblRetake: UITextField!
    @IBOutlet var imgNext: UIImageView!
    @IBOutlet var lblNext: UITextField!
    @IBOutlet var lblQuestion: UILabel!
    @IBOutlet weak var camPreview: UIView!
    @IBOutlet var lblGetReady: UILabel!
    @IBOutlet var lblDone: UILabel!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var btnDone: UIButton!
    @IBOutlet var btnGetReady: UIButton!
    let appConfig = AppConfig.shared
    var currentQuestionIndex = 0
    var hasCamera = false
    
    var timer: Timer?
    private var videoPreviewView: VideoPreviewView!
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                DispatchQueue.main.async {
                    self.setupCaptureSession()
                }
            } else {
                print("Camera access denied.")
            }
        }
        checkAndDeleteOldGalleryVideos()
        makeImageViewBlink(imgRecordStatus)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return .landscape
        }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let settings = appConfig.settings {
            vwRecordGradient.alpha = settings.recordingScreenGradient
            vwCountdown.backgroundColor = UIColor.fromRGBString(settings.recordingScreenBackgroundTheme)
            vwCountdown.isOpaque = false
            vwRecord.backgroundColor = UIColor.fromRGBString(settings.recordingScreenBackgroundTheme)
            if settings.questions.count > currentQuestionIndex {
                lblQuestion.text = settings.questions[currentQuestionIndex]
            }
            
            lblGetReady.text = settings.getReadyButtonTitle
            lblDone.text = settings.doneButtonTitle
            lblTitle.text = settings.recordingHeaderTitle
            lblGetReady.font = settings.getReadyButtonTitleFont
            lblDone.font = settings.doneButtonTitleFont
            lblTitle.font = settings.recordingHeaderTitleFont
            lblQuestion.font = settings.recordingQuestionsFont
            vwRecordGradient.backgroundColor = UIColor.fromRGBString(settings.overAllGradientColor)
            vwRecordGradient.alpha = settings.recordingScreenGradient
            vwGradient.backgroundColor = UIColor.fromRGBString(settings.overAllGradientColor)
            vwGradient.alpha = settings.recordingScreenGradient
            imgNext.tintColor = UIColor.fromRGBString(settings.themeColor)
            imgRetake.tintColor = UIColor.fromRGBString(settings.themeColor)
            lblNext.textColor = UIColor.fromRGBString(settings.themeColor)
            lblRetake.textColor = UIColor.fromRGBString(settings.themeColor)
            lblNext.font = settings.nextRetakeFont
            lblRetake.font = settings.nextRetakeFont
            lblGetReady.textColor = UIColor.fromRGBString(settings.overAllButtonTextColor)
            lblDone.textColor = UIColor.fromRGBString(settings.overAllButtonTextColor)
            
            var configMessage = UIButton.Configuration.filled()
            configMessage.baseBackgroundColor = UIColor.fromRGBString(settings.overAllButtonBackgroundColor)
            btnGetReady.configuration = configMessage
            btnGetReady.layer.cornerRadius = 40
            btnGetReady.clipsToBounds = true
            
            btnDone.configuration = configMessage
            btnDone.layer.cornerRadius = 40
            btnDone.clipsToBounds = true
        }
        startTimer()
    }
    
    func makeImageViewBlink(_ imageView: UIImageView, duration: TimeInterval = 0.5) {
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            options: [.repeat, .autoreverse], // Repeat and reverse animation
            animations: {
                imageView.alpha = 0.0 // Fade out the image
            },
            completion: nil // No need to handle completion for blinking
        )
    }
    
    func startTimer() {
        var count = 3
        lblCountdown.text = "\(count)" // Immediately show the initial countdown value
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            count -= 1
            self.lblCountdown.text = "\(count)"
            
            if count == 0 {
                self.lblCountdown.isHidden = true
                self.lblNowRecording.isHidden = false
                self.stopTimer()
            }
        }
    }
    
    func stopTimer() {
        // Stop the timer
        timer?.invalidate()
        timer = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            // Code to execute after 0.5 second
            showRecording()
        }
    }
    
    func showRecording() {
        vwCountdown.isHidden = true
        vwRecord.isHidden = false
        self.view.bringSubviewToFront(vwRecord)
        self.view.sendSubviewToBack(vwCountdown)
        
        // Start recording
        if hasCamera {
            videoPreviewView.startRecording()
        } else {
            let alert = UIAlertController(title: "Info",
                                              message: "No camera has been detected.",
                                              preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Show Alert
    func showAlert(title: String, message: String) {
        /*
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
         */
    }
    
    // MARK: - Setup Capture Session
    func setupCaptureSession() {
        let session = AVCaptureSession()
        session.sessionPreset = .high // Use high-quality preset
        
        // Try to get the best available front camera
        var camera: AVCaptureDevice?
        
        let ultraWideCamera = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .front)
        let wideAngleCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        
        let hasFrontUltraWide = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .front) != nil
        if hasFrontUltraWide {
            hasCamera = true
            camera = ultraWideCamera
        }
        if let settings = appConfig.settings {
            if settings.cameraZoom == "0.5x" {
                camera = ultraWideCamera
                hasCamera = true
            } else if settings.cameraZoom == "1x" {
                camera = wideAngleCamera
                hasCamera = true
            }
        }
        
        guard let selectedCamera = camera else {
            print("No available front camera found.")
            return
        }

        do {
                try selectedCamera.lockForConfiguration()
                // 🔴 WARNING: This value must be >= device.minAvailableVideoZoomFactor
            selectedCamera.videoZoomFactor = max(1.0, 0.5) // 0.5 is invalid for zoomFactor
            selectedCamera.unlockForConfiguration()
        } catch {
                print("Failed to configure zoom: \(error.localizedDescription)")
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: selectedCamera)
            if session.canAddInput(input) {
                session.addInput(input)
            }

            let output = AVCaptureMovieFileOutput()
            if session.canAddOutput(output) {
                session.addOutput(output)
            }

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.videoPreviewView = VideoPreviewView(frame: self.camPreview.bounds)
                self.camPreview.addSubview(self.videoPreviewView)
                self.previewLayer = AVCaptureVideoPreviewLayer(session: session)
                self.previewLayer?.videoGravity = .resizeAspectFill
                self.previewLayer?.frame = self.videoPreviewView.bounds
                self.videoPreviewView.layer.addSublayer(self.previewLayer!)
                self.setupPreviewLayer()
                
                // Start session in background thread
                DispatchQueue.global(qos: .userInitiated).async {
                    self.videoPreviewView.startSession()
                }
            }

            let maxFOV = CGFloat(selectedCamera.activeFormat.videoFieldOfView)
            do {
                try selectedCamera.lockForConfiguration()
                let minZoomFactor = selectedCamera.minAvailableVideoZoomFactor
                let maxZoomFactor = selectedCamera.activeFormat.videoMaxZoomFactor
                
                let desiredZoomFactor = 0.5
                let finalZoomFactor = max(minZoomFactor, min(desiredZoomFactor, maxZoomFactor))
                
                selectedCamera.videoZoomFactor = finalZoomFactor
                selectedCamera.unlockForConfiguration()
                
                print("Current zoom factor: \(finalZoomFactor)") // Para ma-debug
            } catch {
                print("Error configuring camera: \(error)")
            }

        } catch {
            print("Error setting up camera input: \(error)")
        }
    }
    
    func setupPreviewLayer() {
        if let connection = previewLayer?.connection {
            let orientation = UIDevice.current.orientation
            if connection.isVideoOrientationSupported {
                switch orientation {
                case .landscapeRight:
                    connection.videoOrientation = .landscapeLeft
                case .landscapeLeft:
                    connection.videoOrientation = .landscapeRight
                case .portrait:
                    connection.videoOrientation = .landscapeRight
                default:
                    connection.videoOrientation = .landscapeRight
                }
            }
        }
    }
    
    @IBAction func nextQuestion(_ sender: UIButton) {
        // Handle moving to the next question
        if let settings = appConfig.settings {
            if settings.questions.count > currentQuestionIndex {
                lblQuestion.text = settings.questions[currentQuestionIndex]
                currentQuestionIndex = currentQuestionIndex + 1
            } else {
                currentQuestionIndex = 0
                if settings.questions.count > currentQuestionIndex {
                    lblQuestion.text = settings.questions[currentQuestionIndex]
                }
            }
            
        }
    }
    
    @IBAction func retake(_ sender: UIButton) {
        vwCountdown.isHidden = false
        vwRecord.isHidden = true
        self.view.bringSubviewToFront(vwCountdown)
        self.view.sendSubviewToBack(vwRecord)
        lblCountdown.text = "3"
        lblCountdown.isHidden = false
        self.lblCountdown.isHidden = false
        self.lblNowRecording.isHidden = true
        currentQuestionIndex = 0
        
        // Stop the current recording
        videoPreviewView.stopRecording { [weak self] url in
            guard let self = self, let url = url else {
                print("No recording found to delete.")
                return
            }
            do {
                try FileManager.default.removeItem(at: url)
                print("Recording deleted: \(url)")
            } catch {
                print("Error deleting recording: \(error)")
            }
        }
        startTimer()
    }
    
    @IBAction func done(_ sender: UIButton) {
        // Stop recording and save the video
        
        videoPreviewView.stopRecording { [weak self] url in
            guard let self = self, let url = url else { return }
            self.saveVideoToGallery(localURL: url)
            self.saveVideoToiCloud(localURL: url)
        }
         
        performSegue(withIdentifier: "toThank", sender: nil)
    }

    // MARK: - Save Video to Gallery
    func saveVideoToGallery(localURL: URL) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                self.showAlert(title: "Error", message: "Photo Library access denied.")
                return
            }

            PHPhotoLibrary.shared().performChanges {
                let request = PHAssetCreationRequest.forAsset()
                request.addResource(with: .video, fileURL: localURL, options: nil)
                
                // Save filename to UserDefaults for tracking
                let fileName = localURL.lastPathComponent
                UserDefaults.standard.set(Date(), forKey: fileName)
            } completionHandler: { success, error in
                if success {
                    self.showAlert(title: "Success", message: "Video successfully saved to Photos.")
                } else {
                    self.showAlert(title: "Error", message: "Failed to save video: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }

    // MARK: - Save Video to iCloud Drive
    func saveVideoToiCloud(localURL: URL) {
        let fileName = localURL.lastPathComponent
        let containerId = "iCloud.com.eventVideo.eventVideo"
        
        guard let iCloudContainerURL = FileManager.default.url(forUbiquityContainerIdentifier: containerId)?.appendingPathComponent("Documents") else {
            print("iCloud container unavailable")
            return
        }
        
        let iCloudURL = iCloudContainerURL.appendingPathComponent(fileName)
        
        // Ensure the iCloud directory exists
        if !FileManager.default.fileExists(atPath: iCloudContainerURL.path, isDirectory: nil) {
            do {
                try FileManager.default.createDirectory(at: iCloudContainerURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating iCloud directory: \(error.localizedDescription)")
                return
            }
        }
        
        // Move the video to iCloud
        do {
            try FileManager.default.setUbiquitous(true, itemAt: localURL, destinationURL: iCloudURL)
            print("Video successfully saved to iCloud at: \(iCloudURL)")
            
            // Track the creation date for local cleanup
            let currentDate = Date()
            UserDefaults.standard.set(currentDate, forKey: fileName)
            
        } catch {
            print("Error saving video to iCloud: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Delete Old Local Videos
    func checkAndDeleteOldGalleryVideos() {
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date())
        let defaults = UserDefaults.standard
        var savedVideoNames = defaults.dictionaryRepresentation().keys // Fetch all saved video names

        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                print("Photo Library access denied")
                return
            }

            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
            
            let videos = PHAsset.fetchAssets(with: fetchOptions)
            var assetsToDelete: [PHAsset] = []

            videos.enumerateObjects { (asset, _, _) in
                if let creationDate = asset.creationDate, let oneMonthAgo = oneMonthAgo, creationDate < oneMonthAgo {
                    
                    // Extract filename from asset's local identifier
                    let assetFilename = asset.localIdentifier.components(separatedBy: "/").first ?? ""

                    // Delete only if the filename matches the ones saved by the app
                    if savedVideoNames.contains(assetFilename) {
                        assetsToDelete.append(asset)
                        defaults.removeObject(forKey: assetFilename) // Cleanup UserDefaults entry
                    }
                }
            }

            if !assetsToDelete.isEmpty {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.deleteAssets(assetsToDelete as NSFastEnumeration)
                }) { success, error in
                    if success {
                        print("Deleted \(assetsToDelete.count) old videos saved by the app")
                    } else {
                        print("Error deleting old videos: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            } else {
                print("No old videos found for deletion")
            }
        }
    }
    
    @objc private func orientationChanged() {
        if let connection = previewLayer?.connection {
            let orientation = UIDevice.current.orientation
            if connection.isVideoOrientationSupported {
                switch orientation {
                case .landscapeRight:
                    connection.videoOrientation = .landscapeLeft
                case .landscapeLeft:
                    connection.videoOrientation = .landscapeRight
                case .portrait:
                    connection.videoOrientation = .landscapeRight
                default:
                    connection.videoOrientation = .landscapeRight
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension RecordingViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording video: \(error)")
            return
        }
        print("Video saved to: \(outputFileURL)")
    }
}
