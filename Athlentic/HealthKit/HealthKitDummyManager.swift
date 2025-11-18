//
//  HealthKitDummyManager.swift
//  TodayworkoutDone
//
//  Created by ocean on 4/29/25.
//

import HealthKit

public final class HealthKitDummyManager {
    private let healthStore = HKHealthStore()
    
    public init() {}
    
    @discardableResult
    public func insertDummyQuantity(
        type: HKQuantityTypeIdentifier,
        value: Double,
        date: Date = Date(),
        unit: HKUnit
    ) async throws -> Bool {
        let quantityType = HKQuantityType.quantityType(forIdentifier: type)!
        let quantity = HKQuantity(unit: unit, doubleValue: value)
        let sample = HKQuantitySample(type: quantityType, quantity: quantity, start: date, end: date)
        
        let isAuthorized = try await authorizeHealthKit(typesToShare: [quantityType])
        guard isAuthorized else { throw HealthDataError.authorizationRequestError }
        
        return try await withCheckedThrowingContinuation { continuation in
            healthStore.save(sample) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }
    
    private func authorizeHealthKit(typesToShare: Set<HKSampleType>) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            healthStore.requestAuthorization(toShare: typesToShare, read: []) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }
}
