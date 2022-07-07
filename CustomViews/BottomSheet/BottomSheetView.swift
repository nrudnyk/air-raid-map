//
//  BottomSheetView.swift
//  air-raid-map (iOS)
//
//  Created by Nazar Rudnyk on 18.05.2022.
//

import SwiftUI

struct BottomSheetView<hContent: View, mContent: View>: View {
    let widthFraction = UIDevice.current.userInterfaceIdiom == .pad
        ? 1.0 / 3 * 2
        : 1.0 / 7 * 4
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    @Binding fileprivate var bottomSheetPosition: BottomSheetPosition
    @State fileprivate var translation: CGFloat = .zero
    
    fileprivate let options: [BottomSheet.Options]
    fileprivate let headerContent: hContent?
    fileprivate let mainContent: mContent
    
    fileprivate let allCases = BottomSheetPosition.allCases.sorted(by: { $0.rawValue < $1.rawValue })
    
    fileprivate var isBottomPosition: Bool {
        return self.bottomSheetPosition == .bottom
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Drag indicator
                Button(action: self.switchPositionIndicator, label: {
                    Capsule()
                        .fill(Color(UIColor.tertiaryLabel))
                        .frame(width: 36, height: 5)
                        .padding(.top, 5)
                        .padding(.bottom, 7)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    self.translation = value.translation.height
                                    self.endEditing()
                                }
                                .onEnded { value in
                                    let height: CGFloat = value.translation.height / geometry.size.height
                                    self.switchPosition(with: height)
                                }
                        )
                })
                
                // Header
                if self.headerContent != nil {
                    HStack(alignment: .top, spacing: 0) {
                        if let headerContent = self.headerContent {
                            headerContent
                        }
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture(perform: self.switchPositionIndicator)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                self.translation = value.translation.height
                                self.endEditing()
                            }
                            .onEnded { value in
                                let height: CGFloat = value.translation.height / geometry.size.height
                                self.switchPosition(with: height)
                            }
                    )
                    .padding(.horizontal)
                    .padding(.bottom, self.headerContentPadding(geometry: geometry))
                }
                
                // Content
                Group {
                    if !self.isBottomPosition {
                        self.mainContent
                            .transition(.move(edge: .bottom))
                            .padding(.bottom, geometry.safeAreaInsets.bottom)
                    } else {
                        Color.clear
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .edgesIgnoringSafeArea(.bottom)
            .background(
                EffectView(effect: self.options.backgroundBlurEffect)
                    .cornerRadius(self.options.cornerRadius, corners: [.topRight, .topLeft])
                    .edgesIgnoringSafeArea(.bottom)
                    .shadow(color: self.options.shadowColor, radius: self.options.shadowRadius, x: self.options.shadowX, y: self.options.shadowY)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                self.translation = value.translation.height
                                self.endEditing()
                            }
                            .onEnded { value in
                                let height: CGFloat = value.translation.height / geometry.size.height
                                self.switchPosition(with: height)
                            }
                    )
            )
            .padding(padding(with: geometry))
            .frame(width: geometry.size.width, height: self.frameHeightValue(geometry: geometry), alignment: .top)
            .offset(y: self.offsetYValue(geometry: geometry))
            .transition(.move(edge: .bottom))
        }
        .animation(self.options.animation, value: self.bottomSheetPosition)
        .animation(self.options.animation, value: self.translation)
        .animation(self.options.animation, value: self.options)
    }
    
    fileprivate func headerContentPadding(geometry: GeometryProxy) -> CGFloat {
        return self.isBottomPosition ? geometry.safeAreaInsets.bottom + 25 : 0
    }
    
    fileprivate func frameHeightValue(geometry: GeometryProxy) -> Double {
        return min(max((geometry.size.height * self.bottomSheetPosition.rawValue) - self.translation, 0), geometry.size.height * 1.05)
    }

    fileprivate func padding(with geometry: GeometryProxy) -> EdgeInsets {
        let result: EdgeInsets
        if horizontalSizeClass == .compact && verticalSizeClass == .regular {
            result = .zero
        } else {
            result = EdgeInsets(
                top: 0,
                leading: UIDevice.current.userInterfaceIdiom == .pad ? geometry.safeAreaInsets.bottom : 0,
                bottom: 0,
                trailing: geometry.size.width * widthFraction
            )
        }

        return result
    }
    
    fileprivate func offsetYValue(geometry: GeometryProxy) -> Double {
        if self.isBottomPosition {
            return max(geometry.size.height - (geometry.size.height * self.bottomSheetPosition.rawValue) + self.translation + geometry.safeAreaInsets.bottom, geometry.size.height * -0.05)
        } else {
            return max(geometry.size.height - (geometry.size.height * self.bottomSheetPosition.rawValue) + self.translation, geometry.size.height * -0.05)
        }
    }
    
    fileprivate func switchPositionIndicator() -> Void {
        self.bottomSheetPosition = self.bottomSheetPosition != .middle ? .middle : .bottom
        self.endEditing()
    }
    
    fileprivate func switchPosition(with height: CGFloat) -> Void {
        if let currentIndex = self.allCases.firstIndex(where: { $0 == self.bottomSheetPosition }) {
            if height <= -0.1 && height > -0.3 {
                if currentIndex < self.allCases.endIndex - 1 {
                    self.bottomSheetPosition = self.allCases[currentIndex + 1]
                }
            } else if height <= -0.3 {
                self.bottomSheetPosition = .top
            } else if height >= 0.1 && height < 0.3 {
                if currentIndex > self.allCases.startIndex && (self.allCases[currentIndex - 1].rawValue != 0)  {
                    self.bottomSheetPosition = self.allCases[currentIndex - 1]
                }
            } else if height >= 0.3 {
                self.bottomSheetPosition = .bottom
            }
        }
        
        self.translation = 0
        self.endEditing()
    }
    
    fileprivate func endEditing() -> Void {
        UIApplication.shared.endEditing()
    }
    
    init(
        bottomSheetPosition: Binding<BottomSheetPosition>,
        options: [BottomSheet.Options] = [],
        @ViewBuilder headerContent: () -> hContent?,
        @ViewBuilder mainContent: () -> mContent)
    {
        self._bottomSheetPosition = bottomSheetPosition
        self.options = options
        self.headerContent = headerContent()
        self.mainContent = mainContent()
    }
}

struct BottomSheetView_Previews: PreviewProvider {
    static var bottomSheetView: some View {
        BottomSheetView(
            bottomSheetPosition: .constant(.middle),
            headerContent: {
                VStack {
                    Text("Header Text")
                        .font(.headline)
                    Text("Subtitle")
                        .font(.subheadline)
                }
            },
            mainContent: {
                Color.red.ignoresSafeArea()
            }
        )
    }

    static var previews: some View {
        ZStack(alignment: .topTrailing) {
            if #available(iOS 15.0, *) {
                bottomSheetView
                    .previewInterfaceOrientation(.landscapeRight)
            } else {
                bottomSheetView
            }
        }
        .preferredColorScheme(.dark)
        .environment(\.sizeCategory, .accessibilityExtraExtraLarge)
        .environment(\.locale, .init(identifier: "uk"))
    }
}
