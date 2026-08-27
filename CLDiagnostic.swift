import SwiftUI
import CoreLocation

final class LocationModel: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let manager = CLLocationManager()

    @Published var status = "Esperando permiso…"
    @Published var simulated = "—"
    @Published var accessory = "—"
    @Published var coordinates = "—"

    override init() {
        super.init()

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
    }

    func start() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {
        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            status = "Ubicación autorizada"
            manager.startUpdatingLocation()
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }

        coordinates = String(
            format: "%.7f, %.7f",
            location.coordinate.latitude,
            location.coordinate.longitude
        )

        if let source = location.sourceInformation {
            simulated = source.isSimulatedBySoftware ? "TRUE" : "FALSE"
            accessory = source.isProducedByAccessory ? "TRUE" : "FALSE"
        } else {
            simulated = "nil"
            accessory = "nil"
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        status = "Error: \(error.localizedDescription)"
    }
}

@main
struct CLDiagnosticApp: App {

    @StateObject private var location = LocationModel()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                VStack(spacing: 20) {

                    Text("Core Location Diagnostic")
                        .font(.title2)
                        .bold()

                    Text(location.status)

                    Text("Coordenadas")
                        .bold()

                    Text(location.coordinates)
                        .font(.system(.body, design: .monospaced))

                    Divider()

                    Text("isSimulatedBySoftware")
                        .bold()

                    Text(location.simulated)
                        .font(.title)

                    Text("isProducedByAccessory")
                        .bold()

                    Text(location.accessory)
                        .font(.title)

                    Button("Iniciar ubicación") {
                        location.start()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
    }
}
