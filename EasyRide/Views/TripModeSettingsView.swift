import SwiftUI

#if os(iOS)
struct TripModeSettingsView: View {
    @State private var viewModel = TripConfigurationViewModel()
    @State private var showingDatePicker = false
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
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
        .navigationTitle(LocalizationUtils.localized("Trip_Mode_Settings"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingDatePicker) {
            DatePicker(
                LocalizationUtils.localized("Departure_Time"),
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
            Text(LocalizationUtils.localized("Trip_Mode"))
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
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
                title: LocalizationUtils.localized("Departure_Address"),
                text: $viewModel.pickupAddress,
                placeholder: LocalizationUtils.localized("Enter_Departure_Address")
            )
            
            // Departure Time
            Button(action: { showingDatePicker = true }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(LocalizationUtils.localized("Departure_Time"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(viewModel.scheduledTime.formatted(date: .abbreviated, time: .shortened))
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "calendar")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
            }
            
            // Passenger and Luggage
            VStack(spacing: 16) {
                CounterField(
                    title: LocalizationUtils.localized("Passengers"),
                    value: $viewModel.passengerCount,
                    range: 1...8
                )
                
                HStack(spacing: 16) {
                    CounterField(
                        title: LocalizationUtils.localized("Large_Luggage"),
                        value: $viewModel.largeLuggageCount,
                        range: 0...5
                    )
                    
                    CounterField(
                        title: LocalizationUtils.localized("Small_Luggage"),
                        value: $viewModel.smallLuggageCount,
                        range: 0...5
                    )
                }
            }
            
            // Trip Notes
            InputField(
                title: LocalizationUtils.localized("Trip_Notes"),
                text: $viewModel.notes,
                placeholder: LocalizationUtils.localized("Trip_Notes_Placeholder"),
                isMultiline: true
            )
            
            // Special Instructions
            InputField(
                title: LocalizationUtils.localized("Special_Requests"),
                text: .constant(""), // Placeholder
                placeholder: LocalizationUtils.localized("Special_Requests_Placeholder"),
                isMultiline: true
            )
        }
    }
    
    // MARK: - Custom Route Section
    private var customRouteSection: some View {
        VStack(spacing: 20) {
            // Departure Location
            InputField(
                title: LocalizationUtils.localized("Departure_Address"),
                text: $viewModel.pickupAddress,
                placeholder: LocalizationUtils.localized("Enter_Departure_Address")
            )
            
            // Custom Stops
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(LocalizationUtils.localized("Custom_Route"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(action: viewModel.addNewStop) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                            Text(LocalizationUtils.localized("Add_Stop"))
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
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
                Text(LocalizationUtils.localized("Trip_Preview_Map"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.secondary.opacity(0.1))
                    .frame(height: 200)
                    .overlay(
                        VStack {
                            Image(systemName: "map.fill")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text(LocalizationUtils.localized("Map_Preview"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    )
            }
        }
    }
    
    // MARK: - Next Button
    private var nextButton: some View {
        Button(action: proceedToNext) {
            Text(LocalizationUtils.localized("Next_Step"))
                .fontWeight(.heavy)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isValidConfiguration ? Color.primary : Color.secondary.opacity(0.3))
                .foregroundColor(viewModel.isValidConfiguration ? Color(.systemBackground) : .secondary)
                .cornerRadius(12)
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
                    .foregroundColor(isSelected ? .white : .secondary)
                
                Image(systemName: mode.icon)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(mode.displayName)
                    .font(.subheadline)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.blue : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isSelected ? Color.blue : Color.secondary.opacity(0.3), lineWidth: 1)
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
                .foregroundColor(.secondary)
            
            if isMultiline {
                TextField(placeholder, text: $text, axis: .vertical)
                    .lineLimit(3...6)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
                    .foregroundColor(.primary)
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
                    .foregroundColor(.primary)
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
                .foregroundColor(.secondary)
            
            HStack {
                Button(action: { if value > range.lowerBound { value -= 1 } }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(value > range.lowerBound ? .primary : .secondary)
                }
                .disabled(value <= range.lowerBound)
                
                Spacer()
                
                Text("\(value)")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: { if value < range.upperBound { value += 1 } }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(value < range.upperBound ? .primary : .secondary)
                }
                .disabled(value >= range.upperBound)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
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
                TextField(LocalizationUtils.localized("Stop_Location"), text: $stop.location.address)
                    .textFieldStyle(.plain)
                    .foregroundColor(.primary)
                
                Button(action: onDelete) {
                    Image(systemName: "trash.circle.fill")
                        .foregroundColor(.red)
                }
            }
            
            HStack {
                Text(LocalizationUtils.localized("Stop_Duration"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(stop.duration)) \(LocalizationUtils.localized("Minutes"))")
                    .font(.caption)
                    .foregroundColor(.primary)
                
                Stepper("", value: $stop.duration, in: 15...180, step: 15)
                    .labelsHidden()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationView {
        TripModeSettingsView(navigationPath: .constant(NavigationPath()))
    }
}
#endif
