import XCTest
@testable import EasyRide

final class TripConfigurationTests: XCTestCase {
    
    var viewModel: TripConfigurationViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = TripConfigurationViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialState() {
        XCTAssertEqual(viewModel.selectedMode, .freeRoute)
        XCTAssertEqual(viewModel.passengerCount, 1)
        XCTAssertTrue(viewModel.pickupAddress.isEmpty)
        XCTAssertTrue(viewModel.destinationAddress.isEmpty)
        XCTAssertTrue(viewModel.notes.isEmpty)
        XCTAssertFalse(viewModel.isNotesExpanded)
        XCTAssertFalse(viewModel.showingAddressPicker)
    }
    
    func testInitializationWithExistingConfiguration() {
        let location = Location(latitude: 37.7749, longitude: -122.4194, address: "Test Address")
        let config = TripConfiguration(
            mode: .customRoute,
            pickupLocation: location,
            destination: location,
            passengerCount: 3,
            notes: "Test notes"
        )
        
        let viewModelWithConfig = TripConfigurationViewModel(tripConfiguration: config)
        
        XCTAssertEqual(viewModelWithConfig.selectedMode, .customRoute)
        XCTAssertEqual(viewModelWithConfig.passengerCount, 3)
        XCTAssertEqual(viewModelWithConfig.notes, "Test notes")
        XCTAssertEqual(viewModelWithConfig.pickupAddress, "Test Address")
        XCTAssertEqual(viewModelWithConfig.destinationAddress, "Test Address")
    }
    
    // MARK: - Mode Switching Tests
    
    func testModeSwitching() {
        // Start with free route
        XCTAssertEqual(viewModel.selectedMode, .freeRoute)
        XCTAssertEqual(viewModel.tripConfiguration.mode, .freeRoute)
        
        // Switch to custom route
        viewModel.selectedMode = .customRoute
        XCTAssertEqual(viewModel.selectedMode, .customRoute)
        XCTAssertEqual(viewModel.tripConfiguration.mode, .customRoute)
        
        // Switch back to free route
        viewModel.selectedMode = .freeRoute
        XCTAssertEqual(viewModel.selectedMode, .freeRoute)
        XCTAssertEqual(viewModel.tripConfiguration.mode, .freeRoute)
    }
    
    // MARK: - Address Management Tests
    
    func testPickupAddressUpdate() {
        let testAddress = "123 Test Street, San Francisco, CA"
        viewModel.updatePickupAddress(testAddress)
        
        XCTAssertEqual(viewModel.pickupAddress, testAddress)
        XCTAssertEqual(viewModel.tripConfiguration.pickupLocation.address, testAddress)
    }
    
    func testDestinationAddressUpdate() {
        let testAddress = "456 Destination Ave, San Francisco, CA"
        viewModel.updateDestinationAddress(testAddress)
        
        XCTAssertEqual(viewModel.destinationAddress, testAddress)
        XCTAssertEqual(viewModel.tripConfiguration.destination?.address, testAddress)
    }
    
    func testEmptyDestinationAddress() {
        // Set a destination first
        viewModel.updateDestinationAddress("Test Address")
        XCTAssertNotNil(viewModel.tripConfiguration.destination)
        
        // Clear the destination
        viewModel.updateDestinationAddress("")
        XCTAssertTrue(viewModel.destinationAddress.isEmpty)
        XCTAssertNil(viewModel.tripConfiguration.destination)
    }
    
    // MARK: - Passenger Count Tests
    
    func testPassengerCountUpdate() {
        viewModel.updatePassengerCount(3)
        XCTAssertEqual(viewModel.passengerCount, 3)
        XCTAssertEqual(viewModel.tripConfiguration.passengerCount, 3)
    }
    
    func testPassengerCountLimits() {
        // Test minimum limit
        viewModel.updatePassengerCount(0)
        XCTAssertEqual(viewModel.passengerCount, 1)
        
        viewModel.updatePassengerCount(-5)
        XCTAssertEqual(viewModel.passengerCount, 1)
        
        // Test maximum limit
        viewModel.updatePassengerCount(10)
        XCTAssertEqual(viewModel.passengerCount, 8)
        
        viewModel.updatePassengerCount(100)
        XCTAssertEqual(viewModel.passengerCount, 8)
    }
    
    // MARK: - Scheduled Time Tests
    
    func testScheduledTimeUpdate() {
        let futureDate = Date().addingTimeInterval(3600) // 1 hour from now
        viewModel.updateScheduledTime(futureDate)
        
        XCTAssertEqual(viewModel.scheduledTime, futureDate)
        XCTAssertEqual(viewModel.tripConfiguration.scheduledTime, futureDate)
    }
    
    // MARK: - Notes Tests
    
    func testNotesUpdate() {
        let testNotes = "Please wait at the main entrance"
        viewModel.updateNotes(testNotes)
        
        XCTAssertEqual(viewModel.notes, testNotes)
        XCTAssertEqual(viewModel.tripConfiguration.notes, testNotes)
    }
    
    func testEmptyNotesUpdate() {
        // Set notes first
        viewModel.updateNotes("Test notes")
        XCTAssertEqual(viewModel.tripConfiguration.notes, "Test notes")
        
        // Clear notes
        viewModel.updateNotes("")
        XCTAssertTrue(viewModel.notes.isEmpty)
        XCTAssertNil(viewModel.tripConfiguration.notes)
    }
    
    // MARK: - Address Search Tests
    
    func testAddressSearch() {
        viewModel.searchAddresses("Test")
        XCTAssertFalse(viewModel.suggestedAddresses.isEmpty)
        XCTAssertTrue(viewModel.suggestedAddresses.count <= 3) // Mock returns max 3 results
    }
    
    func testEmptyAddressSearch() {
        viewModel.searchAddresses("")
        XCTAssertTrue(viewModel.suggestedAddresses.isEmpty)
    }
    
    func testAddressSelection() {
        let testAddress = Address(
            name: "Test Location",
            address: "123 Test St, San Francisco, CA",
            location: Location(latitude: 37.7749, longitude: -122.4194, address: "123 Test St")
        )
        
        // Test pickup selection
        viewModel.addressPickerType = .pickup
        viewModel.selectAddress(testAddress)
        
        XCTAssertEqual(viewModel.pickupAddress, testAddress.address)
        XCTAssertFalse(viewModel.showingAddressPicker)
        XCTAssertTrue(viewModel.suggestedAddresses.isEmpty)
        
        // Test destination selection
        viewModel.addressPickerType = .destination
        viewModel.selectAddress(testAddress)
        
        XCTAssertEqual(viewModel.destinationAddress, testAddress.address)
    }
    
    // MARK: - Validation Tests
    
    func testFreeRouteValidation() {
        viewModel.selectedMode = .freeRoute
        
        // Initially invalid (no addresses)
        XCTAssertFalse(viewModel.isValidConfiguration)
        XCTAssertNotNil(viewModel.validationMessage)
        
        // Add pickup only
        viewModel.updatePickupAddress("Pickup Address")
        XCTAssertFalse(viewModel.isValidConfiguration)
        XCTAssertEqual(viewModel.validationMessage, "Please enter destination")
        
        // Add destination
        viewModel.updateDestinationAddress("Destination Address")
        XCTAssertTrue(viewModel.isValidConfiguration)
        XCTAssertNil(viewModel.validationMessage)
    }
    
    func testCustomRouteValidation() {
        viewModel.selectedMode = .customRoute
        
        // Initially invalid (no pickup or stops)
        XCTAssertFalse(viewModel.isValidConfiguration)
        XCTAssertNotNil(viewModel.validationMessage)
        
        // Add pickup only
        viewModel.updatePickupAddress("Pickup Address")
        XCTAssertFalse(viewModel.isValidConfiguration)
        XCTAssertEqual(viewModel.validationMessage, "Please add at least one stop")
        
        // Add a stop (this would be done in the next task)
        // For now, we just test the validation logic
        let stop = TripStop(
            location: Location(latitude: 37.7749, longitude: -122.4194, address: "Stop 1"),
            order: 1
        )
        viewModel.customStops = [stop]
        
        // Update the trip configuration to include the stop
        viewModel.tripConfiguration = TripConfiguration(
            id: viewModel.tripConfiguration.id,
            mode: .customRoute,
            pickupLocation: viewModel.tripConfiguration.pickupLocation,
            passengerCount: viewModel.tripConfiguration.passengerCount,
            stops: [stop]
        )
        
        XCTAssertTrue(viewModel.isValidConfiguration)
        XCTAssertNil(viewModel.validationMessage)
    }
}