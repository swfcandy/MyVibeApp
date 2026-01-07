import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .scan
    @State private var cameraViewModel = CameraViewModel()

    var body: some View {
        ZStack {
            // Main content based on selected tab
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .scan:
                    CameraView(viewModel: cameraViewModel)
                case .routine:
                    RoutineView()
                case .profile:
                    ProfileView()
                }
            }

            // Bottom tab bar overlay
            VStack {
                Spacer()
                BottomTabBar(selectedTab: $selectedTab)
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}

// MARK: - Placeholder Views

struct HomeView: View {
    var body: some View {
        ZStack {
            Color.warmWhite.ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()
                    .frame(height: 60)

                Text("Home")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.sageGreen)

                Text("Your skincare dashboard")
                    .font(.body)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding(20)
        }
    }
}

struct RoutineView: View {
    var body: some View {
        ZStack {
            Color.warmWhite.ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()
                    .frame(height: 60)

                Text("Routine")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.sageGreen)

                Text("Your daily skincare routine")
                    .font(.body)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding(20)
        }
    }
}

struct ProfileView: View {
    var body: some View {
        ZStack {
            Color.warmWhite.ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()
                    .frame(height: 60)

                Text("Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.sageGreen)

                Text("Your account settings")
                    .font(.body)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding(20)
        }
    }
}

#Preview {
    ContentView()
}
