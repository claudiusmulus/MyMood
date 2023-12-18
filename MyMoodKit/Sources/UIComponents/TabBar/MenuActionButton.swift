//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-12-18.
//

import SwiftUI
import Models

struct MenuActionButton: View {
    
    @Binding var selection: Tab
    let backgroundColor: Color
    let borderColor: Color
    let firstAction: MenuAction
    let secondAction: MenuAction
    let onFirstAction: () -> Void
    let onSecondAction: () -> Void
    
    @State private var isExpanded: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            contentBackground()
                .onTapGesture {
                    self.onTap()
                }
            
            ShapeMorphingView()
                .background {
                    Rectangle()
                        .fill(backgroundColor)
                        .mask {
                            Canvas { ctx, size in
                                ctx.addFilter(.alphaThreshold(min: 0.5))
                                ctx.addFilter(.blur(radius: 10))
                                
                                ctx.drawLayer { ctx1 in
                                    for index in 0..<2 {
                                        if let resolvedShareButton = ctx.resolveSymbol(id: index) {
                                            ctx1.draw(resolvedShareButton, at: CGPoint(x: size.width / 2, y: size.height / 2))
                                        }
                                    }
                                }
                            } symbols: {
                                contentMenu(
                                    actionButtonSize: 60.0,
                                    backgroundColor: backgroundColor,
                                    borderColor: borderColor,
                                    fillColor: true,
                                    onFirstAction: onFirstAction,
                                    onSecondAction: onSecondAction
                                )
                            }
                            
                        }
                }
                .allowsHitTesting(false)
            
            contentMenu(
                actionButtonSize: 60.0,
                backgroundColor: backgroundColor,
                borderColor: borderColor,
                fillColor: false,
                onFirstAction: onFirstAction,
                onSecondAction: onSecondAction
            )

        }
        .onChange(of: selection) { oldValue, newValue in
            guard isExpanded else {
                return
            }
            self.onTap()
        }
    }
    
    @ViewBuilder
    private func contentBackground(fill: some ShapeStyle = .ultraThinMaterial) -> some View {
        Rectangle()
            .fill(fill)
            .opacity(0.9)
            .ignoresSafeArea(edges: .top)
            .padding(.bottom, 50)
            .opacity(isExpanded ? 1 : 0)
    }
    
    @ViewBuilder
    private func contentMenu(
        actionButtonSize: CGFloat,
        backgroundColor: Color,
        borderColor: Color,
        fillColor: Bool = true,
        onFirstAction: @escaping () -> Void,
        onSecondAction: @escaping () -> Void
    ) -> some View {
        Group {
            secondaryActionButtons(onFirstAction: onFirstAction, onSecondAction: onSecondAction)
                .foregroundStyle(fillColor ? backgroundColor : .clear)
            primaryActionButton(
                backgroundColor: backgroundColor,
                borderColor: borderColor,
                size: 60,
                showIcon: true
            )
            .foregroundStyle(backgroundColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
    
    @ViewBuilder
    private func primaryActionButton(
        backgroundColor: Color,
        borderColor: Color,
        size: CGFloat,
        showIcon: Bool
    ) -> some View {
        Image(systemName: "plus")
            .foregroundStyle(.white)
            .rotationEffect(isExpanded ? .degrees(45) : .degrees(0))
            .font(.title.bold())
            .opacity(showIcon ? 1 : 0)
            .scaleEffect(showIcon ? 1 : 0)
            .frame(width: size, height: size)
            .background {
                Circle()
                    .fill(backgroundColor)
                    .stroke(borderColor, lineWidth: 2)
                    .shadow(color: .black.opacity(0.4), radius: 5)
            }
            .tag(0)
            .zIndex(100)
            .onTapGesture {
                self.onTap()
            }
    }
    
    @ViewBuilder
    private func secondaryActionButtons(
        onFirstAction: @escaping () -> Void,
        onSecondAction: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 0) {
            secondaryActionButton(
                icon: "person",
                text: "Action1",
                showContent: isExpanded ? true : false,
                padding: EdgeInsets(top: 30, leading: 30, bottom: 0, trailing: 30),
                action: onFirstAction
            )
            
            emptyButton()
            
            secondaryActionButton(
                icon: "car",
                text: "Action2",
                showContent: isExpanded ? true : false,
                padding: EdgeInsets(top: 0, leading: 30, bottom: 30, trailing: 30),
                action: onSecondAction
            )
        }
        .fixedSize(horizontal: true, vertical: false)
        .font(.title)
        .foregroundStyle(.white)
        .background(
            RoundedRectangle(cornerRadius: 20)
        )
        .padding(.horizontal, 40)
        .scaleEffect(isExpanded ? 1 : 0)
        .offset(y: isExpanded ? -80 : 40)
        .tag(1)
    }
    
    @ViewBuilder
    private func secondaryActionButton(
        icon: String,
        text: String,
        showContent: Bool,
        padding: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0),
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.title2)
                Text(text)
                    .font(.title2)
            }
            .padding(padding)
            .frame(maxWidth: .infinity)
            .opacity(showContent ? 1 : 0)
        }
    }
    
    @ViewBuilder
    private func emptyButton(height: CGFloat = 30.0) -> some View {
        Button(action: {
        }, label: {
            Text("")
                .opacity(0)
                .frame(maxWidth: .infinity)
        })
        .frame(height: height)
    }
    
    private func onTap() {
        withAnimation(
            .interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.8)
        ) {
            isExpanded.toggle()
        }
    }
    
    struct ShapeMorphingView: View {
        var body: some View {
            Image(systemName: "person")
                .opacity(0)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    MenuActionButton(
        selection: .constant(.entryList),
        backgroundColor: .backgroundActionButton,
        borderColor: .borderActionButton,
        firstAction: .firstOptionMock,
        secondAction: .secondOptionMock,
        onFirstAction: {},
        onSecondAction: {}
    )
}
