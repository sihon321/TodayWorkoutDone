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
    func getHealthQuantityData(type: HKQuantityTypeIdentifier,
                               from startDate: Date,
                               to endDate: Date) -> Future<Int, Error>
    func getWeeklyCalories(from startDate: Date,
                           to endDate: Date) -> Future<[Double], Error>
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
    
    func getHealthQuantityData(type: HKQuantityTypeIdentifier,
                               from startDate: Date,
                               to endDate: Date) -> Future<Int, Error> {
        Future { [weak self] promise in
            guard let `self` = self else { return }
            self.authorizeHealthKit(typesToShare: [], typesToRead: [.quantityType(forIdentifier: type)!])
                .sink(receiveCompletion: { completion in
                    print("\(completion)")
                }, receiveValue: { [self] _ in
                    let today = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
                    
                    self.healthStore.subject(quantityType: .quantityType(forIdentifier: type)!,
                                             quantitySamplePredicate: today,
                                             options: .cumulativeSum)
                    .receive(on: RunLoop.main)
                    .sink(receiveCompletion: { completion in
                        print("\(completion)")
                    }, receiveValue: { statistics in
                        if let sumQuantity = statistics.sumQuantity() {
                            promise(.success(Int(sumQuantity.doubleValue(for: .kilocalorie()))))
                        } else {
                            promise(.success(0))
                        }
                    })
                    .store(in: &self.cancellables)
                })
                .store(in: &cancellables)
        }
    }
    
    func getWeeklyCalories(from startDate: Date,
                           to endDate: Date) -> Future<[Double], Error> {
        Future { [weak self] promise in
            guard let self = self else { return }
            self.authorizeHealthKit(typesToShare: [], typesToRead: [.quantityType(forIdentifier: .activeEnergyBurned)!])
                .sink(receiveCompletion: { completion in
                    print("\(completion)")
                }, receiveValue: { [self] _ in
                    self.healthStore.subject(
                        for: .quantityType(forIdentifier: .activeEnergyBurned)!,
                        predicate: HKQuery.predicateForSamples(withStart: startDate,
                                                               end: endDate,
                                                               options: .strictStartDate),
                        options: .cumulativeSum,
                        anchorDate: startDate,
                        intervalComponents: DateComponents(day: 1),
                        startDate: startDate,
                        endDate: endDate
                    )
                    .receive(on: RunLoop.main)
                    .sink(receiveCompletion: { completion in
                        print("\(completion)")
                    }, receiveValue: { statistics in
                        var weeklyCalories: [Double] = []
                        
                        statistics.enumerateStatistics(from: startDate, to: endDate) { statistics, date in
                            if let quantity = statistics.sumQuantity() {
                                let calories = quantity.doubleValue(for: HKUnit.kilocalorie())
                                weeklyCalories.append(calories)
                            }
                        }
                        
                        promise(.success(weeklyCalories))
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
