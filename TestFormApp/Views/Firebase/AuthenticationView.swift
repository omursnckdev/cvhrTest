//
//  AuthenticationView.swift
//  TestFormApp
//
//  Authentication view for Firebase login/signup
//

import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var isSignUp = false
    @State private var showError = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if isSignUp {
                        TextField("İsim Soyisim", text: $displayName)
                            .textContentType(.name)
                            .autocapitalization(.words)
                    }

                    TextField("E-posta", text: $email)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)

                    SecureField("Şifre", text: $password)
                        .textContentType(isSignUp ? .newPassword : .password)
                } header: {
                    Text(isSignUp ? "Yeni Hesap Oluştur" : "Giriş Yap")
                }

                Section {
                    Button {
                        Task {
                            await authenticate()
                        }
                    } label: {
                        if firebaseManager.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text(isSignUp ? "Kayıt Ol" : "Giriş Yap")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(!isFormValid || firebaseManager.isLoading)

                    Button {
                        isSignUp.toggle()
                        email = ""
                        password = ""
                        displayName = ""
                    } label: {
                        Text(isSignUp ? "Zaten hesabım var" : "Yeni hesap oluştur")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(firebaseManager.isLoading)
                }

                Section {
                    Button {
                        Task {
                            await signInAnonymously()
                        }
                    } label: {
                        Text("Anonim Giriş (Demo)")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(firebaseManager.isLoading)
                } footer: {
                    Text("Anonim giriş demo amaçlıdır. Kalıcı veri saklama için e-posta ile kayıt olun.")
                        .font(.caption)
                }
            }
            .navigationTitle("Kimlik Doğrulama")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !firebaseManager.isAuthenticated {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("İptal") {
                            dismiss()
                        }
                    }
                }
            }
            .alert("Hata", isPresented: $showError) {
                Button("Tamam", role: .cancel) { }
            } message: {
                if let error = firebaseManager.errorMessage {
                    Text(error)
                }
            }
            .onChange(of: firebaseManager.isAuthenticated) { _, isAuth in
                if isAuth {
                    dismiss()
                }
            }
            .onChange(of: firebaseManager.errorMessage) { _, error in
                showError = error != nil
            }
        }
    }

    private var isFormValid: Bool {
        if isSignUp {
            return !email.isEmpty && !password.isEmpty && password.count >= 6 && !displayName.isEmpty
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }

    private func authenticate() async {
        do {
            if isSignUp {
                try await firebaseManager.signUp(email: email, password: password, displayName: displayName)
            } else {
                try await firebaseManager.signIn(email: email, password: password)
            }
        } catch {
            // Error already handled in FirebaseManager
        }
    }

    private func signInAnonymously() async {
        do {
            try await firebaseManager.signInAnonymously()
        } catch {
            // Error already handled in FirebaseManager
        }
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(FirebaseManager.shared)
}
