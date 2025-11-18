//
//  SignupView.swift
//  TestFormApp
//
//  User signup view with role selection
//

import SwiftUI

struct SignupView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userManager: UserManager

    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var fullName = ""
    @State private var selectedRole: UserRole = .muteahhit

    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Kullanıcı Bilgileri") {
                    TextField("Kullanıcı Adı", text: $username)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()

                    TextField("Ad Soyad", text: $fullName)

                    SecureField("Şifre", text: $password)

                    SecureField("Şifre Tekrar", text: $confirmPassword)
                }

                Section("Rol Seçimi") {
                    Picker("Rol", selection: $selectedRole) {
                        ForEach(UserRole.allCases, id: \.self) { role in
                            Text(role.description).tag(role)
                        }
                    }
                    .pickerStyle(.segmented)

                    // Role description
                    VStack(alignment: .leading, spacing: 8) {
                        switch selectedRole {
                        case .muteahhit:
                            Label("Test formlarını doldurur ve kaydeder", systemImage: "doc.text.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        case .musavir:
                            Label("Müteahhit tarafından doldurulan formları inceler ve onaylar", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        case .isveren:
                            Label("Müşavir tarafından onaylanan formları inceler ve son onayı verir", systemImage: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section {
                    Button("Kayıt Ol") {
                        signUp()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("Kayıt Ol")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
            .alert("Hata", isPresented: $showError) {
                Button("Tamam", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private var isFormValid: Bool {
        !username.isEmpty &&
        !password.isEmpty &&
        !fullName.isEmpty &&
        password == confirmPassword &&
        password.count >= 4
    }

    private func signUp() {
        do {
            try userManager.signUp(
                username: username,
                password: password,
                fullName: fullName,
                role: selectedRole
            )
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    SignupView()
        .environmentObject(UserManager(modelContext: ModelContext(try! ModelContainer(for: User.self))))
}
