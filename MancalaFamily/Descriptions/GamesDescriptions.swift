//
//  MancalaGamesDescriptions.swift
//  Kalah
//
//  Created by Aliesia Borzik on 17.05.2022.
//

import UIKit

protocol KalahRulesDeclaration:
    CakeRule,
    HalfEmptyHolesRule,
    LastPebbleInYourEmptyHoleRule,
    YourKalahRule
{}

protocol OwareRulesDeclaration:
    CakeRule,
    FamineRule,
    HalfEmptyHolesRule, EmptyAllHolesRule,
    LastPebbleInYourEmptyHoleRule,
    YourKalahRule
{}

protocol CongkakRulesDeclaration:
    CakeRule,
    HalfEmptyHolesRule,
    LastPebbleInAnyEmptyHoleRule,
    YourKalahRule
{}

protocol DakonRulesDeclaration:
    CakeRule,
    LastPebbleInYourEmptyHoleRule,
    HalfEmptyHolesRule,
    YourKalahRule,
    PebblesBehindHoleRule
{}

protocol PallanguzhiRulesDeclaration:
    CakeRule,
    LastPebbleInAnyEmptyHoleRule
{}

