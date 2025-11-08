import SwiftUI

/// Vista principale della biblioteca con dashboard e catalogo completo
struct BibliotecaView: View {
    @EnvironmentObject var bibliotecaService: BibliotecaService
    @EnvironmentObject var authService: AuthenticationService

    @State private var searchText = ""
    @State private var selectedStato: LibroStato? = nil
    @State private var selectedCategoria: String? = nil
    @State private var showingAddLibro = false
    @State private var selectedLibro: Libro? = nil
    @State private var showDashboard = true

    var filteredLibri: [Libro] {
        var libri = bibliotecaService.libri

        // Applica filtro ricerca
        if !searchText.isEmpty {
            libri = bibliotecaService.searchLibri(query: searchText)
        }

        // Applica filtro stato
        if let stato = selectedStato {
            libri = libri.filter { $0.stato == stato }
        }

        // Applica filtro categoria
        if let categoria = selectedCategoria {
            libri = libri.filter { $0.categoria == categoria }
        }

        return libri.sorted { $0.titolo < $1.titolo }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "books.vertical.fill")
                        .font(.title)
                        .foregroundColor(AppTheme.masonicGold)

                    Text("Biblioteca Kilwinning")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.masonicBlue)

                    Spacer()

                    // Toggle dashboard/catalogo
                    Button(action: { showDashboard.toggle() }) {
                        Image(systemName: showDashboard ? "books.vertical" : "chart.bar")
                            .font(.title2)
                            .foregroundColor(AppTheme.masonicBlue)
                    }
                }

                // Dashboard statistiche
                if showDashboard {
                    BibliotecaDashboard()
                }

                // Barra di ricerca
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)

                    TextField("Cerca per titolo, autore o categoria...", text: $searchText)
                        .textFieldStyle(.plain)

                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(12)
                .background(Color.appSecondaryBackground)
                .cornerRadius(10)

                // Filtri stato
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterChip(
                            title: "Tutti",
                            isSelected: selectedStato == nil && selectedCategoria == nil,
                            action: {
                                selectedStato = nil
                                selectedCategoria = nil
                            }
                        )

                        FilterChip(
                            title: "Disponibili",
                            isSelected: selectedStato == .disponibile,
                            action: { selectedStato = .disponibile }
                        )

                        FilterChip(
                            title: "In Prestito",
                            isSelected: selectedStato == .inPrestito,
                            action: { selectedStato = .inPrestito }
                        )

                        FilterChip(
                            title: "Preferiti",
                            isSelected: false,
                            action: {
                                // TODO: Filter favorites
                            }
                        )

                        // Categorie
                        ForEach(bibliotecaService.categorie, id: \.id) { categoria in
                            FilterChip(
                                title: "\(categoria.icona) \(categoria.nome)",
                                isSelected: selectedCategoria == categoria.nome,
                                action: { selectedCategoria = categoria.nome }
                            )
                        }

                        // Pulsante aggiungi (solo admin)
                        if authService.currentBrother?.isAdmin == true {
                            Button(action: { showingAddLibro = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(AppTheme.masonicBlue)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color.appBackground)

            Divider()

            // Lista libri
            if bibliotecaService.isLoading {
                VStack {
                    Spacer()
                    ProgressView("Caricamento...")
                    Spacer()
                }
            } else if filteredLibri.isEmpty {
                EmptyStateView(
                    icon: "books.vertical",
                    message: searchText.isEmpty ? "Nessun libro in catalogo" : "Nessun libro trovato"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredLibri, id: \.id) { libro in
                            LibroCard(libro: libro)
                                .onTapGesture {
                                    selectedLibro = libro
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .task {
            await loadData()
        }
        .refreshable {
            await loadData()
        }
        .sheet(item: $selectedLibro) { libro in
            LibroDetailView(libro: libro)
        }
        .sheet(isPresented: $showingAddLibro) {
            AddLibroView()
        }
    }

    private func loadData() async {
        await bibliotecaService.fetchLibri()
        await bibliotecaService.fetchCategorie()
        await bibliotecaService.fetchPreferiti()
        await bibliotecaService.fetchStatistiche()
    }
}

/// Dashboard con statistiche biblioteca
struct BibliotecaDashboard: View {
    @EnvironmentObject var bibliotecaService: BibliotecaService

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatCard(
                    title: "Totale",
                    value: "\(bibliotecaService.statistiche?.totaleLibri ?? 0)",
                    icon: "books.vertical.fill",
                    color: AppTheme.masonicBlue
                )

                StatCard(
                    title: "Disponibili",
                    value: "\(bibliotecaService.statistiche?.libriDisponibili ?? 0)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }

            HStack(spacing: 12) {
                StatCard(
                    title: "In Prestito",
                    value: "\(bibliotecaService.statistiche?.libriPrestati ?? 0)",
                    icon: "arrow.right.circle.fill",
                    color: .orange
                )

                StatCard(
                    title: "I Miei Prestiti",
                    value: "\(bibliotecaService.mieiPrestiti.filter { $0.stato == .attivo }.count)",
                    icon: "person.fill",
                    color: AppTheme.masonicGold
                )
            }
        }
    }
}

/// Card per statistiche
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Spacer()

                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }

            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color.appSecondaryBackground)
        .cornerRadius(12)
    }
}

/// Card per visualizzare un libro
struct LibroCard: View {
    let libro: Libro
    @EnvironmentObject var bibliotecaService: BibliotecaService

    var isFavorito: Bool {
        bibliotecaService.preferiti.contains(libro.id)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Copertina
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppTheme.masonicBlue.opacity(0.1))
                    .frame(width: 80, height: 100)

                if let coverURL = libro.copertinaURL {
                    // TODO: AsyncImage per caricare copertina
                    Image(systemName: "book.fill")
                        .font(.largeTitle)
                        .foregroundColor(AppTheme.masonicBlue)
                } else {
                    Image(systemName: "book.fill")
                        .font(.largeTitle)
                        .foregroundColor(AppTheme.masonicBlue)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(libro.titolo)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)

                    Spacer()

                    // Icona preferito
                    Image(systemName: isFavorito ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundColor(isFavorito ? .red : .gray)
                }

                Text(libro.autore)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                // Voto medio
                if let votoMedio = libro.votoMedio {
                    HStack(spacing: 4) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(round(votoMedio)) ? "star.fill" : "star")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                        Text(String(format: "%.1f", votoMedio))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                HStack {
                    Label(libro.anno, systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Label(libro.categoria, systemImage: "tag")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                HStack {
                    Text(libro.codiceArchivio)
                        .font(.caption2)
                        .foregroundColor(.gray)

                    Spacer()

                    // Badge stato
                    Text(libro.stato.rawValue)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statoColor(libro.stato))
                        .cornerRadius(8)
                }
            }

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding()
        .cardStyle()
    }

    private func statoColor(_ stato: LibroStato) -> Color {
        switch stato {
        case .disponibile: return AppTheme.success
        case .inPrestito: return AppTheme.error
        case .prenotato: return AppTheme.warning
        }
    }
}

/// Componente per filtro chip (già definito nel vecchio file, mantenuto uguale)
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : AppTheme.masonicBlue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? AppTheme.masonicBlue : Color.appSecondaryBackground)
                .cornerRadius(16)
        }
    }
}

#Preview {
    BibliotecaView()
        .environmentObject(AuthenticationService())
        .environmentObject(BibliotecaService())
}
