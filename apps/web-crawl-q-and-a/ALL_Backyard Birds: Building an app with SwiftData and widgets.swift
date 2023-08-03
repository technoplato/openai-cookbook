/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A entities and extensions to define the style.
*/

import SwiftUI

// MARK: - Colors

public struct Colors {
    public static let premiumBirdFoodColor = Color("Premium Bird Food", bundle: .module)
}

public extension ShapeStyle where Self == Color {
    static var premiumBirdFoodColor: Color { Colors.premiumBirdFoodColor }
}

// MARK: - Styles

public struct VibrantShapeStyle: ShapeStyle {
    var opacity: Double
    
    public init(opacity: Double) {
        self.opacity = opacity
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        let startingStyle = {
            switch environment.colorScheme {
            case .light: return Color.black
            case .dark: return Color.white
            @unknown default: return Color.black
            }
        }()
        return startingStyle.opacity(opacity).vibrantlyBlended
    }
}

public extension ShapeStyle where Self == VibrantShapeStyle {
    static func vibrant(opacity: Double) -> Self {
        .init(opacity: opacity)
    }
}

// MARK: - Style Modifiers

public struct VibrantlyBlendedShapeStyle: ShapeStyle {
    var base: AnyShapeStyle
    
    public init(base: AnyShapeStyle) {
        self.base = base
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        switch environment.colorScheme {
        case .light:
            return base.blendMode(.plusDarker)
        case .dark:
            return base.blendMode(.plusLighter)
        @unknown default:
            fatalError()
        }
    }
}

public extension ShapeStyle {
    var vibrantlyBlended: VibrantlyBlendedShapeStyle {
        .init(base: AnyShapeStyle(self))
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The plant view.
*/

import SwiftUI
import BackyardBirdsData
import LayeredArtworkLibrary

public struct PlantView: View {
    var plant: Plant
    var index: Int
    
    public init(plant: Plant, index: Int) {
        self.plant = plant
        self.index = index
    }
    
    public var body: some View {
        ComposedPlant(plant: plant)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .colorMultiply(.init(white: 1.0 - (0.1 * Double(2 - index))))
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Convenience extensions to Core Graphics entities.
*/

import CoreGraphics

extension CGRect {
    var min: CGPoint {
        CGPoint(x: minX, y: minX)
    }
    
    var mid: CGPoint {
        CGPoint(x: midX, y: midY)
    }
    
    var max: CGPoint {
        CGPoint(x: maxX, y: maxY)
    }
}

extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}


// swift-tools-version: 5.9

/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The package that defines the app's user interface elements.
*/

import PackageDescription

let package = Package(
    name: "BackyardBirdsUI",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "BackyardBirdsUI",
            type: .dynamic,
            targets: ["BackyardBirdsUI"]
        )
    ],
    dependencies: [
        .package(path: "../BackyardBirdsData"),
        .package(path: "../LayeredArtworkLibrary")
    ],
    targets: [
        .target(
            name: "BackyardBirdsUI",
            dependencies: [
                .product(name: "BackyardBirdsData", package: "BackyardBirdsData", condition: nil),
                .product(name: "LayeredArtworkLibrary", package: "LayeredArtworkLibrary", condition: nil)
            ],
            path: "."
        )
    ]
)


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A convenience extension to `ImageResource`.
*/

import SwiftUI

public extension ImageResource {
    static let fountainImage = ImageResource(name: "fountain", bundle: .module)
    static let fountainFillImage = ImageResource(name: "fountain.fill", bundle: .module)
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The recent visitors view.
*/

import SwiftUI
import BackyardBirdsData
import LayeredArtworkLibrary

public struct RecentBackyardVisitorsView: View {
    var backyard: Backyard
    
    @State private var seeAll = false
    
    public init(backyard: Backyard) {
        self.backyard = backyard
    }
    
    var events: [BackyardVisitorEvent] {
        if !seeAll {
            return Array(backyard.historicalEvents.prefix(6))
        } else {
            return backyard.historicalEvents
        }
    }
    
    public var body: some View {
        ForEach(events) { event in
            HStack {
                BirdIcon(bird: event.bird)
                    .frame(width: 60, height: 60)
                
                VStack(alignment: .leading) {
                    Text(event.bird.speciesName)
                    Text(event.endDate, style: .relative)
                        .foregroundStyle(.secondary)
                        .font(.callout)
                }
                Spacer()
            }
            #if !os(watchOS)
            .padding()
            .background(.fill.tertiary, in: .rect(cornerRadius: 20))
            #endif
        }
        
        Button {
            withAnimation {
                seeAll.toggle()
            }
        } label: {
            if seeAll {
                Text("Show Less", bundle: .module)
            } else {
                Text("Show More", bundle: .module)
            }
        }
        #if !os(watchOS)
        .buttonStyle(.bordered)
        .buttonBorderShape(.capsule)
        #endif
    }
}

#Preview {
    ModelPreview { backyard in
        RecentBackyardVisitorsView(backyard: backyard)
    }
}

private extension ScrollTransitionPhase {
    var scaleAnchor: UnitPoint {
        switch self {
            case .topLeading: .top
            case .bottomTrailing: .bottom
            default: .center
        }
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The bird icon view.
*/

import SwiftUI
import BackyardBirdsData
import LayeredArtworkLibrary

/// A view that displays the bird.
public struct BirdIcon: View {
    /// The bird data.
    var bird: Bird
  
    /// The insets around the bird icon.
    var insets: Double
    
    /// The direction the bird should face.
    ///
    /// Valid values are `.leading` and `.trailing`.
    var direction: HorizontalEdge

    /// Create an instance of `BirdView`.
    /// - Parameters:
    ///   - bird: The bird data.
    ///   - insets: The insets around the bird icon. If `nil`, the system's default insets apply.
    ///   - direction: The direction the bird should face. Valid values are `.leading` and `.trailing`.
    public init(bird: Bird, insets: Double? = nil, direction: HorizontalEdge = .leading) {
        self.bird = bird
        self.insets = insets ?? 6
        self.direction = direction
    }
    
    /// Create the bird icon view.
    ///
    /// The bird icon view is a tailored version of the ``ComposedBird`` view.
    public var body: some View {
        ComposedBird(bird: bird, direction: direction)
            .padding(insets)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                BackyardSkyView(timeInterval: bird.backgroundTimeInterval)
                    .opacity(0.8)
                    .clipShape(.containerRelative)
            }
            .background(.fill.tertiary)
            .overlay {
                ContainerRelativeShape().strokeBorder(.tertiary)
            }
            .containerShape(.circle)
            .compositingGroup()
    }
}

#Preview {
    ModelPreview { bird in
        BirdIcon(bird: bird)
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The supply gauge.
*/

import SwiftUI
import BackyardBirdsData

public struct BackyardSupplyGauge: View {
    var backyard: Backyard
    var supplies: BackyardSupplies
    
    @Environment(\.layoutDirection) private var originalLayoutDirection
    
    public init(backyard: Backyard, supplies: BackyardSupplies) {
        self.backyard = backyard
        self.supplies = supplies
    }
    
    public var body: some View {
        Gauge(value: remainingDuration, in: 0...supplies.totalDuration) {
            gaugeLabel
                .environment(\.layoutDirection, originalLayoutDirection)
        }
        .gaugeStyle(.accessoryCircularCapacity)
        .tint(gaugeTint)
        .environment(\.layoutDirection, originalLayoutDirection.opposite)
    }
    
    @ViewBuilder
    var gaugeLabel: some View {
        switch supplies {
        case .food:
            backyard.birdFood.image
                .scaledToFit()
                .padding(-4)
                .transition(.scale(scale: 0.5).combined(with: .opacity))
                .id(backyard.birdFood.id)
        case .water:
            Image(systemName: "drop.fill")
                .foregroundStyle(.linearGradient(colors: [.mint, .cyan], startPoint: .top, endPoint: .bottom))
                .imageScale(.small)
        }
    }
    
    var gaugeTint: AnyShapeStyle {
        switch supplies {
        case .food:
            AnyShapeStyle(Gradient(colors: [.orange, .pink]))
        case .water:
            AnyShapeStyle(Gradient(colors: [.cyan, .blue]))
        }
    }
    
    var remainingDuration: TimeInterval {
        max(Date.now.distance(to: backyard.expectedEmptyDate(for: supplies)), 0)
    }
}

private extension LayoutDirection {
    var opposite: LayoutDirection {
        self == .leftToRight ? .rightToLeft : .leftToRight
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The backyard list.
*/

import SwiftUI
import SwiftData
import StoreKit
import BackyardBirdsData

public struct BackyardList: View {
    @Query(sort: [.init(\.creationDate)])
    private var backyards: [Backyard]
    
    @Environment(\.passIDs.group) private var passGroupID
    let isSubscribed: Bool
    let onOfferSelection: () -> Void
    let backyardLimit: Int
    
    @State private var offerWasDismissed = false
    @State private var showingNewBackyardForm = false
    
    public init(isSubscribed: Bool, backyardLimit: Int?, onOfferSelection: @escaping () -> Void) {
        self.isSubscribed = isSubscribed
        self.backyardLimit = backyardLimit ?? .max
        self.onOfferSelection = onOfferSelection
    }
    
    private var shouldShowOfferCard: Bool {
        !isSubscribed && !offerWasDismissed
    }
    
    public var body: some View {
        List {
            if shouldShowOfferCard {
                Button {
                    onOfferSelection()
                } label: {
                    BackyardBirdsPassOfferCard()
                }
                .swipeActions {
                    Button(action: {
                        offerWasDismissed = true
                    }, label: {
                        Label("Dismiss", systemImage: "xmark")
                    })
                }
                .animation(.easeInOut, value: offerWasDismissed)
            }
            ForEach(backyards) { backyard in
                NavigationLink(value: backyard.id) {
                    BackyardViewport(backyard: backyard)
                        .overlay(alignment: .topLeading) {
                            Text(backyard.name)
                                .font(.callout)
                                .scenePadding(.horizontal)
                                .padding(.vertical, 8)
                                .foregroundStyle(Color.primary.shadow(.drop(color: .black.opacity(0.25), radius: 4, y: 1)))
                        }
                }
                .buttonStyle(.borderless)
                .listRowInsets(EdgeInsets())
                .containerShape(.rect(cornerRadius: 10))
            }
        }
        #if os(watchOS)
        .listStyle(.carousel)
        #endif
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The backyard viewport.
*/

import SwiftUI
import BackyardBirdsData
import LayeredArtworkLibrary

struct BirdAnimation {
    var offset: CGSize = .zero
    var scale: Double = 1
    var rotation: Angle = .zero
    var flip: Bool = false
}

public struct BackyardViewport: View {
    var backyard: Backyard
    
    @State private var birdAnimation = BirdAnimation()
    
    public init(backyard: Backyard) {
        self.backyard = backyard
    }
    
    struct PlantPlacement: Hashable, Identifiable {
        var id: Self { self }
        var leading: Bool
        var index: Int
    }
    
    var leadingPlantPlacements: [PlantPlacement] {
        backyard.leadingPlants.indices.map {
            PlantPlacement(leading: true, index: $0)
        }
    }
    
    var trailingPlantPlacements: [PlantPlacement] {
        backyard.trailingPlants.indices.map {
            PlantPlacement(leading: false, index: $0)
        }
    }
    
    var bird: Bird? {
        backyard.currentVisitorEvent?.bird
    }
    
    public var body: some View {
        BackyardViewportLayout(birdNaturalScale: bird?.species.naturalScale ?? 1) {
            HStack {
                SilhouetteArtwork(variant: backyard.leadingSilhouetteVariant)
                    .colorMultiply(backyard.colorData.silhouette.color)
                    .scaleEffect(x: -1)
                
                Spacer()
                
                SilhouetteArtwork(variant: backyard.trailingSilhouetteVariant)
                    .colorMultiply(backyard.colorData.silhouette.color)
            }
            .backyardViewportContent(.silhouette)
            
            FloorArtwork(variant: backyard.floorVariant)
                .backyardViewportContent(.floor)
            
            ForEach(leadingPlantPlacements) { placement in
                PlantView(plant: backyard.leadingPlants[placement.index], index: placement.index)
                    .backyardViewportContent(.plant(.leading))
            }
            
            FountainArtwork(variant: backyard.fountainVariant)
                .backyardViewportContent(.fountain)
                .zIndex(5)
            
            if let bird {
                ComposedBird(bird: bird)
                    .backyardViewportContent(.bird)
                    .rotationEffect(birdAnimation.rotation)
                    .scaleEffect(birdAnimation.scale)
                    .scaleEffect(x: birdAnimation.flip ? -1 : 1)
                    .offset(birdAnimation.offset)
                    .zIndex(6)
            }
            
            ForEach(trailingPlantPlacements) { placement in
                PlantView(plant: backyard.trailingPlants[placement.index], index: placement.index)
                    .backyardViewportContent(.plant(.trailing))
            }
        }
        .flipsForRightToLeftLayoutDirection(true)
        .colorMultiply(backyard.colorData.atmosphereTint.color)
        .background {
            BackyardSkyView(timeInterval: backyard.timeIntervalOffset)
        }
        .overlay {
            ContainerRelativeShape()
                .strokeBorder(.separator, lineWidth: 0.5)
        }
        .clipShape(.containerRelative)
        .compositingGroup()
        .task {
            guard backyard.needsToPresentVisitor else { return }
            Task {
                birdAnimation = .init(offset: CGSize(width: 500, height: -100), scale: 0.1, rotation: .degrees(15))
                try await Task.sleep(for: .seconds(0.25))
                withAnimation(.spring(duration: 2, bounce: 0.25)) {
                    birdAnimation = .init(offset: CGSize(width: 50, height: -10), scale: 1.5, rotation: .degrees(-25))
                }
                try await Task.sleep(for: .seconds(2))
                withAnimation(.spring(duration: 2, bounce: 0.5)) {
                    birdAnimation = .init(offset: CGSize(width: -100, height: 0), scale: 1.2, rotation: .degrees(0))
                }
                try await Task.sleep(for: .seconds(2))
                withAnimation(.spring(duration: 0.25, bounce: 0)) {
                    birdAnimation.flip = true
                }
                try await Task.sleep(for: .seconds(0.1))
                withAnimation(.spring(duration: 2, bounce: 0.5)) {
                    birdAnimation = .init(offset: CGSize(width: 40, height: -10), scale: 0.9, rotation: .degrees(4), flip: true)
                }
                try await Task.sleep(for: .seconds(2))
                withAnimation(.spring(duration: 0.25, bounce: 0)) {
                    birdAnimation.flip = false
                }
                try await Task.sleep(for: .seconds(0.1))
                withAnimation(.spring(duration: 2, bounce: 0.5)) {
                    birdAnimation = .init(offset: CGSize(width: 10, height: 0), scale: 1, rotation: .degrees(0))
                }
            }
        }
    }
}

private struct BackyardViewportContentModifier: ViewModifier {
    var value: BackyardViewportContent
    
    func body(content: Content) -> some View {
        content.layoutValue(key: BackyardViewportContentKey.self, value: value)
    }
}

fileprivate extension View {
    func backyardViewportContent(_ value: BackyardViewportContent) -> some View {
        modifier(BackyardViewportContentModifier(value: value))
    }
}

fileprivate extension GeometryProxy {
    func parallaxOffsetInScrollView(_ length: Double = 20) -> Double {
        // Ensure we're inside a scroll view
        guard let scrollHeight = bounds(of: .scrollView)?.height else {
            return 0
        }
        let centerY = frame(in: .scrollView).midY
        let percent = ((centerY / scrollHeight) - 0.5) * 2
        return percent * -length
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The sky view.
*/

import SwiftUI
import BackyardBirdsData

public struct BackyardSkyView: View {
    var timeInterval: TimeInterval
    
    public init(timeInterval: TimeInterval = 60 * 60 * 12) {
        self.timeInterval = timeInterval
    }
        
    var colorData: BackyardTimeOfDayColorData {
        BackyardTimeOfDayColorData.colorData(timeInterval: timeInterval)
    }
        
    public var body: some View {
        LinearGradient(
            colors: [
                colorData.skyGradientStart.color,
                colorData.skyGradientEnd.color
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The backyard viewport's layout.
*/

import SwiftUI

enum BackyardViewportContent: Hashable {
    case silhouette
    case horizon(HorizontalEdge)
    case floor
    case plant(HorizontalEdge)
    case fountain
    case bird
}

struct BackyardViewportContentKey: LayoutValueKey {
    static var defaultValue: BackyardViewportContent = .fountain
}

struct BackyardViewportLayout: Layout {
    var birdNaturalScale: Double = 1
    
    struct LayoutResult {
        var width: Double
        var height: Double {
            if width <= 0 {
                return 0
            } else if width < 150 {
                return 50
            } else if width < 300 {
                return 120
            } else if width < 600 {
                return 180
            } else {
                return 240
            }
        }
        
        var size: CGSize {
            CGSize(width: width, height: height)
        }
        
        var birdAssetSize: Double {
            let desiredSize = height * 0.45
            return min(max(desiredSize, 70), 120)
        }
        
        var fountainAssetSize: Double {
            birdAssetSize * 2
        }
        
        var plantAssetSize: Double {
            birdAssetSize * 1.5
        }
        
        var birdBounds: CGRect {
            let topPadding = birdAssetSize * 0.3
            return CGRect(x: (width * 0.5) - (birdAssetSize * 0.5), y: topPadding, width: birdAssetSize, height: birdAssetSize)
        }
        
        var fountainY: Double {
            birdBounds.maxY + fountainAssetSize * 0.66
        }
        
        var groundPlaneY: Double {
            birdBounds.maxY + fountainAssetSize * 0.45
        }
        
        var horizonY: Double {
            groundPlaneY - (height * 0.4)
        }
        
        var fountainBounds: CGRect {
            CGRect(x: width * 0.5 - (fountainAssetSize * 0.5), y: fountainY - fountainAssetSize, width: fountainAssetSize, height: fountainAssetSize)
        }
        
        func plantBounds(leading: Bool, index: Int, totalCount: Int) -> CGRect {
            guard totalCount > 0 else {
                return .zero
            }
            let sideItemsDistance = fountainAssetSize * 0.5
            let spacing = plantAssetSize * 0.35
            let itemOffset = 0.0
                + sideItemsDistance
                + (Double(index) * spacing)
            let depthY = Double(1 - index) * height * -0.12
            let plantsYOffset = plantAssetSize * -0.06
            let xPos = (width * 0.5) - (plantAssetSize * 0.5) + (itemOffset * (leading ? -1 : 1))
            return CGRect(
                x: xPos,
                y: groundPlaneY - (plantAssetSize * 2) + depthY + plantsYOffset,
                width: plantAssetSize,
                height: plantAssetSize * 2
            )
        }
        
        var silhouetteBounds: CGRect {
            let assetHeight = fountainAssetSize * 0.5
            let minimumWidth = fountainAssetSize * 2
            let assetWidth = max(width, minimumWidth)
            return CGRect(x: (width - assetWidth) * 0.5, y: horizonY - (assetHeight * 0.95), width: assetWidth, height: assetHeight)
        }
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let result = LayoutResult(width: proposal.width ?? 0)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let result = LayoutResult(width: proposal.width ?? 0)
        
        var categorizedSubviews: [BackyardViewportContent: [LayoutSubview]] = [:]
        subviews.forEach {
            let content = $0[BackyardViewportContentKey.self]
            categorizedSubviews[content, default: []].append($0)
        }
        
        let silhouetteBounds = result.silhouetteBounds
        for subview in categorizedSubviews[.silhouette, default: []] {
            subview.place(at: bounds.origin + silhouetteBounds.origin, anchor: .topLeading, proposal: ProposedViewSize(silhouetteBounds.size))
        }
        
        for subview in categorizedSubviews[.floor, default: []] {
            subview.place(at: bounds.origin + CGPoint(x: 0, y: result.horizonY), anchor: .topLeading,
                          proposal: ProposedViewSize(width: result.width, height: result.height - result.horizonY))
        }
        
        for (isLeading, sideSubviews) in [(true, categorizedSubviews[.plant(.leading), default: []]),
                                          (false, categorizedSubviews[.plant(.trailing), default: []])] {
            for (index, subview) in zip(sideSubviews.indices, sideSubviews) {
                let subviewBounds = result.plantBounds(leading: isLeading, index: index, totalCount: sideSubviews.count)
                subview.place(at: bounds.origin + subviewBounds.origin, anchor: .topLeading, proposal: ProposedViewSize(subviewBounds.size))
            }
        }
        
        for subview in categorizedSubviews[.fountain, default: []] {
            subview.place(at: bounds.origin + result.fountainBounds.origin, anchor: .topLeading,
                          proposal: ProposedViewSize(result.fountainBounds.size))
        }
        
        var birdBounds = result.birdBounds
        let birdDelta = result.birdBounds.width * (1 - birdNaturalScale)
        birdBounds.origin.x += birdDelta * 0.5
        birdBounds.origin.y += birdDelta * 0.84
        birdBounds.size.width -= birdDelta
        birdBounds.size.height -= birdDelta
        for subview in categorizedSubviews[.bird, default: []] {
            subview.place(at: bounds.origin + birdBounds.origin, anchor: .topLeading, proposal: ProposedViewSize(birdBounds.size))
        }
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The Backyard Birds Pass offer card view.
*/

import SwiftUI
import SwiftData
import BackyardBirdsData
import LayeredArtworkLibrary

struct BackyardBirdsPassOfferCard: View {
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Text("Backyard Birds Pass")
                BirdDecoration()
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private let tagValue = BirdTag.premiumGoldenHummingbird.rawValue

struct BirdDecoration: View {
    @Query(filter: #Predicate { $0.tag == tagValue })
    private var birds: [Bird]

    var body: some View {
        if let bird = birds.first {
            ComposedBird(bird: bird, direction: .leading)
                .frame(width: 50, height: 50)
        }
    }
    
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An environment key to indicate a preference for tab navigation.
*/

import SwiftUI

struct PrefersTabNavigationEnvironmentKey: EnvironmentKey {
    static var defaultValue: Bool = false
}

extension EnvironmentValues {
    var prefersTabNavigation: Bool {
        get { self[PrefersTabNavigationEnvironmentKey.self] }
        set { self[PrefersTabNavigationEnvironmentKey.self] = newValue }
    }
}

#if canImport(UIKit)
extension PrefersTabNavigationEnvironmentKey: UITraitBridgedEnvironmentKey {
    static func read(from traitCollection: UITraitCollection) -> Bool {
        return traitCollection.userInterfaceIdiom == .phone
    }
    
    static func write(to mutableTraits: inout UIMutableTraits, value: Bool) {
        // Do not write
    }
}
#endif


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The entry point for Backyard Birds.
*/

import SwiftUI
import SwiftData
import BackyardBirdsData

@main
struct BackyardBirdsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .backyardBirdsShop()
                .backyardBirdsDataContainer()
        }
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The view that holds the app's visual content.
*/

import SwiftUI
import SwiftData
import BackyardBirdsData
import LayeredArtworkLibrary

struct ContentView: View {
    @State private var selection: AppScreen? = .backyards
    @Environment(\.prefersTabNavigation) private var prefersTabNavigation
    
    var body: some View {
        if prefersTabNavigation {
            AppTabView(selection: $selection)
        } else {
            NavigationSplitView {
                AppSidebarList(selection: $selection)
            } detail: {
                AppDetailColumn(screen: selection)
            }
        }
    }
}

#Preview {
    ContentView()
        .backyardBirdsDataContainer(inMemory: true)
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The plants navigation stack.
*/

import SwiftUI
import SwiftData
import BackyardBirdsData

struct PlantsNavigationStack: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), alignment: .top)], spacing: 20) {
                    PlantsSearchResults(searchText: $searchText)
                }
            }
            .searchable(text: $searchText)
            .searchSuggestions {
                if searchText.isEmpty {
                    PlantsSearchSuggestions()
                }
            }
            .contentMargins(20, for: .scrollContent)
            .navigationTitle("Plants")
        }
    }
}

#Preview {
    PlantsNavigationStack()
        .backyardBirdsDataContainer(inMemory: true)
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The plant search suggestions.
*/

import SwiftUI
import SwiftData
import BackyardBirdsData

struct PlantsSearchSuggestions: View {
    @Query private var plants: [Plant]
    
    var speciesNames: [String] {
        Set(plants.map(\.speciesName)).sorted()
    }
    
    var body: some View {
        ForEach(speciesNames, id: \.self) { speciesName in
            Text("**\(speciesName)**")
                .searchCompletion(speciesName)
        }
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The plant summary row.
*/

import SwiftUI
import SwiftData
import BackyardBirdsUI
import BackyardBirdsData
import LayeredArtworkLibrary

struct PlantSummaryRow: View {
    var plant: Plant
    
    var body: some View {
        VStack {
            ComposedPlant(plant: plant)
                .padding(4)
                .padding(.bottom, -20)
                .clipShape(.circle)
                .background(.fill.tertiary, in: .circle)
                .padding(.horizontal, 10)
            
            VStack {
                Text(plant.speciesName)
                    .font(.callout)
            }
            .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    ModelPreview { plant in
        PlantSummaryRow(plant: plant)
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The plant search results.
*/

import SwiftUI
import SwiftData
import BackyardBirdsData

struct PlantsSearchResults: View {
    @Binding var searchText: String
    @Query private var plants: [Plant]
    
    init(searchText: Binding<String>) {
        _searchText = searchText
        _plants = Query(sort: \.creationDate)
    }
    
    var body: some View {
        if $searchText.wrappedValue.isEmpty {
            ForEach(plants) { plant in
                PlantSummaryRow(plant: plant)
            }
        } else {
            ForEach(plants.filter {
                $0.speciesName.contains($searchText.wrappedValue)
            }, content: {
                PlantSummaryRow(plant: $0)
            })
        }
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The environment key that defines the preferred navigation style.
*/

import SwiftUI

struct PrefersTabNavigationEnvironmentKey: EnvironmentKey {
    static var defaultValue: Bool = false
}

extension EnvironmentValues {
    var prefersTabNavigation: Bool {
        get { self[PrefersTabNavigationEnvironmentKey.self] }
        set { self[PrefersTabNavigationEnvironmentKey.self] = newValue }
    }
}

#if os(iOS)
extension PrefersTabNavigationEnvironmentKey: UITraitBridgedEnvironmentKey {
    static func read(from traitCollection: UITraitCollection) -> Bool {
        return traitCollection.userInterfaceIdiom == .phone || traitCollection.userInterfaceIdiom == .tv
    }
    
    static func write(to mutableTraits: inout UIMutableTraits, value: Bool) {
        // Do not write.
    }
}
#endif


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Metrics for use in the store.
*/

import SwiftUI

struct BirdFoodStoreMetrics {
    let card: Card
    let cardActionButton: CardActionButton
    let food: Food
    
    struct Food {
        let imageHeight: CGFloat
        let imagePadding: CGFloat
        let imageQuantityBadgeFont: Font
        let imageWidth: CGFloat
        let nameFont: Font
        let summaryFont: Font
        
        #if os(watchOS)
        static let food = BirdFoodStoreMetrics.Food(
            imageHeight: 55,
            imagePadding: 2.5,
            imageQuantityBadgeFont: .system(size: 12),
            imageWidth: 55,
            nameFont: .caption.weight(.semibold),
            summaryFont: .system(size: 10)
        )
        #else
        static let food = BirdFoodStoreMetrics.Food(
            imageHeight: 100,
            imagePadding: 10,
            imageQuantityBadgeFont: .body,
            imageWidth: 100,
            nameFont: .title3.weight(.semibold),
            summaryFont: .callout
        )
        #endif
    }
    
    struct Card {
        let badgeQuantityMinWidth: CGFloat
        let controlSize: ControlSize
        let horizontalPadding: CGFloat
        let verticalPadding: CGFloat
        let verticalSpacing: CGFloat
        
        #if os(watchOS)
        static let card = BirdFoodStoreMetrics.Card(
            badgeQuantityMinWidth: 18,
            controlSize: .mini,
            horizontalPadding: 10,
            verticalPadding: 10,
            verticalSpacing: 5
        )
        #else
        static let card = BirdFoodStoreMetrics.Card(
            badgeQuantityMinWidth: 25,
            controlSize: .large,
            horizontalPadding: 20,
            verticalPadding: 40,
            verticalSpacing: 24
        )
        #endif
    }
    
    struct CardActionButton {
        let backgroundInset: CGFloat
        let horizontalSpacing: CGFloat
        let minWidth: CGFloat
        
        #if os(watchOS)
        static let cardActionButton = BirdFoodStoreMetrics.CardActionButton(
            backgroundInset: -2,
            horizontalSpacing: 5,
            minWidth: 15
        )
        #else
        static let cardActionButton = BirdFoodStoreMetrics.CardActionButton(
            backgroundInset: -3,
            horizontalSpacing: 10,
            minWidth: 20
        )
        #endif
    }
    
    static let birdFoodStore = BirdFoodStoreMetrics(
        card: BirdFoodStoreMetrics.Card.card,
        cardActionButton: BirdFoodStoreMetrics.CardActionButton.cardActionButton,
        food: BirdFoodStoreMetrics.Food.food
    )
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The bird food icon.
*/

import SwiftUI
import SwiftData
import StoreKit

import BackyardBirdsData

struct BirdFoodProductIcon: View {
    var birdFood: BirdFood
    var quantity: Int
        
    var body: some View {
        image
            .scaledToFit()
            .padding(birdFood.id == "Nectar" && quantity > 1 ? 18 : 10)
            .background(.fill.tertiary, in: .circle)
    }
    
    var image: Image {
        switch quantity {
        case 1: birdFood.image
        default: birdFood.alternateImage
        }
    }
    
}

#Preview {
    ModelPreview { birdFood in
        BirdFoodProductIcon(birdFood: birdFood, quantity: 1)
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The enumeration that defines the Backyard Birds Pass' status.
*/

import StoreKit
import SwiftUI
import SwiftData
import OSLog

import BackyardBirdsData

private let logger = Logger(subsystem: "BackyardBirds", category: "BackyardBirdsPassStatus")

enum PassStatus: Comparable, Hashable {
    case notSubscribed
    case individual
    case family
    case premium
    
    init(levelOfService: Int) {
        self = switch levelOfService {
        case 1: .premium
        case 2: .family
        case 3: .individual
        default: .notSubscribed
        }
    }
    
    init?(productID: Product.ID, ids: PassIdentifiers) {
        switch productID {
        case ids.individual: self = .individual
        case ids.family: self = .family
        case ids.premium: self = .premium
        default: return nil
        }
    }
    
    var backyardLimit: Int? {
        switch self {
        case .notSubscribed: 8
        default: nil
        }
    }
        
}

extension PassStatus: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .notSubscribed: String(localized: "Not Subscribed")
        case .individual: String(localized: "Individual")
        case .family: String(localized: "Family")
        case .premium: String(localized: "Premium")
        }
    }
    
}

extension EnvironmentValues {
    
    private enum PassStatusEnvironmentKey: EnvironmentKey {
        static var defaultValue: PassStatus = .notSubscribed
    }
    
    private enum PassStatusLoadingEnvironmentKey: EnvironmentKey {
        static var defaultValue = true
    }
    
    fileprivate(set) var passStatus: PassStatus {
        get { self[PassStatusEnvironmentKey.self] }
        set { self[PassStatusEnvironmentKey.self] = newValue }
    }
    
    fileprivate(set) var passStatusIsLoading: Bool {
        get { self[PassStatusLoadingEnvironmentKey.self] }
        set { self[PassStatusLoadingEnvironmentKey.self] = newValue }
    }

}

private struct PassStatusTaskModifier: ViewModifier {
    @Environment(\.passIDs) private var passIDs
    @Environment(\.modelContext) private var modelContext

    @State private var state: EntitlementTaskState<PassStatus> = .loading
    
    private var isLoading: Bool {
        if case .loading = state { true } else { false }
    }
    
    func body(content: Content) -> some View {
        content
            .subscriptionStatusTask(for: passIDs.group) { state in
                logger.info("Checking subscription status")
                self.state = await state.map { statuses in
                    await BirdBrain.shared.status(
                        for: statuses,
                        ids: passIDs
                    )
                }
                // After getting the status, send it to the `DataGeneration`
                // model so the app can generate events with or without early access
                // birds as appropriate.
                switch self.state {
                case .failure(let error):
                    logger.error("Failed to check subscription status: \(error)")
                    DataGeneration.generateVisitorEvents(
                        modelContext: modelContext,
                        includeEarlyAccessSpecies: false
                    )
                case .success(let status):
                    logger.info("Providing updated status to data generation")
                    DataGeneration.generateVisitorEvents(
                        modelContext: modelContext,
                        includeEarlyAccessSpecies: status == .premium
                    )
                case .loading: break
                @unknown default: break
                }
                logger.info("Finished checking subscription status")
            }
            .environment(\.passStatus, state.value ?? .notSubscribed)
            .environment(\.passStatusIsLoading, isLoading)
    }
}

extension View {
    
    func subscriptionPassStatusTask() -> some View {
        modifier(PassStatusTaskModifier())
    }
    
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The food quantity badge.
*/

import SwiftUI

struct BirdFoodQuantityBadge: View {
    var count: Int
    
    @ScaledMetric(relativeTo: .caption) private var scale = 1.0
    private let metrics = BirdFoodStoreMetrics.Card.card

    var body: some View {
        Text(count.formatted())
            .foregroundStyle(.white)
            .fontWeight(.semibold)
            .fontDesign(.rounded)
            .padding(.vertical, 2 * scale)
            .padding(.horizontal, 4 * scale)
            .frame(minWidth: metrics.badgeQuantityMinWidth * scale)
            .background(.premiumBirdFoodColor, in: .capsule)
    }
}

#Preview {
    BirdFoodQuantityBadge(count: 5)
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The bird food store view.
*/

import SwiftUI
import StoreKit
import SwiftData

import BackyardBirdsData
import BackyardBirdsUI

struct BirdFoodShop: View {
    @Query(sort: [.init(\.name, comparator: .localizedStandard)])
    private var allBirdFood: [BirdFood]
    
    @Environment(\.dismiss) private var dismiss
        
    var body: some View {
        shopContent
            .background(.background.secondary)
            .navigationTitle("Bird Food Shop")
            #if !os(watchOS)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Done", systemImage: "xmark")
                    }
                    .labelStyle(.titleOnly)
                }
            }
            #endif
    }
    
    #if os(watchOS)
    var shopContent: some View {
        StoreView(ids: productIDs) { product in
            if let (food, product) = birdFood(for: product.id) {
                BirdFoodProductIcon(birdFood: food, quantity: product.quantity)
            }
        }
        .storeButton(.hidden, for: .cancellation)
    }
    #else
    var shopContent: some View {
        ScrollView {
            VStack(spacing: 10) {
                if let (birdFood, product) = bestValue {
                    ProductView(id: product.id) {
                        BirdFoodProductIcon(birdFood: birdFood, quantity: product.quantity)
                            .bestBirdFoodValueBadge()
                    }
                    .padding(.vertical)
                    .background(.background.secondary, in: .rect(cornerRadius: 20))
                    .productViewStyle(.large)
                    .padding()
                    
                    Text("Other Bird Food")
                        .font(.title3.weight(.medium))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom)
                }
                
                ForEach(premiumBirdFood) { birdFood in
                    BirdFoodShopShelf(title: birdFood.name) {
                        ForEach(birdFood.orderedProducts) { product in
                            ProductView(id: product.id) {
                                BirdFoodProductIcon(birdFood: birdFood, quantity: product.quantity)
                            }
                        }
                    }
                }
            }
            .scrollClipDisabled()
        }
        .contentMargins(.horizontal, 20, for: .scrollContent)
        .scrollIndicators(.hidden)
    }
    #endif
    
    private var premiumBirdFood: [BirdFood] {
        allBirdFood
            .filter(\.isPremium)
            .sorted { lhs, rhs in
                lhs.priority > rhs.priority
            }
    }
    
    private var bestValue: (BirdFood, BirdFood.Product)? {
        allBirdFood
            .first { $0.id == "Nutrition Pellet" }
            .flatMap { nutritionPellet in
                nutritionPellet.products.max { lhs, rhs in
                    lhs.quantity < rhs.quantity
                }
                .map {
                    (nutritionPellet, $0)
                }
            }
    }
    
    private var productIDs: some Collection<Product.ID> {
        allBirdFood.lazy
            .flatMap(\.orderedProducts)
            .map(\.id)
    }
    
    private func birdFood(for productID: Product.ID) -> (BirdFood, BirdFood.Product)? {
        allBirdFood.birdFood(for: productID)
    }
    
}

#Preview {
    NavigationStack {
        ZStack {
            BirdFoodShop()
        }
    }
    .backyardBirdsDataContainer(inMemory: true)
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The Backyard Bird Pass store view.
*/

import SwiftUI
import StoreKit
import SwiftData
import BackyardBirdsData
import BackyardBirdsUI
import LayeredArtworkLibrary

// 8:45 p.m. at night uses a great sky gradient.
private let skyTimeInterval = TimeInterval(hours: 20, minutes: 45)

struct BackyardBirdsPassShop: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.passIDs.group) private var passGroupID
    @Environment(\.passStatus) private var passStatus
    
    private var showPremiumUpgrade: Bool {
        passStatus == .individual || passStatus == .family
    }
    
    var body: some View {
        SubscriptionStoreView(
            groupID: passGroupID,
            visibleRelationships: showPremiumUpgrade ? .upgrade : .all
        ) {
            PassMarketingContent(showPremiumUpgrade: showPremiumUpgrade)
                #if !os(watchOS)
                .containerBackground(for: .subscriptionStoreFullHeight) {
                    SkyBackground()
                }
                #endif
        }
        #if os(iOS)
        .storeButton(.visible, for: .redeemCode)
        #else
        .frame(width: 400, height: 550)
        #endif
        .subscriptionStoreControlIcon { _, subscriptionInfo in
            Group {
                switch PassStatus(levelOfService: subscriptionInfo.groupLevel) {
                case .premium:
                    Image(systemName: "bird")
                case .family:
                    Image(systemName: "person.3.sequence")
                default:
                    Image(systemName: "wallet.pass")
                }
            }
            .foregroundStyle(.accent)
            .symbolVariant(.fill)
        }
        #if !os(watchOS)
        .backgroundStyle(.clear)
        .subscriptionStoreButtonLabel(.multiline)
        .subscriptionStorePickerItemBackground(.thinMaterial)
        #endif
    }
    
}

private let tagValue = BirdTag.premiumGoldenHummingbird.rawValue

private struct PassMarketingContent: View {
    var showPremiumUpgrade: Bool = false
    
    @Query(filter: #Predicate { $0.tag == tagValue })
    private var birds: [Bird]
    
    init(showPremiumUpgrade: Bool) {
        self.showPremiumUpgrade = showPremiumUpgrade
    }
    
    var body: some View {
        VStack(spacing: 10) {
            #if !os(watchOS)
            if let bird = birds.first {
                ComposedBird(bird: bird, direction: .trailing)
                    .frame(height: 100)
                    .padding(-10)
            }
            #endif
            VStack(spacing: 3) {
                if showPremiumUpgrade {
                    subscriptionName
                    #if !os(watchOS)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .overlay(.bar, in: .capsule.stroke())
                    #endif
                }
                title
                    .font(.largeTitle.bold())
                #if !os(watchOS)
                    .foregroundStyle(.bar)
                #endif
            }
            description
                .fixedSize(horizontal: false, vertical: true)
                .font(.title3.weight(.medium))
                .padding([.bottom, .horizontal])
                .frame(maxWidth: 350)
        }
        .background {
            Capsule()
                .fill(.indigo.opacity(0.5))
                .blur(radius: 60)
        }
        .foregroundStyle(.white)
        .padding(.vertical)
        .padding(.top, 40)
        .multilineTextAlignment(.center)
    }
    
    @ViewBuilder
    private var subscriptionName: some View {
        Text("Backyard Birds Pass")
    }
    
    @ViewBuilder
    private var title: some View {
        if showPremiumUpgrade {
            Text("Premium")
        } else {
            subscriptionName
        }
    }
    
    @ViewBuilder
    private var description: some View {
        if showPremiumUpgrade {
            Text("""
                Early access to new bird species and enhanced journaling for the \
                most avid bird watchers.
                """,
                comment: "Marketing text to advertise Backyard Birds Pass Premium."
            )
        } else {
            Text("""
                More birdhouses and feeders with unlimited backyards for happy \
                habitats
                """,
                comment: "Marketing text to advertise Backyard Birds Pass."
            )
        }
    }
    
}

@available(watchOS, unavailable)
private struct SkyBackground: View {
    var body: some View {
        #if os(watchOS)
        Text("Unsupported")
        #else
        BackyardSkyView(timeInterval: skyTimeInterval)
            .overlay(alignment: .bottom) {
                Ellipse()
                    .fill(.white.opacity(0.2))
                    .frame(width: 800, height: 400)
                    .offset(y: 200)
            }
            .overlay(alignment: .top) {
                Image(.clouds)
                    .resizable()
                    .scaledToFill()
                    .hueRotation(.degrees(70))
                    .frame(height: 200)
            }
        #endif
    }
}

#Preview {
    ZStack {
        BackyardBirdsPassShop()
    }
    .backyardBirdsDataContainer(inMemory: true)
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The shelf in the bird food store.
*/

import StoreKit
import SwiftUI
import SwiftData

import BackyardBirdsData

struct BirdFoodShopShelf<Content: View>: View {
    var title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack {
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView(.horizontal) {
                LazyHStack {
                    content
                        #if !os(watchOS)
                        .frame(idealHeight: 130)
                        #endif
                        .padding(12)
                        .frame(width: 300, alignment: .leading)
                        .background(.background.secondary, in: .rect(cornerRadius: 20))
                }
                .scrollTargetLayout()
            }
        }
        .scrollTargetBehavior(.viewAligned)
    }

}

#Preview {
    MyPreview()
}

private struct MyPreview: View {
    @Query(filter: #Predicate { $0.id == "Nutrition Pellet" })
    private var birdFood: [BirdFood]

    var body: some View {
        ZStack {
            if let birdFood = birdFood.first {
                BirdFoodShopShelf(title: birdFood.name) {
                    ForEach(birdFood.products) { product in
                        ProductView(id: product.id) {
                            BirdFoodProductIcon(birdFood: birdFood, quantity: product.quantity)
                        }
                    }
                }
            }
        }
        .backyardBirdsDataContainer(inMemory: true)
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The shop view modifier.
*/

import SwiftUI
import SwiftData
import BackyardBirdsData
import OSLog

private let logger = Logger(subsystem: "BackyardBirds", category: "BackyardBirdsShopViewModifier")

struct BackyardBirdsShopViewModifier: ViewModifier {
    @Environment(\.modelContext) private var modelContext
    
    func body(content: Content) -> some View {
        ZStack {
            content
        }
        .subscriptionPassStatusTask()
        .onAppear {
            logger.info("Creating BirdBrain shared instance")
            BirdBrain.createSharedInstance(modelContext: modelContext)
            logger.info("BirdBrain shared instance created")
        }
        .task {
            logger.info("Starting tasks to observe transaction updates")
            // Begin observing StoreKit transaction updates in case a
            // transaction happens on another device.
            await BirdBrain.shared.observeTransactionUpdates()
            // Check if we have any unfinished transactions where we
            // need to grant access to content
            await BirdBrain.shared.checkForUnfinishedTransactions()
            logger.info("Finished checking for unfinished transactions")
        }
    }
}

extension View {
    func backyardBirdsShop() -> some View {
        modifier(BackyardBirdsShopViewModifier())
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The in-app purchase business logic.
*/

import StoreKit
import OSLog

import SwiftData
import BackyardBirdsData

/// Business logic for in-app purchase
actor BirdBrain: ModelActor {
    let executor: any ModelExecutor
    
    private let logger = Logger(
        subsystem: "Backyard Birds",
        category: "Bird Brain"
    )
    
    private var updatesTask: Task<Void, Never>?
    
    private init(executor: DefaultModelExecutor) {
        self.executor = executor
    }
    
    private(set) static var shared: BirdBrain!
    
    static func createSharedInstance(modelContext: ModelContext) {
        shared = BirdBrain(executor: DefaultModelExecutor(context: modelContext))
    }
    
    func process(transaction verificationResult: VerificationResult<Transaction>) async {
        do {
            let unsafeTransaction = verificationResult.unsafePayloadValue
            logger.log("""
            Processing transaction ID \(unsafeTransaction.id) for \
            \(unsafeTransaction.productID)
            """)
        }
        
        let transaction: Transaction
        switch verificationResult {
        case .verified(let t):
            logger.debug("""
            Transaction ID \(t.id) for \(t.productID) is verified
            """)
            transaction = t
        case .unverified(let t, let error):
            // Log failure and ignore unverified transactions
            logger.error("""
            Transaction ID \(t.id) for \(t.productID) is unverified: \(error)
            """)
            return
        }

        // We only need to handle consumables here. We will check the
        // subscription status each time before unlocking a premium subscription
        // feature.
        if case .consumable = transaction.productType {
            
            // The safest practice here is to send the transaction to your
            // server to validate the JWS and keep a ledger of the bird food
            // each account is entitled to. Since this is just a demonstration,
            // we are going to rely on StoreKit's automatic validation and
            // use SwiftData to keep a ledger of the bird food.
            
            guard let (birdFood, product) = birdFood(for: transaction.productID) else {
                logger.fault("""
                Attempting to grant access to \(transaction.productID) for \
                transaction ID \(transaction.id) but failed to query for
                corresponding bird food model.
                """)
                return
            }
            
            let delta = product.quantity * transaction.purchasedQuantity
            
            if transaction.revocationDate == nil, transaction.revocationReason == nil {
                // SwiftData crashes when we do this, so we'll save this for later
                //                if birdFood.finishedTransactions.contains(transaction.id) {
                //                    logger.log("""
                //                    Ignoring unrevoked transaction ID \(transaction.id) for \
                //                    \(transaction.productID) because we have already added \
                //                    \(birdFood.id) for the transaction.
                //                    """)
                //                    return
                //                }
                
                // This doesn't appear to actually be updating the model
                birdFood.ownedQuantity += delta
                //                birdFood.finishedTransactions.insert(transaction.id)
                
                logger.log("""
                Added \(delta) \(birdFood.id)(s) from transaction ID \
                \(transaction.id). New total quantity: \(birdFood.ownedQuantity)
                """)
                
                // Finish the transaction after granting the user content
                await transaction.finish()
                
                logger.debug("""
                Finished transaction ID \(transaction.id) for \
                \(transaction.productID)
                """)
            } else {
                birdFood.ownedQuantity -= delta
                
                logger.log("""
                Removed \(delta) \(birdFood.id)(s) because transaction ID \
                \(transaction.id) was revoked due to \
                \(transaction.revocationReason?.localizedDescription ?? "unknown"). \
                New total quantity: \(birdFood.ownedQuantity).
                """)
            }
        } else {
            // We can just finish the transction since we will grant access to
            // the subscription based on the subscription status.
            await transaction.finish()
        }
        
        do {
            try executor.context.save()
        } catch {
            logger.error("Could not save model context: \(error.localizedDescription)")
        }
    }
    
    func status(for statuses: [Product.SubscriptionInfo.Status], ids: PassIdentifiers) -> PassStatus {
        // Since Backyard Birds Pass supports family sharing, there may be
        // multiple statuses for different family members. Find the status
        // with the highest level of service, since this is what the
        // subscriber is entitled to service for.
        let effectiveStatus = statuses.max { lhs, rhs in
            let lhsStatus = PassStatus(
                productID: lhs.transaction.unsafePayloadValue.productID,
                ids: ids
            ) ?? .notSubscribed
            let rhsStatus = PassStatus(
                productID: rhs.transaction.unsafePayloadValue.productID,
                ids: ids
            ) ?? .notSubscribed
            return lhsStatus < rhsStatus
        }
        guard let effectiveStatus else {
            return .notSubscribed
        }
        
        let transaction: Transaction
        switch effectiveStatus.transaction {
        case .verified(let t):
            logger.debug("""
            Transaction ID \(t.id) for \(t.productID) is verified
            """)
            transaction = t
        case .unverified(let t, let error):
            // Log failure and do not give access
            logger.error("""
            Transaction ID \(t.id) for \(t.productID) is unverified: \(error)
            """)
            return .notSubscribed
        }
        
        // To prevent fraud, the best practice is to send this status to your server
        // to validate off device. For demonstration purposes, the app relies on automatic
        // validation from StoreKit because there is no server.
        
        return PassStatus(productID: transaction.productID, ids: ids) ?? .notSubscribed
    }
    
    func checkForUnfinishedTransactions() async {
        logger.debug("Checking for unfinished transactions")
        for await transaction in Transaction.unfinished {
            let unsafeTransaction = transaction.unsafePayloadValue
            logger.log("""
            Processing unfinished transaction ID \(unsafeTransaction.id) for \
            \(unsafeTransaction.productID)
            """)
            Task.detached(priority: .background) {
                await self.process(transaction: transaction)
            }
        }
        logger.debug("Finished checking for unfinished transactions")
    }
    
    func observeTransactionUpdates() {
        self.updatesTask = Task { [weak self] in
            self?.logger.debug("Observing transaction updates")
            for await update in Transaction.updates {
                guard let self else { break }
                await self.process(transaction: update)
            }
        }
    }
    
    private func birdFood(for productID: Product.ID) -> (BirdFood, BirdFood.Product)? {
        try? executor.context.fetch(FetchDescriptor<BirdFood>()).birdFood(for: productID)
    }
    
}



/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The value badge that is applicable to bird food.
*/

import SwiftUI

private struct BestBirdFoodValueBadge: View {
    
    var body: some View {
        Text("Best Value \(Image(systemName: "sparkles"))", comment: "Bird food label with sparkles icon.")
            .font(.title3.weight(.medium))
            .padding(.vertical, 5)
            .padding(.horizontal)
            .background(.regularMaterial, in: .capsule)
            .overlay {
                Capsule().strokeBorder()
            }
            .foregroundStyle(.premiumBirdFoodColor)
            .dynamicTypeSize(...(.xLarge))
            .fixedSize()
            .offset(y: 10.0)
    }
    
}

extension View {
    
    func bestBirdFoodValueBadge() -> some View {
        overlay(alignment: .bottom) {
            BestBirdFoodValueBadge()
        }
    }
    
}

#Preview {
    BestBirdFoodValueBadge()
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An enum that defines the label of the active screen.
*/

import SwiftUI
import BackyardBirdsUI
import BackyardBirdsData

enum AppScreen: Codable, Hashable, Identifiable, CaseIterable {
    case backyards
    case birds
    case plants
    case account
    
    var id: AppScreen { self }
}

extension AppScreen {
    @ViewBuilder
    var label: some View {
        switch self {
        case .backyards:
            Label("Backyards", image: .fountainImage)
        case .birds:
            Label("Birds", systemImage: "bird")
        case .plants:
            Label("Plants", systemImage: "leaf")
        case .account:
            Label("Account", systemImage: "person.crop.circle")
        }
    }
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .backyards:
            BackyardNavigationStack()
        case .plants:
            PlantsNavigationStack()
        case .birds:
            BirdsNavigationStack()
        case .account:
            AccountNavigationStack()
        }
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The sidebar list.
*/

import SwiftUI

struct AppSidebarList: View {
    @Binding var selection: AppScreen?
    
    var body: some View {
        List(AppScreen.allCases, selection: $selection) { screen in
            NavigationLink(value: screen) {
                screen.label
            }
        }
        .navigationTitle("Backyard Birds")
    }
}

#Preview {
    NavigationSplitView {
        AppSidebarList(selection: .constant(.backyards))
    } detail: {
        Text(verbatim: "Check out that sidebar!")
    }
    .backyardBirdsDataContainer(inMemory: true)
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The main tab view of the app.
*/

import SwiftUI

struct AppTabView: View {
    @Binding var selection: AppScreen?
    
    var body: some View {
        TabView(selection: $selection) {
            ForEach(AppScreen.allCases) { screen in
                screen.destination
                    .tag(screen as AppScreen?)
                    .tabItem { screen.label }
            }
        }
    }
}

#Preview {
    AppTabView(selection: .constant(.backyards))
        .backyardBirdsDataContainer(inMemory: true)
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The detail column of the split view.
*/

import SwiftUI
import SwiftData
import BackyardBirdsData

struct AppDetailColumn: View {
    var screen: AppScreen?
    
    var body: some View {
        Group {
            if let screen {
                screen.destination
            } else {
                ContentUnavailableView("Select a Backyard", systemImage: "bird", description: Text("Pick something from the list."))
            }
        }
        #if os(macOS)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background()
        #endif
    }
}

#Preview {
    AppDetailColumn()
        .backyardBirdsDataContainer(inMemory: true)
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The bird search results.
*/

import SwiftUI
import SwiftData
import BackyardBirdsData

struct BirdsSearchResults<Content: View>: View {
    @Binding var searchText: String
    @Query private var birds: [Bird]
    private var content: (Bird) -> Content
    
    init(searchText: Binding<String>, @ViewBuilder content: @escaping (Bird) -> Content) {
        _searchText = searchText
        _birds = Query(sort: \.creationDate)
        self.content = content
    }
    
    var body: some View {
        if $searchText.wrappedValue.isEmpty {
            ForEach(birds, content: content)
        } else {
            ForEach(birds.filter {
                $0.speciesName.contains($searchText.wrappedValue)
            }, content: content)
        }
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The bird search suggestions.
*/

import SwiftUI
import SwiftData
import BackyardBirdsData

struct BirdsSearchSuggestions: View {
    @Query private var birds: [Bird]
    
    var speciesNames: [String] {
        Set(birds.map(\.speciesName)).sorted()
    }
    
    var body: some View {
        ForEach(speciesNames, id: \.self) { speciesName in
            Text("**\(speciesName)**")
                .searchCompletion(speciesName)
        }
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The new bird indicator view.
*/

import SwiftUI

struct NewBirdIndicator: View {
    var body: some View {
        PhaseAnimator(IndicatorPhase.allCases) { phase in
            Image(systemName: "bird.fill")
                .scaleEffect(phase == .scale ? 1.2 : 1)
                .rotationEffect(phase == .scale ? .degrees(-10) : .zero)
                .padding(8)
                .background(in: .circle)
                .backgroundStyle(.teal.gradient.opacity(phase == .scale ? 1.0 : 0.5))
                .scaleEffect(phase == .scale ? 1.05 : 1.0)
        }
        .foregroundStyle(.white)
    }
    
    enum IndicatorPhase: CaseIterable {
        case idle
        case scale
    }
}

#Preview {
    NewBirdIndicator()
        .font(.system(size: 30))
        .scaleEffect(4.0)
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The birds navigation stack.
*/

import SwiftData
import BackyardBirdsData
import BackyardBirdsUI
import LayeredArtworkLibrary
import SwiftUI

struct BirdsNavigationStack: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [.init(.adaptive(minimum: 110), alignment: .top)], spacing: 20) {
                    BirdsSearchResults(searchText: $searchText) { bird in
                        BirdGridItem(bird: bird)
                    }
                }
            }
            .contentMargins(20, for: .scrollContent)
            .navigationTitle("Birds")
            .searchable(text: $searchText)
            .searchSuggestions {
                if searchText.isEmpty {
                    BirdsSearchSuggestions()
                }
            }
        }
    }
}

#Preview {
    BirdsNavigationStack()
        .backyardBirdsDataContainer(inMemory: true)
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The bird happiness indicator view.
*/

import SwiftUI

struct BirdFoodHappinessIndicator: View {
    var birdName: String
    var foodName: String
    
    @State private var showingHeart = false
    @State private var showingCallout = false
    @ScaledMetric private var indicatorHeight = 80.0
    
    var body: some View {
        HStack(spacing: 0) {
            if showingHeart {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.linearGradient(colors: [.pink, .red], startPoint: .top, endPoint: .bottom))
                    .font(.title)
                    .padding(8)
                    .background(.red.gradient.opacity(0.25), in: .circle)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 5)
                    .transition(.scale(scale: 0.25).combined(with: .opacity))
            }
            
            if showingCallout {
                Text("The \(birdName) loved the \(foodName)!",
                     comment: "First variable is the name of a bird. Second variable is a type of bird food.")
                    .foregroundStyle(.secondary)
                    .font(.callout)
                    .transition(.scale(0.5).combined(with: .opacity))
                    .padding(.trailing, 26)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .clipShape(.capsule)
        .background(.regularMaterial.shadow(.drop(color: .black.opacity(0.15), radius: 20, y: 10)), in: .capsule)
        .padding()
        .frame(height: indicatorHeight)
        .task {
            Task {
                withAnimation(.spring(duration: 0.5, bounce: 0.5)) {
                    showingHeart = true
                }
                try await Task.sleep(for: .seconds(2))
                withAnimation {
                    showingCallout = true
                }
                try await Task.sleep(for: .seconds(4))
                withAnimation {
                    showingCallout = false
                }
                try await Task.sleep(for: .seconds(1))
                withAnimation {
                    showingHeart = false
                }
            }
        }
    }
}

#Preview {
    _IndicatorPreview()
}

private struct _IndicatorPreview: View {
    @State private var id = 0
    
    var body: some View {
        VStack {
            Spacer()
            BirdFoodHappinessIndicator(birdName: "Hummingbird", foodName: "Nutritional Pellet")
                .id(id)
            Spacer()
            Button {
                id += 1
            } label: {
                Text(verbatim: "Restart")
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.fill)
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The bird grid item.
*/

import SwiftUI
import SwiftData
import BackyardBirdsData
import BackyardBirdsUI

struct BirdGridItem: View {
    var bird: Bird
    
    var body: some View {
        VStack {
            BirdIcon(bird: bird, insets: 10)
                .padding(.horizontal, 10)
            
            VStack {
                Text(bird.speciesName)
                    .font(.callout)
                Text(bird.visitStatus.title)
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
            .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    ModelPreview { bird in
        BirdGridItem(bird: bird)
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The backyard grid.
*/

import SwiftUI
import SwiftData
import BackyardBirdsUI
import BackyardBirdsData

struct BackyardGrid: View {
    @State private var searchText = ""
    
    @Environment(\.passStatus) private var passStatus
    @Environment(\.passStatusIsLoading) private var passStatusIsLoading
    
    @Query var backyards: [Backyard]
    
    var body: some View {
        ScrollView {
            if presentingNewBirdIndicatorCard {
                NewBirdIndicatorCard()
            }
            
            LazyVGrid(columns: [.init(.adaptive(minimum: 300))]) {
                BackyardsSearchResults(searchText: $searchText)
            }
        }
        #if os(macOS)
        .contentMargins(10, for: .scrollContent)
        #else
        .contentMargins([.horizontal, .bottom], 10, for: .scrollContent)
        #endif
        .searchable(text: $searchText)
        .searchSuggestions {
            if searchText.isEmpty {
                BackyardsSearchSuggestions()
            }
        }
    }
    
    var backyardsLimit: Int { PassStatus.notSubscribed.backyardLimit ?? 0 }
    
    var canPresentSubscriptionOfferCard: Bool {
        if case .notSubscribed = passStatus, !passStatusIsLoading {
            return true
        }
        return false
    }
    
    var presentingNewBirdIndicatorCard: Bool {
        DataGenerationOptions.showNewBirdIndicatorCard
    }
}

#Preview {
    NavigationStack {
        BackyardGrid()
            .navigationTitle("Backyards")
        #if os(macOS)
            .frame(width: 700, height: 300, alignment: .center)
        #endif
    }
    .backyardBirdsDataContainer(inMemory: true)
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The backyard grid item.
*/

import SwiftUI
import BackyardBirdsUI
import BackyardBirdsData

struct BackyardGridItem: View {
    var backyard: Backyard
    
    var body: some View {
        ZStack {
            NavigationLink(value: backyard.id) {
                BackyardViewport(backyard: backyard)
            }
            .buttonStyle(.plain)
                
            VStack {
                Header(backyard: backyard)
                Spacer()
                SupplyGauges(backyard: backyard)
            }
        }
        .contentShape(.containerRelative)
        .containerShape(.rect(cornerRadius: 20))
    }
    
    struct Header: View {
        var backyard: Backyard
        
        var body: some View {
            HStack {
                Text(backyard.name)
                    .font(.callout)
                    .padding(8)
                    .background()
                    .allowsHitTesting(false)
                
                Spacer()
                
                Button {
                    backyard.isFavorite.toggle()
                } label: {
                    Label("Favorite", systemImage: "star")
                        .symbolVariant(backyard.isFavorite ? .fill : .none)
                        .contentTransition(.symbolEffect(backyard.isFavorite ? .replace.upUp : .replace.downUp))
                        .padding(8)
                        .background(in: .circle)
                }
                .buttonStyle(.plain)
                .buttonBorderShape(.circle)
                .labelStyle(.iconOnly)
            }
            .foregroundStyle(Color.secondary)
            .backgroundStyle(.regularMaterial)
            .padding(8)
        }
    }
    
    struct SupplyGauges: View {
        var backyard: Backyard
        
        var body: some View {
            HStack {
                BackyardSupplyGauge(backyard: backyard, supplies: .food)
                    .scaleEffect(0.65)
                    .padding(8)
                    .frame(width: 44, height: 44)
                    .background(in: .circle)
                Spacer()
                BackyardSupplyGauge(backyard: backyard, supplies: .water)
                    .scaleEffect(0.65)
                    .padding(8)
                    .frame(width: 44, height: 44)
                    .background(in: .circle)
            }
            .padding(8)
            .backgroundStyle(.regularMaterial)
            .allowsHitTesting(false)
        }
    }
}

#Preview {
    ModelPreview { backyard in
        BackyardGridItem(backyard: backyard)
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The backyard navigation stack.
*/

import SwiftUI
import SwiftData
import BackyardBirdsUI
import BackyardBirdsData

struct BackyardNavigationStack: View {
    @Query(sort: \.creationDate)
    private var backyards: [Backyard]
    
    var body: some View {
        NavigationStack {
            BackyardGrid()
                .navigationTitle("Backyards")
                .navigationDestination(for: Backyard.ID.self) { backyardID in
                    if let backyard = backyards.first(where: { $0.id == backyardID }) {
                        BackyardDetailView(backyard: backyard)
                            #if os(macOS)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background()
                            #endif
                    }
                }
        }
    }
}

#Preview {
    BackyardNavigationStack()
        .backyardBirdsDataContainer(inMemory: true)
}



//
/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The bird food picker sheet.
*/

import SwiftUI
import SwiftData
import BackyardBirdsData
import BackyardBirdsUI

struct BirdFoodPickerSheet: View {
    var backyard: Backyard
    
    @Query(sort: [.init(\.priority, order: .reverse), .init(\.name, comparator: .localizedStandard)])
    private var birdFood: [BirdFood]
    
    @Environment(\.dismiss) private var dismiss
    @State private var presentingBirdFoodShop = false
    
    private let metrics = BirdFoodStoreMetrics.birdFoodStore

    var premiumFood: [BirdFood] {
        birdFood.filter(\.isPremium)
    }
    
    var otherFood: [BirdFood] {
        birdFood.filter { !$0.isPremium }
    }
    
    #if os(watchOS)
    var body: some View {
        NavigationStack {
            List {
                birdFoodShopLink
                Section(header: premiumText) {
                    ForEach(premiumFood) { food in
                        BirdFoodCard(
                            backyard: backyard,
                            food: food,
                            presentingBirdFoodShop: $presentingBirdFoodShop
                        )
                    }
                }
                Section(header: standardText) {
                    ForEach(otherFood) { food in
                        BirdFoodCard(
                            backyard: backyard,
                            food: food,
                            presentingBirdFoodShop: .constant(false)
                        )
                    }
                }
            }
            .navigationTitle("Bird Food")
            .navigationDestination(isPresented: $presentingBirdFoodShop) {
                BirdFoodShop()
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    doneButton
                }
            }
        }
    }
    #else
    var body: some View {
        GeometryReader { geometry in
            let cardWidth: CGFloat? = geometry.size.width > 0 ? (min(geometry.size.width * 0.7, 240) - 40) : nil
            
            NavigationStack {
                ScrollView {
                    premiumText
                    birdFoodShopLink
                    
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 10) {
                            ForEach(premiumFood) { food in
                                BirdFoodCard(
                                    backyard: backyard,
                                    food: food,
                                    presentingBirdFoodShop: $presentingBirdFoodShop
                                )
                                .frame(width: cardWidth)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .scrollClipDisabled()
                    .scrollIndicators(.hidden)
                    
                    standardText
                        .padding(.top)
                    
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 10) {
                            ForEach(otherFood) { food in
                                BirdFoodCard(
                                    backyard: backyard,
                                    food: food,
                                    presentingBirdFoodShop: .constant(false)
                                )
                                .frame(width: cardWidth)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .scrollClipDisabled()
                    .scrollIndicators(.hidden)
                }
                .navigationTitle("Bird Food")
                .contentMargins([.top, .horizontal], 20, for: .scrollContent)
                .contentMargins(.bottom, 40, for: .scrollContent)
                .navigationDestination(isPresented: $presentingBirdFoodShop) {
                    BirdFoodShop()
                }
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        doneButton
                    }
                }
            }
        }
    }
    #endif
    
    func sectionHeader(_ text: LocalizedStringKey, comment: StaticString) -> some View {
        Text(text, comment: comment)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.subheadline.bold())
            .foregroundStyle(.tertiary)
    }
    
    var doneButton: some View {
        Button("Done", action: dismiss.callAsFunction)
            #if os(watchOS)
            .buttonStyle(.plain)
            #endif
    }
    
    var premiumText: some View {
        sectionHeader("Premium", comment: "Refers to a premium bird food item versus standard bird food item.")
    }
    
    var standardText: some View {
        sectionHeader("Standard", comment: "Refers to a premium bird food item versus standard bird food item.")
    }
    
    var birdFoodShopLink: some View {
        Button {
            presentingBirdFoodShop = true
        } label: {
            HStack(spacing: 12) {
                Label("Bird Food Shop", systemImage: "storefront")
                #if !os(watchOS)
                Spacer()
                #endif
                Image(systemName: "chevron.forward")
                    .imageScale(.medium)
                    .fontWeight(.semibold)
                    .foregroundStyle(.tertiary)
            }
            #if os(watchOS)
            .labelStyle(.titleOnly)
            #else
            .imageScale(.large)
            #endif
            .controlSize(metrics.card.controlSize)

        }
        #if !os(watchOS)
        .tint(.premiumBirdFoodColor)
        .buttonStyle(.bordered)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        #endif
    }
    
    struct BirdFoodCard: View {
        var backyard: Backyard
        var food: BirdFood
        @Binding var presentingBirdFoodShop: Bool
        private let metrics = BirdFoodStoreMetrics.birdFoodStore
        
        var needsMore: Bool {
            food.isPremium && food.ownedQuantity <= 0
        }
        
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            VStack(spacing: metrics.card.verticalSpacing) {
                food.image
                    .scaledToFit()
                    .padding(metrics.food.imagePadding)
                    .frame(width: metrics.food.imageWidth, height: metrics.food.imageHeight)
                    .background(.fill.tertiary, in: .circle)
                    #if os(watchOS)
                    .alignmentGuide(.bottom) { $0[VerticalAlignment.center] + 28 }
                    .alignmentGuide(.trailing) { $0[.trailing] + 3 }
                    #endif
                    .overlay(alignment: .bottomTrailing) {
                        if food.isPremium {
                            BirdFoodQuantityBadge(count: food.ownedQuantity)
                                .font(metrics.food.imageQuantityBadgeFont)
                                #if !os(watchOS)
                                .alignmentGuide(.bottom) { $0[VerticalAlignment.center] - 10 }
                                .alignmentGuide(.trailing) { $0[.trailing] - 30 }
                                #endif
                        }
                    }
                
                VStack {
                    Text(food.name)
                        .font(metrics.food.nameFont)
                    
                    Text(food.summary)
                        #if !os(watchOS)
                        .lineLimit(2, reservesSpace: true)
                        #endif
                        .foregroundStyle(.secondary)
                        .font(metrics.food.summaryFont)
                }
                .multilineTextAlignment(.center)
                
                Button {
                    if needsMore {
                        presentingBirdFoodShop = true
                    } else {
                        withAnimation(.default.delay(0.35)) {
                            backyard.birdFood = food
                            backyard.foodRefillDate = .now
                        }
                        dismiss()
                    }
                } label: {
                    if needsMore {
                        Text("Shop", comment: "Label on button that leads to Bird Food Shop.")
                    } else if food.isPremium {
                        HStack(spacing: metrics.cardActionButton.horizontalSpacing) {
                            Text("Use", comment: "Refers to Premium Food.")
                            Text(1.formatted())
                                #if !os(watchOS)
                                .font(.callout)
                                #endif
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .frame(minWidth: metrics.cardActionButton.minWidth)
                                .foregroundStyle(.premiumBirdFoodColor)
                                .background(.foreground, in: .capsule.inset(by: metrics.cardActionButton.backgroundInset))
                        }
                    } else {
                        Text("Choose", comment: "Refers to Standard Food.")
                    }
                }
                #if os(watchOS)
                .font(.system(size: 12))
                #endif
                .controlSize(metrics.card.controlSize)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .tint(food.isPremium ? .premiumBirdFoodColor : nil)
            }
            .padding(.horizontal, metrics.card.horizontalPadding)
            .padding(.vertical, metrics.card.verticalPadding)
            #if !os(watchOS)
            .frame(maxWidth: .infinity)
            .background(.fill.tertiary, in: .rect(cornerRadius: 20))
            #endif
        }
    }
}

#Preview {
    ModelPreview { backyard in
        BirdFoodPickerSheet(backyard: backyard)
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Search suggestions.
*/

import SwiftUI
import BackyardBirdsData

struct BackyardSearchSuggestion: Hashable, Identifiable {
    enum VisitorStatus: Hashable {
        case current(Bird, Backyard)
        case previous(Bird, [Backyard])
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .current(let bird, let backyard):
                hasher.combine(0)
                hasher.combine(bird)
                hasher.combine(backyard)
            case .previous(let bird, let backyards):
                hasher.combine(1)
                hasher.combine(bird)
                hasher.combine(backyards)
            }
        }
    }
    
    var id: Bird.ID { bird.id }
    var bird: Bird
    var backyards: [Backyard]
    var visitorStatus: VisitorStatus?
    
    init?(visitor: BackyardVisitorEvent, backyards: [Backyard]) {
        guard let backyard = backyards.first else { return nil }
        
        bird = visitor.bird
        self.backyards = backyards
        if visitor.endDate < .now {
            visitorStatus = .previous(visitor.bird, backyards)
        } else {
            visitorStatus = .current(visitor.bird, backyard)
        }
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The new bird indicator card view.
*/

import SwiftUI
import SwiftData
import BackyardBirdsUI
import BackyardBirdsData
import LayeredArtworkLibrary

struct NewBirdIndicatorCard: View {
    @Query(sort: \.creationDate)
    private var backyards: [Backyard]
    
    var body: some View {
        if let backyard = backyards.first, let bird = backyard.currentVisitorEvent?.bird {
            HStack {
                NewBirdIndicator()
                VStack(alignment: .leading) {
                    Text("\(bird.speciesName) is visiting", comment: "Variable is a bird species")
                        .font(.headline)
                    Text("Arrived in \(backyard.name)", comment: "Variable is a backyard name")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.forward")
                    .font(.subheadline.bold())
                    .foregroundStyle(.tertiary)
                    .frame(width: 30)
            }
            .padding(12)
            .background(.fill.tertiary, in: .capsule)
            .frame(maxWidth: 400)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ZStack {
        NewBirdIndicatorCard()
    }
    .padding()
    .backyardBirdsDataContainer(inMemory: true)
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The backyard search results.
*/

import SwiftUI
import SwiftData
import BackyardBirdsData

struct BackyardsSearchResults: View {
    @Binding var searchText: String
    @Query private var backyards: [Backyard]
    
    init(searchText: Binding<String>) {
        _searchText = searchText
        if searchText.wrappedValue.isEmpty {
            _backyards = Query(sort: \.creationDate)
        } else {
            let term = searchText.wrappedValue
            _backyards = Query(filter: #Predicate { backyard in
                backyard.name.contains(term)
            }, sort: \.name)
        }
    }
    
    var body: some View {
        ForEach(backyards) { backyard in
            BackyardGridItem(backyard: backyard)
        }
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The backyard supply indicator view.
*/

import SwiftUI
import BackyardBirdsUI
import BackyardBirdsData

struct BackyardSupplyIndicator: View {
    var backyard: Backyard
    var supplies: BackyardSupplies
    
    @State private var presentingBirdFoodPicker = false
    
    var body: some View {
        Button {
            switch supplies {
            case .food:
                presentingBirdFoodPicker = true
            case .water:
                withAnimation {
                    backyard.waterRefillDate = .now
                }
            }
        } label: {
            HStack {
                BackyardSupplyGauge(backyard: backyard, supplies: supplies)
                    .controlSize(.large)
                
                VStack(alignment: .leading) {
                    switch supplies {
                    case .food:
                        Text(backyard.birdFood.name)
                    case .water:
                        Text("Water", comment: "Shown in the context of food supplies in a given backyard")
                    }
                    Text(
                        "\(formattedTimeRemaining(from: secondsRemaining)) remaining",
                         comment: "Used to indicate remaining time. Variable is formatted in hours/minutes (e.g. “1h” or “33mn”.)"
                    )
                    .foregroundStyle(.secondary)
                    .font(.callout)
                    .lineLimit(1)
                }
                
                Spacer()
                
                HStack {
                    switch supplies {
                    case .food:
                        Label("Choose Food", systemImage: "arrow.left.arrow.right")
                    case .water:
                        Label("Refill Water", systemImage: "arrow.clockwise")
                    }
                }
                .foregroundStyle(.secondary)
                .frame(width: 44)
                .labelStyle(.iconOnly)
            }
            .padding(12)
            .background(.fill.tertiary)
            .contentShape(.containerRelative)
            .containerShape(.rect(cornerRadius: 20))
            #if !os(macOS)
            .hoverEffect(.highlight)
            #endif
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $presentingBirdFoodPicker) {
            BirdFoodPickerSheet(backyard: backyard)
            #if os(macOS)
                .frame(minWidth: 520, maxWidth: .infinity, minHeight: 400, maxHeight: .infinity)
            #endif
        }
    }

    func formattedTimeRemaining(from timeInterval: TimeInterval) -> String {
        // In this context, we're only looking at the second at most, so it's fine if we round by the second
        let duration = Duration(secondsComponent: Int64(timeInterval), attosecondsComponent: 0)
        return duration.formatted(.units(allowed: [.hours, .minutes, .seconds], width: .abbreviated, maximumUnitCount: 1))
    }
    
    var secondsRemaining: TimeInterval {
        max(Date.now.distance(to: backyard.expectedEmptyDate(for: supplies)), 0)
    }
}

#Preview {
    ModelPreview { backyard in
        BackyardSupplyIndicator(backyard: backyard, supplies: .food)
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The backyard detail view.
*/

import SwiftUI
import SwiftData
import BackyardBirdsData
import BackyardBirdsUI

struct BackyardDetailView: View {
    var backyard: Backyard
    
    @State private var presentingHappinessIndicator = false
    @State private var presentingBirdFoodShop = false
    
    var body: some View {
        ScrollView {
            BackyardViewport(backyard: backyard)
                .containerShape(.rect(cornerRadius: 20))
                .overlay(alignment: .bottom) {
                    if let bird = backyard.currentVisitorEvent?.bird {
                        if presentingHappinessIndicator {
                            BirdFoodHappinessIndicator(birdName: bird.speciesName, foodName: backyard.birdFood.name)
                        }
                    }
                }
            
            LazyVGrid(columns: [.init(.adaptive(minimum: 400))]) {
                BackyardSupplyIndicator(backyard: backyard, supplies: .food)
                BackyardSupplyIndicator(backyard: backyard, supplies: .water)
            }
            
            Text("Recent Visitors")
                .font(.subheadline.bold())
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
            
            LazyVStack {
                RecentBackyardVisitorsView(backyard: backyard)
            }
        }
        .onChange(of: backyard.foodRefillDate) { (_, _) in
            withAnimation(.spring(duration: 0.5, bounce: 0.5)) {
                presentingHappinessIndicator = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
                    presentingHappinessIndicator = false
                }
            }
        }
        .contentMargins(20, for: .scrollContent)
        .navigationTitle(backyard.name)
        .toolbar {
            ToolbarItem {
                Button {
                    backyard.isFavorite.toggle()
                } label: {
                    Label("Favorite", systemImage: "star")
                        .symbolVariant(backyard.isFavorite ? .fill : .none)
                }
            }
        }
    }
}

#Preview {
    ModelPreview { backyard in
        NavigationStack {
            BackyardDetailView(backyard: backyard)
        }
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The backyard search suggestions.
*/

import SwiftUI
import SwiftData
import BackyardBirdsData

struct BackyardsSearchSuggestions: View {
    @Query private var backyards: [Backyard]
    
    var events: [BackyardVisitorEvent] {
        Set(backyards.compactMap(\.currentVisitorEvent))
            .sorted { $0.bird.speciesName < $1.bird.speciesName }
    }
    
    var body: some View {
        ForEach(events) { event in
            let backyard = event.backyard.name
            Text("**\(event.bird.speciesName)** is currently in **\(backyard)**")
                .searchCompletion(backyard)
        }
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The restore purchases button.
*/

import SwiftUI
import StoreKit

struct RestorePurchasesButton: View {
    @State private var isRestoring = false
    
    var body: some View {
        Button("Restore Purchases") {
            isRestoring = true
            Task.detached {
                defer { isRestoring = false }
                try await AppStore.sync()
            }
        }
        .disabled(isRestoring)
    }
    
}

#Preview {
    RestorePurchasesButton()
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The account editor form.
*/

import OSLog
import SwiftUI
import SwiftData
import BackyardBirdsUI
import LayeredArtworkLibrary
import BackyardBirdsData

private let logger = Logger(subsystem: "BackyardBirds", category: "Account Information")

struct EditAccountForm: View {
    var account: Account
    
    @State private var email: String = ""
    @State private var displayName: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Display Name", text: $displayName)
                        #if os(iOS)
                        .textInputAutocapitalization(.words)
                        #endif
                        .disableAutocorrection(true)
                        .textContentType(.name)
                        .onSubmit {
                            logger.info("Requesting to change displayName to \(displayName)")
                            account.displayName = displayName
                        }
                        .onAppear {
                            displayName = account.displayName
                        }
                }
                
                Section("Email") {
                    TextField("Email Address", text: $email)
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        #endif
                        .disableAutocorrection(true)
                        .textContentType(.emailAddress)
                        .onSubmit {
                            logger.info("Requesting to change email to \(email)")
                            account.emailAddress = email
                        }
                        .onAppear {
                            email = account.emailAddress
                        }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Account Information")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            #if !os(iOS)
            .frame(minWidth: 440, maxWidth: .infinity, minHeight: 220, maxHeight: .infinity)
            #endif
        }
    }
}

#Preview {
    ModelPreview { account in
        EditAccountForm(account: account)
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The navigation stack holding the account view.
*/

import SwiftUI
import SwiftData
import BackyardBirdsUI
import LayeredArtworkLibrary
import BackyardBirdsData

struct AccountNavigationStack: View {
    @Query
    private var accounts: [Account]
    
    @Environment(\.passStatus) private var passStatus
    @Environment(\.passIDs.group) private var passGroupID
    
    @State private var presentingPassSheet = false
    @State private var presentingEditAccountSheet = false
    
    #if os(iOS)
    @State private var presentingManagePassSheet = false
    #elseif os(macOS)
    @Environment(\.openURL) private var openURL
    #endif
    
    var body: some View {
        NavigationStack {
            if let account = accounts.first {
                Form {
                    VStack {
                        BirdIcon(bird: account.bird)
                            .frame(width: 80, height: 80)
                        
                        Text(account.displayName)
                            .font(.headline.bold())
                            .overlay(alignment: .leading) {
                                (account.isPremiumMember ? Label("Premium Member", systemImage: "bird.fill") :
                                    Label("Standard Member", systemImage: "bird"))
                                .foregroundStyle(.tint)
                                .labelStyle(.iconOnly)
                                .imageScale(.large)
                                .alignmentGuide(.leading) { $0[.trailing] + 4 }
                            }
                        
                        Text("Joined \(account.joinDate.formatted(.dateTime.month(.wide).day(.twoDigits).year()))",
                             comment: "Variable is the calendar date when the person joined.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowInsets(.none)
                    .listRowBackground(Color.clear)
                    
                    Section {
                        if passStatus == .individual || passStatus == .family {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("""
                                Unlock the complete backyard experience with early \
                                access to new bird species and more!
                                """)
                                Button("Check out Premium \(Image(systemName: "chevron.forward"))") {
                                    presentingPassSheet = true
                                }
                                .font(.callout)
                                .buttonStyle(.borderless)
                            }
                        }
                        if case .notSubscribed = passStatus {
                            Button {
                                presentingPassSheet = true
                            } label: {
                                Label("Get Backyard Birds Pass", systemImage: "wallet.pass")
                                    #if os(macOS)
                                    .labelStyle(.titleOnly)
                                    #endif
                            }
                        } else {
                            Button {
                            #if os(iOS)
                                presentingManagePassSheet = true
                            #elseif os(macOS)
                                openURL(URL(string: "https://apps.apple.com/account/subscriptions")!)
                            #endif
                            } label: {
                                manageSubscriptionLabel
                            }
                        }
                    } footer: {
                        if passStatus != .notSubscribed {
                            Text("Backyard Birds Pass: \(String(describing: passStatus))")
                        }
                    }
                    .symbolVariant(.fill)
                    Section {
                        RestorePurchasesButton()
                    }
                }
                .formStyle(.grouped)
                .navigationTitle("Account")
                .toolbar {
                    Button {
                        presentingEditAccountSheet = true
                    } label: {
                        Label("Edit Account", systemImage: "pencil")
                    }
                }
                .sheet(isPresented: $presentingEditAccountSheet) {
                    EditAccountForm(account: account)
                }
                .sheet(isPresented: $presentingPassSheet) {
                    BackyardBirdsPassShop()
                }
                #if os(iOS)
                .manageSubscriptionsSheet(
                    isPresented: $presentingManagePassSheet,
                    subscriptionGroupID: passGroupID
                )
                #endif
            } else {
                ContentUnavailableView("No Account Found", systemImage: "bird")
            }
        }
    }
    
    @ViewBuilder
    private var manageSubscriptionLabel: some View {
        Label {
            Text("Your Backyard Birds Pass: \(String(describing: passStatus))",
                 comment: "The variable is the type of Backyard Birds Pass (such as Premium, Family, and so on.)")
        } icon: {
            Image(systemName: "wallet.pass")
        }
        #if os(macOS)
        .labelStyle(.titleOnly)
        #endif
    }
    
}

#Preview {
    AccountNavigationStack()
        .backyardBirdsDataContainer(inMemory: true)
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The entry point for the watch app.
*/

import SwiftUI
import SwiftData
import BackyardBirdsData

@main
struct BackyardBirdsWatchApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .backyardBirdsShop()
                .backyardBirdsDataContainer()
        }
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The view that holds the watch app's visual content.
*/

import SwiftUI
import SwiftData
import StoreKit
import BackyardBirdsData
import BackyardBirdsUI

struct ContentView: View {
    @Query(sort: \.creationDate)
    private var backyards: [Backyard]
    
    @Environment(\.passStatus) private var passStatus
    @Environment(\.passStatusIsLoading) private var passStatusIsLoading
    @Environment(\.passIDs.group) private var groupID
    @State private var showingSubscriptionStore = false
    
    private var isSubscribed: Bool {
        return passStatus != .notSubscribed && !passStatusIsLoading
    }
    
    var body: some View {
        NavigationSplitView {
            BackyardList(isSubscribed: isSubscribed, backyardLimit: passStatus.backyardLimit, onOfferSelection: showSubscriptionStore)
            .navigationTitle("Backyard Birds")
            .navigationDestination(for: Backyard.ID.self) { backyardID in
                if let backyard = backyards.first(where: { $0.id == backyardID }) {
                    BackyardTabView(backyard: backyard)
                }
            }
        } detail: {
            ContentUnavailableView("Select a Backyard", systemImage: "bird", description: Text("Pick something from the list."))
        }
        .sheet(isPresented: $showingSubscriptionStore) {
            SubscriptionStoreView(groupID: groupID)
        }
        .onInAppPurchaseCompletion { _, purchaseResult in
            guard case .success(let verificationResult) = purchaseResult,
                  case .success(_) = verificationResult else {
                return
            }
            showingSubscriptionStore = false
        }
    }
    
    private func showSubscriptionStore() {
        showingSubscriptionStore = true
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The backyard content tab.
*/

import SwiftUI
import BackyardBirdsData

struct BackyardContentTab: View {
    var backyard: Backyard
    @State private var presentingBirdFoodPicker = false
    
    var body: some View {
        VStack {
            Spacer()
            
            Label("Food is running low", systemImage: "fork.knife")
            Label("Water is okay", systemImage: "cup.and.saucer.fill")

            Button("Refill") {
                presentingBirdFoodPicker = true
            }
            
            Spacer()
        }
        .containerBackground(.green.gradient, for: .tabView)
        .navigationTitle("Amenities")
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Gauge(value: 0.5) {
                    Label("Water", systemImage: "cup.and.saucer.fill")
                } currentValueLabel: {
                    Text(Duration.seconds(60 * (59 + 4 * 60)), format: timeFormatter)
                }
                .tint(Gradient(colors: [.blue, .green]))
                .gaugeStyle(.accessoryCircularCapacity)
                
                Gauge(value: 0.25) {
                    Label("Food", systemImage: "fork.knife")
                } currentValueLabel: {
                    Text(Duration.seconds(60 * (59 + 6 * 60)), format: timeFormatter)
                }
                .tint(Gradient(colors: [.yellow, .orange]))
                .gaugeStyle(.accessoryCircularCapacity)
            }
        }
        .sheet(isPresented: $presentingBirdFoodPicker) {
            BirdFoodPickerSheet(backyard: backyard)
        }
    }
    
    let timeFormatter: Duration.TimeFormatStyle = Duration.TimeFormatStyle(pattern: .hourMinute)
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The backyard visitors tab.
*/

import SwiftUI
import BackyardBirdsData
import BackyardBirdsUI
import LayeredArtworkLibrary

struct BackyardVisitorsTab: View {
    var backyard: Backyard
    
    var body: some View {
        List {
            if let bird = backyard.currentVisitorEvent?.bird {
                Section("Here Now") {
                    HStack {
                        BirdIcon(bird: bird)
                            .frame(width: 60, height: 60)
                        Text(bird.speciesName)
                    }
                }
            }
            
            Section("Recent") {
                RecentBackyardVisitorsView(backyard: backyard)
            }
        }
        .navigationTitle("Visitors")
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The backyard tab view.
*/

import SwiftUI
import BackyardBirdsData
import SwiftData

struct BackyardTabView: View {
    var backyard: Backyard
    
    var body: some View {
        TabView {
            BackyardSummaryTab(backyard: backyard)
                .tabItem { Text("Summary") }
            
            BackyardContentTab(backyard: backyard)
                .tabItem { Text("Content") }
            
            BackyardVisitorsTab(backyard: backyard)
                .tabItem { Text("Visitors") }
        }
        .tabViewStyle(.carousel)
        .navigationTitle(backyard.name)
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The backyard summary tab.
*/

import SwiftUI
import BackyardBirdsUI
import BackyardBirdsData
import LayeredArtworkLibrary

struct BackyardSummaryTab: View {
    var backyard: Backyard
    
    var body: some View {
        VStack {
            if let bird = backyard.currentVisitorEvent?.bird {
                ComposedBird(bird: bird)
                    .frame(width: 80, height: 80)
                Text(bird.speciesName)
                    .font(.headline.bold())
            }
            
            Text("\(2) others recently", comment: "The variable is the number of birds that visited.")
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Label("Water", systemImage: "cup.and.saucer.fill")
                .foregroundStyle(.blue)
            Label("Sunflower seeds", systemImage: "fork.knife")
                .foregroundStyle(.yellow)
        }
        .tint(.teal)
        .navigationTitle("Summary")
        .containerBackground(.teal.gradient, for: .tabView)
    }
}


// swift-tools-version: 5.9

/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The package that defines the app's data.
*/

import PackageDescription

let package = Package(
    name: "BackyardBirdsData",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "BackyardBirdsData",
            type: .dynamic,
            targets: ["BackyardBirdsData"]
        )
    ],
    targets: [
        .target(
            name: "BackyardBirdsData",
            path: "."
        )
    ]
)


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The plant species information.
*/

import Foundation

public struct PlantSpeciesInfo: RawRepresentable, Hashable, CaseIterable, Codable {
    public var rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public static var allCases: [PlantSpeciesInfo] = [
        .foxglove, .snakePlant, .colocasia, .kentiaPalm, .alocasia
    ]
    
    public static let foxglove = Self(rawValue: "Plant 1")
    public static let snakePlant = Self(rawValue: "Plant 2") // Snake Plant, Rubber Tree
    public static let colocasia = Self(rawValue: "Plant 3")
    public static let kentiaPalm = Self(rawValue: "Plant 4") // Kentia Palm
    public static let alocasia = Self(rawValue: "Plant 5")
    
    public var name: String {
        switch self {
        case .foxglove:
            String(localized: "Foxglove", table: "PlantSpecies", bundle: .module, comment: "Plant 1 name")
        case .snakePlant:
            String(localized: "Snake Plant", table: "PlantSpecies", bundle: .module, comment: "Plant 2 name")
        case .colocasia:
            String(localized: "Colocasia", table: "PlantSpecies", bundle: .module, comment: "Plant 3 name")
        case .kentiaPalm:
            String(localized: "Kentia Palm", table: "PlantSpecies", bundle: .module, comment: "Plant 4 name")
        case .alocasia:
            String(localized: "Alocasia", table: "PlantSpecies", bundle: .module, comment: "Plant 5 name")
        default:
            fatalError()
        }
    }
    
    public var summary: String {
        switch self {
        case .foxglove:
            String(localized: "Totally tubular flowering stems.", table: "PlantSpecies", bundle: .module, comment: "Plant 1 summary")
        case .snakePlant:
            String(localized: "Much more well behaved than the name implies.", table: "PlantSpecies", bundle: .module, comment: "Plant 2 summary")
        case .colocasia:
            String(localized: "Makes a great substitute for an umbrella.", table: "PlantSpecies", bundle: .module, comment: "Plant 3 summary")
        case .kentiaPalm:
            String(localized: "Quite independent and requires minimal attention.", table: "PlantSpecies", bundle: .module, comment: "Plant 4 summary")
        case .alocasia:
            String(localized: "Loves a good leaf cleaning.", table: "PlantSpecies", bundle: .module, comment: "Plant 5 summary")
        default:
            fatalError()
        }
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The plant data.
*/

import Observation
import SwiftData
import OSLog

private let logger = Logger(subsystem: "Backyard Birds Data", category: "Plant")

@Model public class Plant {
    @Attribute(.unique) public var id: String
    public var creationDate: Date
    public var species: PlantSpecies!
    public var backyard: Backyard?
    public var variant: Int
    
    public var speciesName: String { species.info.name }
    public var speciesSummary: String { species.info.summary }
    
    public init(id: UUID = UUID(), variant: Int) {
        self.id = id.uuidString
        self.creationDate = .now
        self.variant = variant
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The generation of plant data.
*/

import SwiftData
import OSLog

private let logger = Logger(subsystem: "BackyardBirdsData", category: "Plant")

extension Plant {
    static func generateIndividualPlants(modelContext: ModelContext) {
        var random = SeededRandomGenerator(seed: 1)
        
        logger.info("Generating individual plants...")
        let allPlantSpecies = try! modelContext.fetch(FetchDescriptor<PlantSpecies>(sortBy: [.init(\.id)]))
        logger.info("Found all plant species, now generating plants...")
        for species in allPlantSpecies {
            let count = Int.random(in: 1...3, using: &random)
            for _ in 0 ..< count {
                generateAndInsert(species: species, modelContext: modelContext, random: &random)
            }
        }
        logger.info("Completed generating individual plants.")
    }
    
    @discardableResult
    static func generateAndInsert(species: PlantSpecies, modelContext: ModelContext, random: inout SeededRandomGenerator) -> Plant {
        let variantCount = species.parts.compactMap(\.variants).first!
        let plant = Plant(variant: .random(in: 0..<variantCount, using: &random))
        modelContext.insert(plant)
        plant.species = species
        return plant
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The plant species.
*/

import Observation
import SwiftData

@Model public class PlantSpecies {
    @Attribute(.unique) public var id: String
    public var parts: [PlantPart]
    
    @Relationship(.cascade, inverse: \Plant.species)
    public var plants: [Plant]
    
    public var info: PlantSpeciesInfo {
        PlantSpeciesInfo(rawValue: id)
    }
    
    public init(info: PlantSpeciesInfo, parts: [PlantPart]) {
        self.id = info.rawValue
        self.parts = parts
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The generation of plant species data.
*/

import SwiftData

// MARK: - Individual Species

extension PlantSpecies {
    static func generateAll(modelContext: ModelContext) {
        modelContext.insert(PlantSpecies(
            info: .foxglove,
            parts: [
                .pot(),
                .plant()
            ]
        ))
        
        modelContext.insert(PlantSpecies(
            info: .snakePlant,
            parts: [
                .plant(),
                .pot()
            ]
        ))
        
        modelContext.insert(PlantSpecies(
            info: .colocasia,
            parts: [
                .plant(),
                .pot()
            ]
        ))
        
        modelContext.insert(PlantSpecies(
            info: .kentiaPalm,
            parts: [
                .plant(),
                .pot()
            ]
        ))
        
        modelContext.insert(PlantSpecies(
            info: .alocasia,
            parts: [
                .plant(),
                .pot()
            ]
        ))
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The parts of a plant.
*/

import Foundation

public struct PlantPart: Identifiable, Codable {
    public var id: String { name }
    public var name: String
    public var pivotX: Double? = nil
    public var pivotY: Double? = nil
    public var variants: Int? = nil
    
    public init(name: String, pivotX: Double? = nil, pivotY: Double? = nil, variants: Int? = nil) {
        self.name = name
        self.pivotX = pivotX
        self.pivotY = pivotY
        self.variants = variants
    }
    
    static func pot(x: Double? = nil, y: Double? = nil) -> PlantPart {
        PlantPart(name: "Pot", pivotX: x, pivotY: y)
    }
    
    static func plant(x: Double? = nil, y: Double? = nil, variants: Int = 4) -> PlantPart {
        PlantPart(name: "Variant", pivotX: x, pivotY: y, variants: variants)
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The model's container.
*/

import SwiftUI
import SwiftData

struct BackyardBirdsDataContainerViewModifier: ViewModifier {
    let container: ModelContainer
    
    init(inMemory: Bool) {
        container = try! ModelContainer(for: DataGeneration.schema, configurations: [ModelConfiguration(inMemory: inMemory)])
    }
    
    func body(content: Content) -> some View {
        content
            .generateData()
            .modelContainer(container)
    }
}

struct GenerateDataViewModifier: ViewModifier {
    @Environment(\.modelContext) private var modelContext
    
    func body(content: Content) -> some View {
        content.onAppear {
            DataGeneration.generateAllData(modelContext: modelContext)
        }
    }
}

public extension View {
    func backyardBirdsDataContainer(inMemory: Bool = DataGenerationOptions.inMemoryPersistence) -> some View {
        modifier(BackyardBirdsDataContainerViewModifier(inMemory: inMemory))
    }
}

fileprivate extension View {
    func generateData() -> some View {
        modifier(GenerateDataViewModifier())
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The model for previews.
*/

import SwiftUI
import SwiftData

public struct ModelPreview<Model: PersistentModel, Content: View>: View {
    var content: (Model) -> Content
    
    public init(@ViewBuilder content: @escaping (Model) -> Content) {
        self.content = content
    }
    
    public var body: some View {
        ZStack {
            PreviewContentView(content: content)
        }
        .backyardBirdsDataContainer(inMemory: true)
    }
    
    struct PreviewContentView: View {
        var content: (Model) -> Content
        
        @Query private var models: [Model]
        @State private var waitedToShowIssue = false
        
        var body: some View {
            if let model = models.first {
                content(model)
            } else {
                ContentUnavailableView {
                    Label {
                        Text(verbatim: "Could not load model for previews")
                    } icon: {
                        Image(systemName: "xmark")
                    }
                }
                .opacity(waitedToShowIssue ? 1 : 0)
                .task {
                    Task {
                        try await Task.sleep(for: .seconds(1))
                        waitedToShowIssue = true
                    }
                }
            }
        }
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The color data.
*/

import SwiftUI

public struct ColorData: Codable {
    public var hue: Double
    public var saturation: Double
    public var brightness: Double
    
    public init(hue: Double, saturation: Double, brightness: Double) {
        self.hue = hue
        self.saturation = saturation
        self.brightness = brightness
    }
    
    public var color: Color {
        Color(hue: hue, saturation: saturation, brightness: brightness)
    }
    
    public func darken(_ percent: Double = 0.9) -> ColorData {
        var copy = self
        copy.brightness *= percent
        copy.saturation *= 1 + ((1 - percent) * 0.5)
        return copy
    }
    
    public func interpolate(to other: ColorData, percent: Double, clamped: Bool = true) -> ColorData {
        ColorData(
            hue: Angle.degrees(hue * 360).interpolate(to: Angle.degrees(other.hue * 360), percent: percent).degrees / 360,
            saturation: saturation.interpolate(to: other.saturation, percent: percent, clamped: clamped),
            brightness: brightness.interpolate(to: other.brightness, percent: percent, clamped: clamped)
        )
    }
    
    public static func pastel(hue: Range<Double>, random: inout SeededRandomGenerator) -> ColorData {
        ColorData(hue: .random(in: hue, using: &random), saturation: 0.6, brightness: 1)
    }
    
    public static func pastel(hue: Double) -> ColorData {
        ColorData(hue: hue, saturation: 0.6, brightness: 1)
    }
    
    public static func white(brightness: Double) -> ColorData {
        ColorData(hue: 0, saturation: 0, brightness: brightness)
    }
    
    public static func vibrant(hue: Range<Double>, random: inout SeededRandomGenerator) -> ColorData {
        ColorData(hue: .random(in: hue, using: &random), saturation: 0.6, brightness: 1)
    }
    
    public static var white: ColorData { .init(hue: 0, saturation: 0, brightness: 1) }
}

@propertyWrapper
struct ClampedScalar: Codable {
    var wraps: Bool = false
    var value: Double
    var wrappedValue: Double {
        get { value }
        set {
            var valueToClamp = newValue
            if wraps {
                valueToClamp = valueToClamp.truncatingRemainder(dividingBy: 1)
            }
            value = min(max(valueToClamp, 0), 1)
        }
    }
    
    init(wrappedValue value: Double, wraps: Bool = false) {
        self.value = value
        self.wraps = wraps
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A seeded random number generator wrapper.
*/

import Foundation

public struct SeededRandomGenerator: RandomNumberGenerator {
    public init(seed: Int) {
        srand48(seed)
    }
    
    public func next() -> UInt64 {
        UInt64(drand48() * 0x1.0p64) ^ UInt64(drand48() * 0x1.0p16)
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Options for generating the data.
*/

import Foundation

public class DataGenerationOptions {
    /// A Boolean that you set to indicate whether to display a new bird indicator using PhaseAnimator in SwiftUI.
    public static let showNewBirdIndicatorCard = false
    
    /// A Boolean that you set to indicate whether the first backyard is initially low on water.
    public static let firstBackyardLowOnWater = false
    
    /// Logic that determines how to display the first bird in the default backyard.
    public static let firstBackyardBirdStatus = FirstBackyardBirdStatus.alreadyVisible
    
    /// Birds initially default to visiting for an hour after the app launches.
    public static let currentBirdsVisitingDuration = TimeInterval(hours: 1)
    
    /// When true, do not save data to disk. When false, saves data to disk.
    public static let inMemoryPersistence = true
    
    public static let initialOwnedBirdFoods: [String: Int] = [
        "Nutrition Pellet": 3
    ]
}

// MARK: - FirstBackyardBirdStatus

public extension DataGenerationOptions {
    
    enum FirstBackyardBirdStatus {
        /// The bird is shown initially as if it's been there for a while.
        case alreadyVisible
        
        /// The bird is visiting but needs to be drawn flying in.
        case fliesIn
        
        /// No bird is visiting.
        case notVisiting
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A helper extension used to calculate animation progress and timing.
*/

import Foundation
import SwiftUI

public extension ClosedRange where Bound: BinaryFloatingPoint {
    /// Returns a value between this range's lower and upper bounds, valued by a percentage between the two.
    /// - Parameters:
    ///   - percent: The percentage between lower and upper bound.
    ///   - clamped: Ignores values outside `0...1`; defaults to `true`.
    /// - Returns: A value between lower and upper bound.
    func value(percent: Bound, clamped: Bool = true) -> Bound {
        var percent = percent
        if clamped {
            percent = Swift.min(Swift.max(percent, 0), 1)
        }
        return (1 - percent) * lowerBound + percent * upperBound
    }
    
    /// Returns the percentage of `value` as it lays between this bound's lower and upper bounds.
    /// - Parameters:
    ///   - value: A value between this range's lower and upper bounds.
    ///   - clamped:Clamps the result between `0...1`; defaults to `true`.
    /// - Returns: A value between `0` and `1`.
    func percent(for value: Bound, clamped: Bool = true) -> Bound {
        var result = (value - lowerBound) / (upperBound - value)
        if clamped {
            result = Swift.min(Swift.max(result, 0), 1)
        }
        return result
    }
}

public extension BinaryFloatingPoint {
    /// Returns a value that smoothly ramps from 0 to 1, useful for animation purposes.
    ///
    /// > Important: The value this method is called on must be a finite number.
    /// - Parameter clamped: Ignores values outside `0...1`; defaults to `true`.
    /// - Returns: A value eased from `0` to `1`.
    func easeInOut(clamped: Bool = true) -> Self {
        assert(self.isFinite)
        let timing = clamped ? min(max(self, 0), 1) : self
        return timing * timing * (3.0 - 2.0 * timing)
    }
    
    /// Takes a value from 0 to 1 and returns a value that starts at `0`, eases into `1`, and eases back into `0`.
    ///
    /// For example, the following inputs generate these outputs:
    /// Input  | Output
    /// --- | ---
    /// `0` | `0`
    /// `0.25` | `0.5`
    /// `0.5` | `1`
    /// `0.75` | `0.5`
    /// `1` | `0`
    ///
    /// > Important: The value this method is called on must be a finite number.
    /// - Parameter clamped: Ignores values outside `0...1`; defaults to `true`.
    /// - Returns: A value eased from `0` to `1` and back to `0`.
    func symmetricEaseInOut(clamped: Bool = true) -> Self {
        assert(self.isFinite)
        let timing = clamped ? min(max(self, 0), 1) : self
        if timing <= 0.5 {
            return (timing * 2).easeInOut(clamped: clamped)
        } else {
            return (2 - (timing * 2)).easeInOut(clamped: clamped)
        }
    }
    
    /// Truncates a value by `truncation` and returns the percentage between that value and `truncation` itself.
    ///
    /// If this value is `175` and you pass `50` for the `truncation` value, this returns `0.5` as it is 50 percent of the next `truncation` value.
    ///
    /// > Important: The value this method is called on must be a finite number.
    /// - Parameter truncation: A value used to both truncate the starting value and to determine percentage.
    /// - Returns: A value from `0` to `1`.
    func percent(truncation: Self) -> Self {
        assert(self.isFinite)
        assert(!truncation.isZero && truncation.isFinite)
        return self.truncatingRemainder(dividingBy: truncation) / truncation
    }
    
    /// Maps this value, assumed to be a percentage from `0` to `1`, to the corresponding value between the `range` of the lower and upper bounds.
    ///
    /// If this value is `0.5` and you pass a range from `0` to `10`, the result is `5` because that's 50 percent of the range passed.
    ///
    /// > Important: The value this method is called on must be a finite number.
    /// - Parameters:
    ///   - range: A closed range.
    ///   - clamped: Ignores values outside `0...1`; defaults to `true`.
    /// - Returns: A value within the range, determined by the value this method is called on, presumedly a percentage from `0` to `1`.
    func map(to range: ClosedRange<Self>, clamped: Bool = true) -> Self {
        assert(self.isFinite)
        return range.value(percent: self, clamped: clamped)
    }
    
    /// Maps a value from `originalRange` into a percentage that is used to return an equivalent value in `newRange`.
    ///
    /// > Important: The value this method is called on must be a finite number.
    /// - Parameters:
    ///   - originalRange: A range used to convert a value into a percentage.
    ///   - newRange: A range that determines the possible resulting value.
    ///   - clamped: Ignores percentages in either range that are outside `0...1`; defaults to `true`.
    /// - Returns: A value within `newRange` based on this value's relative percentage within `originalRange`.
    func remap(from originalRange: ClosedRange<Self>, to newRange: ClosedRange<Self>, clamped: Bool = true) -> Self {
        assert(self.isFinite)
        return newRange.value(percent: originalRange.percent(for: self, clamped: clamped), clamped: clamped)
    }
    
    func interpolate(to destination: Self, percent: Self, clamped: Bool = true) -> Self {
        let percent = clamped ? min(max(percent, 0), 1) : percent
        return (1 - percent) * self + percent * destination
    }
}

extension Angle {
    func interpolate(to destination: Angle, percent: Double) -> Angle {
        let max = Double.pi * 2
        let deltaAngle = (destination.radians - self.radians).truncatingRemainder(dividingBy: max)
        let distance = (2 * deltaAngle).truncatingRemainder(dividingBy: max) - deltaAngle
        return Angle.radians(self.radians + distance * percent)
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An extension to TimeInterval.
*/

import Foundation

public extension TimeInterval {
    /// Creates an imaginary time of day for a backyard.
    ///
    /// - Note: This code is solely intended for use with Backyard Birds sample imaginary to simulate a "time of day" for each backyard.
    /// When dealing with real-world time, use `Date` and `Calendar` instead.
    init(days: Double = 0, hours: Double = 0, minutes: Double = 0, seconds: Double = 0) {
        self = (24 * 60 * 60 * days) + (60 * 60 * hours) + (60 * minutes) + seconds
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The generation data.
*/

import Observation
import SwiftData
import OSLog

private let logger = Logger(subsystem: "BackyardBirdsData", category: "DataGeneration")

// MARK: - Data Generation

@Model public class DataGeneration {
    public var initializationDate: Date?
    public var lastSimulationDate: Date?
    
    @Transient public var includeEarlyAccessSpecies: Bool = false
    
    public var requiresInitialDataGeneration: Bool {
        initializationDate == nil
    }
    
    public init(initializationDate: Date?, lastSimulationDate: Date?, includeEarlyAccessSpecies: Bool = false) {
        self.initializationDate = initializationDate
        self.lastSimulationDate = lastSimulationDate
        self.includeEarlyAccessSpecies = includeEarlyAccessSpecies
    }
    
    private func simulateHistoricalEvents(modelContext: ModelContext) {
        logger.info("Attempting to simulate historical events...")
        if requiresInitialDataGeneration {
            logger.info("Requires an initial data generation")
            generateInitialData(modelContext: modelContext)
        }
    }
    
    private func generateInitialData(modelContext: ModelContext) {
        logger.info("Generating initial data...")
        
        // First, generate all available bird food, bird species, and plant species.
        logger.info("Generating all bird foods")
        BirdFood.generateAll(modelContext: modelContext)
        logger.info("Generating all bird species")
        BirdSpecies.generateAll(modelContext: modelContext)
        logger.info("Generating plant species")
        PlantSpecies.generateAll(modelContext: modelContext)
        
        // Then, generate instances of individual plants not tied to any backyards, all of the birds,
        // and finally the backyards themselves (with their own plants).
        logger.info("Generating initial instances of individual plants")
        Plant.generateIndividualPlants(modelContext: modelContext)
        logger.info("Generating initial instances of all birds")
        Bird.generateAll(modelContext: modelContext)
        logger.info("Generating initial instances of backyards")
        Backyard.generateAll(modelContext: modelContext)
        
        logger.info("Generating account")
        // The app content is complete, now it's time to create the person's account.
        Account.generateAccount(modelContext: modelContext)
        
        logger.info("Completed generating initial data")
        initializationDate = .now
    }
    
    private func generateVisitorEvents(modelContext: ModelContext, includeEarlyAccessSpecies: Bool = false) {
        guard lastSimulationDate == nil else {
            return
        }
        logger.info("Generating visitor events")
        BackyardVisitorEvent.generateHistoricalEvents(
            modelContext: modelContext,
            includeEarlyAccessSpecies: includeEarlyAccessSpecies
        )
        BackyardVisitorEvent.generateCurrentEvents(
            modelContext: modelContext,
            includeEarlyAccessSpecies: includeEarlyAccessSpecies
        )
        BackyardVisitorEvent.generateFutureEvents(
            modelContext: modelContext,
            includeEarlyAccessSpecies: includeEarlyAccessSpecies
        )
        lastSimulationDate = .now
    }

    private static func instance(with modelContext: ModelContext) -> DataGeneration {
        if let result = try! modelContext.fetch(FetchDescriptor<DataGeneration>()).first {
            return result
        } else {
            let instance = DataGeneration(
                initializationDate: nil,
                lastSimulationDate: nil
            )
            modelContext.insert(instance)
            return instance
        }
    }
    
    public static func generateAllData(modelContext: ModelContext) {
        let instance = instance(with: modelContext)
        logger.info("Attempting to statically simulate historical events...")
        instance.simulateHistoricalEvents(modelContext: modelContext)
    }
    
    public static func generateVisitorEvents(modelContext: ModelContext, includeEarlyAccessSpecies: Bool = false) {
        let instance = instance(with: modelContext)
        instance.generateVisitorEvents(
            modelContext: modelContext,
            includeEarlyAccessSpecies: includeEarlyAccessSpecies
        )
    }
    
}

public extension DataGeneration {
    static let container = try! ModelContainer(for: schema, configurations: [.init(inMemory: DataGenerationOptions.inMemoryPersistence)])
    
    static let schema = SwiftData.Schema([
        DataGeneration.self,
        Account.self,
        PlantSpecies.self,
        Plant.self,
        BirdSpecies.self,
        BirdFood.self,
        Bird.self,
        Backyard.self,
        BackyardVisitorEvent.self
    ])
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The generation of bird food data.
*/

import OSLog
import SwiftData

private let logger = Logger(subsystem: "Backyard Birds Data", category: "BirdFood")

extension BirdFood {
    static func generateAll(modelContext: ModelContext) {
        logger.info("Generating all Bird Food...")
        
        logger.info("Nutrition Pellet")
        modelContext.insert(BirdFood(
            id: "Nutrition Pellet",
            name: String(localized: "Nutrition Pellet", table: "BirdFood", bundle: .module),
            summary: String(localized: "A nutritious snack that any bird loves.", table: "BirdFood", bundle: .module),
            products: [
                Product(
                    id: "pellet.single",
                    quantity: 1
                ),
                Product(
                    id: "pellet.box",
                    quantity: 5
                )
            ],
            priority: 3
        ))

        logger.info("Nectar")
        modelContext.insert(BirdFood(
            id: "Nectar",
            name: String(localized: "Nectar", table: "BirdFood", bundle: .module),
            summary: String(localized: "A sweet nectar to draw birds to your backyard.", table: "BirdFood", bundle: .module),
            products: [
                Product(
                    id: "nectar.cup",
                    quantity: 1
                ),
                Product(
                    id: "nectar.bottle",
                    quantity: 5
                )
            ],
            priority: 2
        ))

        logger.info("Golden Acorn")
        modelContext.insert(BirdFood(
            id: "Golden Acorn",
            name: String(localized: "Golden Acorn", table: "BirdFood", bundle: .module),
            summary: String(localized: "Birds crave this golden treat.", table: "BirdFood", bundle: .module),
            products: [
                Product(
                    id: "acorns.individual",
                    quantity: 1
                ),
                Product(
                    id: "acorns.collection",
                    quantity: 5
                )
            ]
        ))
        
        logger.info("Sunflower seeds")
        modelContext.insert(BirdFood(
            id: "Sunflower Seeds",
            name: String(localized: "Sunflower Seeds", table: "BirdFood", bundle: .module),
            summary: String(localized: "A favorite for many backyard visitors.", table: "BirdFood", bundle: .module)
        ))
        
        modelContext.insert(BirdFood(
            id: "Corn",
            name: String(localized: "Corn", table: "BirdFood", bundle: .module),
            summary: String(localized: "Sweet treats for our feathered friends.", table: "BirdFood", bundle: .module)
        ))
        
        modelContext.insert(BirdFood(
            id: "Millet Seeds",
            name: String(localized: "Millet Seeds", table: "BirdFood", bundle: .module),
            summary: String(localized: "Fun fall flavor in every bite.", table: "BirdFood", bundle: .module)
        ))
        
        modelContext.insert(BirdFood(
            id: "Peanuts",
            name: String(localized: "Peanuts", table: "BirdFood", bundle: .module),
            summary: String(localized: "Deshelled peanuts, buttery smooth taste!", table: "BirdFood", bundle: .module)
        ))
        
        modelContext.insert(BirdFood(
            id: "Safflower Seeds",
            name: String(localized: "Safflower Seeds", table: "BirdFood", bundle: .module),
            summary: String(localized: "The bitter rival of sunflower seeds.", table: "BirdFood", bundle: .module)
        ))
        
        modelContext.insert(BirdFood(
            id: "Sorghum Seeds",
            name: String(localized: "Sorghum Seeds", table: "BirdFood", bundle: .module),
            summary: String(localized: "Winter delight to make for a cozy backyard.", table: "BirdFood", bundle: .module)
        ))
        
        for food in try! modelContext.fetch(FetchDescriptor<BirdFood>()) {
            if let quantity = DataGenerationOptions.initialOwnedBirdFoods[food.id] {
                food.ownedQuantity = quantity
            }
        }
        
        logger.info("Completed generating all of the bird food.")
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The result of eating particular bird food.
*/

import Foundation
import SwiftUI

public struct BirdEatFoodResult {
    public var bird: Bird
    public var food: BirdFood
    public var enjoyment: Enjoyment
    
    public init(bird: Bird, food: BirdFood) {
        self.bird = bird
        self.food = food
        
        if food.isPremium {
            enjoyment = .enjoy
        } else if bird.favoriteFood == food {
            enjoyment = .favorite
        } else if bird.dislikedFoods.first(where: { $0.id == food.id }) != nil {
            enjoyment = .dislike
        } else {
            enjoyment = .neutral
        }
    }
    
    public enum Enjoyment {
        case dislike
        case neutral
        case enjoy
        case favorite
    }
}

// MARK: - Localized Title & Icon

public extension BirdEatFoodResult {
    var title: String {
        switch enjoyment {
        case .dislike:
            String(
                localized: "\(bird.speciesName) did not like \(food.name)...",
                table: "BirdFood",
                bundle: .module,
                comment: "The first variable is a bird name, and the second variable is a food name. Shown after a bird eats food they didn't like."
            )
        case .neutral:
            String(
                localized: "\(bird.speciesName) had no opinion on \(food.name).",
                table: "BirdFood",
                bundle: .module,
                comment: """
                    The first variable is a bird name, and the second variable is a food name. Shown after a bird eats food they liked or disliked.
                """
            )
        case .enjoy:
            String(
                localized: "\(bird.speciesName) enjoyed \(food.name)!",
                table: "BirdFood",
                bundle: .module,
                comment: "The first variable is a bird name, and the second variable is a food name. Shown after a bird eats food they liked."
            )
        case .favorite:
            String(
                localized: "\(bird.speciesName) loved \(food.name)!",
                table: "BirdFood",
                bundle: .module,
                comment: "The first variable is a bird name, and the second variable is a food name. Shown after a bird eats their favorite food."
            )
        }
    }
    
    var icon: Image {
        switch enjoyment {
        case .dislike:
            Image(systemName: "hand.thumbsdown")
        case .neutral:
            Image(systemName: "zzz")
        case .enjoy:
            Image(systemName: "hand.thumbsup")
        case .favorite:
            Image(systemName: "heart")
        }
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The fountain variants.
*/

import Foundation

public enum FountainVariant: String, CaseIterable, Codable {
    case terracotta = "Terracotta"
    case stone = "Stone"
    case marble = "Marble"
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The bird food.
*/

import Observation
import SwiftUI
import SwiftData
import OSLog

private let logger = Logger(subsystem: "Backyard Birds Data", category: "BirdFood")

@Model public class BirdFood {
    @Attribute(.unique) public var id: String
    public var name: String
    public var summary: String
    public var priority: Int

    /// The corresponding in-app purchase products if this is a premium food item.
    public var products: [Product]
    /// The owned quantity if this is a premium food item.
    public var ownedQuantity: Int
    /// Track the StoreKit transactions that  have finished for this product
    /// to avoid repeatedly granting content for one transaction.
        
    public var isPremium: Bool {
        !products.isEmpty
    }
    
    public var orderedProducts: [Product] {
        products.sorted { lhs, rhs in
            lhs.quantity < rhs.quantity
        }
    }
    
    public init(
        id: String,
        name: String,
        summary: String,
        products: [Product] = [],
        priority: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.summary = summary
        self.products = products
        self.ownedQuantity = 0
        self.priority = priority ?? (products.isEmpty ? 0 : 1)
//        self.finishedTransactions = []
    }
    
    public struct Product: Identifiable, Codable {
        public var id: String
        public var quantity: Int
    }
}

// MARK: - All Bird Food

extension BirdFood {
    public var image: Image {
        Image("Bird Food/\(id)", bundle: .module)
            .resizable()
    }
    
    public var alternateImage: Image {
        Image("Bird Food/Shop Alternates/\(id)", bundle: .module)
            .resizable()
    }
}

extension Sequence where Element == BirdFood {
    
    public func birdFood(for productID: String) -> (BirdFood, BirdFood.Product)? {
        lazy.compactMap { birdFood in
            birdFood.products
                .first { $0.id == productID }
                .map { (birdFood, $0) }
        }
        .first
    }
    
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The parts of a bird's anatomy.
*/

import Foundation

public struct BirdPart: Identifiable, Codable {
    public var id: String { name }
    public var name: String
    public var colorStyle: Int = BirdPartColorStyle.body.rawValue
    public var pivotX: Double?
    public var pivotY: Double?
    public var isBody: Bool = false
    public var isEye: Bool = false
    public var isWing: Bool = false
    public var flipbookFrameCount: Int?
    public var chance: Double?
    
    static func feet(x: Double? = nil, y: Double? = nil) -> BirdPart {
        BirdPart(name: "Feet", colorStyle: BirdPartColorStyle.white.rawValue, pivotX: x, pivotY: y)
    }
    
    static func body(x: Double? = nil, y: Double? = nil) -> BirdPart {
        BirdPart(name: "Body", colorStyle: BirdPartColorStyle.body.rawValue, pivotX: x, pivotY: y, isBody: true)
    }
    
    static var belly: BirdPart {
        BirdPart(name: "Belly", colorStyle: BirdPartColorStyle.belly.rawValue)
    }
    
    static var chin: BirdPart {
        BirdPart(name: "Chin", colorStyle: BirdPartColorStyle.accent.rawValue)
    }
    
    static func eye(x: Double? = nil, y: Double? = nil) -> BirdPart {
        BirdPart(name: "Eye", colorStyle: BirdPartColorStyle.white.rawValue, pivotX: x, pivotY: y, isEye: true)
    }
    
    static func beak(x: Double? = nil, y: Double? = nil) -> BirdPart {
        BirdPart(name: "Beak", colorStyle: BirdPartColorStyle.beak.rawValue, pivotX: x, pivotY: y)
    }
    
    static func wing(x: Double? = nil, y: Double? = nil) -> BirdPart {
        BirdPart(name: "Wing", colorStyle: BirdPartColorStyle.wing.rawValue, pivotX: x, pivotY: y, isWing: true)
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The bird data.
*/

import Observation
import Foundation
import SwiftData
import SwiftUI

@Model public class Bird {
    @Attribute(.unique) public var id: String
    public var creationDate: Date
    
    public var species: BirdSpecies!
    public var favoriteFood: BirdFood!
    public var dislikedFoods: [BirdFood]
    public var colors: BirdPalette
    public var tag: String?
    public var lastKnownVisit: Date?
    
    /// The preferred time of day, when shown in the UI.
    public var backgroundTimeInterval: Double
    
    public var speciesName: String { species.info.name }
    public var speciesSummary: String { species.info.summary }
    
    public var visitStatus: BirdVisitStatus {
        if let lastKnownVisit {
            .recently(lastKnownVisit)
        } else {
            .never
        }
    }
    
    public init(creationDate: Date = .now, colors: BirdPalette, tag: BirdTag? = nil, backgroundTimeInterval: TimeInterval = TimeInterval(hours: 10)) {
        self.id = UUID().uuidString
        self.creationDate = creationDate
        self.colors = colors
        self.tag = tag?.rawValue
        self.backgroundTimeInterval = backgroundTimeInterval
    }
    
    public func updateVisitStatus(visitedOn date: Date) {
        guard date <= .now else { return }
        if let lastKnownVisit, lastKnownVisit > date {
            return
        }
        lastKnownVisit = date
    }
}

public enum BirdTag: String, Hashable, Codable {
    case classicGreenHummingbird
    case premiumGoldenHummingbird
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The bird species info.
*/

import Foundation

public struct BirdSpeciesInfo: RawRepresentable, Hashable, CaseIterable, Codable {
    public var rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public static var allCases: [BirdSpeciesInfo] = [
        .swallow, .dove, .chickadee, .petrel, .cardinal, .hummingbird
    ]
    
    public static let swallow = Self(rawValue: "Bird 1")
    public static let dove = Self(rawValue: "Bird 2")
    public static let chickadee = Self(rawValue: "Bird 3")
    public static let petrel = Self(rawValue: "Bird 4")
    public static let cardinal = Self(rawValue: "Bird 5")
    public static let hummingbird = Self(rawValue: "Bird 6")
    
    public var name: String {
        switch self {
        case .swallow:
            String(localized: "Swallow", table: "Birds", bundle: .module, comment: "Bird 1 name")
        case .dove:
            String(localized: "Dove", table: "Birds", bundle: .module, comment: "Bird 2 name")
        case .chickadee:
            String(localized: "Chickadee", table: "Birds", bundle: .module, comment: "Bird 3 name")
        case .petrel:
            String(localized: "Petrel", table: "Birds", bundle: .module, comment: "Bird 4 name")
        case .cardinal:
            String(localized: "Cardinal", table: "Birds", bundle: .module, comment: "Bird 5 name")
        case .hummingbird:
            String(localized: "Hummingbird", table: "Birds", bundle: .module, comment: "Bird 6 name")
        default:
            fatalError()
        }
    }
    
    public var summary: String {
        switch self {
        case .swallow:
            String(localized: "A cutie, common to many a backyard.", table: "Birds", bundle: .module, comment: "Bird 1 summary")
        case .dove:
            String(localized: "Happy to eat just about anything.", table: "Birds", bundle: .module, comment: "Bird 2 summary")
        case .chickadee:
            String(localized: "Particularly picky about its food.", table: "Birds", bundle: .module, comment: "Bird 3 summary")
        case .petrel:
            String(localized: "Enjoys a good backyard fountain.", table: "Birds", bundle: .module, comment: "Bird 4 summary")
        case .cardinal:
            String(localized: "Loud and proud, with amazing style.", table: "Birds", bundle: .module, comment: "Bird 5 summary")
        case .hummingbird:
            String(localized: "Frequent flier amongst the flowers.", table: "Birds", bundle: .module, comment: "Bird 6 summary")
        default:
            fatalError()
        }
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A palette of colors for different birds.
*/

import Observation
import SwiftData

public struct BirdPalette: Codable {
    public var body: ColorData
    public var wing: ColorData
    public var beak: ColorData
    public var belly: ColorData
    public var accent: ColorData
    
    public init(body: ColorData, wing: ColorData? = nil, beak: ColorData, belly: ColorData = .white, accent: ColorData = .white) {
        self.body = body
        self.wing = wing ?? body
        self.belly = belly
        self.accent = accent
        self.beak = beak
    }
    
    public func colorData(for colorStyleRawValue: Int) -> ColorData {
        let colorStyle = BirdPartColorStyle(rawValue: colorStyleRawValue)
        switch colorStyle {
        case .body: return body
        case .wing: return wing
        case .belly: return belly
        case .accent: return accent
        case .beak: return beak
        case .white: return .white
        case .black: return .birdBlack
        default:
            fatalError("I didn't know a bird had that part!")
        }
    }
}

public struct BirdPartColorStyle: Hashable, Codable {
    var rawValue: Int = 0
    /// The color for a bird's body.
    static let body = Self(rawValue: 0)
    /// A wing of the bird.
    static let wing = Self(rawValue: 1)
    /// A primary supplemental color.
    static let belly = Self(rawValue: 2)
    /// A secondary supplemental color.
    static let accent = Self(rawValue: 3)
    /// A color appropriate for a beak.
    static let beak = Self(rawValue: 4)
    /// An uncolored bird part, like the eyes and feet.
    static let white = Self(rawValue: 5)
    /// A part of the bird that's colored black.
    static let black = Self(rawValue: 6)
    
    static let allCases: [BirdPartColorStyle] = [
        .body, .wing, .belly, .accent, .beak, .white, .black
    ]
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The bird visit status.
*/

import Foundation

public enum BirdVisitStatus {
    case never
    case recently(Date)
}

// MARK: - Localized Title

public extension BirdVisitStatus {
    var title: String {
        switch self {
        case .never:
            return String(
                localized: "Not yet seen",
                table: "Birds",
                bundle: .module,
                comment: "A phrase used to indicate that a bird has never visited a backyard."
            )
        case .recently(let date):
            return String(
                localized: "Seen \(date.formatted(.relative(presentation: .numeric, unitsStyle: .narrow)))",
                table: "Birds",
                bundle: .module,
                comment: "The variable is a shorthand formatted duration. For example, 4d, 30m, or 20s ago."
            )
        }
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The bird sorting criteria.
*/

import Foundation

public enum BirdSortCriteria {
    case recentlyVisited
    case favoriteFood
    case dislikedFoods
    case favorites
    case species
}

public extension BirdSortCriteria {
    var title: String {
        switch self {
        case .recentlyVisited:
            String(
                localized: "Recently Visited",
                table: "Birds",
                bundle: .module,
                comment: "A short phrase that describes a sort criteria based on how recently a bird has visited."
            )
        case .favoriteFood:
            String(
                localized: "Favorite Food",
                table: "Birds",
                bundle: .module,
                comment: "A short phrase that describes a sort criteria based on birds' favorite foods."
            )
        case .dislikedFoods:
            String(
                localized: "Disliked Foods",
                table: "Birds",
                bundle: .module,
                comment: "A short phrase that describes a sort criteria based on birds' disliked foods."
            )
        case .favorites:
            String(
                localized: "Favorite Birds",
                table: "Birds",
                bundle: .module,
                comment: "A short phrase that describes a sort criteria for the user's favorite birds."
            )
        case .species:
            String(
                localized: "Species",
                table: "Birds",
                bundle: .module,
                comment: "A short phrase that describes a sort criteria based on the bird species."
            )
        }
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The generation of bird species data.
*/

import Foundation
import SwiftData
import OSLog

private let logger = Logger(subsystem: "BackyardBirdsData", category: "BirdSpecies")

extension BirdSpecies {
    static func generateAll(modelContext: ModelContext) {
        logger.info("Generating all bird species")
        
        modelContext.insert(BirdSpecies(
            info: .swallow,
            naturalScale: 0.83,
            parts: [
                .feet(x: 0.58, y: 0.65),
                .body(x: 0.6, y: 0.5),
                .belly,
                .chin,
                .eye(x: 0.7, y: 0.29),
                .beak(x: 0.8, y: 0.3),
                .wing(x: 0.63, y: 0.41)
            ]
        ))
        
        modelContext.insert(BirdSpecies(
            info: .dove,
            naturalScale: 1,
            parts: [
                .feet(),
                .body(),
                .belly,
                .eye(),
                .wing(),
                .beak()
            ]
        ))
        
        modelContext.insert(BirdSpecies(
            info: .chickadee,
            naturalScale: 0.71,
            isEarlyAccess: true,
            parts: [
                .feet(),
                .body(),
                .belly,
                .eye(),
                .beak(),
                .wing()
            ]
        ))
        
        modelContext.insert(BirdSpecies(
            info: .petrel,
            naturalScale: 1,
            parts: [
                .feet(),
                .body(),
                .belly,
                .chin,
                BirdPart(name: "Head", colorStyle: BirdPartColorStyle.black.rawValue),
                .eye(),
                .beak(),
                .wing()
            ]
        ))
        
        modelContext.insert(BirdSpecies(
            info: .cardinal,
            naturalScale: 1,
            parts: [
                .feet(),
                .body(),
                .belly,
                .beak(),
                .eye(),
                .wing()
            ]
        ))
        
        modelContext.insert(BirdSpecies(
            info: .hummingbird,
            naturalScale: 0.76,
            parts: [
                BirdPart(name: "BackWing", colorStyle: BirdPartColorStyle.wing.rawValue, isWing: true, flipbookFrameCount: 2),
                .body(),
                .belly,
                .chin,
                .eye(),
                .beak(),
                BirdPart(name: "FrontWing", colorStyle: BirdPartColorStyle.wing.rawValue, isWing: true, flipbookFrameCount: 2)
            ]
        ))
        
        logger.info("Generated bird species")
    }
}



/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The generation of bird data.
*/

import Foundation
import SwiftData

extension Bird {
    static func generateAll(modelContext: ModelContext) {
        var random = SeededRandomGenerator(seed: 1)
        
        let allBirdFoods = try! modelContext.fetch(FetchDescriptor<BirdFood>(sortBy: [.init(\.id)]))
        let allBirdSpecies = try! modelContext.fetch(FetchDescriptor<BirdSpecies>(sortBy: [.init(\.id)]))
        
        let hummingbirdSpecies = allBirdSpecies.first(where: { $0.info == .hummingbird })!
        
        do {
            let bird = Bird(
                creationDate: .init(timeIntervalSinceNow: -5),
                colors: .hummingbirdPalettes[0],
                tag: .classicGreenHummingbird,
                backgroundTimeInterval: TimeInterval(hours: 12)
            )
            modelContext.insert(bird)
            bird.species = hummingbirdSpecies
            bird.favoriteFood = allBirdFoods.randomElement(using: &random)!
        }
        
        do {
            let bird = Bird(
                creationDate: .init(timeIntervalSinceNow: -3),
                colors: .hummingbirdPalettes[2],
                tag: .premiumGoldenHummingbird,
                backgroundTimeInterval: TimeInterval(hours: 12)
            )
            modelContext.insert(bird)
            bird.species = hummingbirdSpecies
            bird.favoriteFood = allBirdFoods.randomElement(using: &random)!
        }
        
        for species in allBirdSpecies {
            generateBird(species: species)
        }
        
        for species in allBirdSpecies {
            let total = Int.random(in: 5..<8, using: &random)
            for _ in 0 ..< total {
                generateBird(species: species)
            }
        }
        
        func generateBird(species: BirdSpecies) {
            let favoriteFood = allBirdFoods.randomElement(using: &random)!
            var dislikedFoods: [BirdFood] = []
            let totalUnfavored = Int.random(in: 0..<3, using: &random)
            var remainingFood = allBirdFoods
            remainingFood.removeAll(where: { $0.id == favoriteFood.id })
            for _ in 0 ..< totalUnfavored {
                let food = remainingFood.randomElement(using: &random)!
                dislikedFoods.append(food)
                remainingFood.removeAll(where: { $0.id == food.id })
            }
            let bird = Bird(
                colors: .generateColors(info: species.info, random: &random),
                backgroundTimeInterval: .random(in: 0..<TimeInterval(days: 1), using: &random)
            )
            modelContext.insert(bird)
            bird.species = species
            bird.favoriteFood = favoriteFood
            bird.dislikedFoods = dislikedFoods
        }
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The bird species.
*/

import Observation
import Foundation
import SwiftData

@Model public class BirdSpecies {
    @Attribute(.unique) public var id: String
    public var naturalScale: Double = 1
    public var isEarlyAccess: Bool
    public var parts: [BirdPart]
    
    @Relationship(.cascade, inverse: \Bird.species)
    public var birds: [Bird]
    
    public var info: BirdSpeciesInfo { BirdSpeciesInfo(rawValue: id) }
    
    public init(info: BirdSpeciesInfo, naturalScale: Double = 1, isEarlyAccess: Bool = false, parts: [BirdPart]) {
        self.id = info.rawValue
        self.naturalScale = naturalScale
        self.isEarlyAccess = isEarlyAccess
        self.parts = parts
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The generation of bird palette data.
*/

import SwiftData

extension BirdPalette {
    static func generateColors(info: BirdSpeciesInfo, random: inout SeededRandomGenerator) -> BirdPalette {
        switch info {
        case .swallow:
            return swallowPalettes.randomElement(using: &random)!
        case .dove:
            return dovePalettes.randomElement(using: &random)!
        case .chickadee:
            return chickadeePalettes.randomElement(using: &random)!
        case .petrel:
            return petrelPalettes.randomElement(using: &random)!
        case .cardinal:
            return cardinalPalettes.randomElement(using: &random)!
        case .hummingbird:
            return hummingbirdPalettes.randomElement(using: &random)!
        default:
            fatalError()
        }
    }
    
    // MARK: - Palettes
    
    static let swallowPalettes: [BirdPalette] = [
        BirdPalette(body: .birdRed, beak: .birdBlack),
        BirdPalette(body: .birdBrown, beak: .birdBlack, belly: .birdBeige, accent: .birdOrange),
        BirdPalette(body: .birdOrange, beak: .birdBlack, accent: .birdBlack),
        BirdPalette(body: .birdDarkBlue, beak: .birdBlack, accent: .birdBlack),
        BirdPalette(body: .birdBlack, beak: .birdBlack, accent: .birdRed),
        BirdPalette(body: .birdWhite, beak: .birdBlack, accent: .birdBlue),
        BirdPalette(body: .birdPurple, beak: .birdBlack, accent: .birdBlack)
    ]

    static let dovePalettes: [BirdPalette] = [
        BirdPalette(body: .birdRed, beak: .birdYellow),
        BirdPalette(body: .birdBrown, beak: .birdBlack, belly: .birdBeige),
        BirdPalette(body: .birdYellow, beak: .birdBlack),
        BirdPalette(body: .birdBlue, wing: .birdWhite, beak: .birdBlack),
        BirdPalette(body: .birdBlack, beak: .birdBlack, belly: .birdBlack),
        BirdPalette(body: .birdWhite, beak: .birdBlack, belly: .birdWhite),
        BirdPalette(body: .birdPurple, beak: .birdBlack, belly: .birdLightPurple)
    ]

    static let chickadeePalettes: [BirdPalette] = [
        BirdPalette(body: .birdRed, beak: .birdYellow),
        BirdPalette(body: .birdBrown, beak: .birdYellow),
        BirdPalette(body: .birdYellow, beak: .birdYellow),
        BirdPalette(body: .birdBlue, wing: .birdBlack, beak: .birdYellow),
        BirdPalette(body: .birdBlack, beak: .birdBlack),
        BirdPalette(body: .birdWhite, beak: .birdYellow),
        BirdPalette(body: .birdPurple, beak: .birdBlack, belly: .birdLightPurple)
    ]

    static let petrelPalettes: [BirdPalette] = [
        BirdPalette(body: .birdRed, beak: .birdYellow, belly: .birdWhite, accent: .birdWhite),
        BirdPalette(body: .birdBrown, beak: .birdYellow, belly: .birdBeige, accent: .birdOrange),
        BirdPalette(body: .birdYellow, beak: .birdYellow, accent: .birdOrange),
        BirdPalette(body: .birdBlue, beak: .birdYellow, accent: .birdBlue),
        BirdPalette(body: .birdBlack, beak: .birdYellow, accent: .birdBlack),
        BirdPalette(body: .birdWhite, beak: .birdYellow, accent: .birdWhite),
        BirdPalette(body: .birdPurple, beak: .birdBlack, belly: .birdLightPurple, accent: .birdPurple)
    ]

    static let cardinalPalettes: [BirdPalette] = [
        BirdPalette(body: .birdRed, beak: .birdYellow, belly: .birdBeige),
        BirdPalette(body: .birdBrown, beak: .birdYellow, belly: .birdBeige),
        BirdPalette(body: .birdYellow, beak: .birdBrown),
        BirdPalette(body: .birdBlue, beak: .birdBlack),
        BirdPalette(body: .birdBlack, beak: .birdBlack, belly: .birdRed),
        BirdPalette(body: .birdWhite, beak: .birdBlack),
        BirdPalette(body: .birdPurple, beak: .birdBlack, belly: .birdLightPurple)
    ]

    static let hummingbirdPalettes: [BirdPalette] = [
        BirdPalette(body: .birdGreen, beak: .birdBlack, belly: .birdLightGreen, accent: .birdPink),
        BirdPalette(body: .birdDarkBlue, beak: .birdBlack, accent: .birdPink),
        BirdPalette(body: .birdYellow, beak: .birdBlack, accent: .birdPink),
        BirdPalette(body: .birdBlack, beak: .birdBlack, accent: .birdPurple),
        BirdPalette(body: .birdPurple, beak: .birdBlack, belly: .birdLightPurple, accent: .birdPurple),
        BirdPalette(body: .birdTeal, beak: .birdBlack, belly: .birdLightGreen, accent: .birdDarkBlue)
    ]
}

// MARK: - Individual Colors

extension ColorData {
    static let birdBeige = ColorData(hue: 28 / 360, saturation: 0.17, brightness: 0.94)
    static let birdBlack = ColorData(hue: 285 / 360, saturation: 0, brightness: 0.29)
    static let birdBlue = ColorData(hue: 212 / 360, saturation: 0.43, brightness: 0.85)
    static let birdBrown = ColorData(hue: 28 / 360, saturation: 0.70, brightness: 0.54)
    static let birdDarkBlue = ColorData(hue: 212 / 360, saturation: 0.64, brightness: 0.80)
    static let birdGray = ColorData(hue: 0 / 360, saturation: 0, brightness: 0.77)
    static let birdGreen = ColorData(hue: 89 / 360, saturation: 0.53, brightness: 0.77)
    static let birdLightGreen = ColorData(hue: 90 / 360, saturation: 0.13, brightness: 0.95)
    static let birdLightPurple = ColorData(hue: 283 / 360, saturation: 0.37, brightness: 0.90)
    static let birdOrange = ColorData(hue: 30 / 360, saturation: 0.81, brightness: 0.94)
    static let birdPink = ColorData(hue: 327 / 360, saturation: 0.48, brightness: 0.91)
    static let birdPurple = ColorData(hue: 283 / 360, saturation: 0.61, brightness: 0.86)
    static let birdRed = ColorData(hue: 353 / 360, saturation: 0.75, brightness: 0.87)
    static let birdTeal = ColorData(hue: 166 / 360, saturation: 0.64, brightness: 0.77)
    static let birdWhite = ColorData(hue: 0 / 360, saturation: 0, brightness: 0.96)
    static let birdYellow = ColorData(hue: 37 / 360, saturation: 0.68, brightness: 0.94)
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The backyard supplies.
*/

import Foundation

private let timeIntervalUntilFoodLow = TimeInterval(hours: 8)
private let timeIntervalUntilFoodEmpty = timeIntervalUntilFoodLow + TimeInterval(hours: 1)
private let timeIntervalUntilWaterLow = TimeInterval(hours: 15)
private let timeIntervalUntilWaterEmpty = timeIntervalUntilWaterLow + TimeInterval(hours: 1)

public enum BackyardSupplies: Hashable, CaseIterable, Codable {
    case food
    case water
    
    public var title: String {
        switch self {
        case .food:
            String(localized: "Food")
        case .water:
            String(localized: "Water")
        }
    }
    
    /// The approximate number of seconds after being refilled until this supply is considered "low".
    public var durationUntilLow: TimeInterval {
        switch self {
        case .food:
            timeIntervalUntilFoodLow
        case .water:
            timeIntervalUntilWaterLow
        }
    }
    
    /// The approximate number of seconds after being refilled until this supply is empty.
    public var totalDuration: TimeInterval {
        switch self {
        case .food:
            timeIntervalUntilFoodEmpty
        case .water:
            timeIntervalUntilWaterEmpty
        }
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The backyard time of day.
*/

import Foundation
import SwiftUI

public enum BackyardTimeOfDay: Hashable, Codable {
    case night, sunrise, morning, afternoon, sunset
    
    public init(timeInterval: TimeInterval) {
        let timeInterval = timeInterval.truncatingRemainder(dividingBy: TimeInterval(days: 1))
        let hour = Int(floor(timeInterval / TimeInterval(hours: 1)))
        self.init(hour: hour)
    }
    
    public init(afterTimeInterval timeInterval: TimeInterval) {
        let timeInterval = timeInterval.truncatingRemainder(dividingBy: TimeInterval(days: 1))
        let hour = Int(floor(timeInterval / TimeInterval(hours: 1)))
        self.init(hour: hour + 1)
    }
    
    public init(hour: Int) {
        switch hour {
        case 0 ..< 6:
            self = .night
        case 6:
            self = .sunrise
        case 7 ..< 12:
            self = .morning
        case 12 ..< 20:
            self = .afternoon
        case 20:
            self = .sunset
        default:
            self = .night
        }
    }
    
    @ViewBuilder
    public var view: some View {
        Group {
            switch self {
            case .night:
                Image(systemName: "moon")
            case .sunrise:
                Image(systemName: "sunrise")
            case .morning:
                Image(systemName: "sun.min")
            case .afternoon:
                Image(systemName: "sun.max")
            case .sunset:
                Image(systemName: "sunset")
            }
        }
        .id(self)
    }
    
    public var colorSchemeOverride: ColorScheme? {
        if case .night = self {
            return .dark
        }
        return nil
    }
    
    public var colorData: BackyardTimeOfDayColorData {
        switch self {
        case .night: Self.nightColorData
        case .sunrise: Self.sunriseColorData
        case .morning: Self.morningColorData
        case .afternoon: Self.afternoonColorData
        case .sunset: Self.sunsetColorData
        }
    }
}

extension BackyardTimeOfDay {
    static let nightColorData = BackyardTimeOfDayColorData(
        skyGradientStart: ColorData(hue: 231 / 360, saturation: 0.57, brightness: 0.85),
        skyGradientEnd: ColorData(hue: 245 / 360, saturation: 0.41, brightness: 1),
        silhouette: ColorData(hue: 243 / 360, saturation: 0.45, brightness: 0.90),
        atmosphereTint: ColorData(hue: 245 / 360, saturation: 0.22, brightness: 1)
    )
    
    static let sunriseColorData = BackyardTimeOfDayColorData(
        skyGradientStart: ColorData(hue: 31 / 360, saturation: 0.4, brightness: 0.99),
        skyGradientEnd: ColorData(hue: 48 / 360, saturation: 0.31, brightness: 1),
        silhouette: ColorData(hue: 31 / 360, saturation: 0.32, brightness: 0.94),
        atmosphereTint: ColorData(hue: 31 / 360, saturation: 0.15, brightness: 1)
    )
    
    static let morningColorData = BackyardTimeOfDayColorData(
        skyGradientStart: ColorData(hue: 185 / 360, saturation: 0.39, brightness: 0.95),
        skyGradientEnd: ColorData(hue: 186 / 360, saturation: 0.37, brightness: 0.9),
        silhouette: ColorData(hue: 185 / 360, saturation: 0.44, brightness: 0.85),
        atmosphereTint: .white
    )
    
    static let afternoonColorData = BackyardTimeOfDayColorData(
        skyGradientStart: ColorData(hue: 216 / 360, saturation: 0.62, brightness: 1),
        skyGradientEnd: ColorData(hue: 205 / 360, saturation: 0.32, brightness: 1),
        silhouette: ColorData(hue: 216 / 360, saturation: 0.60, brightness: 1),
        atmosphereTint: .white
    )
    
    static let sunsetColorData = BackyardTimeOfDayColorData(
        skyGradientStart: ColorData(hue: 286 / 360, saturation: 0.28, brightness: 1),
        skyGradientEnd: ColorData(hue: 360 / 360, saturation: 0.42, brightness: 1),
        silhouette: ColorData(hue: 322 / 360, saturation: 0.34, brightness: 0.95),
        atmosphereTint: ColorData(hue: 288 / 360, saturation: 0.13, brightness: 1)
    )

}

// MARK: - Localized Title

public extension BackyardTimeOfDay {
    var title: String {
        switch self {
        case .sunrise: String(
            localized: "Sunrise",
            table: "Backyards",
            bundle: .module,
            comment: "Short phrase that describes the sunrise time of day for a backyard."
        )
        case .morning: String(
            localized: "Morning",
            table: "Backyards",
            bundle: .module,
            comment: "Short phrase that describes the morning time of day for a backyard."
        )
        case .afternoon: String(
            localized: "Afternoon",
            table: "Backyards",
            bundle: .module,
            comment: "Short phrase that describes the afternoon time of day for a backyard."
        )
        case .sunset: String(
            localized: "Sunset",
            table: "Backyards",
            bundle: .module,
            comment: "Short phrase that describes the sunset time of day for a backyard."
        )
        case .night: String(
            localized: "Night",
            table: "Backyards",
            bundle: .module,
            comment: "Short phrase that describes the night time of day for a backyard."
        )
        }
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The backyard data.
*/

import Foundation
import Observation
import SwiftData

@Model public class Backyard {
    @Attribute(.unique) public var id: String
    public var name: String
    public var waterRefillDate: Date
    public var foodRefillDate: Date
    public var creationDate: Date
    public var presentingVisitor: Bool = false
    public var isFavorite: Bool = false
    public var timeIntervalOffset: TimeInterval = TimeInterval(hours: 12)
    public var birdFood: BirdFood
    public var visitorEvents: [BackyardVisitorEvent]
    
    @Relationship(inverse: \Plant.backyard)
    public var leadingPlants: [Plant]
    
    @Relationship(inverse: \Plant.backyard)
    public var trailingPlants: [Plant]
    
    public var floorVariant: Int = 0
    public var fountainVariant: Int = 0
    public var leadingSilhouetteVariant: Int = 0
    public var trailingSilhouetteVariant: Int = 0
    public var leadingForegroundPlantVariant: Int = 0
    public var trailingForegroundPlantVariant: Int = 0
    
    public var currentVisitorEvent: BackyardVisitorEvent? {
        guard let event = visitorEvents.first(where: { $0.dateRange.contains(.now) }) else {
            return nil
        }
        return event
    }
    
    public var hasVisitor: Bool {
        currentVisitorEvent != nil
    }
    
    public var needsToPresentVisitor: Bool {
        hasVisitor && !presentingVisitor
    }
    
    public var historicalEvents: [BackyardVisitorEvent] {
        visitorEvents
            .filter { $0.endDate < .now }
            .sorted(using: KeyPathComparator(\.endDate, order: .reverse))
    }
    
    public var colorData: BackyardTimeOfDayColorData {
        BackyardTimeOfDayColorData.colorData(timeInterval: timeIntervalOffset - creationDate.timeIntervalSinceNow)
    }
    
    public init(name: String?) {
        self.id = UUID().uuidString
        self.name = name ?? String(localized: "Backyard", table: "Backyards", bundle: .module)
        self.creationDate = .now
        self.waterRefillDate = .now
        self.foodRefillDate = .now
    }
    
    public func expectedEmptyDate(for supplies: BackyardSupplies) -> Date {
        refillDate(for: supplies).addingTimeInterval(supplies.totalDuration)
    }
    
    public func lowSuppliesDate(for supplies: BackyardSupplies) -> Date {
        refillDate(for: supplies).addingTimeInterval(supplies.durationUntilLow)
    }
    
    public func refillDate(for supplies: BackyardSupplies) -> Date {
        switch supplies {
        case .food:
            foodRefillDate
        case .water:
            waterRefillDate
        }
    }
    
    public func refillSupplies() {
        refillSupplies(.food)
        refillSupplies(.water)
    }
    
    public func refillSupplies(_ supplies: BackyardSupplies) {
        switch supplies {
        case .food:
            foodRefillDate = .now
        case .water:
            waterRefillDate = .now
        }
    }
}

// MARK: - Backyard Snapshots

extension Backyard {
    public func snapshots(through date: Date, total: Int = 12) -> [BackyardSnapshot] {
        var unmergedSnapshots: [BackyardSnapshot] = []
        
        // Upcoming visitor events.
        let relevantVisitorEvents = visitorEvents.filter { event in
            event.startDate > .now && event.endDate < date
        }
        
        // Add both arrival and departure snapshots.
        for event in relevantVisitorEvents {
            let arriveSnapshot = BackyardSnapshot(
                backyard: self,
                visitingBird: event.bird,
                visitingBirdDuration: event.duration,
                timeInterval: timeIntervalOffset + event.startDate.timeIntervalSinceNow,
                date: event.startDate,
                notableEvents: [.visitorArrive]
            )
            unmergedSnapshots.append(arriveSnapshot)
            let departSnapshot = BackyardSnapshot(
                backyard: self,
                visitingBird: nil,
                timeInterval: timeIntervalOffset + event.endDate.timeIntervalSinceNow,
                date: event.endDate,
                notableEvents: [.visitorDepart]
            )
            unmergedSnapshots.append(departSnapshot)
        }
        
        // Add general time of day transitions.
        for timeInterval in stride(from: 0, through: date.timeIntervalSinceNow, by: TimeInterval(hours: 1)) {
            let timeInterval = timeIntervalOffset + timeInterval
            
            // Near 12 a.m., 6 a.m., 12 p.m., 6 p.m.
            let isSignificantTime = timeInterval.truncatingRemainder(dividingBy: TimeInterval(hours: 6)) <= TimeInterval(hours: 1)
            
            unmergedSnapshots.append(BackyardSnapshot(
                backyard: self,
                visitingBird: nil,
                timeInterval: timeInterval,
                date: Date(timeIntervalSinceNow: timeInterval),
                notableEvents: isSignificantTime ? [.signifantTimeOfDay] : []
            ))
        }
        
        // Add snapshots for low supplies.
        for date in [lowSuppliesDate(for: .food), lowSuppliesDate(for: .food)] {
            unmergedSnapshots.append(BackyardSnapshot(
                backyard: self,
                visitingBird: nil,
                timeInterval: timeIntervalOffset + date.timeIntervalSinceNow,
                date: date,
                notableEvents: [.lowSupplySeverityIncrease]
            ))
        }
        
        // Sort by date and merge any nearby events.
        
        unmergedSnapshots.sort(using: KeyPathComparator(\.date))
        var snapshots: [BackyardSnapshot] = [unmergedSnapshots.first!]
        
        for next in unmergedSnapshots.dropFirst() {
            if let merged = snapshots.last!.merged(with: next) {
                snapshots[snapshots.count - 1] = merged
            } else {
                snapshots.append(next)
            }
        }
        
        snapshots = snapshots
            .sorted(using: KeyPathComparator(\.priority, order: .reverse))
            .prefix(total - 1)
            .sorted(using: KeyPathComparator(\.date))
            
        // Initial state.
        snapshots.insert(BackyardSnapshot(
            backyard: self,
            visitingBird: currentVisitorEvent?.bird,
            timeInterval: timeIntervalOffset,
            date: .now
        ), at: 0)
        
        return snapshots
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Colors that correspond to the time of day in the backyard.
*/

import Foundation
import SwiftUI

public struct BackyardTimeOfDayColorData {
    public var skyGradientStart: ColorData
    public var skyGradientEnd: ColorData
    public var silhouette: ColorData
    public var atmosphereTint: ColorData
    
    public var skyGradientFlat: ColorData {
        skyGradientStart.interpolate(to: skyGradientEnd, percent: 0.5)
    }
    
    public func interpolate(to other: BackyardTimeOfDayColorData, percent: Double, clamped: Bool = true) -> BackyardTimeOfDayColorData {
        BackyardTimeOfDayColorData(
            skyGradientStart: skyGradientStart.interpolate(to: other.skyGradientStart, percent: percent, clamped: clamped),
            skyGradientEnd: skyGradientEnd.interpolate(to: other.skyGradientEnd, percent: percent, clamped: clamped),
            silhouette: silhouette.interpolate(to: other.silhouette, percent: percent, clamped: clamped),
            atmosphereTint: atmosphereTint.interpolate(to: other.atmosphereTint, percent: percent, clamped: clamped)
        )
    }
    
    public static func colorData(timeInterval: TimeInterval) -> BackyardTimeOfDayColorData {
        let timeInterval = timeInterval.truncatingRemainder(dividingBy: TimeInterval(days: 1))
        let currentTimeOfDay = BackyardTimeOfDay(timeInterval: timeInterval)
        let nextTimeOfDay = BackyardTimeOfDay(afterTimeInterval: timeInterval)
        let percent = timeInterval.truncatingRemainder(dividingBy: TimeInterval(hours: 1)) / TimeInterval(hours: 1)
        
        return currentTimeOfDay.colorData
            .interpolate(to: nextTimeOfDay.colorData, percent: percent)
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The backyard visitor event.
*/

import Foundation
import Observation
import SwiftData

@Model public class BackyardVisitorEvent {
    @Attribute(.unique) public var id: String
    public var backyard: Backyard!
    public var bird: Bird!
    public var startDate: Date
    public var endDate: Date
    public var duration: TimeInterval
    
    public var dateRange: Range<Date> {
        startDate ..< endDate
    }
    
    public init(id: UUID = UUID(), startDate: Date, duration: TimeInterval) {
        self.id = id.uuidString
        self.startDate = startDate
        self.duration = duration
        self.endDate = startDate.addingTimeInterval(duration)
    }
}



/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Generates the backyard data.
*/

import OSLog
import SwiftData

private let logger = Logger(subsystem: "BackyardBirdsData", category: "Backyard")

extension Backyard {
    static func generateAll(modelContext: ModelContext) {
        var random = SeededRandomGenerator(seed: 8)
        
        logger.info("Generating all backyards")
        let allPlantSpecies = try! modelContext.fetch(FetchDescriptor<PlantSpecies>(sortBy: [.init(\.id)]))
        let allBirdFood = try! modelContext.fetch(FetchDescriptor<BirdFood>(sortBy: [.init(\.id)]))
        
        logger.info("Generating first backyard")
        let backyard1 = Backyard(name: String(localized: "Bird Springs", table: "Backyards", bundle: .module))
        modelContext.insert(backyard1)
        backyard1.isFavorite = true
        backyard1.birdFood = allBirdFood.first(where: { $0.id == "Sunflower Seeds" })!
        backyard1.timeIntervalOffset = TimeInterval(hours: 8)
        backyard1.leadingPlants = [
            .generateAndInsert(species: allPlantSpecies.randomElement(using: &random)!, modelContext: modelContext, random: &random),
            .generateAndInsert(species: allPlantSpecies.randomElement(using: &random)!, modelContext: modelContext, random: &random),
            .generateAndInsert(species: allPlantSpecies.randomElement(using: &random)!, modelContext: modelContext, random: &random)
        ]
        backyard1.trailingPlants = [
            .generateAndInsert(species: allPlantSpecies.randomElement(using: &random)!, modelContext: modelContext, random: &random),
            .generateAndInsert(species: allPlantSpecies.randomElement(using: &random)!, modelContext: modelContext, random: &random),
            .generateAndInsert(species: allPlantSpecies.randomElement(using: &random)!, modelContext: modelContext, random: &random)
        ]
        if DataGenerationOptions.firstBackyardLowOnWater {
            backyard1.waterRefillDate = Date(timeIntervalSinceNow: -BackyardSupplies.water.durationUntilLow)
        } else {
            backyard1.waterRefillDate = Date(timeIntervalSinceNow: -BackyardSupplies.water.durationUntilLow * 0.6)
        }
        backyard1.foodRefillDate = Date(timeIntervalSinceNow: -BackyardSupplies.food.durationUntilLow * 0.33)
        backyard1.floorVariant = .random(in: 0..<4, using: &random)
        backyard1.fountainVariant = .random(in: 0..<3, using: &random)
        backyard1.leadingSilhouetteVariant = .random(in: 0..<10, using: &random)
        backyard1.trailingSilhouetteVariant = .random(in: 0..<10, using: &random)
        
        logger.info("generating remaining backyards")
        func generateRandomBackyard(name: String, timeOffset: Double) {
            let backyard = Backyard(name: name)
            modelContext.insert(backyard)
            backyard.birdFood = allBirdFood.randomElement(using: &random)!
            backyard.timeIntervalOffset = timeOffset
            backyard.leadingPlants = (0..<3).map { _ in
                .generateAndInsert(species: allPlantSpecies.randomElement(using: &random)!, modelContext: modelContext, random: &random)
            }
            
            backyard.trailingPlants = (0..<3).map { _ in
                .generateAndInsert(species: allPlantSpecies.randomElement(using: &random)!, modelContext: modelContext, random: &random)
            }
            backyard.waterRefillDate = Date(timeIntervalSinceNow: -BackyardSupplies.water.durationUntilLow *
                .random(in: 0.25 ..< 0.75, using: &random))
            backyard.foodRefillDate = Date(timeIntervalSinceNow: -BackyardSupplies.food.durationUntilLow * .random(in: 0.25 ..< 0.75, using: &random))
            backyard.floorVariant = .random(in: 0..<4, using: &random)
            backyard.fountainVariant = .random(in: 0..<3, using: &random)
            backyard.leadingSilhouetteVariant = .random(in: 0..<10, using: &random)
            backyard.trailingSilhouetteVariant = .random(in: 0..<10, using: &random)
        }
        
        generateRandomBackyard(name: String(localized: "Feathered Friends", table: "Backyards", bundle: .module), timeOffset: TimeInterval(hours: 12))
        generateRandomBackyard(name: String(localized: "Calm Palms", table: "Backyards", bundle: .module), timeOffset: TimeInterval(hours: 20))
        generateRandomBackyard(name: String(localized: "Chirp Center", table: "Backyards", bundle: .module), timeOffset: TimeInterval(hours: 21))
        generateRandomBackyard(name: String(localized: "Quiet Haven", table: "Backyards", bundle: .module), timeOffset: TimeInterval(hours: 6))
        
        logger.info("Backyards generated")
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The backyard snapshot.
*/

import Foundation

public struct BackyardSnapshot {
    public var backyard: Backyard
    public var visitingBird: Bird?
    public var visitingBirdDuration: TimeInterval?
    public var timeInterval: TimeInterval
    public var date: Date
    public var notableEvents: Set<NotableEvent> = []
    
    public var timeOfDay: BackyardTimeOfDay {
        BackyardTimeOfDay(timeInterval: timeInterval)
    }
    
    public var priority: Int {
        notableEvents.map(\.priorityValue).reduce(0, +)
    }
    
    public init(backyard: Backyard, visitingBird: Bird? = nil, visitingBirdDuration: TimeInterval? = nil,
                timeInterval: TimeInterval, date: Date, notableEvents: Set<NotableEvent> = []) {
        self.backyard = backyard
        self.visitingBird = visitingBird
        self.visitingBirdDuration = visitingBirdDuration
        self.timeInterval = timeInterval
        self.date = date
        self.notableEvents = notableEvents
    }
    
    public enum NotableEvent {
        /// Sunsets, sunrise, noon, midnight, and so on.
        case signifantTimeOfDay
        
        /// Low water, low bird food, or potentially out of supplies.
        case lowSupplySeverityIncrease
        
        /// Bird arrives.
        case visitorArrive
        
        /// Bird departs.
        case visitorDepart
        
        public var priorityValue: Int {
            switch self {
            case .signifantTimeOfDay: 1
            case .visitorDepart: 1
            case .visitorArrive: 2
            case .lowSupplySeverityIncrease: 3
            }
        }
    }
    
    public func merged(with other: BackyardSnapshot, maxDistance: TimeInterval = TimeInterval(minutes: 5)) -> BackyardSnapshot? {
        // Only merge if these events are within a certain `TimeInterval` distance.
        guard date.distance(to: other.date) < maxDistance else {
            return nil
        }
        let moreRecent = self.date > other.date ? self : other
        let lessRecent = self.date < other.date ? self : other
        return BackyardSnapshot(
            backyard: backyard,
            visitingBird: moreRecent.visitingBird ?? lessRecent.visitingBird,
            visitingBirdDuration: moreRecent.visitingBirdDuration ?? lessRecent.visitingBirdDuration,
            timeInterval: moreRecent.timeInterval,
            date: moreRecent.date,
            notableEvents: moreRecent.notableEvents.union(lessRecent.notableEvents)
        )
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The generation of backyard visitor events.
*/

import Foundation
import OSLog
import SwiftData

private let logger = Logger(subsystem: "BackyardBirdsData", category: "BackyardVisitorEvent")

extension BackyardVisitorEvent {
    static func generateHistoricalEvents(modelContext: ModelContext, includeEarlyAccessSpecies: Bool) {
        var random = SeededRandomGenerator(seed: 1)
        
        logger.info("Generating historical visitor events")
        let birds = try! modelContext.fetch(FetchDescriptor<Bird>(sortBy: [.init(\.creationDate)]))
            .shuffled(using: &random)
            .filter { includeEarlyAccessSpecies || !$0.species.isEarlyAccess }
        let backyards = try! modelContext.fetch(FetchDescriptor<Backyard>(sortBy: [.init(\.creationDate)]))
        
        for minutesAgo in stride(from: 5, through: 300, by: 40) {
            // Selection of birds this hour.
            for (backyard, bird) in zip(backyards, birds.shuffled(using: &random)) {
                let date = Date.now.addingTimeInterval(TimeInterval(minutes: -Double(minutesAgo)))
                let event = BackyardVisitorEvent(
                    startDate: date,
                    duration: .random(in: 5...30, using: &random)
                )
                modelContext.insert(event)
                event.backyard = backyard
                event.bird = bird
                backyard.visitorEvents.insert(event, at: 0)
                bird.updateVisitStatus(visitedOn: date)
            }
        }
        
        logger.info("Finished generating historical visitor events")
    }
    
    static func generateCurrentEvents(modelContext: ModelContext, includeEarlyAccessSpecies: Bool) {
        var random = SeededRandomGenerator(seed: 4)
        
        logger.info("Generating current events")
        let allBirds = try! modelContext.fetch(FetchDescriptor<Bird>(sortBy: [.init(\.creationDate)]))
            .filter { includeEarlyAccessSpecies || !$0.species.isEarlyAccess }
        let birds = allBirds.shuffled(using: &random)
        let firstHummingbird = allBirds.first(where: { $0.species.info == .hummingbird })!
        let backyards = try! modelContext.fetch(FetchDescriptor<Backyard>(sortBy: [.init(\.creationDate)]))
        let firstBackyard = backyards.first!
        
        let duration = DataGenerationOptions.currentBirdsVisitingDuration
        for (bird, backyard) in zip(birds, backyards) {
            if backyard == firstBackyard, case .notVisiting = DataGenerationOptions.firstBackyardBirdStatus {
                continue
            }
            let bird = backyard == firstBackyard ? firstHummingbird : bird
            let event = BackyardVisitorEvent(startDate: .now, duration: duration)
            modelContext.insert(event)
            event.backyard = backyard
            event.bird = bird
            if backyard == firstBackyard {
                switch DataGenerationOptions.firstBackyardBirdStatus {
                case .alreadyVisible:
                    logger.info("Setting first bird to be initially visible")
                    backyard.presentingVisitor = true
                case .fliesIn:
                    logger.info("Setting first bird to fly in")
                    backyard.presentingVisitor = false
                case .notVisiting:
                    fatalError()
                }
                backyard.visitorEvents.append(event)
            } else {
                backyard.visitorEvents.append(event)
                backyard.presentingVisitor = true
            }
            
        }
        logger.info("Finished generating current events")
    }
    
    static func generateFutureEvents(modelContext: ModelContext, includeEarlyAccessSpecies: Bool) {
        var random = SeededRandomGenerator(seed: 1)
        
        logger.info("Generating future events")
        let birds = try! modelContext.fetch(FetchDescriptor<Bird>(sortBy: [.init(\.creationDate)]))
            .shuffled(using: &random)
            .filter { includeEarlyAccessSpecies || !$0.species.isEarlyAccess }
        let backyards = try! modelContext.fetch(FetchDescriptor<Backyard>(sortBy: [.init(\.creationDate)]))
        
        let earliestDate = Date.now.addingTimeInterval(DataGenerationOptions.currentBirdsVisitingDuration)
        for hours in stride(from: 0, through: 48, by: 3) {
            // Selection of birds this hour.
            for (backyard, bird) in zip(backyards, birds.shuffled(using: &random)) {
                let event = BackyardVisitorEvent(
                    startDate: earliestDate.addingTimeInterval(TimeInterval(hours) * TimeInterval(hours: 1)),
                    duration: .random(in: 15...50, using: &random)
                )
                modelContext.insert(event)
                event.backyard = backyard
                event.bird = bird
                backyard.visitorEvents.insert(event, at: 0)
            }
        }
        
        logger.info("Finished generating future events")
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The definition of the account.
*/

import Observation
import Foundation
import SwiftData
import OSLog

private let logger = Logger(subsystem: "BackyardBirdsData", category: "Account")

@Model public class Account {
    
    @Attribute(.unique) public var id: String
    public var bird: Bird!
    public var joinDate: Date
    public var displayName: String
    public var emailAddress: String
    public var isPremiumMember: Bool

    public init(joinDate: Date, displayName: String, emailAddress: String, isPremiumMember: Bool) {
        self.id = UUID().uuidString
        self.joinDate = joinDate
        self.displayName = displayName
        self.emailAddress = emailAddress
        self.isPremiumMember = isPremiumMember
        logger.notice("User \(self.id) has been created with DisplayName: '\(self.displayName)' and is \(!self.isPremiumMember ? "not " : "")a premium user.")
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Generates the account data.
*/

import Foundation
import OSLog
import SwiftData

private let logger = Logger(subsystem: "BackyardBirdsData", category: "Account Generation")

extension Account {
    static func generateAccount(modelContext: ModelContext) {
        logger.info("Generating/Fetching Account")
        let bird = try! modelContext.fetch(FetchDescriptor<Bird>(sortBy: [.init(\.creationDate)])).first!
        
        let date = Calendar.current.date(from: DateComponents(year: 2023, month: 6, day: 5, hour: 9, minute: 41))!
        let account = Account(
            joinDate: date,
            displayName: "Ravi Patel",
            emailAddress: "ravipatel@icloud.com",
            isPremiumMember: true
        )
        modelContext.insert(account)
        account.bird = bird
        
        logger.info("Finished Generating/Fetching Account")
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Identifiers for use in the store.
*/

import SwiftUI

public struct PassIdentifiers {
    public var group: String
    
    public var individual: String
    public var family: String
    public var premium: String
}

public extension EnvironmentValues {
    
    private enum PassIDsKey: EnvironmentKey {
        static var defaultValue = PassIdentifiers(
            group: "6F3A93AB",
            individual: "pass.individual",
            family: "pass.family",
            premium: "pass.premium"
        )
    }
    
    var passIDs: PassIdentifiers {
        get { self[PassIDsKey.self] }
        set { self[PassIDsKey.self] = newValue }
    }
    
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The widget bundle.
*/

import WidgetKit
import SwiftUI
import SwiftData
import BackyardBirdsData

@main
struct WidgetsBundle: WidgetBundle {
    var body: some Widget {
        BackyardWidget()
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The resupply backyard intent.
*/

import AppIntents
import SwiftData
import BackyardBirdsData

struct ResupplyBackyardIntent: AppIntent {
    static var title: LocalizedStringResource = "Refill Backyard Supplies"
    
    @Parameter(title: "Backyard")
    var backyard: BackyardEntity
    
    init(backyard: BackyardEntity) {
        self.backyard = backyard
    }
    
    init() {
    }
    
    func perform() async throws -> some IntentResult {
        let modelContext = ModelContext(DataGeneration.container)
        let id = backyard.id
        guard let backyard = try! modelContext.fetch(
            FetchDescriptor<Backyard>(predicate: #Predicate { $0.id == id })
        ).first else {
            return .result()
        }
        backyard.refillSupplies()
        try! modelContext.save()
        return .result()
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The backyard widget intent.
*/

import WidgetKit
import AppIntents
import SwiftData
import OSLog
import BackyardBirdsData

private let logger = Logger(subsystem: "Widgets", category: "BackyardWidgetIntent")

struct BackyardWidgetIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Backyard"
    static let description = IntentDescription("Keep track of your backyards.")
    
    @Parameter(title: "Backyards", default: BackyardWidgetContent.all)
    var backyards: BackyardWidgetContent
    
    @Parameter(title: "Backyard")
    var specificBackyard: BackyardEntity?
    
    init(backyards: BackyardWidgetContent = .all, specificBackyard: BackyardEntity? = nil) {
        self.backyards = backyards
        self.specificBackyard = specificBackyard
    }
    
    init() {
    }
    
    static var parameterSummary: some ParameterSummary {
        When(\.$backyards, .equalTo, BackyardWidgetContent.specific) {
            Summary {
                \.$backyards
                \.$specificBackyard
            }
        } otherwise: {
            Summary {
                \.$backyards
            }
        }
    }
}

struct BackyardEntity: AppEntity, Identifiable, Hashable {
    var id: Backyard.ID
    var name: String
    
    init(id: Backyard.ID, name: String) {
        self.id = id
        self.name = name
    }
    
    init(from backyard: Backyard) {
        self.id = backyard.id
        self.name = backyard.name
    }
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Backyard")
    static var defaultQuery = BackyardEntityQuery()
}

struct BackyardEntityQuery: EntityQuery, Sendable {
    func entities(for identifiers: [BackyardEntity.ID]) async throws -> [BackyardEntity] {
        logger.info("Loading backyards for identifiers: \(identifiers)")
        let modelContext = ModelContext(DataGeneration.container)
        let backyards = try! modelContext.fetch(FetchDescriptor<Backyard>(predicate: #Predicate { identifiers.contains($0.id) }))
        logger.info("Found \(backyards.count) backyards")
        return backyards.map { BackyardEntity(from: $0) }
    }
    
    func suggestedEntities() async throws -> [BackyardEntity] {
        logger.info("Loading backyards to suggest for specific backyard...")
        let modelContext = ModelContext(DataGeneration.container)
        let backyards = try! modelContext.fetch(FetchDescriptor<Backyard>())
        logger.info("Found \(backyards.count) backyards")
        return backyards.map { BackyardEntity(from: $0) }
    }
}

enum BackyardWidgetContent: String, AppEnum {
    case all
    case favorites
    case specific
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Backyard List")
    
    static let caseDisplayRepresentations: [BackyardWidgetContent: DisplayRepresentation] = [
        .all: DisplayRepresentation(title: LocalizedStringResource("All", comment: "A phrase that means all backyards should be shown in a widget.")),
        .favorites: DisplayRepresentation(title: LocalizedStringResource("Favorites",
                                        comment: "A phrase that means only favorite backyards should be shown in a widget.")),
        .specific: DisplayRepresentation(title: LocalizedStringResource("Specific",
                                        comment: "A phrase that means only a specific backyard should be shown in a widget."))
    ]
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The widget's timeline provider.
*/

import BackyardBirdsData
import SwiftData
import WidgetKit
import OSLog

private let logger = Logger(subsystem: "Widgets", category: "BackyardSnapshotTimelineProvider")

struct BackyardWidgetEntry: TimelineEntry {
    var date: Date
    var snapshot: BackyardSnapshot?
    
    static var empty: Self {
        Self(date: .now)
    }
}

struct BackyardSnapshotTimelineProvider: AppIntentTimelineProvider {
    let modelContext = ModelContext(DataGeneration.container)
    
    init() {
        DataGeneration.generateAllData(modelContext: modelContext)
    }
    
    func backyards(for configuration: BackyardWidgetIntent) -> [Backyard] {
        if let id = configuration.specificBackyard?.id {
            try! modelContext.fetch(
                FetchDescriptor<Backyard>(predicate: #Predicate { $0.id == id })
            )
        } else if configuration.backyards == .favorites {
            try! modelContext.fetch(
                FetchDescriptor<Backyard>(predicate: #Predicate { $0.isFavorite == true })
            )
        } else {
            try! modelContext.fetch(FetchDescriptor<Backyard>())
        }
    }
    
    func placeholder(in context: Context) -> BackyardWidgetEntry {
        let backyard = try! modelContext.fetch(FetchDescriptor<Backyard>(sortBy: [.init(\.creationDate)])).first!
        return BackyardWidgetEntry(
            date: .now,
            snapshot: BackyardSnapshot(
                backyard: backyard,
                visitingBird: nil,
                timeInterval: backyard.timeIntervalOffset,
                date: .now,
                notableEvents: []
            )
        )
    }

    func snapshot(for configuration: BackyardWidgetIntent, in context: Context) async -> BackyardWidgetEntry {
        logger.info("Finding backyards for widget snapshot, intent: \(String(configuration.backyards.rawValue))")
        let backyards = backyards(for: configuration)
        logger.info("Found \(backyards.count) backyards")
        guard let backyard = backyards.first else {
            return .empty
        }
        
        let snapshot = backyard.snapshots(through: .now, total: 1).first!
        return BackyardWidgetEntry(date: snapshot.date, snapshot: snapshot)
    }
    
    func timeline(for configuration: BackyardWidgetIntent, in context: Context) async -> Timeline<BackyardWidgetEntry> {
        logger.info("Finding backyards for widget timeline, intent: \(String(configuration.backyards.rawValue))")
        let backyards = backyards(for: configuration)
        logger.info("Found \(backyards.count) backyards")
        guard let backyard = backyards.first else {
            return Timeline(
                entries: [.empty],
                policy: .never
            )
        }
        
        let snapshots = backyard.snapshots(through: .init(timeIntervalSinceNow: 60 * 60 * 36)).map {
            BackyardWidgetEntry(date: $0.date, snapshot: $0)
        }
        return Timeline(entries: snapshots, policy: .atEnd)
    }
    
    func recommendations() -> [AppIntentRecommendation<BackyardWidgetIntent>] {
        [
            AppIntentRecommendation(intent: BackyardWidgetIntent(backyards: .all), description: "All Backyards"),
            AppIntentRecommendation(intent: BackyardWidgetIntent(backyards: .favorites), description: "Favorite Backyards")
        ]
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The backyard widget.
*/

import WidgetKit
import SwiftUI
import SwiftData
import BackyardBirdsUI
import BackyardBirdsData
import LayeredArtworkLibrary

struct BackyardWidget: Widget {
    private let kind = "Backyard Widget"

    var families: [WidgetFamily] {
        #if os(watchOS)
        return [.accessoryRectangular]
        #elseif os(iOS)
        return [.accessoryRectangular, .systemSmall, .systemMedium, .systemLarge]
        #else
        return [.systemSmall, .systemMedium, .systemLarge]
        #endif
    }
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: BackyardWidgetIntent.self,
            provider: BackyardSnapshotTimelineProvider()
        ) { entry in
            BackyardWidgetView(entry: entry)
        }
        .supportedFamilies(families)
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The backyard widget view.
*/

import SwiftUI
import WidgetKit
import BackyardBirdsData
import BackyardBirdsUI
import LayeredArtworkLibrary

struct BackyardWidgetView: View {
    var entry: BackyardWidgetEntry
    
    var body: some View {
        if let snapshot = entry.snapshot {
            BackyardSnapshotWidgetView(snapshot: snapshot)
        } else {
            Text("No Backyards")
                .foregroundStyle(.secondary)
                .containerBackground(.fill, for: .widget)
        }
    }
    
}

struct BackyardSnapshotWidgetView: View {
    var snapshot: BackyardSnapshot
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.widgetRenderingMode) private var widgetRenderingMode
    
    var hasVisitingBird: Bool {
        snapshot.visitingBird != nil
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            header
            
            Spacer()
            
            birdView
            
            if snapshot.notableEvents.contains(.lowSupplySeverityIncrease) {
                suppliesLowDetail
            } else if snapshot.notableEvents.contains(.visitorArrive) {
                arrivalMessage
            } else {
                gauges
            }
        }
        .environment(\.colorScheme, snapshot.timeOfDay.colorSchemeOverride ?? colorScheme)
        .containerBackground(for: .widget) {
            BackyardSkyView(timeInterval: snapshot.timeInterval)
                .opacity(colorScheme == .dark ? 0.75 : 1)
        }
    }
    
    @ViewBuilder
    var header: some View {
        HStack(spacing: 4) {
            Image(.fountainFillImage)
            Text(snapshot.backyard.name)
            Spacer()
            snapshot.timeOfDay.view
                .imageScale(.large)
                .symbolVariant(.fill)
                .transition(.scale.combined(with: .opacity))
        }
        .font(.caption)
        .foregroundStyle(.secondary.vibrantlyBlended)
        .environment(\.backgroundMaterial, .regular)
    }
    
    @ViewBuilder
    var birdView: some View {
        if let bird = snapshot.visitingBird {
            ZStack {
                if widgetRenderingMode == .fullColor {
                    ComposedBird(bird: bird)
                } else {
                    VibrantBird(bird: bird)
                }
            }
            .id(bird.id)
            .transition(
                .asymmetric(
                    insertion: .offset(x: 100),
                    removal: .offset(x: -100)
                )
                .combined(with: .scale(scale: 0.7))
                .combined(with: .opacity)
            )
        }
    }
    
    @ViewBuilder
    var arrivalMessage: some View {
        if let visitingBird = snapshot.visitingBird {
            HStack {
                VStack(alignment: .leading) {
                    Text(visitingBird.speciesName)
                        .font(.subheadline.bold())
                    Text("Arrived \(Duration.seconds(4 * 60).formatted(Self.remainingMinutesFormatter)) ago",
                         comment: "The variable is formatted as minutes.")
                        .foregroundStyle(.secondary.vibrantlyBlended)
                        .font(.footnote)
                }
                
                Spacer()
            }
            .font(.caption)
            .transition(.offset(y: 50).combined(with: .scale(scale: 0.9)).combined(with: .opacity))
        }
    }
    
    @ViewBuilder
    var suppliesLowDetail: some View {
        VStack(alignment: .leading) {
            if hasVisitingBird {
                HStack {
                    lowWaterIndicator
                        .imageScale(.large)
                    Text("Water Low · \(Duration.seconds(59 * 60).formatted(Self.remainingMinutesFormatter))",
                         comment: "The variable is formatted as minutes.")
                        .foregroundStyle(.tertiary.vibrantlyBlended)
                        .font(.footnote)
                    Spacer()
                }
            } else {
                VStack(alignment: .leading) {
                    lowWaterIndicator
                        .imageScale(.large)
                        .font(.title2)
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Water Low")
                                .font(.headline.bold())
                            Text("\(Duration.seconds(59 * 60).formatted(Self.remainingMinutesFormatter)) remaining",
                                 comment: "The variable is formatted as minutes.")
                                .foregroundStyle(.tertiary.vibrantlyBlended)
                                .font(.footnote)
                        }
                        Spacer()
                    }
                }
            }
            Button(intent: ResupplyBackyardIntent(backyard: BackyardEntity(from: snapshot.backyard))) {
                Label("Refill Water", systemImage: "arrow.clockwise")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(.quaternary, in: .containerRelative)
            }
            .font(.subheadline)
            .buttonStyle(.plain)
            .transition(.scale.combined(with: .opacity))
        }
        .font(.caption)
        .environment(\.backgroundMaterial, .regular)
    }
    
    var lowWaterIndicator: some View {
        Image(systemName: "drop.triangle.fill")
            .foregroundStyle(.primary.opacity(0.4).vibrantlyBlended, .quaternary)
            .symbolRenderingMode(.palette)
            .transition(.scale.combined(with: .opacity))
    }
    
    var gauges: some View {
        Grid {
            GridRow {
                Image(systemName: "drop.fill")
                    .foregroundStyle(.secondary.vibrantlyBlended)
                
                Text(Duration.seconds(60 * 60 * 5), format: Self.remainingHoursFormatter)
                    .foregroundStyle(.secondary.vibrantlyBlended)
                
                Gauge(value: 0.6) {
                    EmptyView()
                }
                .tint(Gradient(colors: [.mint, .cyan]))
                .labelsHidden()
            }
            
            GridRow {
                Image(systemName: "fork.knife")
                    .foregroundStyle(.secondary.vibrantlyBlended)
                
                Text(Duration.seconds(60 * 60 * 3), format: Self.remainingHoursFormatter)
                    .foregroundStyle(.secondary.vibrantlyBlended)
                
                Gauge(value: 0.4) {
                    EmptyView()
                }
                .tint(Gradient(colors: [.red, .orange]))
                .labelsHidden()
            }
        }
        .font(.caption)
    }
    
    private static let remainingMinutesFormatter = Duration.UnitsFormatStyle(allowedUnits: [.minutes], width: .condensedAbbreviated)
    private static let remainingHoursFormatter = Duration.UnitsFormatStyle(allowedUnits: [.hours], width: .condensedAbbreviated)
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The fountain.
*/

import SwiftUI
import BackyardBirdsData

private let variants = [
    "Terracotta", "Stone", "Marble"
]

public struct FountainArtwork: View {
    var variantIndex: Int
    
    public init(variant: Int) {
        self.variantIndex = variant
    }
    
    var variant: String {
        variants[variantIndex]
    }
    
    public var body: some View {
        Image("Fountain/\(variant)", bundle: .module)
            .resizable()
            .scaledToFit()
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The plant, composed of its parts.
*/

import BackyardBirdsData
import SwiftUI

public struct ComposedPlant: View {
    var plant: Plant
    
    public init(plant: Plant) {
        self.plant = plant
    }
    
    public var body: some View {
        ZStack {
            ForEach(plant.species.parts) { part in
                Image(imageName(for: part), bundle: .module)
                    .resizable()
                    .scaledToFit()
            }
        }
    }
    
    func imageName(for part: PlantPart) -> String {
        var result = "\(plant.species.id)/\(part.name)"
        if part.variants != nil {
            result.append(" \(plant.variant + 1)")
        }
        return result
    }
}



/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The bird, composed of its parts.
*/

import BackyardBirdsData
import SwiftUI

public struct ComposedBird: View {
    var bird: Bird
    var direction: HorizontalEdge
    
    public init(bird: Bird, direction: HorizontalEdge = .leading) {
        self.bird = bird
        self.direction = direction
    }
    
    public var body: some View {
        ZStack {
            ForEach(bird.species.parts) { part in
                if part.flipbookFrameCount != nil {
                    let i = 0
                    Image("\(bird.species.id)/\(part.name)\(i + 1)", bundle: .module)
                        .resizable()
                        .scaledToFit()
                        .colorMultiply(bird.colors.colorData(for: part.colorStyle).color)
                } else {
                    Image("\(bird.species.id)/\(part.name)", bundle: .module)
                        .resizable()
                        .scaledToFit()
                        .colorMultiply(bird.colors.colorData(for: part.colorStyle).color)
                }
            }
        }
        .scaleEffect(x: direction == .trailing ? 1 : -1)
        .flipsForRightToLeftLayoutDirection(true)
        .id(bird.id)
    }
    
    func frameIndex(date: Date, frameCount: Int) -> Int {
        let totalSeconds = date.timeIntervalSince1970
        let duration = TimeInterval(frameCount) * 0.1
        let seconds = totalSeconds.truncatingRemainder(dividingBy: duration)
        let progress = seconds / duration
        let frame = Int(floor(progress * Double(frameCount)))
        return frame
    }
}

#Preview {
    ModelPreview { bird in
        ComposedBird(bird: bird)
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The vibrant bird.
*/

import SwiftUI
import BackyardBirdsData

public struct VibrantBird: View {
    var bird: Bird
    var direction: HorizontalEdge
    
    public init(bird: Bird, direction: HorizontalEdge = .trailing) {
        self.bird = bird
        self.direction = direction
    }
    
    public var body: some View {
        Image("Vibrant \(bird.species.id)", bundle: .module)
            .resizable()
            .scaledToFit()
            .scaleEffect(direction == .leading ? -1 : 1)
            .flipsForRightToLeftLayoutDirection(true)
    }
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The silhouette.
*/

import SwiftUI

private let variants = [
    "Building 1", "Building 2", "Building 3", "Building 4", "Building 5",
    "Trees 1", "Trees 2", "Trees 3", "Trees 4", "Trees 5"
]

public struct SilhouetteArtwork: View {
    var variantIndex: Int
    
    public init(variant: Int) {
        self.variantIndex = variant
    }
    
    public var body: some View {
        Image(variants[variantIndex], bundle: .module)
            .resizable()
            .scaledToFit()
    }
}



// swift-tools-version: 5.9

/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The package that defines the app's user interface elements.
*/

import PackageDescription

let package = Package(
    name: "LayeredArtworkLibrary",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "LayeredArtworkLibrary",
            type: .dynamic,
            targets: ["LayeredArtworkLibrary"]
        )
    ],
    dependencies: [
        .package(path: "../BackyardBirdsData")
    ],
    targets: [
        .target(
            name: "LayeredArtworkLibrary",
            dependencies: [
                .product(name: "BackyardBirdsData", package: "BackyardBirdsData", condition: nil)
            ],
            path: "."
        )
    ]
)


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A convenience extensionto create floor images.
*/

import SwiftUI

public extension Image {
    static let floor = Image("Floor 1", bundle: .module).resizable()
}


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The floor.
*/

import SwiftUI

public struct FloorArtwork: View {
    var variant: Int
    
    public init(variant: Int) {
        self.variant = variant
    }
    
    public var body: some View {
        Image("Floor \(variant + 1)", bundle: .module)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}



