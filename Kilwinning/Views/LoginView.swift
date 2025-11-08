import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var username = ""
    @State private var password = ""
    @State private var showError = false
    @State private var hasAttemptedLogin = false

    // MARK: - Computed Properties per Validazione

    /// Verifica se l'username è valido (almeno 3 caratteri)
    private var isValidUsername: Bool {
        username.count >= AppConstants.Validation.minUsernameLength
    }

    /// Verifica se la password rispetta i requisiti minimi
    private var isValidPassword: Bool {
        password.count >= AppConstants.Validation.minPasswordLength
    }

    /// Verifica se il form è valido per l'invio
    private var isFormValid: Bool {
        isValidUsername && isValidPassword
    }
    
    var body: some View {
        ZStack {
            // Sfondo con gradiente elegante blu scuro
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.25, blue: 0.45),
                    Color(red: 0.25, green: 0.35, blue: 0.55)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Logo e titolo superiore
                VStack(spacing: 12) {
                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppTheme.white)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    Text("Spettabile Loggia")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(AppTheme.white)
                    
                    Text("Kilwinning")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppTheme.masonicGold)
                }
                .padding(.bottom, 40)
                
                // Card centrale bianca con form
                VStack(spacing: 25) {
                    // Titolo form
                    VStack(spacing: 8) {
                        Text("Accesso Riservato")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Inserisci le tue credenziali")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 10)
                    
                    VStack(spacing: 18) {
                        // Campo Username
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 12) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppTheme.masonicBlue)
                                    .frame(width: 24)
                                
                                TextField("Username", text: $username)
                                    .textContentType(.username)
                                    #if os(iOS)
                                    .autocapitalization(.none)
                                    .textInputAutocapitalization(.never)
                                    #endif
                                    .font(.system(size: 16))
                            }
                            .padding()
                            .background(Color.systemGray6)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(hasAttemptedLogin && !isValidUsername && !username.isEmpty ? Color.red : Color.clear, lineWidth: 2)
                            )
                            
                            if hasAttemptedLogin && !isValidUsername && !username.isEmpty {
                                Text("Username deve contenere almeno \(AppConstants.Validation.minUsernameLength) caratteri")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.leading, 8)
                            }
                        }
                        
                        // Campo Password
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppTheme.masonicBlue)
                                    .frame(width: 24)
                                
                                SecureField("Password", text: $password)
                                    .textContentType(.password)
                                    .font(.system(size: 16))
                            }
                            .padding()
                            .background(Color.systemGray6)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(hasAttemptedLogin && !isValidPassword && !password.isEmpty ? Color.red : Color.clear, lineWidth: 2)
                            )
                            
                            if hasAttemptedLogin && !isValidPassword && !password.isEmpty {
                                Text("Password deve contenere almeno \(AppConstants.Validation.minPasswordLength) caratteri")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.leading, 8)
                            }
                        }
                    }
                    
                    // Pulsante Accedi
                    Button(action: {
                        hasAttemptedLogin = true
                        guard isFormValid else { return }

                        Task {
                            do {
                                try await authService.login(email: username, password: password)
                            } catch {
                                authService.errorMessage = error.localizedDescription
                                showError = true
                            }
                        }
                    }) {
                        HStack(spacing: 10) {
                            if authService.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 20))
                                Text("Accedi")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: isFormValid ? 
                                    [AppTheme.masonicBlue, AppTheme.masonicLightBlue] : 
                                    [AppTheme.masonicBlue.opacity(0.5), AppTheme.masonicLightBlue.opacity(0.5)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: isFormValid ? AppTheme.masonicBlue.opacity(0.4) : .clear, radius: 8, x: 0, y: 4)
                    }
                    .disabled(authService.isLoading || !isFormValid)
                }
                .padding(30)
                .background(Color.systemBackground)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Footer con info versione
                Text("Sistema Gestione Tornate v1.0")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.white.opacity(0.7))
                    .padding(.bottom, 30)
            }
        }
        .alert("Errore", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(authService.errorMessage ?? "Errore sconosciuto")
        }
    }
}

#Preview {
    LoginView()
}
