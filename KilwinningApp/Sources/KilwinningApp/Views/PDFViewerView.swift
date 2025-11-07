import SwiftUI
// Platform-specific imports for PDF handling
#if os(iOS)
import UIKit
#else
import AppKit
#endif
#if canImport(PDFKit)
import PDFKit
#endif
#if canImport(QuickLook)
import QuickLook
#endif

/// Vista per visualizzare un PDF
struct PDFViewerView: View {
    let pdfURL: String
    let titolo: String
    
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Caricamento PDF...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                } else if let error = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)
                        
                        Text("Errore nel caricamento")
                            .font(.headline)
                        
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    #if canImport(PDFKit)
                    if let url = URL(string: pdfURL) {
                        PDFKitView(url: url)
                    } else {
                        Text("URL PDF non valido")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    #else
                    Text("Visualizzazione PDF non disponibile su questa piattaforma")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    #endif
                }
            }
            .navigationTitle(titolo)
            // Platform-specific navigation bar display mode (iOS only)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
                
                #if canImport(PDFKit)
                ToolbarItem(placement: .primaryAction) {
                    if !isLoading, errorMessage == nil, let url = URL(string: pdfURL) {
                        ShareLink(item: url) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
                #endif
            }
            .task {
                await loadPDF()
            }
        }
    }
    
    private func loadPDF() async {
        // Simulazione caricamento
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        guard URL(string: pdfURL) != nil else {
            errorMessage = "URL PDF non valido"
            isLoading = false
            return
        }
        
        isLoading = false
    }
}

#if canImport(PDFKit)
// Platform-specific PDFKit wrapper: uses UIViewRepresentable on iOS and NSViewRepresentable on macOS
#if os(iOS)
/// Wrapper for PDFView on iOS
struct PDFKitView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        
        // Carica il PDF dall'URL
        if let document = PDFDocument(url: url) {
            pdfView.document = document
        }
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        // Non necessario aggiornare
    }
}
#else
/// Wrapper for PDFView on macOS
struct PDFKitView: NSViewRepresentable {
    let url: URL
    
    func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        
        // Carica il PDF dall'URL
        if let document = PDFDocument(url: url) {
            pdfView.document = document
        }
        
        return pdfView
    }
    
    func updateNSView(_ nsView: PDFView, context: Context) {
        // Non necessario aggiornare
    }
}
#endif
#endif

#Preview {
    PDFViewerView(
        pdfURL: "https://example.com/tavola.pdf",
        titolo: "Il Simbolismo della Squadra"
    )
}
