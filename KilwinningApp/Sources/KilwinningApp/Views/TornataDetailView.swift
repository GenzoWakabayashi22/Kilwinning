import SwiftUI

/// Vista dettaglio tornata con sezione discussioni audio
struct TornataDetailView: View {
    let tornata: Tornata
    let brother: Brother
    
    @StateObject private var dataService = DataService.shared
    @StateObject private var audioService = AudioService.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var presenceStatus: PresenceStatus = .nonConfermato
    @State private var discussioni: [AudioDiscussione] = []
    @State private var selectedAudio: AudioDiscussione? = nil
    @State private var isLoadingDiscussioni = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header tornata
                    VStack(alignment: .leading, spacing: 12) {
                        Text(tornata.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.masonicBlue)
                        
                        HStack(spacing: 16) {
                            Label(tornata.formattedDate, systemImage: "calendar")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        HStack(spacing: 12) {
                            // Tipo tornata badge
                            Label(tornata.type.rawValue, systemImage: tornata.type == .cerimonia ? "star.fill" : "calendar")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(tornata.type == .cerimonia ? AppTheme.masonicGold : AppTheme.masonicBlue)
                                .cornerRadius(8)
                            
                            // Location badge
                            Label(tornata.location.rawValue, systemImage: tornata.location.isHome ? "house.fill" : "arrow.right.circle.fill")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                // Platform-specific background color
                                #if os(iOS)
                                .background(Color(.systemGray))
                                #else
                                .background(Color(NSColor.systemGray))
                                #endif
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .cardStyle()
                    
                    // Informazioni
                    VStack(alignment: .leading, spacing: 16) {
                        InfoRow(label: "Introdotta da", value: tornata.introducedBy)
                        
                        HStack {
                            Text("Cena:")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Image(systemName: tornata.hasDinner ? "checkmark.circle.fill" : "xmark.circle")
                                .foregroundColor(tornata.hasDinner ? AppTheme.success : .gray)
                            
                            Text(tornata.hasDinner ? "Sì" : "No")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                        
                        if let notes = tornata.notes, !notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Note:")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Text(notes)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                    .padding()
                                    // Platform-specific background color
                                    #if os(iOS)
                                    .background(Color(.systemGray6))
                                    #else
                                    .background(Color(NSColor.controlBackgroundColor))
                                    #endif
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .cardStyle()
                    
                    // Sezione Discussioni Audio
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "waveform")
                                .font(.title2)
                                .foregroundColor(AppTheme.masonicGold)
                            
                            Text("Discussioni Audio")
                                .font(.headline)
                                .foregroundColor(AppTheme.masonicBlue)
                            
                            Spacer()
                            
                            if !discussioni.isEmpty {
                                Text("\(discussioni.count)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(AppTheme.masonicBlue)
                                    .cornerRadius(10)
                            }
                        }
                        
                        if isLoadingDiscussioni {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            .padding()
                        } else if discussioni.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "waveform.slash")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray.opacity(0.5))
                                
                                Text("Nessuna discussione audio disponibile")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(discussioni, id: \.id) { discussione in
                                    AudioDiscussioneRow(discussione: discussione)
                                        .onTapGesture {
                                            selectedAudio = discussione
                                        }
                                }
                            }
                        }
                    }
                    .padding()
                    .cardStyle()
                    
                    // Stato presenza
                    VStack(alignment: .leading, spacing: 12) {
                        Text("La tua presenza")
                            .font(.headline)
                            .foregroundColor(AppTheme.masonicBlue)
                        
                        HStack(spacing: 12) {
                            PresenceButton(
                                status: .presente,
                                isSelected: presenceStatus == .presente,
                                action: { updatePresence(.presente) }
                            )
                            
                            PresenceButton(
                                status: .assente,
                                isSelected: presenceStatus == .assente,
                                action: { updatePresence(.assente) }
                            )
                        }
                    }
                    .padding()
                    .cardStyle()
                }
                .padding()
            }
            .navigationTitle("Dettagli Tornata")
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
            }
            .task {
                await loadData()
            }
            .sheet(item: $selectedAudio) { audio in
                AudioPlayerView(
                    audioURL: audio.audioURL,
                    titolo: audio.titoloIntervento,
                    fratello: audio.fratelloIntervento
                )
            }
        }
    }
    
    private func loadData() async {
        // Carica stato presenza
        presenceStatus = dataService.getPresenceStatus(brotherId: brother.id, tornataId: tornata.id)
        
        // Carica discussioni audio
        isLoadingDiscussioni = true
        discussioni = await audioService.fetchDiscussioni(for: tornata.id)
        isLoadingDiscussioni = false
    }
    
    private func updatePresence(_ status: PresenceStatus) {
        Task {
            await dataService.updatePresence(brotherId: brother.id, tornataId: tornata.id, status: status)
            presenceStatus = status
        }
    }
}

/// Riga per una discussione audio
struct AudioDiscussioneRow: View {
    let discussione: AudioDiscussione
    
    var body: some View {
        HStack(spacing: 16) {
            // Icona play
            ZStack {
                Circle()
                    .fill(AppTheme.masonicBlue.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: "play.fill")
                    .font(.title3)
                    .foregroundColor(AppTheme.masonicBlue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(discussione.titoloIntervento)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Fr. \(discussione.fratelloIntervento)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack(spacing: 12) {
                    if let durata = discussione.durata {
                        Label(durata, systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Label(discussione.formattedUploadDate, systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        // Platform-specific background color
        #if os(iOS)
        .background(Color(.systemGray6))
        #else
        .background(Color(NSColor.controlBackgroundColor))
        #endif
        .cornerRadius(12)
    }
}

// PresenceButton moved to Utilities/CommonViews.swift to avoid duplication

#Preview {
    TornataDetailView(
        tornata: Tornata(
            title: "Il sentiero della saggezza",
            date: Date(),
            type: .ordinaria,
            location: .tofa,
            introducedBy: "Fr. Marco Rossi",
            hasDinner: true,
            notes: "Tornata con discussione sul simbolismo della squadra e del compasso"
        ),
        brother: Brother(
            firstName: "Paolo Giulio",
            lastName: "Gazzano",
            email: "demo@kilwinning.it",
            degree: .maestro,
            role: .venerabileMaestro,
            isAdmin: true
        )
    )
}
