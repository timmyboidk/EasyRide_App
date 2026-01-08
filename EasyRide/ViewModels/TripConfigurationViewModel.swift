import Foundation
import SwiftUI

@Observable
class TripConfigurationViewModel {
  // MARK: - Properties
  var tripConfiguration: TripConfiguration
  var selectedMode: TripMode {
    didSet {
      if selectedMode != oldValue {
        updateTripMode(selectedMode)
      }
    }
  }

  // Free Route Mode Properties
  var pickupAddress: String = ""
  var destinationAddress: String = ""
  var scheduledTime: Date = Date().addingTimeInterval(900)  // 15 minutes from now
  var passengerCount: Int = 1
  var largeLuggageCount: Int = 0
  var smallLuggageCount: Int = 0
  var notes: String = ""
  var isNotesExpanded: Bool = false

  // Custom Route Mode Properties
  var customStops: [TripStop] = []

  // UI State
  var isLoading: Bool = false
  var showingAddressPicker: Bool = false
  var addressPickerType: AddressPickerType = .pickup
  var suggestedAddresses: [Address] = []

  // MARK: - Initialization
  init(tripConfiguration: TripConfiguration? = nil) {
    if let config = tripConfiguration {
      self.tripConfiguration = config
      self.selectedMode = config.mode
      self.pickupAddress = config.pickupLocation.address
      self.destinationAddress = config.destination?.address ?? ""
      self.scheduledTime = config.scheduledTime ?? Date().addingTimeInterval(900)
      self.passengerCount = config.passengerCount
      self.notes = config.notes ?? ""
      self.customStops = config.stops
    } else {
      // Default configuration
      let defaultPickup = Location(
        latitude: 37.7749,
        longitude: -122.4194,
        address: "Current Location"
      )

      self.tripConfiguration = TripConfiguration(
        mode: .freeRoute,
        pickupLocation: defaultPickup,
        passengerCount: 1
      )
      self.selectedMode = .freeRoute
    }
  }

  // MARK: - Mode Management
  private func updateTripMode(_ mode: TripMode) {
    let updatedConfig = TripConfiguration(
      id: tripConfiguration.id,
      mode: mode,
      pickupLocation: tripConfiguration.pickupLocation,
      destination: mode == .freeRoute ? tripConfiguration.destination : nil,
      scheduledTime: tripConfiguration.scheduledTime,
      passengerCount: tripConfiguration.passengerCount,
      stops: mode == .customRoute ? customStops : [],
      notes: tripConfiguration.notes,
      serviceOptions: tripConfiguration.serviceOptions
    )

    tripConfiguration = updatedConfig
  }

  // MARK: - Free Route Methods
  func updatePickupAddress(_ address: String) {
    pickupAddress = address
    // In a real app, this would trigger geocoding
    updatePickupLocation(from: address)
  }

  func updateDestinationAddress(_ address: String) {
    destinationAddress = address
    // In a real app, this would trigger geocoding
    updateDestinationLocation(from: address)
  }

  private func updatePickupLocation(from address: String) {
    // Mock geocoding - in real app would use MapKit or Google Places
    let location = Location(
      latitude: 37.7749 + Double.random(in: -0.01...0.01),
      longitude: -122.4194 + Double.random(in: -0.01...0.01),
      address: address
    )

    tripConfiguration = TripConfiguration(
      id: tripConfiguration.id,
      mode: tripConfiguration.mode,
      pickupLocation: location,
      destination: tripConfiguration.destination,
      scheduledTime: scheduledTime,
      passengerCount: passengerCount,
      stops: tripConfiguration.stops,
      notes: notes,
      serviceOptions: tripConfiguration.serviceOptions
    )
  }

  private func updateDestinationLocation(from address: String) {
    guard !address.isEmpty else {
      updateDestination(nil)
      return
    }

    // Mock geocoding
    let location = Location(
      latitude: 37.7749 + Double.random(in: -0.05...0.05),
      longitude: -122.4194 + Double.random(in: -0.05...0.05),
      address: address
    )

    updateDestination(location)
  }

  private func updateDestination(_ destination: Location?) {
    tripConfiguration = TripConfiguration(
      id: tripConfiguration.id,
      mode: tripConfiguration.mode,
      pickupLocation: tripConfiguration.pickupLocation,
      destination: destination,
      scheduledTime: scheduledTime,
      passengerCount: passengerCount,
      stops: tripConfiguration.stops,
      notes: notes,
      serviceOptions: tripConfiguration.serviceOptions
    )
  }

  func updateScheduledTime(_ time: Date) {
    scheduledTime = time
    tripConfiguration = TripConfiguration(
      id: tripConfiguration.id,
      mode: tripConfiguration.mode,
      pickupLocation: tripConfiguration.pickupLocation,
      destination: tripConfiguration.destination,
      scheduledTime: time,
      passengerCount: tripConfiguration.passengerCount,
      stops: tripConfiguration.stops,
      notes: tripConfiguration.notes,
      serviceOptions: tripConfiguration.serviceOptions
    )
  }

  func updatePassengerCount(_ count: Int) {
    passengerCount = max(1, min(8, count))  // Limit between 1-8 passengers
    tripConfiguration = TripConfiguration(
      id: tripConfiguration.id,
      mode: tripConfiguration.mode,
      pickupLocation: tripConfiguration.pickupLocation,
      destination: tripConfiguration.destination,
      scheduledTime: tripConfiguration.scheduledTime,
      passengerCount: passengerCount,
      stops: tripConfiguration.stops,
      notes: tripConfiguration.notes,
      serviceOptions: tripConfiguration.serviceOptions
    )
  }

  func updateNotes(_ newNotes: String) {
    notes = newNotes
    tripConfiguration = TripConfiguration(
      id: tripConfiguration.id,
      mode: tripConfiguration.mode,
      pickupLocation: tripConfiguration.pickupLocation,
      destination: tripConfiguration.destination,
      scheduledTime: tripConfiguration.scheduledTime,
      passengerCount: tripConfiguration.passengerCount,
      stops: tripConfiguration.stops,
      notes: newNotes.isEmpty ? nil : newNotes,
      serviceOptions: tripConfiguration.serviceOptions
    )
  }

  // MARK: - Address Suggestions
  func searchAddresses(_ query: String) {
    guard !query.isEmpty else {
      suggestedAddresses = []
      return
    }

    // Mock address suggestions - in real app would use Places API
    suggestedAddresses = [
      Address(
        name: "Home", address: "\(query) Street, San Francisco, CA", latitude: 37.7749,
        longitude: -122.4194),
      Address(
        name: "Work", address: "\(query) Avenue, San Francisco, CA", latitude: 37.7849,
        longitude: -122.4094),
      Address(
        name: "Airport", address: "San Francisco International Airport", latitude: 37.6213,
        longitude: -122.3790, type: AddressType.airport),
    ]
  }

  func selectAddress(_ address: Address) {
    switch addressPickerType {
    case .pickup:
      pickupAddress = address.address
      updatePickupLocation(from: address.address)
    case .destination:
      destinationAddress = address.address
      updateDestinationLocation(from: address.address)
    }
    showingAddressPicker = false
    suggestedAddresses = []
  }

  func updateLargeLuggageCount(_ count: Int) {
      largeLuggageCount = max(0, min(10, count))
  }

  func updateSmallLuggageCount(_ count: Int) {
      smallLuggageCount = max(0, min(10, count))
  }

  // MARK: - Custom Route Methods
  func addNewStop() {
    let newStop = TripStop(
      location: Location(
        latitude: 37.7749 + Double.random(in: -0.02...0.02),
        longitude: -122.4194 + Double.random(in: -0.02...0.02),
        address: "New Stop Location"
      ),
      notes: nil,
      order: customStops.count
    )
    customStops.append(newStop)
    updateTripConfiguration()
  }

  func editStop(at index: Int) {
    // In a real app, this would open an edit dialog
    print("Edit stop at index \(index)")
  }

  func removeStop(at index: Int) {
    guard index < customStops.count else { return }
    customStops.remove(at: index)

    // Reorder remaining stops
    for i in 0..<customStops.count {
      customStops[i] = TripStop(
        id: customStops[i].id,
        location: customStops[i].location,
        duration: customStops[i].duration,
        notes: customStops[i].notes, order: i
      )
    }

    updateTripConfiguration()
  }

  func moveStop(from source: IndexSet, to destination: Int) {
    customStops.move(fromOffsets: source, toOffset: destination)

    // Reorder all stops
    for i in 0..<customStops.count {
      customStops[i] = TripStop(
        id: customStops[i].id,
        location: customStops[i].location,
        duration: customStops[i].duration,
        notes: customStops[i].notes,
        order: i
      )
    }

    updateTripConfiguration()
  }

  func updateStopDuration(at index: Int, duration: TimeInterval) {
    guard index < customStops.count else { return }

    customStops[index] = TripStop(
      id: customStops[index].id,
      location: customStops[index].location,
      duration: duration,
      notes: customStops[index].notes,
      order: customStops[index].order
    )

    updateTripConfiguration()
  }

  private func updateTripConfiguration() {
    tripConfiguration = TripConfiguration(
      id: tripConfiguration.id,
      mode: selectedMode,
      pickupLocation: tripConfiguration.pickupLocation,
      destination: selectedMode == .freeRoute ? tripConfiguration.destination : nil,
      scheduledTime: scheduledTime,
      passengerCount: passengerCount,
      stops: selectedMode == .customRoute ? customStops : [],
      notes: notes.isEmpty ? nil : notes,
      serviceOptions: tripConfiguration.serviceOptions
    )
  }

  // MARK: - Validation
  var isValidConfiguration: Bool {
    switch selectedMode {
    case .freeRoute:
      // Allow proceeding if at least pickup is set (Destination might be optional or set later in some flows)
      // Based on user feedback, it seems flow is blocked. Let's make it minimal.
      return !pickupAddress.isEmpty
    case .customRoute:
      return !pickupAddress.isEmpty && !customStops.isEmpty
    }
  }

  var validationMessage: String? {
    switch selectedMode {
    case .freeRoute:
      if pickupAddress.isEmpty {
        return "Please enter pickup location"
      }
      if destinationAddress.isEmpty {
        return "Please enter destination"
      }
    case .customRoute:
      if pickupAddress.isEmpty {
        return "Please enter pickup location"
      }
      if customStops.isEmpty {
        return "Please add at least one stop"
      }
    }
    return nil
  }
}
