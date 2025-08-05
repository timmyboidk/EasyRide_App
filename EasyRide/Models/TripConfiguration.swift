import Foundation


struct TripConfiguration: Codable {
    let id: String
    let mode: TripMode
    let pickupLocation: Location
    let destination: Location?
    let scheduledTime: Date?
    let passengerCount: Int
    var stops: [TripStop]
    let notes: String?
    let serviceOptions: [ServiceOption]
    
    init(
        id: String = UUID().uuidString,
        mode: TripMode,
        pickupLocation: Location,
        destination: Location? = nil,
        scheduledTime: Date? = nil,
        passengerCount: Int = 1,
        stops: [TripStop] = [],
        notes: String? = nil,
        serviceOptions: [ServiceOption] = []
    ) {
        self.id = id
        self.mode = mode
        self.pickupLocation = pickupLocation
        self.destination = destination
        self.scheduledTime = scheduledTime
        self.passengerCount = passengerCount
        self.stops = stops
        self.notes = notes
        self.serviceOptions = serviceOptions
    }
    
    var totalDistance: Double {
        guard !stops.isEmpty else {
            return destination?.distance(to: pickupLocation) ?? 0
        }
        
        var distance: Double = 0
        var currentLocation = pickupLocation
        
        for stop in stops.sorted(by: { $0.order < $1.order }) {
            distance += currentLocation.distance(to: stop.location)
            currentLocation = stop.location
        }
        
        if let destination = destination {
            distance += currentLocation.distance(to: destination)
        }
        
        return distance
    }
    
    var estimatedDuration: TimeInterval {
        let baseTime = totalDistance / 1000 * 60 // Assume 1 km per minute average
        let stopTime = stops.reduce(0) { $0 + $1.duration }
        return baseTime + stopTime
    }
}



