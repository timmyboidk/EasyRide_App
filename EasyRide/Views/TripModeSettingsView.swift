import SwiftUI

#if os(iOS)
struct TripModeSettingsView: View {
    @State private var viewModel = TripConfigurationViewModel()
    @State private var showingDatePicker = false
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Mode Selection
                    modeSelectionSection
                    
                    // Trip Details based on selected mode
                    if viewModel.selectedMode == .freeRoute {
                        freeTripSection
                    } else {
                        customRouteSection
                    }
                    
                    // Next Button
                    nextButton
                }
                .padding()
            }
        }
        .navigationTitle("出行模式设置")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingDatePicker) {
            DatePicker(
                "出发时间",
                selection: $viewModel.scheduledTime,
                in: Date()...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.wheel)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Mode Selection Section
    private var modeSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("出行模式")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            HStack(spacing: 16) {
                ForEach(TripMode.allCases) { mode in
                    ModeSelectionButton(
                        mode: mode,
                        isSelected: viewModel.selectedMode == mode
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectedMode = mode
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Free Trip Section
    private var freeTripSection: some View {
        VStack(spacing: 20) {
            // Departure Location
            InputField(
                title: "出发地点",
                text: $viewModel.pickupAddress,
                placeholder: "请输入出发地点"
            )
            
            // Departure Time
            Button(action: { showingDatePicker = true }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("出发时间")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text(viewModel.scheduledTime.formatted(date: .abbreviated, time: .shortened))
                            .font(.body)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            
            // Passenger and Luggage
            HStack(spacing: 16) {
                CounterField(
                    title: "乘客人数",
                    value: $viewModel.passengerCount,
                    range: 1...8
                )
                
                CounterField(
                    title: "行李件数",
                    value: .constant(0), // Placeholder
                    range: 0...10
                )
            }
            
            // Trip Notes
            InputField(
                title: "行程备注",
                text: $viewModel.notes,
                placeholder: "例如：市区游览+晚上机场接送",
                isMultiline: true
            )
            
            // Special Instructions
            InputField(
                title: "特殊要求",
                text: .constant(""), // Placeholder
                placeholder: "可包含语言要求、陪同、搬运等",
                isMultiline: true
            )
        }
    }
    
    // MARK: - Custom Route Section
    private var customRouteSection: some View {
        VStack(spacing: 20) {
            // Departure Location
            InputField(
                title: "出发地点",
                text: $viewModel.pickupAddress,
                placeholder: "请输入出发地点"
            )
            
            // Custom Stops
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("自定义路线")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Button(action: viewModel.addNewStop) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                            Text("添加停靠点")
                        }
                        .font(.caption)
                        .foregroundColor(.white)
                    }
                }
                
                ForEach(viewModel.customStops.indices, id: \.self) { index in
                    CustomStopRow(
                        stop: $viewModel.customStops[index],
                        onDelete: { viewModel.removeStop(at: index) }
                    )
                }
            }
            
            // Trip Preview Map Placeholder
            VStack {
                Text("行程预览地图")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .overlay(
                        VStack {
                            Image(systemName: "map.fill")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("地图预览")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
            }
        }
    }
    
    // MARK: - Next Button
    private var nextButton: some View {
        Button(action: proceedToNext) {
            Text("下一步")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isValidConfiguration ? Color.white : Color.gray.opacity(0.3))
                .foregroundColor(viewModel.isValidConfiguration ? .black : .gray)
                .cornerRadius(10)
        }
        .disabled(!viewModel.isValidConfiguration)
    }
    
    // MARK: - Helper Methods
    private func proceedToNext() {
        navigationPath.append(BookingStep.valueAddedServicesPayment)
    }
}

// MARK: - Mode Selection Button
struct ModeSelectionButton: View {
    let mode: TripMode
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .white : .gray)
                
                Image(systemName: mode.icon)
                    .font(.caption)
                    .foregroundColor(.white)
                
                Text(mode.displayName)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.white.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isSelected ? Color.white : Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Input Field
struct InputField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var isMultiline: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            if isMultiline {
                TextField(placeholder, text: $text, axis: .vertical)
                    .lineLimit(3...6)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .foregroundColor(.white)
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Counter Field
struct CounterField: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                Button(action: { if value > range.lowerBound { value -= 1 } }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(value > range.lowerBound ? .white : .gray)
                }
                .disabled(value <= range.lowerBound)
                
                Spacer()
                
                Text("\(value)")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: { if value < range.upperBound { value += 1 } }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(value < range.upperBound ? .white : .gray)
                }
                .disabled(value >= range.upperBound)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Custom Stop Row
struct CustomStopRow: View {
    @Binding var stop: TripStop
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                TextField("停靠地点", text: $stop.location.address)
                    .textFieldStyle(.plain)
                    .foregroundColor(.white)
                
                Button(action: onDelete) {
                    Image(systemName: "trash.circle.fill")
                        .foregroundColor(.red)
                }
            }
            
            HStack {
                Text("停留时长")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("\(Int(stop.duration))分钟")
                    .font(.caption)
                    .foregroundColor(.white)
                
                Stepper("", value: $stop.duration, in: 15...180, step: 15)
                    .labelsHidden()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationView {
        TripModeSettingsView(navigationPath: .constant(NavigationPath()))
    }
}
#endif
