import SwiftUI

struct LoginView: View {
    @StateObject private var authService = AuthenticationService.shared
    @State private var email = ""
    @State private var password = ""
    @State private var showingRegistration = false
    @State private var showingPasswordReset = false
    @State private var showError = false
    
    var body: some View {
        ZStack {
            // Sfondo con gradiente
            AppTheme.primaryGradient
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Logo e titolo
                VStack(spacing: 15) {
                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 70))
                        .foregroundColor(AppTheme.white)
                    
                    Text("Spettabile Loggia")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.white)
                    
                    Text("Kilwinning")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(AppTheme.masonicGold)
                    
                    Text("Sistema Gestione Tornate")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.white.opacity(0.9))
                }
                
                Spacer()
                
                // Form di login
                VStack(spacing: 20) {
                    VStack(spacing: 15) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(AppTheme.masonicBlue)
                                .frame(width: 25)
                            TextField("Email o nome utente", text: $email)
                                .textContentType(.emailAddress)
                                // iOS-only modifiers: autocapitalization and keyboardType not available on macOS
                                #if os(iOS)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                #endif
                        }
                        .padding()
                        .background(AppTheme.white)
                        .cornerRadius(10)
                        
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(AppTheme.masonicBlue)
                                .frame(width: 25)
                            SecureField("Password", text: $password)
                                .textContentType(.password)
                        }
                        .padding()
                        .background(AppTheme.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 30)
                    
                    // Pulsante Accedi
                    Button(action: {
                        Task {
                            do {
                                try await authService.login(email: email, password: password)
                            } catch {
                                authService.errorMessage = error.localizedDescription
                                showError = true
                            }
                        }
                    }) {
                        if authService.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Accedi")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.masonicGold)
                    .foregroundColor(AppTheme.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                    .disabled(authService.isLoading)
                    
                    // Link password dimenticata
                    Button("Password dimenticata?") {
                        showingPasswordReset = true
                    }
                    .foregroundColor(AppTheme.white)
                    .font(.footnote)
                }
                
                Spacer()
                
                // Link registrazione
                HStack {
                    Text("Non hai un account?")
                        .foregroundColor(AppTheme.white)
                    Button("Registrati") {
                        showingRegistration = true
                    }
                    .foregroundColor(AppTheme.masonicGold)
                    .fontWeight(.semibold)
                }
                .font(.footnote)
                .padding(.bottom, 30)
            }
        }
        .alert("Errore", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(authService.errorMessage ?? "Errore sconosciuto")
        }
        .sheet(isPresented: $showingRegistration) {
            RegistrationView()
        }
        .sheet(isPresented: $showingPasswordReset) {
            PasswordResetView()
        }
    }
}

#Preview {
    LoginView()
}
