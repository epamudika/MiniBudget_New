//
//  Untitled.swift
//  MiniBudget_New
//
//  Created by COBSCCOMP242P-051 on 2026-05-07.


import SwiftUI

struct MainTabView: View {

    // Currently active tab index.
    @State private var selectedTab: MainTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {

            
            Group {
                switch selectedTab {
                case .home:     DashboardView(selectedTab: $selectedTab)
                case .history:  HistoryView(selectedTab: $selectedTab)
                case .calendar: CalendarView(selectedTab: $selectedTab)
                case .rewards:  RewardsView(selectedTab: $selectedTab)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            //  Custom tab bar
            customTabBar
        }
        .ignoresSafeArea(edges: .bottom)
        .background(AppTheme.background)
    }

    // Custom tab bar
    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases, id: \.self) { tab in
                tabBarButton(tab: tab)
            }
        }
        .frame(height: 60)
        .background(
            AppTheme.tabBarBG
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: -2)
        )
        // Bottom safe-area padding so the bar sits above the home indicator
        .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0)
    }

    // One tab button
    private func tabBarButton(tab: MainTab) -> some View {
        let isActive = selectedTab == tab

        return Button(action: { selectedTab = tab }) {
            VStack(spacing: 4) {
                // Icon
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: isActive ? .semibold : .regular))
                    .foregroundColor(isActive ? AppTheme.tabActive : AppTheme.tabInactive)

                // Label
                Text(tab.label)
                    .font(.system(size: 10, weight: isActive ? .semibold : .regular))
                    .foregroundColor(isActive ? AppTheme.tabActive : AppTheme.tabInactive)

                // Active indicator dot
                Circle()
                    .fill(isActive ? AppTheme.tabActive : Color.clear)
                    .frame(width: 4, height: 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
    }
}

#Preview {
    MainTabView()
}
