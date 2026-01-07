import AVFoundation
import SwiftUI

struct CameraView: View {
    @Bindable var viewModel: CameraViewModel

    // Apple HIG: Standard spacing constants
    private let standardPadding: CGFloat = 16
    private let largePadding: CGFloat = 24
    private let gridUnit: CGFloat = 8

    // Layout constants
    private let dynamicIslandOffset: CGFloat = 60
    private let tabBarHeight: CGFloat = 58
    private let safeAreaBottom: CGFloat = 34
    private let captureButtonSize: CGFloat = 80

    // Animation state
    @State private var isPressing = false
    @State private var ringScale: CGFloat = 1.0
    @State private var ringOpacity: Double = 0.0

    var body: some View {
        GeometryReader { geometry in
            let buttonY = geometry.size.height - tabBarHeight - safeAreaBottom - 65

            ZStack {
                // Camera preview
                if viewModel.permissionGranted {
                    CameraPreviewView(session: viewModel.captureSession)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .ignoresSafeArea()
                        .blur(radius: viewModel.showResultCard ? 10 : 0)
                } else {
                    cameraPermissionView
                }

                // Captured image overlay
                if viewModel.showCapturedImage, let image = viewModel.capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .ignoresSafeArea()
                        .blur(radius: viewModel.showResultCard ? 10 : 0)
                }

                // Top controls - fixed position below dynamic island
                VStack {
                    HStack {
                        Spacer()
                        topControls
                    }
                    .padding(.top, dynamicIslandOffset)
                    .padding(.horizontal, standardPadding)
                    .opacity(viewModel.showResultCard ? 0 : 1)

                    Spacer()
                }

                // Capture button - absolute fixed position
                if viewModel.permissionGranted {
                    captureButton
                        .position(x: geometry.size.width / 2, y: buttonY)
                        .opacity(viewModel.showResultCard ? 0 : 1)
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

    // MARK: - Top Controls

    private var topControls: some View {
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
        }
    }

    // MARK: - Capture Button with Ring Pulse Animation

    private var captureButton: some View {
        ZStack {
            // Pulse ring (animates outward)
            Circle()
                .stroke(.white.opacity(ringOpacity), lineWidth: 3)
                .frame(width: 80, height: 80)
                .scaleEffect(ringScale)
                .animation(.easeOut(duration: 0.4), value: ringScale)

            // Outer ring
            Circle()
                .stroke(.white, lineWidth: 4)
                .frame(width: 80, height: 80)
                .scaleEffect(isPressing ? 0.92 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressing)

            // Inner filled circle
            Circle()
                .fill(.white)
                .frame(width: 64, height: 64)
                .scaleEffect(isPressing ? 0.88 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressing)
        }
        .frame(width: 150, height: 150)
        .contentShape(Circle())
        .onTapGesture {
            triggerHaptic()
            capturePhoto()
        }
        .onLongPressGesture(minimumDuration: 0.01, pressing: { pressing in
            isPressing = pressing
        }, perform: {})
    }

    // MARK: - Capture Flow

    private func capturePhoto() {
        // Trigger ring pulse animation
        withAnimation(.easeOut(duration: 0.4)) {
            ringScale = 1.8
            ringOpacity = 0.6
        }

        // Reset ring
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            ringScale = 1.0
            ringOpacity = 0.0
        }

        // Capture the photo
        viewModel.capturePhoto()

        // Show captured image
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            viewModel.showCapturedImage = true
        }

        // Show result card after 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                viewModel.showResultCard = true
            }
        }
    }

    private func triggerHaptic() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }

    // MARK: - Permission View

    private var cameraPermissionView: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: largePadding) {
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
                    .padding(.horizontal, largePadding * 2)

                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Open Settings")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, largePadding * 1.5)
                        .padding(.vertical, standardPadding)
                        .background(Color.sageGreen)
                        .clipShape(Capsule())
                }
                .padding(.top, standardPadding)
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
