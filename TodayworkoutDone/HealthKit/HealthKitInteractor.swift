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
    func authorizeHealthKit(typesToShare: Set<HKQuantityType>,
                            typesToRead: Set<HKQuantityType>) -> Deferred<Future<Bool, Error>>
    func stepCount() -> Future<Int, Error>
}

class RealHealthKitInteractor: HealthKitInteractor {
    
    let healthStore = HKHealthStore()
    private var cancellables: Set<AnyCancellable> = []
    
    func authorizeHealthKit(typesToShare: Set<HKQuantityType>,
                            typesToRead: Set<HKQuantityType>) -> Deferred<Future<Bool, Error>> {
        Deferred {
            Future { [unowned self] promise in
                guard HKHealthStore.isHealthDataAvailable() else {
                    promise(.failure(HealthDataError.unavailableOnDevice))
                    return
                }
                
//                let typesToShare: Set = [
//                    HKQuantityType.workoutType()
//                ]
                
//                let typesToRead: Set = [
//                    HKQuantityType.quantityType(forIdentifier: .stepCount)!,
//                    HKQuantityType.quantityType(forIdentifier: .heartRate)!,
//                    HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
//                    HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
//                    HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
//                    HKObjectType.activitySummaryType()
//                ]
                
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
    
    func stepCount() -> Future<Int, Error> {
        Future { [unowned self] promise in
            self.authorizeHealthKit(typesToShare: [], typesToRead: [.quantityType(forIdentifier: .stepCount)!])
                .sink(receiveCompletion: { completion in
                    print("\(completion)")
                }, receiveValue: { [self] _ in
                    let calendar = NSCalendar.current
                    let now = Date()
                    let components = calendar.dateComponents([.year, .month, .day], from: now)
                    guard let startDate = calendar.date(from: components) else {
                        promise(.failure(HealthDataError.unavailableOnDevice))
                        return
                    }
                     
                    guard let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else {
                        promise(.failure(HealthDataError.unavailableOnDevice))
                        return
                    }


                    let today = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
                    
                    self.healthStore.subject(quantityType: .quantityType(forIdentifier: .stepCount)!,
                                             quantitySamplePredicate: today,
                                             options: .cumulativeSum)
                    .receive(on: RunLoop.main)
                    .sink(receiveCompletion: { completion in
                        print("\(completion)")
                    }, receiveValue: { statistics in
                        if let sumQuantity = statistics.sumQuantity() {
                            promise(.success(Int(sumQuantity.doubleValue(for: .count()))))
                        } else {
                            promise(.success(0))
                        }
                    })
                    .store(in: &cancellables)
                })
                .store(in: &cancellables)
        }
    }
}

enum HealthDataError: Error {
    case unavailableOnDevice
    case authorizationRequestError
}

struct StubHealthKitInteractor: HealthKitInteractor {
    func authorizeHealthKit(typesToShare: Set<HKQuantityType>,
                            typesToRead: Set<HKQuantityType>) -> Deferred<Future<Bool, Error>> {
        return Deferred {
            Future { promise in
                promise(.success(true))
            }
        }
    }
    func stepCount() -> Future<Int, Error> {
        Future { promise in
            promise(.success(0))
        }
    }
}
