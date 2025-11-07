import SwiftUI

struct RegistrationView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var authService = AuthenticationService.shared
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Intestazione
                        VStack(spacing: 10) {
                            Image(systemName: "person.badge.plus.fill")
                                .font(.system(size: 60))
                                .foregroundColor(AppTheme.masonicBlue)
                            
                            Text("Registrazione")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.masonicBlue)
                        }
                        .padding(.top, 30)
                        
                        // Form
                        VStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Nome")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.masonicBlue)
                                TextField("Nome", text: $firstName)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Cognome")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.masonicBlue)
                                TextField("Cognome", text: $lastName)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.masonicBlue)
                                TextField("Email", text: $email)
                                    .textContentType(.emailAddress)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.masonicBlue)
                                SecureField("Password", text: $password)
                                    .textContentType(.newPassword)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Conferma Password")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.masonicBlue)
                                SecureField("Conferma Password", text: $confirmPassword)
                                    .textContentType(.newPassword)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                        }
                        .padding(.horizontal, 30)
                        
                        // Pulsante Registra
                        Button(action: register) {
                            if authService.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Registrati")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.masonicBlue)
                        .foregroundColor(AppTheme.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 30)
                        .disabled(authService.isLoading || !isFormValid)
                        
                        Spacer()
                    }
                }
            }
            .navigationBarItems(trailing: Button("Annulla") {
                dismiss()
            })
            .alert("Errore", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword
    }
    
    private func register() {
        guard password == confirmPassword else {
            errorMessage = "Le password non coincidono"
            showError = true
            return
        }
        
        Task {
            do {
                try await authService.register(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    password: password
                )
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(AppTheme.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppTheme.masonicLightBlue.opacity(0.3), lineWidth: 1)
            )
    }
}

#Preview {
    RegistrationView()
}
