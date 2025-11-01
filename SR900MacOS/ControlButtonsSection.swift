import SwiftUI

struct ControlButtonsSection: View {
    @ObservedObject var controlState: MainControlState
    
    var body: some View {
        VStack(spacing: 15) {
            TemperatureControlBar(controlState: controlState)
            SliderControlsSection(controlState: controlState)
        }
        .padding(.top, 10)
        .offset(y: 20)
    }
}

// MARK: - Temperature Control Bar
struct TemperatureControlBar: View {
    @ObservedObject var controlState: MainControlState
    
    var body: some View {
        HStack(spacing: 10) {
            HeatingCoolingButton(
                mode: "Heating",
                currentMode: $controlState.heatingCoolingMode
            )
            .offset(x: -2)
            
            BeanTemperatureDisplay(controlState: controlState)
            
            HeatingCoolingButton(
                mode: "Cooling",
                currentMode: $controlState.heatingCoolingMode
            )
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Heating/Cooling Button
struct HeatingCoolingButton: View {
    let mode: String
    @Binding var currentMode: String
    
    var body: some View {
        Button(action: {
            currentMode = mode
        }) {
            HStack {
                Image(systemName: currentMode == mode ? "circle.fill" : "circle")
                    .font(.openSans(size: 14))
                    .offset(x: -20)
                
                Text(mode)
                    .font(.openSansBold(size: 14))
            }
            .foregroundColor(.black)
            .frame(width: 170, height: 40)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.black, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Bean Temperature Display
struct BeanTemperatureDisplay: View {
    @ObservedObject var controlState: MainControlState
    
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: "thermometer")
                .font(.openSans(size: 24))
                .offset(x: -68, y: 29)
            
            Text("\(controlState.beanTempValue)\(controlState.temperatureUnit)")
                .font(.openSansBold(size: 20))
                .offset(x: -22, y: -1)
            
            VStack(spacing: 2) {
                Text("Bean")
                    .font(.openSansBold(size: 10))
                    .offset(x: -3, y: -2)
                
                Text("Temperature")
                    .font(.openSansBold(size: 10))
                    .offset(x: -3, y: -2)
            }
            .offset(x: 46, y: -30)
        }
        .foregroundColor(.black)
        .frame(width: 170, height: 40)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 0)
                .stroke(Color.black, lineWidth: 2)
        )
    }
}

// MARK: - Slider Controls Section
struct SliderControlsSection: View {
    @ObservedObject var controlState: MainControlState
    
    var body: some View {
        VStack(spacing: 10) {
            DraggableSlider(
                value: $controlState.fanMotorLevel,
                range: 0...9,
                step: 1,
                label: "Fan Motor Level",
                icon: "fan",
                trackColor: .blue,
                thumbColor: .white,
                textColor: .black
            )
            
            DraggableSlider(
                value: $controlState.heatLevel,
                range: 0...9,
                step: 1,
                label: "Heat Level",
                icon: "flame",
                trackColor: .red,
                thumbColor: .white,
                textColor: .black
            )
            
            DraggableSlider(
                value: $controlState.roastingTime,
                range: 0...15,
                step: 1,
                label: "Roasting Time",
                icon: "clock",
                trackColor: .red,
                thumbColor: .white,
                textColor: .black
            )
            
            DraggableSlider(
                value: $controlState.coolingTime,
                range: 0...4,
                step: 1,
                label: "Cooling Time",
                icon: "clock",
                trackColor: .blue,
                thumbColor: .white,
                textColor: .black
            )
        }
        .padding(.horizontal, 20)
    }
}