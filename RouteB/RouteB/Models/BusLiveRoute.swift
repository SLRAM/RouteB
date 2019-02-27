//
//  MTABusModel.swift
//  RouteB
//
//  Created by Stephanie Ramirez on 2/25/19.
//  Copyright © 2019 Stephanie Ramirez. All rights reserved.
//

import Foundation

struct BusLiveRoute: Codable {
    let Siri: Siri
}
struct Siri: Codable {
    let ServiceDelivery: ServiceDelivery
}
struct ServiceDelivery: Codable {
    let ResponseTimestamp: String //time stamp actually
    let VehicleMonitoringDelivery: [VehicleMonitoringDelivery]
    let SituationExchangeDelivery: [SituationExchangeDelivery]
}
struct VehicleMonitoringDelivery: Codable {
    let VehicleActivity: [VehicleActivity]
    let ResponseTimestamp: String //actually timestamp
    let ValidUntil: String //actually timestamp
}
struct VehicleActivity: Codable {
    let MonitoredVehicleJourney: MonitoredVehicleJourney
    let RecordedAtTime: String //actually timestamp
}

struct MonitoredVehicleJourney: Codable {
    let LineRef: String
    let DirectionRef: String
    let FramedVehicleJourneyRef: FramedVehicleJourneyRef
    let JourneyPatternRef: String
    let PublishedLineName: [String]
    let OperatorRef: String
    let OriginRef: String
    let DestinationRef: String
    let DestinationName: [String]
    let SituationRef: [SituationRef]
    let Monitored: Bool
    let VehicleLocation: VehicleLocation
    let Bearing: Double
    let ProgressRate: String
//    let BlockRef: String
    let VehicleRef: String
    let MonitoredCall: MonitoredCall
}
struct FramedVehicleJourneyRef: Codable {
    let DataFrameRef: String //actually YYYY-MM-DD
    let DatedVehicleJourneyRef: String
}
struct SituationRef: Codable {
    let SituationSimpleRef: String
}
struct VehicleLocation: Codable {
    let Longitude: Double
    let Latitude: Double
}
struct MonitoredCall: Codable {
//    let ExpectedArrivalTime: String //actually timestamp
    let ArrivalProximityText: String
//    let ExpectedDepartureTime: String //actually timestamp
    let DistanceFromStop: Double //might be int
    let NumberOfStopsAway: Int
    let StopPointRef: String
    let VisitNumber: Int
    let StopPointName: [String]
}

struct SituationExchangeDelivery: Codable {
    let Situations: Situations
}
struct Situations: Codable {
    let PtSituationElement: [PtSituationElement]
}
struct PtSituationElement: Codable {
    let PublicationWindow: PublicationWindow
    let Severity: String
    let Summary: [String] // could use this for adivsory warnings
    let Description: [String] //could use for advisory warnings
    let Affects: Affects
    let Consequences: Consequences
    let CreationTime: String //actually timestamp
    let SituationNumber: String
}
struct PublicationWindow: Codable {
    let StartTime: String //actually timestamp
    let EndTime: String //actually timestamp
}
struct Affects: Codable {
    let VehicleJourneys: VehicleJourneys
}
struct VehicleJourneys: Codable {
    let AffectedVehicleJourney: [AffectedVehicleJourney]
    
}
struct AffectedVehicleJourney: Codable {
    let LineRef: String
    let DirectionRef: String
}
struct Consequences: Codable {
    let Consequence: [Consequence]
}
struct Consequence: Codable {
    let Condition: [String] //use this for advisory warning
}

