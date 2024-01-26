//
//  SwiftUIView.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-17.
//

import SwiftUI

public struct HSegmentedControl<Item: SegmentedItem>: View {
  
  let items: [Item]
  @Binding private var selectedItem: Item?
  @Binding private var itemProgress: CGFloat
  let foregroundColor: Color
  
  public init(
    items: [Item],
    selectedItem: Binding<Item?>,
    itemProgress: Binding<CGFloat>,
    foregroundColor: Color
  ) {
    self.items = items
    self._selectedItem = selectedItem
    self._itemProgress = itemProgress
    self.foregroundColor = foregroundColor
  }
  
  public var body: some View {
    HStack(spacing: 0) {
      ForEach(items) { item in
        HStack(spacing: 10) {
          Image(systemName: item.iconSystemName)
          
          Text(item.title)
            .font(.callout)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .contentShape(.capsule)
        .onTapGesture {
          withAnimation(.snappy) {
            selectedItem = item
          }
        }
      }
    }
    .segmentedControlMask(itemProgress: self.itemProgress)
    .foregroundStyle(self.foregroundColor)
    .background {
      GeometryReader {
        let size = $0.size
        let capsuleWidth = size.width / CGFloat(items.count)
        Capsule()
          .fill(.black)
          .frame(width: capsuleWidth)
          .offset(x: itemProgress * (size.width - capsuleWidth))
      }
    }
  }
}

extension View {
  
  @ViewBuilder
  func segmentedControlMask(itemProgress: CGFloat, itemsCount: Int = 3) -> some View {
    ZStack {
      self.foregroundStyle(.black)
      
      self
        .symbolVariant(.fill)
        .mask {
          GeometryReader {
            let size = $0.size
            let capsuleWidth = size.width / CGFloat(itemsCount)
            Capsule()
              .frame(width: capsuleWidth)
              .offset(x: itemProgress * (size.width - capsuleWidth))
          }
        }
      
    }
    
  }
}

public protocol SegmentedItem: Identifiable, Hashable {
  var iconSystemName: String { get }
  var title: String { get }
}

enum TestItem: String, SegmentedItem, CaseIterable {
  case tab1 = "Tab1"
  case tab2 = "Tab2"
  case tab3 = "Tab3"
  
  var title: String {
    self.rawValue
  }
  
  var id: String {
    self.rawValue
  }
  
  var iconSystemName: String {
    switch self {
      case .tab1:
        return "person"
      case .tab2:
        return "trash"
      case .tab3:
        return "gear"
    }
  }
}

#Preview {
  HSegmentedControl(
    items: TestItem.allCases,
    selectedItem: .constant(.tab1),
    itemProgress: .constant(0),
    foregroundColor: .white
  )
  .background {
    Capsule().stroke(.black, lineWidth: 2.0)
  }
}
