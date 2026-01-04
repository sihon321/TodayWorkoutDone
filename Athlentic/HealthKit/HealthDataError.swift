//
//  HealthDataError.swift
//  Athlentic
//
//  Created by oceano on 1/4/26.
//

import Foundation

enum HealthDataError: Error {
    case unavailableOnDevice
    case authorizationRequestError
    case dataSaveError
    case invalidType
}
