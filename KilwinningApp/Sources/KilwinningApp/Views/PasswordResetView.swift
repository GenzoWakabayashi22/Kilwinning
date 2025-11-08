import SwiftUI

struct PasswordResetView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var authService = AuthenticationService.shared
    
    @State private var email = ""
    @State private var showSuccess = false
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Intestazione
                    VStack(spacing: 10) {
                        Image(systemName: "key.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.masonicBlue)
                        
                        Text("Recupero Password")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.masonicBlue)
                        
                        Text("Inserisci la tua email per ricevere le istruzioni")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 50)
                    
                    // Campo email
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.caption)
                            .foregroundColor(AppTheme.masonicBlue)
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            #if os(iOS)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            #endif
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    .padding(.horizontal, 30)
                    
                    // Pulsante Invia
                    Button(action: resetPassword) {
                        if authService.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Invia")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.masonicBlue)
                    .foregroundColor(AppTheme.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                    .disabled(authService.isLoading || email.isEmpty)
                    
                    Spacer()
                }
            }
            #if os(iOS)
            .navigationBarItems(trailing: Button("Annulla") {
                dismiss()
            })
            #else
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
            }
            #endif
            .alert("Successo", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Controlla la tua email per le istruzioni di recupero password")
            }
            .alert("Errore", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(authService.errorMessage ?? "Errore sconosciuto")
            }
        }
    }
    
    private func resetPassword() {
        Task {
            do {
                try await authService.resetPassword(email: email)
                showSuccess = true
            } catch {
                authService.errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

#Preview {
    PasswordResetView()
}
