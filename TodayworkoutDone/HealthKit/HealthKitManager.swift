//
//  HealthKitInteractor.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/08/15.
//

import Foundation
import HealthKit
import Combine
import ComposableArchitecture

private enum HealthKitManagerKey: DependencyKey {
    static let liveValue: HealthKitManager = LiveHealthKitManager()
}

extension DependencyValues {
    var healthKitManager: HealthKitManager {
        get { self[HealthKitManagerKey.self] }
        set { self[HealthKitManagerKey.self] = newValue }
    }
}
protocol HealthKitManager {
    func authorizeHealthKit(
        typesToShare: Set<HKSampleType>,
                            typesToRead: Set<HKObjectType>
    ) async throws -> Bool
    
    func requestAuthorization() async throws -> Bool
    
    func getHealthQuantityData(
        type: HKQuantityTypeIdentifier,
        from startDate: Date,
        to endDate: Date,
        unit: HKUnit
    ) async throws -> Double
    
    func getHealthQuantityTimeSeries(
        type: HKQuantityTypeIdentifier,
        from startDate: Date,
        to endDate: Date,
        unit: HKUnit,
        interval: DateComponents
    ) async throws -> [Date: Double]
    
    func getAverageHealthSampleData(
        type: HKQuantityTypeIdentifier,
        from startDate: Date,
        to endDate: Date,
        unit: HKUnit
    ) async throws -> Double
}

class LiveHealthKitManager: HealthKitManager {
    let healthStore = HKHealthStore()
    
    func authorizeHealthKit(typesToShare: Set<HKSampleType> = .init(),
                            typesToRead: Set<HKObjectType> = .init()) async throws -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthDataError.unavailableOnDevice
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }
    
    func requestAuthorization() async throws -> Bool {
        let typesToRead: Set<HKObjectType> = [
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
            HKObjectType.activitySummaryType()
        ]
        
        return try await authorizeHealthKit(typesToRead: typesToRead)
    }
    
    func getHealthQuantityData(type: HKQuantityTypeIdentifier,
                               from startDate: Date,
                               to endDate: Date,
                               unit: HKUnit) async throws -> Double {
        let isAuthorized = try await authorizeHealthKit(typesToShare: [], typesToRead: [.quantityType(forIdentifier: type)!])
        guard isAuthorized else {
            throw HealthDataError.authorizationRequestError
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
            let query = HKStatisticsQuery(quantityType: .quantityType(forIdentifier: type)!,
                                          quantitySamplePredicate: predicate,
                                          options: .cumulativeSum) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let sumQuantity = result?.sumQuantity() {
                    continuation.resume(returning: sumQuantity.doubleValue(for: unit))
                } else {
                    continuation.resume(returning: 0)
                }
            }
            healthStore.execute(query)
        }
    }
    
    func getHealthQuantityTimeSeries(
        type: HKQuantityTypeIdentifier,
        from startDate: Date,
        to endDate: Date,
        unit: HKUnit,
        interval: DateComponents
    ) async throws -> [Date: Double] {
        let isAuthorized = try await authorizeHealthKit(typesToShare: [], typesToRead: [.quantityType(forIdentifier: type)!])
        guard isAuthorized else {
            throw HealthDataError.authorizationRequestError
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
            
            let query = HKStatisticsCollectionQuery(
                quantityType: .quantityType(forIdentifier: type)!,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
                anchorDate: startDate,
                intervalComponents: interval
            )
            
            query.initialResultsHandler = { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let statsCollection = results else {
                    continuation.resume(returning: [:])
                    return
                }
                
                var resultDict = [Date: Double]()
                statsCollection.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                    if let value = statistics.sumQuantity()?.doubleValue(for: unit) {
                        resultDict[statistics.startDate] = value
                    }
                }
                continuation.resume(returning: resultDict)
            }
            
            healthStore.execute(query)
        }
    }
    
    func getAverageHealthSampleData(type: HKQuantityTypeIdentifier,
                                    from startDate: Date,
                                    to endDate: Date,
                                    unit: HKUnit) async throws -> Double {
        let isAuthorized = try await authorizeHealthKit(typesToShare: [], typesToRead: [.quantityType(forIdentifier: type)!])
        guard isAuthorized else {
            throw HealthDataError.authorizationRequestError
        }

        return try await withCheckedThrowingContinuation { continuation in
            guard let quantityType = HKQuantityType.quantityType(forIdentifier: type) else {
                continuation.resume(throwing: HealthDataError.invalidType)
                return
            }

            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

            let query = HKSampleQuery(sampleType: quantityType,
                                      predicate: predicate,
                                      limit: HKObjectQueryNoLimit,
                                      sortDescriptors: nil) { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let samples = results as? [HKQuantitySample], !samples.isEmpty else {
                    continuation.resume(returning: 0)
                    return
                }

                let total = samples.reduce(0.0) { partialResult, sample in
                    partialResult + sample.quantity.doubleValue(for: unit)
                }

                let average = total / Double(samples.count)
                continuation.resume(returning: average)
            }

            healthStore.execute(query)
        }
    }
}

enum HealthDataError: Error {
    case unavailableOnDevice
    case authorizationRequestError
    case dataSaveError
    case invalidType
}
