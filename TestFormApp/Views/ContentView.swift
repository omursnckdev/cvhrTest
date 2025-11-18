//
//  ContentView.swift
//  TestFormApp
//
//  Main entry view with navigation and authentication
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var templateManager: FormTemplateManager
    @EnvironmentObject var dataManager: FilledFormDataManager
    @EnvironmentObject var userManager: UserManager

    var body: some View {
        Group {
            if userManager.isAuthenticated, let user = userManager.currentUser {
                RoleBasedMainView(user: user)
            } else {
                LoginView()
            }
        }
    }
}

struct RoleBasedMainView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var dataManager: FilledFormDataManager
    @EnvironmentObject var templateManager: FormTemplateManager

    let user: User

    var body: some View {
        TabView {
            // Tab 1: Main content based on role
            NavigationStack {
                mainContentView
                    .navigationTitle(mainTitle)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Menu {
                                Text(user.fullName)
                                Text(user.role.description)
                                    .font(.caption)

                                Divider()

                                Button(role: .destructive) {
                                    userManager.logout()
                                } label: {
                                    Label("Çıkış Yap", systemImage: "rectangle.portrait.and.arrow.right")
                                }
                            } label: {
                                Image(systemName: "person.circle.fill")
                            }
                        }
                    }
            }
            .tabItem {
                Label(mainTabLabel, systemImage: mainTabIcon)
            }

            // Tab 2: Approved documents (visible to all)
            NavigationStack {
                ApprovedDocumentsView()
            }
            .tabItem {
                Label("Onaylı Formlar", systemImage: "checkmark.seal.fill")
            }
        }
    }

    @ViewBuilder
    private var mainContentView: some View {
        switch user.role {
        case .muteahhit:
            // Müteahhit sees category list to create new forms
            CategoryListView()
        case .musavir:
            // Müşavir sees forms pending their approval
            ApprovalListView(role: .musavir)
        case .isveren:
            // İşVeren sees forms pending their approval
            ApprovalListView(role: .isveren)
        }
    }

    private var mainTitle: String {
        switch user.role {
        case .muteahhit:
            return "Formlar"
        case .musavir:
            return "Onay Bekleyenler"
        case .isveren:
            return "Onay Bekleyenler"
        }
    }

    private var mainTabLabel: String {
        switch user.role {
        case .muteahhit:
            return "Formlar"
        case .musavir, .isveren:
            return "Bekleyen Onaylar"
        }
    }

    private var mainTabIcon: String {
        switch user.role {
        case .muteahhit:
            return "doc.text"
        case .musavir:
            return "checkmark.circle"
        case .isveren:
            return "checkmark.seal"
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(FormTemplateManager())
        .environmentObject(FilledFormDataManager())
        .environmentObject(UserManager(modelContext: ModelContext(try! ModelContainer(for: User.self))))
}
