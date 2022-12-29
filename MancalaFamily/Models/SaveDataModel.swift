//
//  MancalaModel.swift
//  Kalah
//
//  Created by Aliesia Borzik on 01.07.2022.
//

import Foundation

struct GameDataSaves {
    var playerData: PlayerParametersData
    var gameData: GameParametersData
    var otherData: OtherParametersData
    var famineRuleData: FamineRuleParametersData?
    
    struct PlayerParametersData {
        var playerName1: String
        var playerName2: String
        var isFPM: Bool
        var isSPM: Bool
    }
    
    struct OtherParametersData {
        var didCakeRuleUsed: Bool
        var didChangeRotation: Bool
        var didFamineRuleUsed: Bool
        var lastDataSaving: Date
        var numOfAttemps: String
        var travelDirrection: String
    }
    
    struct GameParametersData {
        var gameKey: String
        var attemps: String
    }
    
    struct FamineRuleParametersData {
        var didCaptureAllowed: Bool
        var didGameShouldEnds: Bool
        var didPlayerFamine: Bool
        var didPlayerWasFamine: Bool
    }
}
