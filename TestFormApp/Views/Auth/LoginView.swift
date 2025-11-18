//
//  LoginView.swift
//  TestFormApp
//
//  User login view
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userManager: UserManager

    @State private var username = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSignup = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // App logo/title
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)

                    Text("Test Form Uygulaması")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Giriş Yapın")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)

                // Login form
                VStack(spacing: 16) {
                    TextField("Kullanıcı Adı", text: $username)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()

                    SecureField("Şifre", text: $password)
                        .textFieldStyle(.roundedBorder)

                    Button {
                        login()
                    } label: {
                        Text("Giriş Yap")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid ? Color.accentColor : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!isFormValid)
                }
                .padding(.horizontal)

                // Signup link
                Button {
                    showSignup = true
                } label: {
                    HStack {
                        Text("Hesabınız yok mu?")
                            .foregroundColor(.secondary)
                        Text("Kayıt Olun")
                            .foregroundColor(.accentColor)
                            .fontWeight(.semibold)
                    }
                }
                .padding(.top, 8)

                Spacer()
            }
            .navigationBarHidden(true)
            .alert("Hata", isPresented: $showError) {
                Button("Tamam", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .sheet(isPresented: $showSignup) {
                SignupView()
            }
        }
    }

    private var isFormValid: Bool {
        !username.isEmpty && !password.isEmpty
    }

    private func login() {
        do {
            try userManager.login(username: username, password: password)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(UserManager(modelContext: ModelContext(try! ModelContainer(for: User.self))))
}
