//
//  HealthKit+Combine.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/08/15.
//

import Combine
import HealthKit

extension HKHealthStore {
    func subject(
        for sampleType: HKSampleType,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) -> AnyPublisher<[HKSample], Error> {
        let subject = PassthroughSubject<[HKSample], Error>()
        
        let query = HKSampleQuery(
            sampleType: sampleType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: sortDescriptors
        ) { _, samplesOrNil, error in
            if let error = error {
                subject.send(completion: .failure(error))
                return
            }
            
            guard let samples = samplesOrNil else {
                subject.send(completion: .finished)
                return
            }
            
            subject.send(samples)
            subject.send(completion: .finished)
        }
        
        
        execute(query)
        
        return subject.eraseToAnyPublisher()
    }
    
    func subject(
        quantityType: HKQuantityType,
        quantitySamplePredicate: NSPredicate? = nil,
        options: HKStatisticsOptions = []
    ) -> AnyPublisher<HKStatistics, Error> {
        let subject = PassthroughSubject<HKStatistics, Error>()
        
        let query = HKStatisticsQuery(
            quantityType: quantityType,
            quantitySamplePredicate: quantitySamplePredicate,
            options: options
        ) { query, statisticsOrNil, errorOrNil in
            if let error = errorOrNil {
                subject.send(completion: .failure(error))
                return
            }
            
            guard let statistics = statisticsOrNil else {
                subject.send(completion: .finished)
                return
            }
            
            subject.send(statistics)
            subject.send(completion: .finished)
        }

        execute(query)
        
        return subject.eraseToAnyPublisher()
    }
    
    func subject(
        for quantityType: HKQuantityType,
        predicate: NSPredicate? = nil,
        options: HKStatisticsOptions = [],
        anchorDate: Date,
        intervalComponents: DateComponents,
        startDate: Date,
        endDate: Date
    ) -> AnyPublisher<[HKStatistics], Error> {
        let subject = PassthroughSubject<[HKStatistics], Error>()
        
        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            anchorDate: anchorDate,
            intervalComponents: intervalComponents
        )
        query.initialResultsHandler = { query, results, error in
            if let myResults = results{
                myResults.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
                    if let quantity = statistics.sumQuantity() {
                        let date = statistics.startDate
                        let steps = quantity.doubleValue(for: HKUnit.count())
                        print("START DATE :: \(statistics.startDate)")
                        print("STEP COUNT :: \(steps)")
                    }
                }
            } else {
                print("STEP COUNT DATA NIL")
            }
        }
        
        execute(query)
        return subject.eraseToAnyPublisher()
    }
}
