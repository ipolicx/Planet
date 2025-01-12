//
//  AvatarPickerView.swift
//  Planet
//
//  Created by Xin Liu on 7/27/23.
//

import SwiftUI

enum AvatarCategory: String, CaseIterable {
    case nostalgia = "Nostalgia"
}

struct AvatarPickerView: View {
    @EnvironmentObject var store: PlanetStore
    @Binding var selection: AvatarCategory?
    @Environment(\.dismiss) var dismiss
    @State var avatars: [String: String]?
    @State var selectedAvatar: NSImage?
    @State var avatarChanged: Bool = false

    private func loadAvatars(category: AvatarCategory) -> [String: String]? {
        switch category {
        case .nostalgia:
            debugPrint("Loading Avatar category: \(category)")
            if let metadataFile = Bundle.main.url(forResource: "NSTG", withExtension: "json") {
                do {
                    let data = try Data(contentsOf: metadataFile)
                    let decoder = JSONDecoder()
                    let metadata = try decoder.decode([String: String].self, from: data)
                    debugPrint("Loaded avatar metadata: \(metadata)")
                    return metadata
                }
                catch {
                    debugPrint("Failed to load avatar metadata: \(error)")
                }
            }
            else {
                debugPrint("Avatar metadata NSTG.json not found")
            }
        }
        return nil
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List(selection: $selection) {
                    ForEach(AvatarCategory.allCases, id: \.self) { aCategory in
                        Text(aCategory.rawValue)
                    }
                }

                Spacer()

                if case .myPlanet(let planet) = store.selectedView {
                    ArtworkView(
                        image: selectedAvatar,
                        planetNameInitials: planet.nameInitials,
                        planetID: planet.id,
                        cornerRadius: 72,
                        size: CGSize(width: 144, height: 144),
                        uploadAction: { url in
                            do {
                                selectedAvatar = NSImage(contentsOf: url)
                                avatarChanged = true
                            }
                            catch {
                                debugPrint("failed to upload planet avatar: \(error)")
                            }
                        },
                        deleteAction: {
                            do {
                                selectedAvatar = nil
                            }
                            catch {
                                debugPrint("failed to remove planet avatar: \(error)")
                            }
                        }
                    )
                    .padding(.bottom, 20)
                }
            }
            .frame(width: 200)

            VStack(spacing: 0) {
                if let avatars = avatars, let keys = Array(avatars.keys) as? [String] {
                    ScrollView {
                        LazyVGrid(
                            columns: [GridItem(), GridItem(), GridItem()],
                            alignment: .center
                        ) {
                            ForEach(keys.sorted(), id: \.self) { aKey in
                                VStack {
                                    Image(aKey)
                                        .resizable()
                                        .frame(width: 64, height: 64)
                                        .cornerRadius(32)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 32)
                                                .stroke(Color("BorderColor"), lineWidth: 1)
                                        )
                                        .padding(.top, 16)
                                        .padding(.horizontal, 16)
                                        .padding(.bottom, 8)

                                    Text(avatars[aKey] ?? "")
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                }
                                .onTapGesture {
                                    debugPrint("Tapped on avatar: \(aKey)")
                                    if case .myPlanet(let planet) = store.selectedView {
                                        debugPrint("About to set planet avatar to \(aKey)")
                                        do {
                                            let image = NSImage(named: aKey)
                                            if let image = image, let avatarURL = image.temporaryURL
                                            {
                                                selectedAvatar = image
                                                avatarChanged = true
                                                debugPrint("Set planet avatar to \(aKey)")
                                            }
                                        }
                                        catch {
                                            debugPrint("failed to update planet avatar: \(error)")
                                        }
                                    }
                                    else {
                                        debugPrint("Cannot set planet avatar")
                                    }

                                }

                            }
                        }
                    }
                }

                Divider()

                HStack(spacing: 12) {
                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .padding(.vertical, 4)
                            .padding(.horizontal, 16)
                    }

                    Button {
                        if let avatar = selectedAvatar, let avatarURL = avatar.temporaryURL,
                            case .myPlanet(let planet) = store.selectedView
                        {
                            try? planet.updateAvatar(path: avatarURL)
                            dismiss()
                        }
                    } label: {
                        Text("Save")
                            .padding(.vertical, 4)
                            .padding(.horizontal, 16)
                    }
                    .disabled(!avatarChanged)
                }
                .padding(16)
            }
        }
        .frame(width: 600, height: 400)
        .onAppear {
            if selection == nil {
                selection = .nostalgia
            }
            if case .myPlanet(let planet) = store.selectedView {
                selectedAvatar = planet.avatar
            }
            if let category = selection {
                avatars = loadAvatars(category: category)
            }
        }
        .onChange(of: selection) { newValue in
            if let category = newValue {
                avatars = loadAvatars(category: category)
            }
        }
    }
}
