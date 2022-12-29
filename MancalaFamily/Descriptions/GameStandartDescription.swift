//
//  GameStandartsDescription.swift
//  Kalah
//
//  Created by Aliesia Borzik on 06.09.2022.
//

import UIKit

protocol MancalaGameStandarts: MancalaLogicValuesStandart, MancalaPlayerStandarts, HolesInitDeclaration, BoardGameStandarts {}

protocol MancalaLogicValuesStandart: AnyObject {
    
    var move: [Int] { get set }
    var skip: [Int] { get }
    var changeableSkip: [Int] { get set }
    var numOfMove: Int { get set }

    var firstPlayerHoles: [Int] { get set }
    var secondPlayerHoles: [Int] { get set }
    
    //soon
    //for continue game when someone win and looser continue with his collected pebbles
    //not work if random scatter of pebbles
//    var changedPlayerHoles1: [Int] { get }
//    var changedPlayerHoles2: [Int] { get }
    //or
    //var changeableSkip: [Int] { get set }
    
    var gameName: String { get set }
    var savingKey: String { get }
    var savedKey: String { get set }
    var savedPosition: [Int] { get set }
    
    var didMoveEnds: Bool { get set }
    var didGameEnds: Bool { get set }
    var didMoveAlreadyCreated: Bool { get set }
    
    var didCaptureAllowed: Bool { get set }
    var didPlayerFamine: Bool { get set }
    var didPlayerWasFamine: Bool { get set }
    
    var didCakeRuleUsed: Bool { get set }
    var didChangeRotationForSecondPlayer: Bool { get set }
    var numberOfAttems: String { get set }
    var scatterOfPebbles: String { get set }
    var didFamineRuleUsed: Bool { get set }
    
    ///The way where pebbles will put.
    ///
    ///In each game travel dirrection is different. Here short declaration of default dirrection of cups tags.
    ///- Parameters:
    /// - Kalah - anticlockwise.
    /// - Oware - anticlockwise.
    /// - Congkak - clockwise.
    /// - Dakon - clockwise.
    /// - Pallanguzhi - ???.
    var travelDirrection: String { get set }
    
}

protocol BoardGameStandarts: AnyObject {
    
    var allHoles: [UIButton]! { get set }
    var cupstorage1: UIButton! { get set }
    var cupstorage2: UIButton! { get set }
    var cakeButton: UIButton! { get set }
    
}

protocol HolesInitDeclaration {
    
    var firstHoleSender: UIButton? { get set }
    var lastHoleSender: UIButton? { get }
    var oppositeHoleSender: UIButton? { get }
    var nextHoleSender: UIButton? { get }
    var throughOneHoleSender: UIButton? { get }
    
    var lastHoleTag: Int { get }
    var firstHoleTag: Int { get }
    
    var cupstorage1Score: Int { get }
    var cupstorage2Score: Int { get }
}

protocol MancalaPlayerStandarts: UIViewController  {
    var playerNames: [String] { get set }
    var isFirstPlayerMoving: Bool { get set }
    var isSecondPlayerMoving: Bool { get }
    
    var nameplate1: UIButton! { get set }
    var nameplate2: UIButton! { get set }
    
    func showWhoMovingNow()
}
