import SwiftUI

struct FollowPlanetView: View {
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var planetStore: PlanetStore
    @State var link = ""
    @State var isFollowing = false
    @State var isCancelled = false

    var body: some View {
        VStack (spacing: 0) {
            Text("Follow Planet")
                .frame(height: 34, alignment: .leading)
                .padding(.bottom, 2)
                .padding(.horizontal, 16)
                .font(.system(size: 15, weight: .regular, design: .default))
                .background(.clear)

            Divider()

            VStack {
                if isFollowing {
                    Text("Following \(link)")
                    ProgressView()
                        .progressViewStyle(.linear)
                } else {
                    TextEditor(text: $link)
                        .font(.system(size: 13, weight: .regular, design: .monospaced))
                        .lineSpacing(4)
                        .disableAutocorrection(true)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.secondary.opacity(0.25), lineWidth: 1.0)
                        )
                }
            }
            .frame(height: 60)
            .padding(.all, 16)

            Divider()

            HStack {
                Button {
                    cancelAction()
                } label: {
                    Text("Cancel")
                }
                .keyboardShortcut(.escape, modifiers: [])

                Spacer()

                Button {
                    followAction()
                } label: {
                    Text("Follow")
                }
                .disabled(isFollowing)
            }
            .padding(16)
        }
        .frame(width: 480, alignment: .center)
        .task {
            // Follow a new planet from internal planet link.
            Task { @MainActor in
                guard self.planetStore.followingPlanetLink != "" else { return }
                self.link = self.planetStore.followingPlanetLink
                self.followAction()
            }
        }
    }

    private func cancelAction() {
        isCancelled = true
        isFollowing = false
        dismiss()
        Task { @MainActor in
            self.planetStore.followingPlanetLink = ""
        }
    }

    private func followAction() {
        isFollowing = true
        Task {
            do {
                let planet = try await FollowingPlanetModel.follow(link: link)
                if isCancelled {
                    planet.delete()
                } else {
                    planetStore.followingPlanets.insert(planet, at: 0)
                    planetStore.selectedView = .followingPlanet(planet)
                }
            } catch PlanetError.PlanetExistsError {
                // ignore
            } catch PlanetError.ENSNoContentHashError {
                if !isCancelled {
                    PlanetStore.shared.alert(
                        title: "Unable to follow planet".localized,
                        message: "This ENS has no contenthash.".localized
                    )
                }
            } catch {
                if !isCancelled {
                    PlanetStore.shared.alert(
                        title: "Failed to follow planet".localized,
                        message: "\(error)".localized
                    )
                }
            }
            isCancelled = false
            isFollowing = false
            dismiss()
            Task { @MainActor in
                self.planetStore.followingPlanetLink = ""
            }
        }
    }
}
