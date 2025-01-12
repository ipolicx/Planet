//
//  CPNSettings.swift
//  Planet
//
//  Created by Xin Liu on 7/7/23.
//

import SwiftUI

struct CPNSettings: View {
    let CONTROL_CAPTION_WIDTH: CGFloat = 170
    let CONTROL_ROW_SPACING: CGFloat = 8

    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var planetStore: PlanetStore
    @ObservedObject var planet: MyPlanetModel

    @State private var currentSettings: [String: String] = [:]
    @State private var userSettings: [String: String] = [:]

    @State private var settingKeys: [String] = [
        "mainnetCollectionID",
        "mainnetCollectionCategory",
        "mainnetRPC",
        "mainnetCPNBeneficiaryAddress",
        "separator1",
        "goerliCollectionID",
        "goerliCollectionCategory",
        "goerliRPC",
        "goerliCPNBeneficiaryAddress",
        "separator2",
        "highlightColor",
    ]

    init(planet: MyPlanetModel) {
        self.planet = planet
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                HStack(spacing: 10) {
                    planet.smallAvatarAndNameView()
                    Spacer()
                }

                TabView {
                    VStack(spacing: CONTROL_ROW_SPACING) {
                        if let template = planet.template, let settings = template.settings {
                            ForEach(settingKeys, id: \.self) { key in
                                if key.hasPrefix("separator") {
                                    Divider()
                                        .padding(.top, 6)
                                        .padding(.bottom, 6)
                                }
                                else {
                                    HStack {
                                        HStack {
                                            Text("\(settings[key]?.name ?? key)")
                                            Spacer()
                                        }
                                        .frame(width: CONTROL_CAPTION_WIDTH)

                                        TextField("", text: binding(key: key))
                                            .textFieldStyle(.roundedBorder)
                                    }

                                    if let description = settings[key]?.description,
                                        description.count > 0
                                    {
                                        HStack {
                                            HStack {
                                                Spacer()
                                            }
                                            .frame(width: CONTROL_CAPTION_WIDTH + 10)

                                            Text(
                                                description
                                            )
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                            .fixedSize(horizontal: false, vertical: true)

                                            Spacer()
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)
                    .tabItem {
                        Text("CPN Settings")
                    }
                }

                HStack(spacing: 8) {
                    Spacer()

                    Button {
                        PlanetStore.shared.isConfiguringCPN = false
                    } label: {
                        Text("Cancel")
                            .frame(width: 50)
                    }
                    .keyboardShortcut(.escape, modifiers: [])

                    Button {
                        debugPrint("Template-level user settings: \(userSettings)")
                        Task {
                            planet.updateTemplateSettings(settings: userSettings)
                            try? planet.copyTemplateSettings()
                            try await planet.publish()
                        }
                        dismiss()
                    } label: {
                        Text("OK")
                            .frame(width: 50)
                    }
                }

            }.padding(PlanetUI.SHEET_PADDING)
        }
        .padding(0)
        .frame(width: 520, alignment: .top)
        .onAppear {
            currentSettings = planet.templateSettings()
            for (key, value) in currentSettings {
                userSettings[key] = value
            }
        }
    }

    private func binding(key: String) -> Binding<String> {
        return Binding<String>(
            get: {
                return userSettings[key] ?? planet.template?.settings?[key]?.defaultValue ?? ""
            },
            set: {
                userSettings[key] = $0
            }
        )
    }
}
