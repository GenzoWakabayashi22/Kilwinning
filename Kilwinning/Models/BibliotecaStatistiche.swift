import Foundation

/// Statistiche generali della biblioteca
struct BibliotecaStatistiche: Codable {
    var totaleLibri: Int
    var libriDisponibili: Int
    var libriPrestati: Int
    var libriPrenotati: Int
    var totalePrestiti: Int
    var prestitiAttivi: Int
    var recensioniTotali: Int
    var votoMedioGlobale: Double?

    enum CodingKeys: String, CodingKey {
        case totaleLibri = "totale_libri"
        case libriDisponibili = "libri_disponibili"
        case libriPrestati = "libri_prestati"
        case libriPrenotati = "libri_prenotati"
        case totalePrestiti = "totale_prestiti"
        case prestitiAttivi = "prestiti_attivi"
        case recensioniTotali = "recensioni_totali"
        case votoMedioGlobale = "voto_medio_globale"
    }

    init(totaleLibri: Int = 0,
         libriDisponibili: Int = 0,
         libriPrestati: Int = 0,
         libriPrenotati: Int = 0,
         totalePrestiti: Int = 0,
         prestitiAttivi: Int = 0,
         recensioniTotali: Int = 0,
         votoMedioGlobale: Double? = nil) {
        self.totaleLibri = totaleLibri
        self.libriDisponibili = libriDisponibili
        self.libriPrestati = libriPrestati
        self.libriPrenotati = libriPrenotati
        self.totalePrestiti = totalePrestiti
        self.prestitiAttivi = prestitiAttivi
        self.recensioniTotali = recensioniTotali
        self.votoMedioGlobale = votoMedioGlobale
    }
}

/// Statistiche avanzate per admin
struct BibliotecaStatisticheAvanzate: Codable {
    var topLibriPrestati: [LibroStatistica]
    var topLibriRecensiti: [LibroStatistica]
    var topFratelliAttivi: [FratelloStatistica]
    var libriMaiPrestati: Int
    var mediaDurataPrestiti: Double? // in giorni
    var trendMensile: [TrendMensile]

    enum CodingKeys: String, CodingKey {
        case topLibriPrestati = "top_libri_prestati"
        case topLibriRecensiti = "top_libri_recensiti"
        case topFratelliAttivi = "top_fratelli_attivi"
        case libriMaiPrestati = "libri_mai_prestati"
        case mediaDurataPrestiti = "media_durata_prestiti"
        case trendMensile = "trend_mensile"
    }
}

/// Statistica per un singolo libro
struct LibroStatistica: Codable, Identifiable {
    let id: Int
    var titolo: String
    var autore: String
    var conteggio: Int // numero prestiti o recensioni
    var votoMedio: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case titolo
        case autore
        case conteggio
        case votoMedio = "voto_medio"
    }
}

/// Statistica per un fratello
struct FratelloStatistica: Codable, Identifiable {
    let id: Int
    var nome: String
    var numeroPrestiti: Int
    var numeroRecensioni: Int
    var votoMedioAssegnato: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case nome
        case numeroPrestiti = "numero_prestiti"
        case numeroRecensioni = "numero_recensioni"
        case votoMedioAssegnato = "voto_medio_assegnato"
    }
}

/// Trend mensile
struct TrendMensile: Codable, Identifiable {
    var id: String { "\(anno)-\(mese)" }
    var mese: Int
    var anno: Int
    var numeroPrestiti: Int
    var numeroRecensioni: Int

    enum CodingKeys: String, CodingKey {
        case mese
        case anno
        case numeroPrestiti = "numero_prestiti"
        case numeroRecensioni = "numero_recensioni"
    }

    var nomeM: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        let monthSymbols = formatter.monthSymbols!
        return monthSymbols[mese - 1]
    }
}
