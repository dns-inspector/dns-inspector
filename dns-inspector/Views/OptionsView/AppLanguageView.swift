import SwiftUI

struct AppLanguageView: View {
    @State private var currentLanguage = UserOptions.appLanguage ?? .English
    @State private var showRestartAlert = false

    var body: some View {
        List {
            Section {
                ForEach(SupportedLanguages.allCases, id:\.rawValue) { language in
                    Button {
                        currentLanguage = language
                    } label: {
                        HStack {
                            Text(language.name)
                            Spacer()
                            if currentLanguage == language {
                                Image(systemName: "checkmark").foregroundStyle(.accent)
                            }
                        }
                    }.buttonStyle(.plain)
                }
            } footer: {
                Text(localized: "localization_credits")
            }
        }
        .navigationTitle(localized: "App language")
        .onChange(of: currentLanguage) { newLanguage in
            if newLanguage != UserOptions.appLanguage {
                UserOptions.appLanguage = newLanguage
                showRestartAlert = true
            }
        }
        .alert(Localize("App language"), isPresented: $showRestartAlert) {
            Button {
                showRestartAlert = false
            } label: {
                Text(localized: "Dismiss")
            }
        } message: {
            Text(localized: "Your changes will take affect only quitting and restarting DNS Inspector")
        }

    }
}

#Preview {
    AppLanguageView()
}
