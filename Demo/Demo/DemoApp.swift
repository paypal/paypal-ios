import SwiftUI

@main
struct DemoApp: App {

    init() {
        DemoSettings.applyManualTestingConfiguration()
    }

    var body: some Scene {
        WindowGroup {
            FeatureSelectionView()
        }
    }
}
