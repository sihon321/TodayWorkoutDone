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
    ) -> AnyPublisher<[HKCategorySample], Error> {
        let subject = PassthroughSubject<[HKCategorySample], Error>()
        
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
            
            guard let samples = samplesOrNil as? [HKCategorySample] else {
                subject.send(completion: .finished)
                return
            }
            
            subject.send(samples)
            subject.send(completion: .finished)
        }
        
        execute(query)
        
        return subject.eraseToAnyPublisher()
    }
}
