import SwiftUI

struct AdministrationView: View {
    @State private var selectedSection = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            Text("Amministrazione")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.masonicBlue)
            
            // Menu sezioni
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    AdminTabButton(title: "Utenti", icon: "person.3.fill", isSelected: selectedSection == 0) {
                        selectedSection = 0
                    }
                    
                    AdminTabButton(title: "Tornate", icon: "calendar.badge.plus", isSelected: selectedSection == 1) {
                        selectedSection = 1
                    }
                    
                    AdminTabButton(title: "Statistiche", icon: "chart.bar.fill", isSelected: selectedSection == 2) {
                        selectedSection = 2
                    }
                    
                    AdminTabButton(title: "Report", icon: "doc.text.fill", isSelected: selectedSection == 3) {
                        selectedSection = 3
                    }
                }
            }
            
            // Contenuto
            switch selectedSection {
            case 0:
                UsersManagementView()
            case 1:
                TornateManagementView()
            case 2:
                StatisticsView()
            case 3:
                ReportsView()
            default:
                UsersManagementView()
            }
        }
    }
}

struct AdminTabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(isSelected ? AppTheme.white : AppTheme.masonicBlue)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? AppTheme.masonicBlue : AppTheme.white)
            .cornerRadius(10)
            .shadow(color: AppTheme.cardShadow, radius: 2, x: 0, y: 1)
        }
    }
}

struct UsersManagementView: View {
    @StateObject private var dataService = DataService()
    @EnvironmentObject var authService: AuthenticationService
    @State private var showingAddUser = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Gestione Fratelli")
                    .font(.headline)
                    .foregroundColor(AppTheme.masonicBlue)
                
                Spacer()
                
                Button(action: { showingAddUser = true }) {
                    Label("Aggiungi Fratello", systemImage: "plus.circle.fill")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.masonicGold)
                }
            }
            
            VStack(spacing: 10) {
                // Statistiche rapide
                HStack(spacing: 15) {
                    QuickStatCard(
                        title: "Totale Fratelli",
                        value: "25",
                        icon: "person.3.fill",
                        color: AppTheme.masonicBlue
                    )
                    
                    QuickStatCard(
                        title: "Amministratori",
                        value: "3",
                        icon: "star.fill",
                        color: AppTheme.masonicGold
                    )
                }
                
                // Placeholder per lista utenti
                InfoMessageCard(
                    message: "La gestione completa degli utenti sarà disponibile nella versione finale con integrazione backend."
                )
            }
        }
        .sheet(isPresented: $showingAddUser) {
            AddUserView()
                .environmentObject(authService)
        }
    }
}

struct AddUserView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authService: AuthenticationService
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var degree: MasonicDegree = .apprendista
    @State private var role: InstitutionalRole = .none
    @State private var showError = false
    @State private var showSuccess = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Dati Personali") {
                    TextField("Nome", text: $firstName)
                    TextField("Cognome", text: $lastName)
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        #endif
                }
                
                Section("Credenziali") {
                    SecureField("Password", text: $password)
                        .textContentType(.newPassword)
                    
                    if !password.isEmpty && password.count < AppConstants.Validation.minPasswordLength {
                        Text("La password deve contenere almeno \(AppConstants.Validation.minPasswordLength) caratteri")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                Section("Grado Massonico") {
                    Picker("Grado", selection: $degree) {
                        ForEach(MasonicDegree.allCases, id: \.self) { degree in
                            Text(degree.rawValue).tag(degree)
                        }
                    }
                }
                
                Section("Ruolo Istituzionale") {
                    Picker("Ruolo", selection: $role) {
                        ForEach(InstitutionalRole.allCases, id: \.self) { role in
                            Text(role.rawValue).tag(role)
                        }
                    }
                }
                
                Section {
                    Button(action: createUser) {
                        if authService.isLoading {
                            HStack {
                                ProgressView()
                                Text("Creazione in corso...")
                            }
                        } else {
                            Text("Crea Fratello")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(AppTheme.masonicBlue)
                        }
                    }
                    .disabled(!isFormValid || authService.isLoading)
                }
            }
            .navigationTitle("Nuovo Fratello")
            #if os(iOS)
            .navigationBarItems(
                leading: Button("Annulla") { dismiss() }
            )
            #else
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
            }
            #endif
            .alert("Errore", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .alert("Successo", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Fratello \(firstName) \(lastName) creato con successo")
            }
        }
    }
    
    private var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        password.count >= AppConstants.Validation.minPasswordLength
    }
    
    private func createUser() {
        Task {
            do {
                try await authService.createUser(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    password: password,
                    degree: degree,
                    role: role
                )
                showSuccess = true
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

struct TornateManagementView: View {
    @State private var showingAddTornata = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Gestione Tornate")
                    .font(.headline)
                    .foregroundColor(AppTheme.masonicBlue)
                
                Spacer()
                
                Button(action: { showingAddTornata = true }) {
                    Label("Nuova Tornata", systemImage: "plus.circle.fill")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.masonicGold)
                }
            }
            
            InfoMessageCard(
                message: "Crea e gestisci le tornate della Loggia. La funzionalità completa sarà disponibile con integrazione backend."
            )
        }
        .sheet(isPresented: $showingAddTornata) {
            AddTornataView()
        }
    }
}

struct AddTornataView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var dataService = DataService()

    @State private var title = ""
    @State private var date = Date()
    @State private var type: TornataType = .ordinaria
    @State private var location: TornataLocation = .tofa
    @State private var introducedBy = ""
    @State private var hasDinner = false
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Informazioni Base") {
                    TextField("Titolo", text: $title)
                    DatePicker("Data e Ora", selection: $date)
                    
                    Picker("Tipo", selection: $type) {
                        ForEach(TornataType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    Picker("Luogo", selection: $location) {
                        Text(TornataLocation.tofa.rawValue).tag(TornataLocation.tofa)
                        Text(TornataLocation.visita.rawValue).tag(TornataLocation.visita)
                    }
                }
                
                Section("Dettagli") {
                    TextField("Introduce", text: $introducedBy)
                    Toggle("Cena Prevista", isOn: $hasDinner)
                }
                
                Section("Note") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Nuova Tornata")
            #if os(iOS)
            .navigationBarItems(
                leading: Button("Annulla") { dismiss() },
                trailing: Button("Salva") {
                    saveTornata()
                }
                .disabled(title.isEmpty || introducedBy.isEmpty)
            )
            #else
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        saveTornata()
                    }
                    .disabled(title.isEmpty || introducedBy.isEmpty)
                }
            }
            #endif
        }
    }
    
    private func saveTornata() {
        let tornata = Tornata(
            title: title,
            date: date,
            type: type,
            location: location,
            introducedBy: introducedBy,
            hasDinner: hasDinner,
            notes: notes.isEmpty ? nil : notes
        )
        
        Task {
            await dataService.createTornata(tornata)
            dismiss()
        }
    }
}

struct StatisticsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Statistiche Loggia")
                .font(.headline)
                .foregroundColor(AppTheme.masonicBlue)
            
            VStack(spacing: 12) {
                StatisticRow(
                    label: "Media presenze 2025",
                    value: "85%",
                    icon: "chart.line.uptrend.xyaxis"
                )
                
                StatisticRow(
                    label: "Tornate totali 2025",
                    value: "24",
                    icon: "calendar"
                )
                
                StatisticRow(
                    label: "Cerimonie effettuate",
                    value: "8",
                    icon: "star.fill"
                )
                
                StatisticRow(
                    label: "Tavole presentate",
                    value: "42",
                    icon: "doc.text.fill"
                )
            }
            .padding()
            .cardStyle()
        }
    }
}

struct ReportsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Generazione Report")
                .font(.headline)
                .foregroundColor(AppTheme.masonicBlue)
            
            VStack(spacing: 12) {
                ReportButton(
                    title: "Report Presenze Annuale",
                    icon: "doc.text",
                    description: "Esporta report dettagliato delle presenze"
                )
                
                ReportButton(
                    title: "Report Tornate",
                    icon: "calendar",
                    description: "Elenco completo delle tornate effettuate"
                )
                
                ReportButton(
                    title: "Report Tavole",
                    icon: "doc.richtext",
                    description: "Catalogo delle tavole architettoniche"
                )
            }
            
            InfoMessageCard(
                message: "La generazione automatica dei report in formato PDF e CSV sarà disponibile nella versione finale."
            )
        }
    }
}

struct QuickStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .cardStyle()
    }
}

struct InfoMessageCard: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "info.circle.fill")
                .font(.title2)
                .foregroundColor(AppTheme.masonicBlue)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.masonicBlue.opacity(0.05))
        .cornerRadius(10)
    }
}

struct ReportButton: View {
    let title: String
    let icon: String
    let description: String
    
    var body: some View {
        Button(action: {
            // TODO: Implementare generazione report
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(AppTheme.masonicGold)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "arrow.down.doc")
                    .foregroundColor(AppTheme.masonicBlue)
            }
            .padding()
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AdministrationView()
}
