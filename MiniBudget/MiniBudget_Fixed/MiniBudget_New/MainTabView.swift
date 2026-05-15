//
//  MainTabView.swift
//  MiniBudget_New
//
//  Created by Erandi Pathirana on 2026-04-26.

import SwiftUI
import UIKit

struct MainTabView: View {

    @State private var selectedTab: MBTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {

            Group {
                switch selectedTab {
                case .home:     DashboardView(selectedTab: $selectedTab)
                case .decision: decisionTab
                case .history:  HistoryView(selectedTab: $selectedTab)
                case .calendar: CalendarView(selectedTab: $selectedTab)
             
                case .rewards:  RewardsView(selectedTab: $selectedTab)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom tab bar
            customTabBar
        }
        .ignoresSafeArea(edges: .bottom)
        .background(AppTheme.background)
    }

    private var decisionTab: some View {
        NavigationStack {
            AddPurchaseView(selectedTab: $selectedTab)
        }
    }

    // Custom tab bar
    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(MBTab.allCases, id: \.self) { tab in
                tabBarButton(tab: tab)
            }
        }
        .frame(height: 60)
        .background(
            AppTheme.tabBarBG
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: -2)
        )
        .padding(.bottom, UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.bottom ?? 0)
    }

    // One tab button
    private func tabBarButton(tab: MBTab) -> some View {
        let isActive = selectedTab == tab

        return Button(action: { selectedTab = tab }) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: isActive ? .semibold : .regular))
                    .foregroundColor(isActive ? AppTheme.tabActive : AppTheme.tabInactive)

                Text(tab.label)
                    .font(.system(size: 10, weight: isActive ? .semibold : .regular))
                    .foregroundColor(isActive ? AppTheme.tabActive : AppTheme.tabInactive)

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
