//
//  LoginView.swift
//  college-ios-app
//
//  Created by pc on 17.10.2025.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel
    @StateObject private var viewModel: LoginViewModel
    @Environment(\.dismiss) private var dismiss
    
    @FocusState private var focusedField: Field?
    @State private var showPassword = false
    
    enum Field { case username, password }
    
    init() {
        _viewModel = StateObject(wrappedValue: LoginViewModel(authService: nil))
    }
    
    init(authService: AuthService) {
        _viewModel = StateObject(wrappedValue: LoginViewModel(authService: authService))
    }
    
    private var isPasswordTooShort: Bool {
        viewModel.password.count < 6
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // MARK: Brand
                HStack(spacing: 8) {
                    Image("LaunchIcon")
                        .resizable()
                        .renderingMode(.original)
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    Text("МойКЦТ")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .padding(.top, 24)
                
                // MARK: Title & Subtitle
                Text("Войдите в ваш\nаккаунт")
                    .font(.system(size: 34, weight: .bold))
                    .lineSpacing(2)
                
                Text("Введите ваш корпоративный логин и пароль")
                    .font(.callout)
                    .foregroundColor(.secondary)
                
                // MARK: Login
                VStack(alignment: .leading, spacing: 8) {
                    Text("Логин")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    RoundedField(isFocused: focusedField == .username) {
                        TextField("i24s0291", text: $viewModel.login)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .keyboardType(.asciiCapable)
                            .focused($focusedField, equals: .username)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .password }
                    }
                }
                
                // MARK: Password
                VStack(alignment: .leading, spacing: 8) {
                    Text("Пароль")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    RoundedField(isFocused: focusedField == .password) {
                        HStack {
                            Group {
                                if showPassword {
                                    TextField("Пароль", text: $viewModel.password)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled(true)
                                } else {
                                    SecureField("Пароль", text: $viewModel.password)
                                }
                            }
                            .focused($focusedField, equals: .password)
                            .submitLabel(.go)
                            .onSubmit {
                                guard !isPasswordTooShort else { return }
                                Task {
                                    await viewModel.signIn()
                                    if viewModel.isLoggedIn {
                                        await sessionViewModel.syncFromSession()
                                        dismiss()
                                    }
                                }
                            }
                            
                            Button {
                                showPassword.toggle()
                            } label: {
                                Image(systemName: "eye.slash")
                                    .symbolVariant(showPassword ? .fill : .none)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 4)
                            }
                            .accessibilityLabel(showPassword ? "Скрыть пароль" : "Показать пароль")
                        }
                    }
                }
                
                // MARK: Action
                Button {
                    Task {
                        await viewModel.signIn()
                        if viewModel.isLoggedIn {
                            await sessionViewModel.syncFromSession()
                            dismiss()
                        }
                    }
                } label: {
                    HStack {
                        Spacer()
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        } else {
                            Text("Войти")
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.accentColor)
                    )
                    .foregroundColor(.white)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isLoading || viewModel.login.isEmpty || viewModel.password.isEmpty || isPasswordTooShort)
                .opacity(viewModel.isLoading || viewModel.login.isEmpty || viewModel.password.isEmpty || isPasswordTooShort ? 0.6 : 1)
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .padding(.top, 4)
                }
                
                Spacer(minLength: 24)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .onAppear {
            viewModel.setAuthService(sessionViewModel.authService)
        }
    }
}

// MARK: - Rounded input container
private struct RoundedField<Content: View>: View {
    let isFocused: Bool
    @ViewBuilder let content: Content
    
    init(isFocused: Bool = false, @ViewBuilder content: () -> Content) {
        self.isFocused = isFocused
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isFocused ? Color.accentColor : Color.clear, lineWidth: 2)
            )
            .animation(.easeInOut(duration: 0.15), value: isFocused)
    }
}

#Preview {
    let refreshStorage = KeychainTokenStorage()
    let authSession = AuthSession(refreshStorage: refreshStorage)
    
    let decoder = JSONDecoder()
    
    let client = AFHTTPClient(baseURL: URL(string: "https://auth.example.com")!, decoder: decoder)
    let api = AuthAPI(client: client)
    let authService = AuthService(api: api, session: authSession)
    
    let sessionViewModel = SessionViewModel(authService: authService, authSession: authSession)
    
    return LoginView()
        .environmentObject(sessionViewModel)
}
