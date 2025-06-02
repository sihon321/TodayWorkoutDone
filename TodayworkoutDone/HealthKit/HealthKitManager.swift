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

struct HealthProfile {
    let age: Int?
    let biologicalSex: HKBiologicalSex?
    let height: Double?
    let weight: Double?
}

protocol HealthKitManager {
    func fetchUserProfile() async throws -> HealthProfile
    
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
    
    func saveHeightAndWeight(height: Double, weight: Double) async throws
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
            .quantityType(forIdentifier: .stepCount)!,
            .quantityType(forIdentifier: .distanceWalkingRunning)!,
            .quantityType(forIdentifier: .walkingSpeed)!,
            .quantityType(forIdentifier: .walkingAsymmetryPercentage)!,
            .quantityType(forIdentifier: .walkingStepLength)!,
            .quantityType(forIdentifier: .walkingDoubleSupportPercentage)!,
            
            .quantityType(forIdentifier: .activeEnergyBurned)!,
            .quantityType(forIdentifier: .basalEnergyBurned)!,
            .quantityType(forIdentifier: .heartRate)!,
            .quantityType(forIdentifier: .restingHeartRate)!,
            
            .quantityType(forIdentifier: .appleMoveTime)!,
            .quantityType(forIdentifier: .appleStandTime)!,
            
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
    
    func fetchUserProfile() async throws -> HealthProfile {
        var age: Int?
        var sex: HKBiologicalSex?
        var height: Double?
        var weight: Double?

        let birthday = try? healthStore.dateOfBirthComponents()
        if let year = birthday?.year {
            age = Calendar.current.component(.year, from: Date()) - year
        }

        sex = try? healthStore.biologicalSex().biologicalSex

        let heightType = HKQuantityType.quantityType(forIdentifier: .height)!
        let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        let unit = HKUnit.meter()
        let kg = HKUnit.gramUnit(with: .kilo)

        let h = try await self.queryMostRecentSample(of: heightType, unit: unit)
        let w = try await self.queryMostRecentSample(of: weightType, unit: kg)

        height = h
        weight = w

        return HealthProfile(age: age, biologicalSex: sex, height: height, weight: weight)
    }

    private func queryMostRecentSample(of type: HKQuantityType, unit: HKUnit) async throws -> Double? {
        return try await withCheckedThrowingContinuation { continuation in
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            let query = HKSampleQuery(
                sampleType: type,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard
                    let quantitySample = samples?.first as? HKQuantitySample
                else {
                    continuation.resume(returning: nil)
                    return
                }

                let value = quantitySample.quantity.doubleValue(for: unit)
                continuation.resume(returning: value)
            }

            healthStore.execute(query)
        }
    }
    
    func saveHeightAndWeight(height: Double, weight: Double) async throws {
        let now = Date()

        let heightType = HKQuantityType.quantityType(forIdentifier: .height)!
        let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!

        let heightQuantity = HKQuantity(unit: .meter(), doubleValue: height)
        let weightQuantity = HKQuantity(unit: .gramUnit(with: .kilo), doubleValue: weight)

        let heightSample = HKQuantitySample(type: heightType, quantity: heightQuantity, start: now, end: now, metadata: [
            HKMetadataKeyWasUserEntered: true
        ])
        
        let weightSample = HKQuantitySample(type: weightType, quantity: weightQuantity, start: now, end: now, metadata: [
            HKMetadataKeyWasUserEntered: true
        ])

        return try await withCheckedThrowingContinuation { continuation in
            healthStore.save([heightSample, weightSample]) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}

enum HealthDataError: Error {
    case unavailableOnDevice
    case authorizationRequestError
    case dataSaveError
    case invalidType
}
