import Sparkle
import SwiftUI

struct UpdatesPreferencePane: View {
    @EnvironmentObject var updater: ObservableUpdater
    
    @AppStorage("autoInstallation") var autoInstallationType: AutoInstallationType = .none
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            GroupBox(label: Text("Versions")) {
                VStack(alignment: .leading) {
                    Toggle(
                        "AutomaticInstallNewVersion",
                        isOn: $autoInstallationType.isAutoInstalling
                    )
                    .disabled(updater.disableAutoInstallNewVersions)

                    Toggle(
                        "IncludePreRelease",
                        isOn: $autoInstallationType.isAutoInstallingBeta
                    )
                    .disabled(updater.disableIncludePrereleaseVersions)
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .groupBoxStyle(PreferencesGroupBoxStyle())
            
            Text("This fork does not check for Xcodes.app updates. Download new builds from the GitHub releases page.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

@MainActor
class ObservableUpdater: ObservableObject {
    private let updater: SPUUpdater
    private let updaterDelegate = UpdaterDelegate()

    var disableAutoInstallNewVersions: Bool { PreferenceKey.autoInstallation.isManaged() }
    var disableIncludePrereleaseVersions: Bool { PreferenceKey.autoInstallation.isManaged() }

    init() {
        updater = SPUStandardUpdaterController(startingUpdater: false, updaterDelegate: updaterDelegate, userDriverDelegate: nil).updater
        updater.automaticallyChecksForUpdates = false
        updater.clearFeedURLFromUserDefaults()
    }
}

class UpdaterDelegate: NSObject, SPUUpdaterDelegate {
    func feedURLString(for updater: SPUUpdater) -> String? {
        return nil
    }
}

struct UpdatesPreferencePane_Previews: PreviewProvider {
    @MainActor
    static var previews: some View {
        Group {
            UpdatesPreferencePane()
                .environmentObject(AppState())
                .environmentObject(ObservableUpdater())
                .frame(maxWidth: 600)
                .frame(minHeight: 300)
        }
    }
}
