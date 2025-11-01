struct VoltageSelector: View {
    @Binding var voltageSupply: String
    
    var body: some View {
        VStack(spacing: 6) {
            Text("Voltage Supply")
                .font(.openSansBold(size: 18))
            
            HStack(spacing: 20) {
                VoltageItem(label: "LOW", value: "<113V", isOn: voltageSupply == "LOW") { voltageSupply = "LOW" }
                VoltageItem(label: "AVERAGE", value: "113-118V", isOn: voltageSupply == "AVERAGE") { voltageSupply = "AVERAGE" }
                VoltageItem(label: "HIGH", value: ">118V", isOn: voltageSupply == "HIGH") { voltageSupply = "HIGH" }
            }
        }
    }
}
