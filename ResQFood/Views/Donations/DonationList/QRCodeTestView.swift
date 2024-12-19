//
//  TestView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 18.12.24.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins
import AVFoundation
import WebKit


struct QRCodeTestView: View {

    var body: some View {
        TabView{
            Tab("QRCODE", systemImage: "qrcode"){
                QRCodeView(qrCode: generateQRCode(from: "https://resqfood.example.com/donation/12345"))
            }
            Tab("SCANNER", systemImage: "qrcode.viewfinder"){
                QRCodeScannerView()
            }
        }
        
    }
}

#Preview {
    QRCodeTestView()
}

struct QRCodeView: View {
    let qrCode: UIImage?

    var body: some View {
        if let qrCode = qrCode {
            Image(uiImage: qrCode)
                .resizable()
                .interpolation(.none) // Für scharfe Darstellung
                .scaledToFit()
                .frame(width: 200, height: 200)
        } else {
            Text("Fehler beim Erstellen des QR-Codes")
        }
    }
}

struct QRCodeScannerView: View {
    @State private var scannedCode: String?
    @State private var isScannerPresented = false

    var body: some View {
        VStack(spacing: 20) {
            if let scannedCode = scannedCode {
                Text("Gescannt: \(scannedCode)")
                    .font(.headline)
            } else {
                Text("Noch kein QR-Code gescannt")
                    .font(.subheadline)
            }

            Button(action: {
                isScannerPresented = true
            }) {
                Text("QR-Code scannen")
                    .font(.title2)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .sheet(isPresented: $isScannerPresented) {
            VStack{
                Group {
                    #if targetEnvironment(simulator)
                    MockCameraView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                withAnimation {
                                    let code = "https://resqfood.example.com/donation/12345"
                                    self.scannedCode = code
                                    self.isScannerPresented = false                    }
                            }
                        }
                    #else
                    QRScannerView { code in
                        self.scannedCode = code
                        self.isScannerPresented = false
                    }
                    #endif
                }
                .padding(.top, 72)
                Spacer()
            }
            
            
        }
    }
}

struct MockCameraView: View {
    var body: some View {
        VStack{
            GifImageView("QRDEMO")
        }
        .overlay(
            Rectangle()
                .stroke(lineWidth: 5)
                .tint(Color("primaryAT"))
        )
        .frame(width: 350, height: 350)
    }
}

struct GifImageView: UIViewRepresentable {
    private let name: String
    init(_ name: String) {
        self.name = name
    }
    func makeUIView(context: Context) -> WKWebView {
        let webview = WKWebView()
        
        webview.isOpaque = false
        webview.backgroundColor = .clear
        
        webview.scrollView.backgroundColor = .clear
        
        let url = Bundle.main.url(forResource: name, withExtension: "gif")!
        let data = try! Data(contentsOf: url)
        webview.load(
            data,
            mimeType: "image/gif",
            characterEncodingName: "UTF-8",
            baseURL: url.deletingLastPathComponent()
        )
        return webview
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.reload()
    }
}



func generateQRCode(from string: String) -> UIImage? {
    let filter = CIFilter.qrCodeGenerator()

    guard let data = string.data(using: .ascii) else { return nil }
    filter.message = data
    filter.correctionLevel = "H"

    if let outputImage = filter.outputImage {
        let transform = CGAffineTransform(scaleX: 12, y: 12)
        let scaledImage = outputImage.transformed(by: transform)
        if let cgImage = CIContext().createCGImage(scaledImage, from: scaledImage.extent) {
            return UIImage(cgImage: cgImage)
        }
    }
    return nil
}

struct QRScannerView: UIViewControllerRepresentable {
    var onCodeScanned: (String) -> Void // Callback, wenn QR-Code erkannt wird

    func makeUIViewController(context: Context) -> QRScannerViewController {
        let scannerVC = QRScannerViewController()
        scannerVC.delegate = context.coordinator
        return scannerVC
    }

    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {
        // Kein spezielles Update benötigt
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onCodeScanned: onCodeScanned)
    }

    // Coordinator zur Verbindung von SwiftUI und UIKit
    class Coordinator: NSObject, QRScannerViewControllerDelegate {
        var onCodeScanned: (String) -> Void

        init(onCodeScanned: @escaping (String) -> Void) {
            self.onCodeScanned = onCodeScanned
        }

        func didFindCode(_ code: String) {
            onCodeScanned(code)
        }
    }
}

protocol QRScannerViewControllerDelegate: AnyObject {
    func didFindCode(_ code: String)
}

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: QRScannerViewControllerDelegate?

    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    private func setupCamera() {
        // Berechtigungsprüfung für Kamera
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch cameraAuthorizationStatus {
        case .notDetermined:
            // Berechtigung anfordern
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.setupCamera()
                    }
                } else {
                    print("Kamera-Zugriff verweigert.")
                }
            }
        case .authorized:
            configureSession()
        case .restricted, .denied:
            print("Kamera-Zugriff verweigert oder eingeschränkt.")
        default:
            print("Unbekannter Berechtigungsstatus.")
        }
    }

    private func configureSession() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("Kamera nicht verfügbar.")
            return
        }

        // Konfiguriere Kamera-Session
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            print("Kamera-Input konnte nicht erstellt werden.")
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            print("Kamera-Input konnte nicht hinzugefügt werden.")
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            print("QR-Code-Output konnte nicht hinzugefügt werden.")
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = view.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        if let previewLayer = previewLayer {
            view.layer.addSublayer(previewLayer)
        }

        captureSession.startRunning()
    }

    // Verarbeitung erkannter QR-Codes
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                  let stringValue = readableObject.stringValue else { return }

            captureSession.stopRunning() // Kamera-Scan pausieren
            delegate?.didFindCode(stringValue) // Code an Delegate senden
            dismiss(animated: true)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning() // Kamera stoppen, wenn View verschwindet
    }
}
