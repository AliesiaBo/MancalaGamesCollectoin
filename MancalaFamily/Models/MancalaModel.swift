//
//  MancalaModel.swift
//  MancalaFamily
//
//  Created by Aliesia Borzik on 04.10.2022.
//

import UIKit
import CoreData

class MancalaModel: UIViewController {
        
    var gameName: String = "Kalah"
    var playerNames: [String] = ["Player1", "Player2"]
    
    var isFirstPlayerMoving = true
    var isSecondPlayerMoving: Bool { return !isFirstPlayerMoving }
    
    var firstHoleSender: UIButton?
    var move: [Int] = []
    var numOfMove = 0
    var changeableSkip: [Int] = []
    var firstPlayerHoles: [Int] = []
    var secondPlayerHoles: [Int] = []
    
    var savedPosition: [Int] = []
    var savedKey: String = ""
    
    var didMoveEnds = true
    var didGameEnds = false
    var didMoveAlreadyCreated = false
    var isFirstMove = false
    
    var timer = Timer()
    var timerCount = 0
    var pressedHolePebbles = 0
    var TInterval: Double = 0.33
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK: - Settings Changes / Other Parameters
    
    var didCakeRuleUsed = true //realised
    var didChangeRotationForSecondPlayer = false //realised
    var numberOfAttems = "Many" //realised
    var didFamineRuleUsed = false //not realised for all games
    
    ///The way where pebbles will put.
    ///
    ///In each game travel dirrection is different. Here short declaration of default dirrection of cups tags.
    ///- Parameters:
    /// - Kalah - anticlockwise.
    /// - Oware - anticlockwise.
    /// - Congkak - clockwise.
    /// - Dakon - clockwise.
    /// - Pallanguzhi - ???.
    var travelDirrection = "Standart" //realised
    var scatterOfPebbles = "Equable" //realised
    
    //MARK: - Famine Rule Values
    
    var didCaptureAllowed = true
    var didPlayerFamine = false
    var didPlayerWasFamine = false
    
    //MARK: - Other
    var fontName: String = ""
    var numberOfPebbles: String = ""
}
