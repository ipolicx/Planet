//
//  AppContentView.swift
//  PlanetLite
//

import SwiftUI


struct AppContentView: View {
    @StateObject private var planetStore: PlanetStore

    static let itemWidth: CGFloat = 128

    let dropDelegate: AppContentDropDelegate

    let timer = Timer.publish(every: 300, on: .current, in: .common).autoconnect()

    init() {
        _planetStore = StateObject(wrappedValue: PlanetStore.shared)
        dropDelegate = AppContentDropDelegate()
    }

    var body: some View {
        VStack {
            if planetStore.myPlanets.count == 0 {
                // Default empty view of the Lite app
                Text("Hello World :)")
                    .foregroundColor(.secondary)
                Button {
                    planetStore.isCreatingPlanet = true
                } label: {
                    Text("Create First Site")
                }
                .disabled(planetStore.isCreatingPlanet)
                Text("Learn more about [Croptop](https://croptop.eth.limo)")
                    .foregroundColor(.secondary)
            } else {
                switch planetStore.selectedView {
                case .myPlanet(let planet):
                    if planet.articles.count == 0 {
                        // TODO: Add an illustration here
                        Text("Drag and drop a picture here to start.")
                            .foregroundColor(.secondary)
                    } else {
                        AppContentGridView(planet: planet, itemSize: NSSize(width: Self.itemWidth, height: Self.itemWidth))
                    }
                default:
                    Text("No Content")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(0)
        .frame(minWidth: PlanetUI.WINDOW_CONTENT_WIDTH_MIN, idealWidth: PlanetUI.WINDOW_CONTENT_WIDTH_MIN, maxWidth: .infinity, minHeight: PlanetUI.WINDOW_CONTENT_HEIGHT_MIN, idealHeight: PlanetUI.WINDOW_CONTENT_HEIGHT_MIN, maxHeight: .infinity, alignment: .center)
        .background(Color(NSColor.textBackgroundColor))
        .onDrop(of: [.image], delegate: dropDelegate) // TODO: Video and Audio support
        .onReceive(timer) { _ in
            Task {
                await planetStore.aggregate()
            }
        }
        .sheet(isPresented: $planetStore.isConfiguringCPN) {
            if case .myPlanet(let planet) = planetStore.selectedView {
                CPNSettings(planet: planet)
            }
        }
        .sheet(isPresented: $planetStore.isConfiguringAggregation) {
            if case .myPlanet(let planet) = planetStore.selectedView {
                AggregationSettings(planet: planet)
            }
        }
        .sheet(isPresented: $planetStore.isShowingPlanetIPNS) {
            if case .myPlanet(let planet) = planetStore.selectedView {
                MyPlanetIPNSView(planet: planet)
            }
        }
    }
}

struct AppContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppContentView()
    }
}
