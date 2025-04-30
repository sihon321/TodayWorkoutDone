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
    func authorizeHealthKit(typesToShare: Set<HKSampleType>,
                            typesToRead: Set<HKObjectType>) async throws -> Bool
    func requestAuthorization() async throws -> Bool
    func getHealthQuantityData(type: HKQuantityTypeIdentifier,
                               from startDate: Date,
                               to endDate: Date,
                               unit: HKUnit) async throws -> Int
    func getWeeklyCalories(from startDate: Date,
                           to endDate: Date) async throws -> [Date: Double]
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
                               unit: HKUnit) async throws -> Int {
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
                    continuation.resume(returning: Int(sumQuantity.doubleValue(for: unit)))
                } else {
                    continuation.resume(returning: 0)
                }
            }
            healthStore.execute(query)
        }
    }
    
    func getWeeklyCalories(from startDate: Date,
                           to endDate: Date) async throws -> [Date: Double] {
        let isAuthorized = try await authorizeHealthKit(typesToShare: [], typesToRead: [.quantityType(forIdentifier: .activeEnergyBurned)!])
        guard isAuthorized else {
            throw HealthDataError.authorizationRequestError
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
            let interval = DateComponents(day: 1)
            
            let query = HKStatisticsCollectionQuery(quantityType: .quantityType(forIdentifier: .activeEnergyBurned)!,
                                                    quantitySamplePredicate: predicate,
                                                    options: .cumulativeSum,
                                                    anchorDate: startDate,
                                                    intervalComponents: interval)
            
            query.initialResultsHandler = { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                var weeklyCalories: [Date: Double] = [:]
                results?.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                    if let quantity = statistics.sumQuantity() {
                        let date = statistics.startDate
                        let calories = quantity.doubleValue(for: .kilocalorie())
                        weeklyCalories[date] = calories
                    }
                }
                continuation.resume(returning: weeklyCalories)
            }
            healthStore.execute(query)
        }
    }
}

enum HealthDataError: Error {
    case unavailableOnDevice
    case authorizationRequestError
    case dataSaveError
}
