struct LanguageSelector: View {
    @Binding var languageIsEnglish: Bool
    
    var body: some View {
        VStack {
            Text("Language")
                .font(.openSansBold(size: 18))
            
            HStack(spacing: 40) {
                LanguageOption(label: "English", selected: languageIsEnglish) { languageIsEnglish = true }
                LanguageOption(label: "Español", selected: !languageIsEnglish) { languageIsEnglish = false }
            }
        }
    }
}
