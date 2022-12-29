//
//  PallanguzhiGameViewController.swift
//  Kalah
//
//  Created by Aliesia Borzik on 22.04.2022.
//

import UIKit
import CoreData

//no hunger rule
//but if moving player have no pebbles - move comes to other player
//so he can do move some times, until opponent have no seeds

class PallanguzhiGameViewController: MancalaModel, PallanguzhiRulesDeclaration,  CoreDataManagerForMancala, BoardCupsAndGameLogicController {
    
    @IBOutlet var allHoles: [UIButton]!
    @IBOutlet var holes: [UIButton]!
    
    @IBOutlet weak var cupstorage1: UIButton!
    @IBOutlet weak var cupstorage2: UIButton!
    @IBOutlet weak var cakeButton: UIButton!
    
    @IBOutlet weak var nameplate1: UIButton!
    @IBOutlet weak var nameplate2: UIButton!
    
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
    
    deinit { print("PallanguzhiGameViewController removed from memory") }
    
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
        if didCakeRuleUsed {
            cakeButton.alpha = numOfMove == 1 ? 1 : 0.3
        }
        
        isFirstPlayerMoving = true
        
        didMoveEnds = true
        firstHoleSender = nil
        
        createNewStandartCups()
        setExtraHoles()
        
        saveBeginningPosition()
        showWhoMovingNow()
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
        if move.count == 0 {
            print("Error, \(#function), \(#line)")
            return
        }
        
        timer = Timer.scheduledTimer(timeInterval: TInterval, target: self, selector: #selector(self.movingTimer), userInfo: nil, repeats: true)
    }
    
    @objc func movingTimer() {
        if timerCount == move.count {
            firstHoleSender!.setAttributedTitle(cupTitle("\(pressedHolePebbles)"), for: .normal)
            
            //Interim Rules
            if didSixPebblesInHoleRuleValid() { sixPebblesInHoleRuleIsValid()
                if [7, 15].contains(lastHoleTag) {
                    print("End moving")
                    didMoveEnds = true
                    timer.invalidate()
                    return
                }
            }
            
            if didLastPebbleInAnyEmptyHoleRuleValid() {
                if nextHoleSender?.score() != 0 {
                    //1 condition
                    //change firstHoleSender if next hole not empty
                    firstHoleSender = nextHoleSender
                }
                else if nextHoleSender?.score() == 0 &&
                   throughOneHoleSender?.score() != 0 {
                    //2 condition
                    nextHoleIsEmptyRuleIsValid()
                    //change firstHoleSender if hole through one not empty
                    //Need to check .score(), cause it possible there 0 pebbles. Then try to check next hole and select it!!!
                    firstHoleSender = throughTwoHoleSender
                    //continue
                }
                else if nextHoleSender?.score() == 0 &&
                        throughOneHoleSender?.score() == 0 {
                    //3 condition
                    print("End moving")
                    didMoveEnds = true
                    timer.invalidate()
                    return
                }
            } else {
                //change firstHoleSender if next hole not empty
                //Need to check .score(), cause it possible there 0 pebbles!!!
                guard let nextNotEmptyHole = findingNextNotEmptyHole() else {
                    print("End moving")
                    didMoveEnds = true
                    timer.invalidate()
                    return
                }
                firstHoleSender = nextNotEmptyHole
            }
            
            print("Rele. Continue")
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
        
        //not end code
        func findingNextNotEmptyHole() -> UIButton? {
            let nextHole = firstHoleTag
            
            for n in 1...12 {
                guard let nextHoleS = allHoles.first(where: { $0.tag == nextHole + n
                }) else { continue }
                
                return nextHoleS
            }
                    
            return nil
        }
        
        guard let hole = allHoles.first(where: { $0.tag == move[timerCount] }) else { return }
        let score = hole.score()
        
        firstHoleSender!.setAttributedTitle(cupTitle(String(move.count - timerCount - 1)), for: .normal)
        if hole.tag != firstHoleTag { hole.setAttributedTitle(cupTitle("\(score+1)"), for: .normal) }
        if hole.tag == firstHoleTag { pressedHolePebbles += 1 }
        
        timerCount += 1
    }

    //MARK: - Next Hole is Empty
    
    func nextHoleIsEmptyRuleIsValid() {
        guard let score = throughOneHoleSender?.score() else { return }
        throughOneHoleSender?.setAttributedTitle(cupTitle("0"), for: .normal)
        
        isFirstPlayerMoving ? cupstorage1.setAttributedTitle(cupTitle("\(cupstorage1Score + score)"), for: .normal) : cupstorage2.setAttributedTitle(cupTitle("\(cupstorage2Score + score)"), for: .normal)
    }
    
    //MARK: - Second Interim Rule: Six Pebbles
    
    func didSixPebblesInHoleRuleValid() -> Bool {
        guard
            lastHoleSender != nil,
            lastHoleSender?.score() == 6
        else { return false }
            
        return true
    }
    
    func sixPebblesInHoleRuleIsValid() {
        lastHoleSender?.setAttributedTitle(cupTitle("0"), for: .normal)
        let score: Int = 6
        if firstPlayerHoles.contains(lastHoleTag) {
            guard let a = Int(cupstorage1.currentAttributedTitle!.string) else { return }
            cupstorage1.setAttributedTitle(cupTitle("\(score+a)"), for: .normal)
        } else {
            guard let a = Int(cupstorage2.currentAttributedTitle!.string) else { return }
            
            cupstorage1.setAttributedTitle(cupTitle("\(score+a)"), for: .normal)
        }
    }
    
    //MARK: - Head Navigation
    
    @IBAction func makeMovePressed(_ sender: UIButton) {
        
        if !didMoveEnds { return }
        if firstHoleSender == nil { return }
        
        isFirstPlayerMoving.toggle()
        movingPlayerHolesActive()
        
        let headTitle = isFirstPlayerMoving ? "\(playerNames[0]) Moving" : "\(playerNames[1]) Moving"
        showInfoAlert(title: headTitle, message: "", titleAction: "Okay")
        
        numOfMove += 1
        if didCakeRuleUsed { cakeButton.alpha = numOfMove == 1 ? 1 : 0.3 }
        firstHoleSender = nil
        saveBeginningPosition()
    }
    
    //MARK: - Optional Rule: Cake Rule
    @IBAction func cakeMovingPressed(_ sender: UIButton)
    { cakeMovingPressedLogic() }
    
    @IBAction func restartPressed(_ sender: UIButton) {
        showActionAlert(title: K.T.restartTitle, message: "") { UIAlertAction in
            self.timer.invalidate()
            self.createNewGame()
        }
    }
    
    @IBAction func returnToMenuPressed(_ sender: UIButton)
    { returnToMenuPressedLogic() }
    
    
    @IBAction func manualEndingGamePressed(_ sender: UIButton)
    { manualEndingGamePressedLogic() }
    
    @IBAction func nameplatePressed(_ sender: UIButton)
    { nameplatePressedLogic(tag: sender.tag) }
    
    //MARK: - Extra 
    
    func setExtraHoles() {
        holes.first(where: {$0.tag == 4})?.setAttributedTitle(cupTitle("1"), for: .normal)
        holes.first(where: {$0.tag == 12})?.setAttributedTitle(cupTitle("1"), for: .normal)
    }
}
