//
//  RulesDescription.swift
//  Kalah
//
//  Created by Aliesia Borzik on 13.05.2022.
//

import UIKit

//MARK: - Pebbles Rules
protocol CakeRule: BoardCupsAndGameLogicController {
    func cakeRule()
}

protocol HalfEmptyHolesRule: BoardCupsAndGameLogicController {
    func didHalfEmptyHolesRuleIsValid() -> Bool
    func halfEmptyHolesRuleIsValid()
}

protocol LastPebbleInYourEmptyHoleRule: LastPebbleInEmptyHoleRuleIsValid {
    func didLastPebbleInYourEmptyHoleRuleValid() -> Bool
}

protocol LastPebbleInAnyEmptyHoleRule: LastPebbleInEmptyHoleRuleIsValid {
    func didLastPebbleInAnyEmptyHoleRuleValid() -> Bool
}

protocol LastPebbleInEmptyHoleRuleIsValid: BoardCupsAndGameLogicController {
    func lastPebbleInEmptyHoleRuleIsValid()
}

protocol YourKalahRule: BoardCupsAndGameLogicController {
    func didYourStorageRuleValid() -> Bool
}

protocol FamineRule: BoardCupsAndGameLogicController {
    var didCaptureAllowed: Bool { get set }
    var didPlayerFamine: Bool { get set }
    var didPlayerWasFamine: Bool { get set }
    
    func IsPlayerFamineNow() -> Bool
    func didPlayerStillFamine() -> Bool
}

protocol PebblesBehindHoleRule: BoardCupsAndGameLogicController {
    func didPebblesBehindHoleRuleIsValid() -> Bool
    func pebblesBehindHoleRuleIsValid()
}

protocol EmptyAllHolesRule: BoardCupsAndGameLogicController {
    func didEmptyAllHolesRuleIsValid() -> Bool
}

//MARK: - Player Rules Soon...

//MARK: - Moving Rules Soon...

protocol GameLogicManager: BoardCupsAndGameLogicController {
    
    
    
}

protocol didMoveIsPossiple: BoardCupsAndGameLogicController {
    func didMoveIsPossiple() -> Bool
    func moveIsPossible()
    func moveIsImpossible()
    func moving()
}
