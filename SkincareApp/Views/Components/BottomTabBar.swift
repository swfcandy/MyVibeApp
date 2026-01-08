import SwiftUI

enum Tab: Int, CaseIterable {
    case home
    case scan
    case profile

    var icon: String {
        switch self {
        case .home: "house.fill"
        case .scan: "camera.fill"
        case .profile: "person.fill"
        }
    }

    var title: String {
        switch self {
        case .home: "Home"
        case .scan: "Scan"
        case .profile: "Profile"
        }
    }
}

struct BottomTabBar: View {
    @Binding var selectedTab: Tab
    var onScanTapped: (() -> Void)?

    static let charcoal = Color(red: 0.17, green: 0.17, blue: 0.18)
    static let pureBlack = Color.black

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                Button {
                    if tab == .scan && selectedTab == .scan {
                        onScanTapped?()
                    } else {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedTab = tab
                        }
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 24))
                            .symbolEffect(.bounce.down, value: selectedTab == tab)

                        Text(tab.title)
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundStyle(selectedTab == tab ? .white : .white.opacity(0.5))
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 8)
    }
}

#Preview {
    VStack {
        Spacer()
        BottomTabBar(selectedTab: .constant(.scan))
    }
    .background(Color.black)
}
