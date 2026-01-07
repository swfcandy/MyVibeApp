import SwiftUI

enum Tab: Int, CaseIterable {
    case home
    case scan
    case routine
    case profile

    var icon: String {
        switch self {
        case .home: "house.fill"
        case .scan: "camera.fill"
        case .routine: "list.bullet.clipboard.fill"
        case .profile: "person.fill"
        }
    }

    var title: String {
        switch self {
        case .home: "Home"
        case .scan: "Scan"
        case .routine: "Routine"
        case .profile: "Profile"
        }
    }
}

struct BottomTabBar: View {
    @Binding var selectedTab: Tab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    private func tabButton(for tab: Tab) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 22, weight: .medium))
                    .symbolEffect(.bounce, value: selectedTab == tab)

                Text(tab.title)
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .foregroundStyle(selectedTab == tab ? Color.sageGreen : .white.opacity(0.6))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background {
                if selectedTab == tab {
                    Capsule()
                        .fill(Color.sageGreen.opacity(0.15))
                        .padding(.horizontal, 4)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack {
            Spacer()
            BottomTabBar(selectedTab: .constant(.scan))
        }
    }
}
