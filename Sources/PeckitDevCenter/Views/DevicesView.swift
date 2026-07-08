import SwiftUI

struct DevicesView: View {
    @EnvironmentObject var config: AppConfig

    @State private var avds: [String] = []
    @State private var androidDevices: [AndroidDevice] = []
    @State private var simulators: [IOSSimulator] = []
    @State private var busyMessage: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("▓▓▓ DEVICES ▓▓▓")
                    .font(Term.monoTitle)
                    .foregroundColor(Term.green)

                TermPanel(title: "ANDROID — EMULADORES (AVD)") {
                    ForEach(avds, id: \.self) { avd in
                        HStack {
                            Text(avd)
                                .font(Term.mono)
                                .foregroundColor(Term.gray)
                            Spacer()
                            TermButton(label: "LAUNCH") {
                                AndroidController.startEmulator(avdName: avd)
                                busyMessage = "iniciando \(avd)..."
                            }
                        }
                    }
                    if avds.isEmpty {
                        Text("no se encontraron AVDs")
                            .font(Term.monoSmall)
                            .foregroundColor(Term.gray)
                    }
                }

                TermPanel(title: "ANDROID — DISPOSITIVOS (adb)") {
                    ForEach(androidDevices) { device in
                        HStack {
                            StatusDot(state: .ok)
                            Text(device.id)
                                .font(Term.mono)
                                .foregroundColor(config.selectedAndroidSerial == device.id ? Term.green : Term.gray)
                            Text(device.description)
                                .font(Term.monoSmall)
                                .foregroundColor(Term.dimGreen)
                            Spacer()
                            TermButton(label: config.selectedAndroidSerial == device.id ? "SELECTED" : "SELECT") {
                                config.selectedAndroidSerial = device.id
                            }
                            if device.isEmulator {
                                TermButton(label: "STOP", danger: true) {
                                    AndroidController.killEmulator(serial: device.id)
                                    refresh()
                                }
                            }
                        }
                    }
                    if androidDevices.isEmpty {
                        Text("ningun dispositivo/emulador corriendo")
                            .font(Term.monoSmall)
                            .foregroundColor(Term.gray)
                    }
                    HStack {
                        TermButton(label: "REFRESH") { refresh() }
                        TermButton(label: "RESTART ADB") { AndroidController.restartAdb(); refresh() }
                    }
                }

                TermPanel(title: "IOS — SIMULADORES") {
                    ForEach(simulators) { sim in
                        HStack {
                            StatusDot(state: sim.state == "Booted" ? .ok : .unknown)
                            Text(sim.name)
                                .font(Term.mono)
                                .foregroundColor(config.selectedIOSUdid == sim.id ? Term.green : Term.gray)
                            Text(sim.state)
                                .font(Term.monoSmall)
                                .foregroundColor(Term.dimGreen)
                            Spacer()
                            TermButton(label: config.selectedIOSUdid == sim.id ? "SELECTED" : "SELECT") {
                                config.selectedIOSUdid = sim.id
                            }
                            if sim.state != "Booted" {
                                TermButton(label: "BOOT") {
                                    IOSController.boot(udid: sim.id)
                                    refresh()
                                }
                            } else {
                                TermButton(label: "SHUTDOWN", danger: true) {
                                    IOSController.shutdown(udid: sim.id)
                                    refresh()
                                }
                            }
                        }
                    }
                    if simulators.isEmpty {
                        Text("no se encontraron simuladores")
                            .font(Term.monoSmall)
                            .foregroundColor(Term.gray)
                    }
                    TermButton(label: "REFRESH") { refresh() }
                }

                if !busyMessage.isEmpty {
                    Text(busyMessage)
                        .font(Term.monoSmall)
                        .foregroundColor(Term.amber)
                }
            }
            .padding(20)
        }
        .background(Term.background)
        .onAppear { refresh() }
    }

    private func refresh() {
        avds = AndroidController.listAVDs()
        androidDevices = AndroidController.listDevices()
        simulators = IOSController.listSimulators()
    }
}
