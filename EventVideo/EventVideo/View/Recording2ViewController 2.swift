import UIKit
import AVFoundation
import Photos

class Recording2ViewController: UIViewController {
    @IBOutlet weak var camPreview: UIView!
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
        startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoPreviewView.stopSession()
    }
    
    func startTimer() {
        var count = 3
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            count -= 1
            
            if count == 0 {
                self.stopTimer()
            }
        }
    }
    
    func stopTimer() {
        // Stop the timer
        timer?.invalidate()
        timer = nil
        
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
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Setup Capture Session
    func setupCaptureSession() {
        let session = AVCaptureSession()
        session.sessionPreset = .high // Use high-quality preset

        // Try to get the best available front camera
        var camera: AVCaptureDevice?

        if let ultraWideCamera = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .front) {
            camera = ultraWideCamera
            self.showAlert(title: "Info", message: "Ultra Wide Camera Used.")
            hasCamera = true
        } else if let wideAngleCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            camera = wideAngleCamera
            self.showAlert(title: "Info", message: "Wide Angle Camera Used.")
            hasCamera = true
        } else if let trueDepthCamera = AVCaptureDevice.default(.builtInTrueDepthCamera, for: .video, position: .front) {
            camera = trueDepthCamera
            self.showAlert(title: "Info", message: "True Depth Camera Used.")
            hasCamera = true
        } else if let defaultFrontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            camera = defaultFrontCamera
            self.showAlert(title: "Info", message: "Default Camera Used.")
            hasCamera = true
        }

        guard let selectedCamera = camera else {
            print("No available front camera found.")
            return
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
                self.previewLayer?.setAffineTransform(CGAffineTransform(scaleX: 0.5, y: 0.5))
                self.videoPreviewView.layer.addSublayer(self.previewLayer!)
                self.setupPreviewLayer()
                
                // Start session in background thread
                DispatchQueue.global(qos: .userInitiated).async {
                    self.videoPreviewView.startSession()
                }
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
    
    @IBAction func done(_ sender: UIButton) {
        videoPreviewView.stopRecording { [weak self] url in
            guard let self = self, let url = url else { return }
            self.saveVideoToGallery(localURL: url)
            self.saveVideoToiCloud(localURL: url)
        }
    }

    func applyHalfZoomToVideo(at inputURL: URL, completion: @escaping (URL?) -> Void) {
        let asset = AVAsset(url: inputURL)
        let composition = AVMutableComposition()

        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            print("No video track found")
            completion(nil)
            return
        }

        // Create a composition track
        guard let compositionTrack = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            completion(nil)
            return
        }

        do {
            try compositionTrack.insertTimeRange(
                CMTimeRange(start: .zero, duration: asset.duration),
                of: videoTrack,
                at: .zero
            )
        } catch {
            print("Failed to insert time range: \(error)")
            completion(nil)
            return
        }

        // Apply scale transform (0.5x)
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionTrack)

        // Center the scaled video in the frame
        let naturalSize = videoTrack.naturalSize
        let scale = CGAffineTransform(scaleX: 0.5, y: 0.5)
        let translate = CGAffineTransform(translationX: naturalSize.width * 0.25, y: naturalSize.height * 0.25)
        let finalTransform = scale.concatenating(translate)

        transformer.setTransform(finalTransform, at: .zero)

        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        instruction.layerInstructions = [transformer]

        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = naturalSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        videoComposition.instructions = [instruction]

        // Export the scaled video
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("scaledVideo.mov")
        try? FileManager.default.removeItem(at: outputURL)

        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            completion(nil)
            return
        }

        exportSession.videoComposition = videoComposition
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mov
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                if exportSession.status == .completed {
                    print("Scaled video exported to: \(outputURL)")
                    completion(outputURL)
                } else {
                    print("Failed to export scaled video: \(exportSession.error?.localizedDescription ?? "Unknown error")")
                    completion(nil)
                }
            }
        }
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
extension Recording2ViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording video: \(error)")
            return
        }
        print("Video saved to: \(outputFileURL)")
    }
}
