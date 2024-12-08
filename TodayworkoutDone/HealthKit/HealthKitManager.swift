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
                            typesToRead: Set<HKObjectType>) -> Deferred<Future<Bool, Error>>
    func requestAuthorization() -> Future<Bool, Error>
    func stepCount(from startDate: Date, to endDate: Date) -> Future<Int, Error>
    func appleExerciseTime(from startDate: Date, to endDate: Date) -> Future<Int, Error>
    func activeEnergyBurned(from startDate: Date, to endDate: Date) -> Future<Int, Error>
}

class LiveHealthKitManager: HealthKitManager {
    
    let healthStore = HKHealthStore()
    private var cancellables: Set<AnyCancellable> = []
    
    internal func authorizeHealthKit(typesToShare: Set<HKSampleType> = .init(),
                                    typesToRead: Set<HKObjectType> = .init()) -> Deferred<Future<Bool, Error>> {
        Deferred {
            Future { [weak self] promise in
                guard let `self` = self,
                    HKHealthStore.isHealthDataAvailable() else {
                    promise(.failure(HealthDataError.unavailableOnDevice))
                    return
                }
                
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
    
    func requestAuthorization() -> Future<Bool, Error> {
        Future { [weak self] promise in
            guard let self = self else { return }
            let typesToRead: Set<HKObjectType> = [
                HKQuantityType.quantityType(forIdentifier: .stepCount)!,
                HKQuantityType.quantityType(forIdentifier: .heartRate)!,
                HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
                HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
                HKObjectType.activitySummaryType()
            ]
            
            self.authorizeHealthKit(typesToRead: typesToRead)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Authorization request finished.")
                    case .failure(let error):
                        print("Authorization request failed with error: \(error)")
                    }
                }, receiveValue: { isSucceeded in
                    if isSucceeded {
                        promise(.success(isSucceeded))
                    } else {
                        promise(.failure(HealthDataError.authorizationRequestError))
                    }
                })
                .store(in: &cancellables)
        }
    }
    
    func stepCount(from startDate: Date, to endDate: Date) -> Future<Int, Error> {
        Future { [weak self] promise in
            guard let `self` = self else { return }
            self.authorizeHealthKit(typesToShare: [], typesToRead: [.quantityType(forIdentifier: .stepCount)!])
                .sink(receiveCompletion: { completion in
                    print("\(completion)")
                }, receiveValue: { [self] _ in
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
                    .store(in: &self.cancellables)
                })
                .store(in: &cancellables)
        }
    }
    
    func appleExerciseTime(from startDate: Date = Date(),
                           to endDate: Date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!) -> Future<Int, Error> {
        Future { [weak self] promise in
            guard let `self` = self else { return }
            self.authorizeHealthKit(typesToShare: [], typesToRead: [.quantityType(forIdentifier: .appleExerciseTime)!])
                .sink(receiveCompletion: { completion in
                    print("\(completion)")
                }, receiveValue: { [self] _ in
                    let today = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
                    
                    self.healthStore.subject(quantityType: .quantityType(forIdentifier: .appleExerciseTime)!,
                                             quantitySamplePredicate: today,
                                             options: .cumulativeSum)
                    .receive(on: RunLoop.main)
                    .sink(receiveCompletion: { completion in
                        print("\(completion)")
                    }, receiveValue: { statistics in
                        if let sumQuantity = statistics.sumQuantity() {
                            promise(.success(Int(sumQuantity.doubleValue(for: .minute()))))
                        } else {
                            promise(.success(0))
                        }
                    })
                    .store(in: &self.cancellables)
                })
                .store(in: &cancellables)
        }
    }
    
    func activeEnergyBurned(from startDate: Date = Date(),
                            to endDate: Date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!) -> Future<Int, Error> {
        Future { [weak self] promise in
            guard let `self` = self else { return }
            self.authorizeHealthKit(typesToShare: [], typesToRead: [.quantityType(forIdentifier: .activeEnergyBurned)!])
                .sink(receiveCompletion: { completion in
                    print("\(completion)")
                }, receiveValue: { [self] _ in
                    let today = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
                    
                    self.healthStore.subject(quantityType: .quantityType(forIdentifier: .appleExerciseTime)!,
                                             quantitySamplePredicate: today,
                                             options: .cumulativeSum)
                    .receive(on: RunLoop.main)
                    .sink(receiveCompletion: { completion in
                        print("\(completion)")
                    }, receiveValue: { statistics in
                        if let sumQuantity = statistics.sumQuantity() {
                            promise(.success(Int(sumQuantity.doubleValue(for: .minute()))))
                        } else {
                            promise(.success(0))
                        }
                    })
                    .store(in: &self.cancellables)
                })
                .store(in: &cancellables)
        }
    }
}

enum HealthDataError: Error {
    case unavailableOnDevice
    case authorizationRequestError
}

struct StubHealthKitInteractor: HealthKitManager {
    func authorizeHealthKit(typesToShare: Set<HKSampleType>,
                            typesToRead: Set<HKObjectType>) -> Deferred<Future<Bool, Error>> {
        return Deferred {
            Future { promise in
                promise(.success(true))
            }
        }
    }
    
    func requestAuthorization() -> Future<Bool, Error> {
        Future { promise in
            promise(.success(false))
        }
    }
    
    func stepCount(from startDate: Date, to endDate: Date) -> Future<Int, Error> {
        Future { promise in
            promise(.success(0))
        }
    }
    
    func activeEnergyBurned(from startDate: Date, to endDate: Date) -> Future<Int, Error> {
        Future { promise in
            promise(.success(0))
        }
    }
    
    func appleExerciseTime(from startDate: Date, to endDate: Date) -> Future<Int, Error> {
        Future { promise in
            promise(.success(0))
        }
    }
}
