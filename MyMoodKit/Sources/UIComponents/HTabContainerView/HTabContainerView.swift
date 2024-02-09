//
//  SwiftUIView.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-17.
//

import SwiftUI

public struct HTabContainerView<TabItem: SegmentedItem, Content: View>: View {
  
  @Binding private var selectedTab: TabItem?
  @State private var tabProgress: CGFloat = 0
  
  let tabItems: [TabItem]
  let content: (TabItem) -> Content
  let shouldHideActionContent: () -> Bool
  
  public init(
    tabItems: [TabItem],
    selectedTab: Binding<TabItem?>,
    @ViewBuilder content: @escaping (TabItem) -> Content,
    shouldHideActionContent: @escaping () -> Bool
  ) {
    self._selectedTab = selectedTab
    self.tabItems = tabItems
    self.content = content
    self.shouldHideActionContent = shouldHideActionContent
  }
  
  public var body: some View {
    VStack {
      HSegmentedControl(
        items: tabItems, 
        selectedItem: $selectedTab,
        itemProgress: $tabProgress,
        foregroundColor: .white
      )
      .background {
        Capsule().stroke(.black, lineWidth: 2.0)
      }
      .padding(.horizontal)
      .opacity(shouldHideActionContent() ? 0 : 1)
      .offset(y: shouldHideActionContent() ? -200 : 0)
      
      GeometryReader {
        let size = $0.size
        
        ScrollView(.horizontal) {
          LazyHStack(spacing: 0) {
            ForEach(self.tabItems) {
              content($0)
                .id($0)
                .containerRelativeFrame(.horizontal)
            }
          }
          .scrollTargetLayout()
          .tabContainerOffsetX { value in
            let progress = -value / (CGFloat(self.tabItems.count - 1) * size.width)
            self.tabProgress = max(0, min(progress, 1))
          }
        }
        .scrollPosition(id: $selectedTab)
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.paging)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
  }
}

#Preview {
  HTabContainerView(
    tabItems: TestItem.allCases,
    selectedTab: .constant(.tab1)) {
      switch $0 {
        case .tab1:
          Text("Tab1")
        case .tab2:
          Text("Tab2")
        case .tab3:
          Text("Tab3")
      }
    } shouldHideActionContent: {
      false
    }

}
