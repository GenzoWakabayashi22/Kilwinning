import SwiftUI
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
                    PDFKitView(url: URL(string: pdfURL)!)
                    #else
                    Text("Visualizzazione PDF non disponibile su questa piattaforma")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    #endif
                }
            }
            .navigationTitle(titolo)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
                
                #if canImport(PDFKit)
                ToolbarItem(placement: .primaryAction) {
                    if !isLoading, errorMessage == nil {
                        ShareLink(item: URL(string: pdfURL)!) {
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
/// Wrapper per PDFView
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
#endif

#Preview {
    PDFViewerView(
        pdfURL: "https://example.com/tavola.pdf",
        titolo: "Il Simbolismo della Squadra"
    )
}
