//
//  CongkakGameViewController.swift
//  Kalah
//
//  Created by Aliesia Borzik on 11.04.2022.
//

import UIKit
import CoreData

class CongkakGameViewController: MancalaModel, CongkakRulesDeclaration, CoreDataManagerForMancala, BoardCupsAndGameLogicController  {
    
    @IBOutlet var allHoles: [UIButton]!
    
    @IBOutlet weak var cupstorage1: UIButton!
    @IBOutlet weak var cupstorage2: UIButton!
    @IBOutlet weak var cakeButton: UIButton!
    
    @IBOutlet weak var nameplate1: UIButton!
    @IBOutlet weak var nameplate2: UIButton!
    
    var choosenHole1: UIButton?
    var choosenHole2: UIButton?
    
    //MARK: - View Manipulating
    
    override func viewDidAppear(_ animated: Bool) {
        firstUpdateGameLogic()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            self.setNameInNameplate()
            self.updateHolesWithoutChanging()
        }
    }
    
    deinit { print("CongkakGameViewController removed from memory") }
    
    //MARK: - Load Game Settings
    
    func fullCreatingNewGame() {
        didFamineRuleUsed = false
        loadGameSettings()
        travelDirrection == "Anticlockwise" ? reverseCupsTags() : nil
        if scatterOfPebbles == K.S.random {
            isFirstMove = false
            createNewGame_part1()
            createNewGame_part2()
            return
        }
        createNewGame_part1()
    }
    
    //MARK: - Update/End Game
    
    func createNewGame_part1() {
        playerNames.shuffle()
        setNameInNameplate()
        
        numOfMove = 0
        
        if scatterOfPebbles == K.S.random {
            createGivenCups(key: createRandomKey(num: 49, cups: 7) )
            showInfoAlert(title: K.T.noSynchMove, message: K.M.noFirstSynchMoveMessage, titleAction: "Ok")
        } else {
            createNewStandartCups()
            showInfoAlert(title: "Move together", message: "Both players choosing the cups, then the game beggining", titleAction: "Ok")
        }
        
        cakeButton.alpha = didCakeRuleUsed ? 0.5 : 0
        
        choosenHole1?.tintColor = .white
        choosenHole2?.tintColor = .white
        
        choosenHole2 = nil
        choosenHole1 = nil
    }
    
    func createNewGame_part2() {
        isFirstPlayerMoving = true
        
        choosenHole1?.tintColor = .white
        choosenHole2?.tintColor = .white
        
        if didCakeRuleUsed { cakeButton.alpha = numOfMove == 1 ? 1 : 0.3 }
        
        didMoveEnds = true
        firstHoleSender = nil
        
        saveBeginningPosition()
        showWhoMovingNow()
    }
    
    //MARK: - Moving Algoritm
    @IBAction func holePressed(_ sender: UIButton) {
        guard didGameEnds == false else { return }
        firstHoleSender = sender
        if !isFirstMove {
            if numberOfAttems == "Many" || didMoveEnds {
                didMoveIsPossible() ?
                moveIsPossible() :
                moveIsImpossible()
                return
            }
            return
        }
        
        firstSynchronousMove()
    }
    
    func firstSynchronousMove() {
        firstPlayerHoles.contains(firstHoleTag) ?
        whenFirstPlayerChooseHole() :
        whenSecondPlayerChooseHole()
    }
    
    func whenFirstPlayerChooseHole() {
        if choosenHole1 != nil {
            print("change hole1")
            choosenHole1?.tintColor = .white
        }
        
        firstHoleSender?.tintColor = .orange
        choosenHole1 = firstHoleSender
    }
    
    func whenSecondPlayerChooseHole() {
        if choosenHole2 != nil {
            print("change hole2")
            choosenHole2?.tintColor = .white
        }
        firstHoleSender?.tintColor = .orange
        choosenHole2 = firstHoleSender
    }
    
    func onceMoving(from choosenHole: UIButton) {
        
        firstHoleSender = choosenHole
        move = createNormalMove()
        
        if move.count == 0 { print("no move"); return }
        if move.count > 7 { move.remove(at: 7) }
        
        for n in 0..<move.count {
            guard let hole = allHoles.first(where: {$0.tag == move[n]})
            else {
                print("can't find hole")
                continue
            }
            
            let a = hole.score()//num of pebbles in nextHoles
            if hole.tag != choosenHole.tag { hole.setAttributedTitle(cupTitle(String(a+1)), for: .normal) }
            
            if n == move.count - 1 {
                print("end move")
                let peb = choosenHole.score()
                choosenHole.setAttributedTitle(cupTitle("\(peb - move.count)"), for: .normal)
            }
        }
    } 
    
    ///Gradual Transfer Of Seeds
    func longMoving() {
        didMoveEnds = false
        print("start moving")
        
        move = createNormalMove()
        if move.count == 0 { return }
        
        timerCount = 0
        pressedHolePebbles = 0
        
        print(move)
        timer = Timer.scheduledTimer(timeInterval: TInterval, target: self, selector: #selector(self.movingTimer), userInfo: nil, repeats: true)
    }
    
    @objc func movingTimer() {
        if timerCount == move.count {
            firstHoleSender!.setAttributedTitle(cupTitle("\(pressedHolePebbles)"), for: .normal)
            
            if lastHoleSender!.score() == 1 || [8,16].contains(lastHoleSender?.tag) {
                print("End moving")
                didMoveEnds = true
                timer.invalidate()
                return
                
            } else {
                print("Rele. Continue")
                firstHoleSender = lastHoleSender!  //change firstHoleSender
                move = createNormalMove() //create new move
                if move.count == 0 {
                    didMoveEnds = true
                    timer.invalidate()
                    return
                }
                print(move)
                timerCount = 0
                pressedHolePebbles = 0
            }
        }
        
        guard let hole = allHoles.first(where: { $0.tag == move[timerCount] }) else { return }
        let a = hole.score() //num of pebbles in next holes
        
        firstHoleSender!.setAttributedTitle(cupTitle(String(move.count - timerCount - 1)), for: .normal)
        if hole.tag != firstHoleTag { hole.setAttributedTitle(cupTitle(String(a+1)), for: .normal) }
        if hole.tag == firstHoleTag { pressedHolePebbles += 1 }
        timerCount += 1
    }
    
    //MARK: - Optional Rule: Cake Rule
    
    @IBAction func cakeMovingPressed(_ sender: UIButton) {
        if !didMoveEnds { return }
        returnBegginingPosition()
        firstHoleSender = nil
        cakeRule()
        saveBeginningPosition()
        
        isFirstPlayerMoving.toggle()
        movingPlayerHolesActive()
        
        cakeButton.alpha = 0.3
        numOfMove += 1
    }
    
    //MARK: - Move Pressed Functions
    
    func normalMove() {
        if !didMoveEnds { return }
        if firstHoleSender == nil { return }
        
        numOfMove += 1
        
        if didLastPebbleInAnyEmptyHoleRuleValid() {
            lastPebbleInEmptyHoleRuleIsValid()
        }
        
        if didHalfEmptyHolesRuleIsValid() {
            halfEmptyHolesRuleIsValid()
            endGame()
            return
        }
        
        if didYourStorageRuleValid() {
            isFirstPlayerMoving.toggle()
        }
        
        didCakeRuleUsed ? (cakeButton.alpha = numOfMove == 1 ? 1 : 0.3) : nil
        
        isFirstPlayerMoving.toggle()
        movingPlayerHolesActive()
        
        firstHoleSender = nil
        saveBeginningPosition()
        
        showWhoMovingNow()
    }
    
    func firstMove() {
        guard let hole1 = choosenHole1,
              let hole2 = choosenHole2 else {
                  showInfoAlert(title: "You choose not enough cups", message: "", titleAction: "Ok")
                  print("not enough holes")
                  return
              }
        print("first move")
        
        onceMoving(from: hole1)
        onceMoving(from: hole2)
        
        choosenHole1?.tintColor = .white
        choosenHole2?.tintColor = .white
        
        isFirstMove = false
        numOfMove = 1
    }
    
    //MARK: - Head Navigation
    
    @IBAction func makeMovePressed(_ : UIButton) {
        if !isFirstMove {
            normalMove()
            return
        }
        firstMove()
        createNewGame_part2()
    }
    
    @IBAction func restartPressed(_ sender: UIButton) {
        if !didMoveEnds { return }
        showActionAlert(title: K.T.restartTitle, message: "") { UIAlertAction in
            self.timer.invalidate()
            self.createNewGame_part1()
        }
    }
    
    @IBAction func returnToMenuPressed(_ sender: UIButton) {
        returnToMenuPressedLogic()
    }
    
    @IBAction func manualEndingGamePressed(_ sender: UIButton) {
        manualEndingGamePressedLogic()
    }
    
    @IBAction func nameplatePressed(_ sender: UIButton) {
        nameplatePressedLogic(tag: sender.tag)
    }
}
