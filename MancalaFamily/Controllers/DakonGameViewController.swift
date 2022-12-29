//
//  DakonGameViewController.swift
//  Kalah
//
//  Created by Aliesia Borzik on 21.04.2022.
//

import UIKit
import CoreData

class DakonGameViewController: MancalaModel, DakonRulesDeclaration, CoreDataManagerForMancala, BoardCupsAndGameLogicController {

    @IBOutlet var allHoles: [UIButton]!
    
    @IBOutlet weak var cupstorage1: UIButton!
    @IBOutlet weak var cupstorage2: UIButton!
    @IBOutlet weak var cakeButton: UIButton!
    
    @IBOutlet weak var nameplate1: UIButton!
    @IBOutlet weak var nameplate2: UIButton!
    
    //MARK: - View Manipulating
    
    override func viewDidAppear(_ animated: Bool) {
        if didActiveSave() {
            showTwoOptionsAlert(headTitle: "Here's save!", message: "Do you want load last save? If you start new game, you're lost it", noActionTitle: "Quit", action1Title: "Load", action2Title: "New Game") { UIAlertAction in
                //load saved game
                self.loadSavedGame()
                self.context.delete(self.contextGameName!)
                
            } doAction2: { UIAlertAction in
                //Creating new game
                //firstly deletingSave
                self.context.delete(self.contextGameName!)
                //create new game
                self.fullCreatingNewGame()
            }
            return
        }
        fullCreatingNewGame()
    }
    
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            self.setNameInNameplate()
            self.updateHolesWithoutChanging()
        }
    }
    
    deinit { print("DakonGameViewController removed from memory") }
    
    //MARK: - Update/End Game
    
    func fullCreatingNewGame() {
        didFamineRuleUsed = false
        loadGameSettings()
        travelDirrection == "Clockwise" ? reverseCupsTags() : nil
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
        didGameEnds = false
        firstHoleSender = nil
        
        createNewStandartCups()
        
        saveBeginningPosition()
        showWhoMovingNow()
    }
    
    //MARK: - Load Saved Game
    
    func loadSavedGame() {
        
        //Loading Data for current game
        guard
            let loadedPlayerData = tryFetchDataForCurrentGame(with: PlayerParameters.fetchRequest()),
            let loadedGameData = tryFetchDataForCurrentGame(with: GameParameters.fetchRequest()),
            let loadedOtherData = tryFetchDataForCurrentGame(with: OtherParameters.fetchRequest())
        else {
            showErrorAlert()
            createNewGame()
            return
        }
        
        //working with loaded data
        //_Start
        //init saved data
        //loaded GameData
        //if saved key is empty, create new game
        savedKey = loadedGameData.gameKey ?? ""
        if savedKey == "" {
            showErrorAlert()
            createNewGame()
            return
        }
        numOfMove = Int(loadedGameData.attemps ?? "2") ?? 2
        
        //loaded PlayerData
        isFirstPlayerMoving = loadedPlayerData.isFPM
        playerNames = [loadedPlayerData.playerName1 ?? "Player1", loadedPlayerData.playerName2 ?? "Player2"]
        setNameInNameplate()
        
        //loaded OtherData
        didCakeRuleUsed = loadedOtherData.didCakeRuleUsed
        didChangeRotationForSecondPlayer = loadedOtherData.didChangeRotationForSecondPlayer
        numberOfAttems = loadedOtherData.numOfAttemps ?? "Many" //soon
        didFamineRuleUsed = loadedOtherData.didFamineModeUsed  //soon
        travelDirrection = loadedOtherData.travelDirrection ?? "Standart"  //soon
        //data loaded, so
        //update UI and show alerts like in createNewGame
        
        loadSavedCups()
        saveBeginningPosition()
        
        didChangeRotationForSecondPlayer ? updateRotation() : nil
        if didCakeRuleUsed { cakeButton.alpha = numOfMove == 1 ? 1 : 0.3 }
        travelDirrection == "Clockwise" ? reverseCupsTags() : nil
        
        didMoveEnds = true
        firstHoleSender = nil
        
        showWhoMovingNow()
        //_End
    }
    
    //MARK: - Moving Algoritm
    @IBAction func holePressed(_ sender: UIButton) {
        guard didGameEnds == false else { return }
        firstHoleSender = sender
        didMoveIsPossible() ?
            moveIsPossible() :
            moveIsImpossible()
    }
    
    ///Gradual Transfer Of Seeds
    func longMoving() {
        didMoveEnds = false
        
        move = createNormalMove()
        if move.count == 0 { return }
        
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
    

    
    //MARK: - Head Navigation
    
    @IBAction func makeMovePressed(_ sender: UIButton) {
        
        if didMoveEnds == false { return }
        if firstHoleSender == nil { return }
        
        numOfMove += 1
        
        if didLastPebbleInYourEmptyHoleRuleValid() {
            lastPebbleInEmptyHoleRuleIsValid()
        }
        
        if didPebblesBehindHoleRuleIsValid() {
            pebblesBehindHoleRuleIsValid()
        }
        
        if didHalfEmptyHolesRuleIsValid() {
            halfEmptyHolesRuleIsValid()
            endGame()
            return
        }
        
        if didMoveEnds == false { return }
        
        if didYourStorageRuleValid() {
            isFirstPlayerMoving.toggle()
        }
        
        if didCakeRuleUsed { cakeButton.alpha = numOfMove == 1 ? 1 : 0.3 }
        
        isFirstPlayerMoving.toggle()
        movingPlayerHolesActive()
        
        firstHoleSender = nil
        saveBeginningPosition()
        
        let headTitle = isFirstPlayerMoving ? "\(playerNames[0]) Moving" : "\(playerNames[1]) Moving"
        showInfoAlert(title: headTitle, message: "", titleAction: "Okay")
    }
    
    //MARK: - Almost The Same Code In Games
    //MARK: - Optional Rule: Cake Rule
    
    @IBAction func cakeMovingPressed(_ sender: UIButton)
    { cakeMovingPressedLogic() }

    //MARK: - Restart
    
    @IBAction func restartPressed(_ sender: UIButton) {
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
    
    @IBAction func nameplatePressed(_ sender: UIButton)
    { nameplatePressedLogic(tag: sender.tag) }
}
