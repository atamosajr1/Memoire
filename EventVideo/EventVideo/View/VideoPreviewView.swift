import UIKit
import AVFoundation

class VideoPreviewView: UIView {
    private var captureSession: AVCaptureSession?
    private var movieFileOutput: AVCaptureMovieFileOutput?
    private var videoDataOutput: AVCaptureVideoDataOutput?
    private var videoQueue = DispatchQueue(label: "videoQueue")
    private var ciContext: CIContext!
    private var currentFilter: CIFilter?
    private var assetWriter: AVAssetWriter?
    private var assetWriterInput: AVAssetWriterInput?
    private var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    private var isRecording = false
    private var recordingStartTime: CMTime?
    private var displayLayer: CALayer?
    let appConfig = AppConfig.shared

    private var previewLayer: AVCaptureVideoPreviewLayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCaptureSession()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCaptureSession()
    }

    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .high
        ciContext = CIContext()

        var types: [AVCaptureDevice.DeviceType] = [.builtInUltraWideCamera]
        if let settings = appConfig.settings {
            if settings.cameraZoom == "0.5x" {
                types = [.builtInUltraWideCamera]
            } else if settings.cameraZoom == "1x" {
                types = [.builtInWideAngleCamera]
            }
        }
        let videoDevice = AVCaptureDevice.DiscoverySession(
            deviceTypes: types,
            mediaType: .video,
            position: .front
        ).devices.first

        guard let videoDevice = videoDevice,
              let audioDevice = AVCaptureDevice.default(for: .audio) else {
            print("Failed to access front camera or microphone.")
            return
        }

        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            let audioInput = try AVCaptureDeviceInput(device: audioDevice)

            if let captureSession = captureSession {
                if captureSession.canAddInput(videoInput) {
                    captureSession.addInput(videoInput)
                }
                if captureSession.canAddInput(audioInput) {
                    captureSession.addInput(audioInput)
                }
            }
        } catch {
            print("Error configuring inputs: \(error)")
            return
        }

        movieFileOutput = AVCaptureMovieFileOutput()
        if let captureSession = captureSession,
           let movieFileOutput = movieFileOutput,
           captureSession.canAddOutput(movieFileOutput) {
            captureSession.addOutput(movieFileOutput)

            if let connection = movieFileOutput.connection(with: .video),
               connection.isVideoOrientationSupported {
                connection.videoOrientation = .landscapeRight
                connection.automaticallyAdjustsVideoMirroring = false
                connection.isVideoMirrored = false
            }

        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer?.videoGravity = .resizeAspectFill
        if let previewLayer = previewLayer {
            layer.addSublayer(previewLayer)

            if let connection = previewLayer.connection, connection.isVideoOrientationSupported {
                connection.videoOrientation = .landscapeRight
                connection.automaticallyAdjustsVideoMirroring = false
                connection.isVideoMirrored = true // Mirror front camera preview only
            }
        }
    }

    func startSession() {
        if let connection = movieFileOutput?.connection(with: .video),
           let device = (self.captureSession?.inputs.first as? AVCaptureDeviceInput)?.device {
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .landscapeRight
            }
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = false

            do {
                try device.lockForConfiguration()
                let desiredZoomFactor = 0.5
                let minZoom = device.minAvailableVideoZoomFactor
                let maxZoom = device.activeFormat.videoMaxZoomFactor
                let finalZoom = max(minZoom, min(desiredZoomFactor, maxZoom))
                device.videoZoomFactor = finalZoom
                device.unlockForConfiguration()
            } catch {
                print("Failed to set zoom: \(error)")
            }
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }

    func stopSession() {
        captureSession?.stopRunning()
    }

    func startRecording() {
        let tempDir = NSTemporaryDirectory()
        let tempName = UUID().uuidString
        let tempPath = (tempDir as NSString).appendingPathComponent("\(tempName).mov")
        let tempURL = URL(fileURLWithPath: tempPath)

        movieFileOutput?.startRecording(to: tempURL, recordingDelegate: self)
        isRecording = true
    }

    func stopRecording(completion: @escaping (URL?) -> Void) {
        guard isRecording else {
            completion(nil)
            return
        }

        isRecording = false
        movieFileOutput?.stopRecording()

        // `completion` is handled in delegate callback below
        self.recordingCompletion = completion
    }

    private var recordingCompletion: ((URL?) -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate

extension VideoPreviewView: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        if let error = error {
            print("Recording failed: \(error)")
            recordingCompletion?(nil)
        } else {
            print("Recording saved to: \(outputFileURL)")
            recordingCompletion?(outputFileURL)
        }
        recordingCompletion = nil
    }
}
