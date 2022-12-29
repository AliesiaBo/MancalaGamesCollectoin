//
//  GameViewController.swift
//  Kalah
//
//  Created by Aliesia Borzik on 30.12.2021.
//

//Coming soon...
//_Start

//_End

import UIKit
import CoreData

class KalahGameViewController: MancalaModel, KalahRulesDeclaration, CoreDataManagerForMancala, BoardCupsAndGameLogicController {

    @IBOutlet var allHoles: [UIButton]!
    
    @IBOutlet weak var cupstorage1: UIButton!
    @IBOutlet weak var cupstorage2: UIButton!
    @IBOutlet weak var cakeButton: UIButton!
    
    @IBOutlet weak var nameplate1: UIButton!
    @IBOutlet weak var nameplate2: UIButton!
    
    //MARK: - View Load Manipulating
    
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
    
    deinit { print("KalahGameViewController removed from memory") }
    
    //MARK: - Create New Game
    
    func fullCreatingNewGame() {
        //only once
        didFamineRuleUsed = false
        loadGameSettings()
        setRightDirrection()
        //many times
        createNewGame()
    }
    
    func createNewGame() {
        playerNames.shuffle()
        setNameInNameplate()
        
        numOfMove = 0
        
        cakeButton.alpha = didCakeRuleUsed ? 0.3 : 0
        
        isFirstPlayerMoving = true
        updateRotation()
        
        didMoveEnds = true
        didMoveAlreadyCreated = false
        didGameEnds = false
        firstHoleSender = nil
        
        scatterOfPebbles == K.S.random ?
        createGivenCups(key: createRandomKey(num: 72, cups: 12)) :
        createNewStandartCups()
        
        saveBeginningPosition()
        showWhoMovingNow()
    }
    
    //MARK: - Moving Algoritms
    
    @IBAction func holePressed(_ sender: UIButton) {
        guard didGameEnds == false else { return }
        if numberOfAttems == "Many" || didMoveEnds {
            firstHoleSender = sender
            
            didMoveIsPossible() ?
            moveIsPossible() :
            moveIsImpossible()
        }
    }
    
    func longMoving() {
        didMoveEnds = false
        didMoveAlreadyCreated = false
        
        if travelDirrection == K.S.cross
        {
            if firstHoleSender!.score() % 2 == 1 { //odd num - clockwise
                move = createNormalMove()
            }
            if firstHoleSender!.score() % 2 == 0 { //even num - anticlockwise
                move = createReversedMove()
            }
        } else {
            move = createNormalMove()
        }
        
        if move.count == 0 { return }
        timerCount = 0
        pressedHolePebbles = 0
        
        timer = Timer.scheduledTimer(timeInterval: TInterval, target: self, selector: #selector(self.movingTimer), userInfo: nil, repeats: true)
    }
    
    @objc func movingTimer() {
        if timerCount == move.count {
            firstHoleSender?.setAttributedTitle(cupTitle("\(pressedHolePebbles)"), for: .normal)
            
            didMoveEnds = true
            didMoveAlreadyCreated = true
            timer.invalidate()

            if numberOfAttems == "One" { makeMovePressed() }
            return
        }
        
        guard let hole = allHoles.first(where: { $0.tag == move[timerCount] }) else { return }
        let a = hole.score()
        
        firstHoleSender?.setAttributedTitle(cupTitle(String(move.count - timerCount - 1)), for: .normal)
        
        if hole.tag != firstHoleSender?.tag { hole.setAttributedTitle(cupTitle(String(a+1)), for: .normal) }
        if hole.tag == firstHoleSender?.tag { pressedHolePebbles += 1 }
        timerCount += 1
    }
    
    //MARK: - Head Navigation / Make Move
    
    @IBAction func makeMovePressed(_ sender: UIButton? = nil) {
        guard
            didMoveEnds != false,
            didMoveAlreadyCreated == true
        else { return }
        numOfMove += 1
        
        if didLastPebbleInYourEmptyHoleRuleValid() {
            lastHoleSender?.setAttributedTitle(cupTitle("0"), for: .normal)
            lastPebbleInEmptyHoleRuleIsValid()
        }
        
        if didHalfEmptyHolesRuleIsValid() {
            collectingAllOwnSeeds()
            halfEmptyHolesRuleIsValid()
            endGame()
            return
        }
        
        didYourStorageRuleValid() ? isFirstPlayerMoving.toggle() : nil
        
        if didCakeRuleUsed { cakeButton.alpha = numOfMove == 1 ? 1 : 0.3 }
        
        isFirstPlayerMoving.toggle()
        movingPlayerHolesActive()
        
        didMoveAlreadyCreated = false
        firstHoleSender = nil
        move = []
        saveBeginningPosition()
        
        didChangeRotationForSecondPlayer ? updateRotation() : nil
        
        showWhoMovingNow()
    }
    
    //MARK: - Almost The Same Code In Games
    //MARK: - Optional Rule: Cake Rule
    
    @IBAction func cakeMovingPressed(_ sender: UIButton)
    { cakeMovingPressedLogic() }
    
    //MARK: - Restart
    
    @IBAction func restartPressed(_ sender: UIButton) {
        if !didMoveEnds { return }
        showActionAlert(title: K.T.restartTitle, message: "") { UIAlertAction in
            self.timer.invalidate()
            self.createNewGame()
        }
    }
    
    //MARK: - Return To Menu
    
    @IBAction func returnToMenuPressed(_ sender: UIButton)
    { returnToMenuPressedLogic() }

    //MARK: - Manual Ending Game
    
    @IBAction func manualEndingGamePressed(_ sender: UIButton)
    { manualEndingGamePressedLogic() }
    
    //MARK: - Nameplates
    
    @IBAction func nameplatePressed(_ sender: UIButton)
    { nameplatePressedLogic(tag: sender.tag) }
} //411


