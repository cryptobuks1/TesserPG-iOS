//
//  RedPacketService+Error.swift
//  TesserCube
//
//  Created by Cirno MainasuK on 2019-12-19.
//  Copyright © 2019 Sujitech. All rights reserved.
//

import Foundation

extension RedPacketService {
    
    enum Error: Swift.Error {
        case `internal`(String)
        
        case approveFail
        
        case creationFail
        
        case checkAvailabilityFail
        case checkClaimedListFail
        
        case noAvailableShareForClaim
        case claimAfterExpired
        case claimFail
        
        case openRedPacketFail(String)
        
        case refundBeforeExpired
        case noAvailableShareForRefund
        case refundFail
    }
    
}

extension RedPacketService.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .internal(message):            return "Internal error: \(message)\nPlease try again"
        case .approveFail:                      return "Fail to approve token transfer"
        case .creationFail:                     return "Fail to create red packet"
        case .checkAvailabilityFail:            return "Fail to check red packet availability"
        case .checkClaimedListFail:             return "Fail to check red packet claimed list"
        case .noAvailableShareForClaim:         return "No available share for claim"
        case .claimAfterExpired:                return "Cannot claim the expired red packet"
        case .claimFail:                        return "Fail to claim red packet"
        case let .openRedPacketFail(message):   return "Fail to open red packet\n\(message)"
        case .refundBeforeExpired:              return "Unable to refund before expiration"
        case .noAvailableShareForRefund:        return "No available share for refund"
        case .refundFail:                       return "Fail to refund red packet"
        }
    }
}
