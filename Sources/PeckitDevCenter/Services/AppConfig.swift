import Foundation

final class AppConfig: ObservableObject {
    @Published var projectPath: String {
        didSet { UserDefaults.standard.set(projectPath, forKey: "projectPath") }
    }
    @Published var metroPort: String {
        didSet { UserDefaults.standard.set(metroPort, forKey: "metroPort") }
    }
    @Published var selectedAndroidSerial: String {
        didSet { UserDefaults.standard.set(selectedAndroidSerial, forKey: "selectedAndroidSerial") }
    }
    @Published var selectedIOSUdid: String {
        didSet { UserDefaults.standard.set(selectedIOSUdid, forKey: "selectedIOSUdid") }
    }

    init() {
        let home = NSHomeDirectory()
        self.projectPath = UserDefaults.standard.string(forKey: "projectPath") ?? "\(home)/peckit-mobile"
        self.metroPort = UserDefaults.standard.string(forKey: "metroPort") ?? "8081"
        self.selectedAndroidSerial = UserDefaults.standard.string(forKey: "selectedAndroidSerial") ?? ""
        self.selectedIOSUdid = UserDefaults.standard.string(forKey: "selectedIOSUdid") ?? ""
    }
}
