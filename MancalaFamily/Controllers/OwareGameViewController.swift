//
//  OwareGameViewController.swift
//  Kalah
//
//  Created by Aliesia Borzik on 05.04.2022.
//

import UIKit
import CoreData

class OwareGameViewController: MancalaModel, OwareRulesDeclaration, CoreDataManagerForMancala, BoardCupsAndGameLogicController {
    
    @IBOutlet var allHoles: [UIButton]!
    @IBOutlet var holes: [UIButton]!
    
    @IBOutlet weak var cupstorage1: UIButton!
    @IBOutlet weak var cupstorage2: UIButton!
    @IBOutlet weak var cakeButton: UIButton!
    
    @IBOutlet weak var nameplate1: UIButton!
    @IBOutlet weak var nameplate2: UIButton!
    
    //MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        firstUpdateGameLogic()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            self.setNameInNameplate()
            self.updateHolesWithoutChanging()
        }
    }
    
    deinit { print("OwareGameViewController removed from memory") }
    
    //MARK: - Create New Game
    
    func fullCreatingNewGame() {
        didFamineRuleUsed = true
        loadGameSettings()
        travelDirrection == "Clockwise" ? reverseCupsTags() : nil
        createNewGame()
    }
    
    func createNewGame() {
        playerNames.shuffle()
        setNameInNameplate()
        
        numOfMove = 0
        cakeButton.alpha = didCakeRuleUsed ? 0.5 : 0
        
        isFirstPlayerMoving = true
        
        didMoveEnds = true
        didGameEnds = false
        
        firstHoleSender = nil
        
        scatterOfPebbles == K.S.random ?
        createGivenCups(key: createRandomKey(num: 72, cups: 12)) : createNewStandartCups()
        
        saveBeginningPosition()
        showWhoMovingNow()
    }
    
    //MARK: - Moving Algoritm
    
    @IBAction func HolePressed(_ sender: UIButton) {
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
        print("start moving")
        
        guard let td = TravelDirrection(rawValue: travelDirrection) else { return }
        switch td {
        case .Standart:
            move = createNormalMove()
        case .Cross:
            if firstHoleSender!.score() % 2 == 1 { //odd num - clockwise
                move = createNormalMove()
            }
            if firstHoleSender!.score() % 2 == 0 { //even num - anticlockwise
                move = createReversedMove()
            }
        case .Clockwise:
            move = createNormalMove() //cause reverse cups
        case .Anticlockwise:
            move = createNormalMove()
        }
        
        if move.count == 0 { return }
        timerCount = 0

        timer = Timer.scheduledTimer(timeInterval: TInterval, target: self, selector: #selector(self.movingTimer), userInfo: nil, repeats: true)
    }
    
    @objc func movingTimer() {
        if timerCount == move.count {
            firstHoleSender?.setAttributedTitle(cupTitle("0"), for: .normal)
            didMoveEnds = true
            timer.invalidate()
            print("end moving")
            return
        }
        
        guard let hole = allHoles.first(where: { $0.tag == move[timerCount] })
        else { return }
        
        let a = hole.score()
        
        firstHoleSender?.setAttributedTitle(cupTitle(String(move.count - timerCount - 1)), for: .normal)

        hole.setAttributedTitle(cupTitle(String(a+1)), for: .normal)
        timerCount += 1
    }
    
    func fastMoving() {
        print("no seed capture")
        if move.count == 0 { return }
        
        for n in 0...move.count {
            if n == move.count {
                firstHoleSender?.setAttributedTitle(cupTitle("0"), for: .normal)
                return
            }
            
            guard let hole = holes.first(where: {$0.tag == move[n]}),
                  let a = hole.currentAttributedTitle?.string,
                  let b = Int(a) else { continue } //num of pebbles in pressedHole
            
            firstHoleSender?.setAttributedTitle(cupTitle(String(move.count - n - 1)), for: .normal)
            if hole.tag != firstHoleSender!.tag { hole.setAttributedTitle(cupTitle(String(b+1)), for: .normal) }
            break
        }
    }
    
    //MARK: - First Rule: Seed Capture
    
    func didSeedCaptureIsPossible() -> Bool {
        guard let a = lastHoleSender?.currentAttributedTitle?.string else { return false }
        if ["2", "3"].contains(a) &&
            (isFirstPlayerMoving && secondPlayerHoles.contains(lastHoleTag) ||
             isSecondPlayerMoving && firstPlayerHoles.contains(lastHoleTag)) {
            return true
        }
        return false
    }
    
    func seedCaptureIsPossible() {
        guard let a = lastHoleSender?.currentAttributedTitle?.string else { return }
        var pebbles: Int = Int(a)!

        lastHoleSender?.setAttributedTitle(cupTitle("0"), for: .normal)
        !skip.contains(lastHoleTag) ? checkPreviousHoles(&pebbles) : nil
        // if fpm [12, 11, 10, 9, 8, 7] ->
        // if spm [6, 5, 4, 3, 2, 1] ->
        pebbles += isFirstPlayerMoving ? cupstorage1Score : cupstorage2Score

        isFirstPlayerMoving ?
        cupstorage1.setAttributedTitle(cupTitle(String(pebbles)), for: .normal) :
        cupstorage2.setAttributedTitle(cupTitle(String(pebbles)), for: .normal)
    }
    
    func checkPreviousHoles(_ pebbles: inout Int) {
        let previousHoles = isFirstPlayerMoving ?
        secondPlayerHoles.filter {($0 < lastHoleTag) && ($0 >= 7)} :
        firstPlayerHoles.filter {($0 < lastHoleTag) && ($0 >= 1)}
        
        for n in previousHoles {
            guard let hole = holes.first(where: { $0.tag == n }),
                  let b = hole.currentAttributedTitle?.string,
                  ["2", "3"].contains(b)
            else { return }
            
            pebbles += Int(b)!
            hole.setAttributedTitle(cupTitle("0"), for: .normal)
        }
    }
    
    //MARK: - Second Rule: Ban On Total Seed Capture
    ///Ban On Total Seed Capture.
    func didSeedCaptureIsAllow() -> Bool {
        var checkingNum = 0
        if isFirstPlayerMoving {
            for hole in holes {
                /*If player1 capture all opponent seeds, he should set other move.*/
                if !secondPlayerHoles.contains(hole.tag) { continue }
                checkingNum += hole.score() == 0 ? 1 : 0
            }
        } else {
            for hole in holes {
                if !firstPlayerHoles.contains(hole.tag) { continue }
                checkingNum += hole.score() == 0 ? 1 : 0
            }
        }
        return checkingNum == 6
    }
    
    func seedCaptureNotAllow() {
        didCaptureAllowed = false
        returnBegginingPosition()
        let title = "You can't capture all opponents seeds!"
        let mes = "Continue game without capture or try other way?"
        
        showTwoOptionsAlert(headTitle: title, message: mes, noActionTitle: "What?", action1Title: "Try other way", action2Title: "Continue") { UIAlertAction in
            //return beggining position already done
        } doAction2: { [self] UIAlertAction in
            fastMoving()
        }
    }
    
    //MARK: - Optional Rule: Cake Rule
    
    @IBAction func cakeMovingPressed(_ sender: UIButton)
    { cakeMovingPressedLogic() }
    
    //MARK: - Checking SeedCapture Rule
    func checkingSeedCaptureRule() {
        didSeedCaptureIsPossible() ? seedCaptureIsPossible() : nil
        didSeedCaptureIsAllow() ? seedCaptureNotAllow() : nil
        // If player could capture all seeds, capture don't allows but game is still going
    }
    
    //MARK: - Head Navigation
    
    @IBAction func makeMovePressed(_ sender: UIButton) {
        
        defer { firstHoleSender = nil; move = [] }
        
        if !didMoveEnds { return }
        if firstHoleSender == nil { return }
        
        didCaptureAllowed = true
        
        if didEmptyAllHolesRuleIsValid() { endGame(); return }
        
        // Check if moving player put the seed to famine player.
        // Don't run if moving player spend all seeds and now don't have them (EmptyAllHolesRule)
        // Not needed in seed capture checking!!! (if seeds don't go around???!!!)
        if didPlayerFamine {
            didPlayerFamine = didPlayerStillFamine()
            
            if didPlayerFamine {
                playerIsStillFamineWarning()
                returnBegginingPosition()
                return
            }
            didPlayerWasFamine = true
            checkingSeedCaptureRule()
        }
        
        if didPlayerWasFamine == false { //(3) and skip this too. I don't think seeds go around, do it? Or don't...
            checkingSeedCaptureRule()
            if didEmptyAllHolesRuleIsValid() { endGame(); return }
        }
        
        didPlayerFamine = IsPlayerFamineNow()
        didPlayerFamine ? playerIsFamineNowWarning() : nil
        didPlayerWasFamine = false
        
        turnPassesToTheNextPlayer()
    }
    
    func turnPassesToTheNextPlayer() {
        isFirstPlayerMoving.toggle()
        movingPlayerHolesActive()
        numOfMove += 1
        if didCakeRuleUsed { cakeButton.alpha = numOfMove == 1 ? 1 : 0.3 }
        
        didChangeRotationForSecondPlayer ?
        updateRotation() : nil
        
        saveBeginningPosition()
        showWhoMovingNow()
    }
    
    @IBAction func restartPressed(_ sender: UIButton) {
        if !didMoveEnds { return }
        showActionAlert(title: K.T.restartTitle, message: "") { UIAlertAction in
            self.timer.invalidate()
            self.createNewGame()
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
} //409

