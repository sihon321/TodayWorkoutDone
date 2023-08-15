//
//  HealthKitInteractor.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/08/15.
//

import Foundation
import HealthKit
import Combine

protocol HealthKitInteractor {
    
}

class RealHealthKitInteractor {
    
    let healthStore = HKHealthStore()
    
    func authorizeHealthKit() -> Deferred<Future<Bool, Error>> {
        Deferred {
            Future { [unowned self] promise in
                guard HKHealthStore.isHealthDataAvailable() else {
                    promise(.failure(HealthDataError.unavailableOnDevice))
                    return
                }
                
                let typesToShare: Set = [
                    HKQuantityType.workoutType()
                ]
                
                let typesToRead: Set = [
                    HKQuantityType.quantityType(forIdentifier: .heartRate)!,
                    HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
                    HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                    HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
                    HKObjectType.activitySummaryType()
                ]
                
                healthStore.requestAuthorization(toShare: typesToShare,
                                                 read: typesToRead) { isSuccess, error in
                    guard error == nil else {
                        promise(.failure(error!))
                        return
                    }
                    
                    if isSuccess {
                        promise(.success(true))
                    } else {
                        promise(.failure(HealthDataError.authorizationRequestError))
                    }
                }
            }
        }
    }
}



enum HealthDataError: Error {
    case unavailableOnDevice
    case authorizationRequestError
}
