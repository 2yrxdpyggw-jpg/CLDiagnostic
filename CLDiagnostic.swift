import UIKit
import CoreLocation

final class LocationViewController: UIViewController, CLLocationManagerDelegate {

    private let manager = CLLocationManager()
    private let textView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "CL Diagnostic"

        textView.isEditable = false
        textView.font = .monospacedSystemFont(ofSize: 15, weight: .regular)
        textView.textColor = .label
        textView.backgroundColor = .systemBackground
        textView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone

        textView.text = """
        CL Diagnostic

        Solicitando permiso de ubicación...
        """

        manager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()

        case .denied:
            textView.text = "Ubicación: DENEGADA"

        case .restricted:
            textView.text = "Ubicación: RESTRINGIDA"

        case .notDetermined:
            break

        @unknown default:
            break
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }

        let source = location.sourceInformation

        let simulated: String
        let accessory: String

        if let source {
            simulated = source.isSimulatedBySoftware ? "TRUE" : "FALSE"
            accessory = source.isProducedByAccessory ? "TRUE" : "FALSE"
        } else {
            simulated = "nil"
            accessory = "nil"
        }

        let formatter = ISO8601DateFormatter()

        textView.text = """
        CL DIAGNOSTIC
        ─────────────────────

        COORDENADAS
        Latitude:  \(location.coordinate.latitude)
        Longitude: \(location.coordinate.longitude)

        ALTITUD
        \(location.altitude) m

        PRECISIÓN
        Horizontal: \(location.horizontalAccuracy) m
        Vertical:   \(location.verticalAccuracy) m

        MOVIMIENTO
        Velocidad: \(location.speed) m/s
        Rumbo:     \(location.course)°

        TIMESTAMP
        \(formatter.string(from: location.timestamp))

        ─────────────────────
        SOURCE INFORMATION

        isSimulatedBySoftware:
        \(simulated)

        isProducedByAccessory:
        \(accessory)

        ─────────────────────
        Core Location está
        entregando estos valores
        directamente a la app.
        """
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        textView.text = """
        ERROR DE CORE LOCATION

        \(error.localizedDescription)
        """
    }
}

@main
final class CLDiagnosticApp: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
        [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        let window = UIWindow(frame: UIScreen.main.bounds)
        let controller = LocationViewController()
        let navigation = UINavigationController(rootViewController: controller)

        window.rootViewController = navigation
        window.makeKeyAndVisible()

        self.window = window

        return true
    }
}
