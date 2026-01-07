import AVFoundation
import SwiftUI

struct CameraView: View {
    @Bindable var viewModel: CameraViewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if viewModel.permissionGranted {
                    CameraPreviewView(session: viewModel.captureSession)
                        .ignoresSafeArea()
                } else {
                    cameraPermissionView
                }

                // Top controls overlay
                VStack {
                    HStack {
                        Spacer()

                        Button {
                            viewModel.flipCamera()
                        } label: {
                            Image(systemName: "camera.rotate")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundStyle(.white)
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 60)
                    }

                    Spacer()
                }
            }
        }
        .onAppear {
            viewModel.checkPermissions()
            viewModel.startSession()
        }
        .onDisappear {
            viewModel.stopSession()
        }
    }

    private var cameraPermissionView: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Color.sageGreen)

                Text("Camera Access Required")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)

                Text("Please enable camera access in Settings to analyze your skin.")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Open Settings")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(Color.sageGreen)
                        .clipShape(Capsule())
                }
                .padding(.top, 10)
            }
        }
    }
}

// MARK: - Camera Preview UIViewRepresentable

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {}
}

final class CameraPreviewUIView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}

#Preview {
    CameraView(viewModel: CameraViewModel())
}
