import AVFoundation
import SwiftUI

@Observable
@MainActor
final class CameraViewModel: NSObject {
    var isFrontCamera = false
    var capturedImage: UIImage?
    var permissionGranted = false
    var showResultCard = false
    var showCapturedImage = false

    // AVCaptureSession is thread-safe and manages its own synchronization
    nonisolated(unsafe) private let session = AVCaptureSession()
    nonisolated(unsafe) private var currentInput: AVCaptureDeviceInput?
    nonisolated(unsafe) private let photoOutput = AVCapturePhotoOutput()

    nonisolated var captureSession: AVCaptureSession {
        session
    }

    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionGranted = true
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                Task { @MainActor in
                    self?.permissionGranted = granted
                    if granted {
                        self?.setupSession()
                    }
                }
            }
        default:
            permissionGranted = false
        }
    }

    private func setupSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let camera = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: isFrontCamera ? .front : .back
        ) else { return }

        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(input) {
                session.addInput(input)
                currentInput = input
            }

            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
            }
        } catch {
            print("Camera setup error: \(error)")
        }

        session.commitConfiguration()
    }

    func startSession() {
        guard !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }

    func stopSession() {
        guard session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
        }
    }

    func flipCamera() {
        session.beginConfiguration()

        if let currentInput {
            session.removeInput(currentInput)
        }

        isFrontCamera.toggle()

        guard let newCamera = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: isFrontCamera ? .front : .back
        ) else {
            session.commitConfiguration()
            return
        }

        do {
            let newInput = try AVCaptureDeviceInput(device: newCamera)
            if session.canAddInput(newInput) {
                session.addInput(newInput)
                currentInput = newInput
            }
        } catch {
            print("Camera flip error: \(error)")
        }

        session.commitConfiguration()
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    fileprivate func handleCapturedImage(_ image: UIImage) {
        capturedImage = image
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }

        Task { @MainActor [weak self] in
            self?.handleCapturedImage(image)
        }
    }
}
