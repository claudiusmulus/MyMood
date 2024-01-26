//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-12-18.
//

import SwiftUI
import Theme
import Models

public enum Tab: String, CaseIterable {
    case entryList = "Entries"
    case stats = "Stats"
    
    public var systemIcon: String {
        switch self {
        case .entryList:
            return "list.bullet"
        case .stats:
            return "chart.bar"
        }
    }
}

struct TabBarItem: View {
    
    let activeColor: Color
    let inactiveColor: Color
    let tab: Tab
    @Binding var activeTab: Tab
    
    var body: some View {
        Image(systemName: tab.systemIcon)
            .font(.title2)
            .foregroundStyle(activeTab == tab ? activeColor : inactiveColor)
            .frame(width: 50, height: 50)
            .frame(maxWidth: .infinity)
            .onTapGesture {
                activeTab = tab
            }
    }
}

public struct CustomTabView<TabContent: View>: View {

    @Binding var selection: Tab
    
    let firstAction: MenuAction
    let secondAction: MenuAction
    let onPrimaryAction: () -> Void
    let onSecondaryAction: () -> Void
    
    let content: (Tab) -> TabContent
    
    public init(
        selection: Binding<Tab>,
        firstAction: MenuAction,
        secondAction: MenuAction,
        onPrimaryAction: @escaping () -> Void,
        onSecondaryAction: @escaping () -> Void,
        @ViewBuilder content: @escaping (Tab) -> TabContent
    ) {
        self._selection = selection
        self.firstAction = firstAction
        self.secondAction = secondAction
        self.onPrimaryAction = onPrimaryAction
        self.onSecondaryAction = onSecondaryAction
        self.content = content
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            Color.tabBar.ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $selection) {
                    ForEach(Tab.allCases, id: \.rawValue) {
                        content($0)
                    }
                }
                EmptyItem()
            }
            
            CustomTabBar(
                activeColor: .blue,
                inactiveColor: .gray,
                backgroundColor: .tabBar,
                selection: $selection,
                firstAction: firstAction,
                secondAction: secondAction,
                onPrimaryAction: onPrimaryAction,
                onSecondaryAction: onSecondaryAction
            )
        }
    }
}

struct CustomTabBar: View {
    let activeColor: Color
    let inactiveColor: Color
    let backgroundColor: Color
    @Binding var selection: Tab
    let firstAction: MenuAction
    let secondAction: MenuAction
    let onPrimaryAction: () -> Void
    let onSecondaryAction: () -> Void
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            
            MenuActionButton(
                selection: $selection,
                backgroundColor: .backgroundActionButton,
                borderColor: .borderActionButton,
                firstAction: firstAction,
                secondAction: secondAction,
                onFirstAction: onPrimaryAction,
                onSecondAction: onSecondaryAction
            )
            
            HStack(alignment: .bottom, spacing: 0) {
                TabBarItem(
                    activeColor: activeColor,
                    inactiveColor: inactiveColor,
                    tab: .entryList,
                    activeTab: $selection
                )
                .background(backgroundColor)
                
                EmptyItem()
                
                TabBarItem(
                    activeColor: activeColor,
                    inactiveColor: inactiveColor,
                    tab: .stats,
                    activeTab: $selection
                )
                .background(backgroundColor)
            }
        }
    }
}

struct EmptyItem: View {
    var body: some View {
        Image(systemName: "person")
            .font(.title2)
            .frame(width: 50, height: 50)
            .frame(maxWidth: .infinity)
            .opacity(0)
    }
}

#Preview {
    CustomTabView(
        selection: .constant(.entryList),
        firstAction: .moodCheckin,
        secondAction: .secondOptionMock,
        onPrimaryAction: {
            print("Custom action 1")
        },
        onSecondaryAction: {
            print("Custom action 2")
        }
    ) {
        switch $0 {
        case .entryList:
            Text("Entry List")
                .tag(Tab.entryList)
                .toolbar(.hidden, for: .tabBar)
        case .stats:
            Text("Stats")
                .tag(Tab.stats)
                .toolbar(.hidden, for: .tabBar)
        }
    }
}
