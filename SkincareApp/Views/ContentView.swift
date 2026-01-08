import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .scan
    @State private var cameraViewModel = CameraViewModel()
    @State private var cardOffset: CGFloat = 0

    private let cardHeight: CGFloat = 400

    private var tabBarBackground: Color {
        selectedTab == .scan ? BottomTabBar.pureBlack.opacity(0.6) : BottomTabBar.charcoal
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content based on selected tab
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .scan:
                    CameraView(viewModel: cameraViewModel)
                case .profile:
                    ProfileView()
                }
            }
            .ignoresSafeArea()

            // Bottom tab bar with safe area
            VStack(spacing: 0) {
                BottomTabBar(selectedTab: $selectedTab) {
                    cameraViewModel.capturePhoto()
                }
            }
            .background(tabBarBackground)
            .ignoresSafeArea(edges: .bottom)

            // Result card overlay - on top of everything
            if cameraViewModel.showResultCard {
                resultCard
            }
        }
    }

    // MARK: - Result Card

    private var resultCard: some View {
        VStack {
            Spacer()

            VStack(spacing: 0) {
                // Centered drag handle
                HStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 36, height: 5)
                    Spacer()
                }
                .padding(.top, 12)

                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width, height: cardHeight)
            .background(
                UnevenRoundedRectangle(
                    topLeadingRadius: 24,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 24
                )
                .fill(Color.white)
            )
            .offset(y: cardOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.height > 0 {
                            cardOffset = value.translation.height
                        }
                    }
                    .onEnded { value in
                        if value.translation.height > 100 {
                            dismissCard()
                        } else {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                cardOffset = 0
                            }
                        }
                    }
            )
        }
        .ignoresSafeArea(edges: .bottom)
        .transition(.move(edge: .bottom))
    }

    private func dismissCard() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            cameraViewModel.showResultCard = false
            cameraViewModel.showCapturedImage = false
            cardOffset = 0
        }
    }
}

// MARK: - Placeholder Views

struct HomeView: View {
    private let standardPadding: CGFloat = 16
    private let largePadding: CGFloat = 24

    var body: some View {
        ZStack {
            Color.warmWhite

            VStack(spacing: largePadding) {
                Spacer()
                    .frame(height: 100)

                Text("Home")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.sageGreen)

                Text("Your skincare dashboard")
                    .font(.body)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding(standardPadding)
        }
    }
}

struct ProfileView: View {
    private let standardPadding: CGFloat = 16
    private let largePadding: CGFloat = 24

    var body: some View {
        ZStack {
            Color.warmWhite

            VStack(spacing: largePadding) {
                Spacer()
                    .frame(height: 100)

                Text("Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.sageGreen)

                Text("Your account settings")
                    .font(.body)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding(standardPadding)
        }
    }
}

#Preview {
    ContentView()
}
