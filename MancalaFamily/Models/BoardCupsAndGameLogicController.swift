//
//  BoardCupsControllerDescription.swift
//  Kalah
//
//  Created by Aliesia Borzik on 16.09.2022.
//

import UIKit
import CoreData

protocol BoardCupsAndGameLogicController: CoreDataManagerForMancala {
    var fontName: String { get set }
    var numberOfPebbles: String { get set }
    var timer: Timer { get set }
    
    func fullCreatingNewGame()
    func longMoving()
}

extension BoardCupsAndGameLogicController {
    
    func initialisingStaticValues() {
        let a = Mancala(rawValue: gameName)
        fontName = a?.font ?? Mancala.kalah.font
        numberOfPebbles = a?.numOfPebbles ?? Mancala.kalah.numOfPebbles
        gameName = gameNameV2
        firstPlayerHoles = a?.firstPH ?? Mancala.kalah.firstPH
        secondPlayerHoles = a?.secondPH ?? Mancala.kalah.secondPH
    }
    
    func createNewStandartCups() {
        let titleNumber = NSAttributedString(string: numberOfPebbles, attributes: [.font: UIFont(name: fontName, size: fontSize/20)!])
        let titleZero = NSAttributedString(string: "0", attributes: [.font: UIFont(name:fontName, size: fontSize/20)!])
        
        let hc = allHoles.count
        
        for hole in allHoles {
            switch hole.tag {
            case 1...(hc/2)-1:
                hole.setAttributedTitle(titleNumber, for: .normal)
                hole.titleLabel?.alpha = 1
            case hc/2:
                hole.setAttributedTitle(titleZero, for: .normal)
                hole.titleLabel?.alpha = 1
            case (hc/2)+1...hc-1:
                hole.setAttributedTitle(titleNumber, for: .normal)
                hole.titleLabel?.alpha = 0.5
            case hc:
                hole.setAttributedTitle(titleZero, for: .normal)
                hole.titleLabel?.alpha = 0.5
            default:
                print("Error, Could't Find Hole")
                break
            }
        }
    }
    
    func reverseCupsTags() {
        (cupstorage1, cupstorage2) = (cupstorage2, cupstorage1)
        
        let hc = allHoles.count
        for hole in allHoles {
            switch hole.tag {
            case 1...(hc/2)-1:
                hole.tag = 1 + (hc/2)-1 - hole.tag
            case hc/2:
                hole.tag = hc
            case (hc/2)+1...hc-1:
                hole.tag = (hc/2)+1 + hc-1 - hole.tag
            case hc:
                hole.tag = hc/2
            default:
                print("Error, Could't Find Hole")
                break
            }
        }
        
    }
    
    func collectingAllOwnSeeds() {
        var score1 = 0
        var score2 = 0
        
        allHoles.forEach({ hole in
            if firstPlayerHoles.contains(hole.tag) { score1 += hole.score() }
            if secondPlayerHoles.contains(hole.tag) { score2 += hole.score() }
            hole.setAttributedTitle(cupTitle("0"), for: .normal)
        })
        score1 += cupstorage1Score
        score2 += cupstorage2Score

        cupstorage1.setAttributedTitle(cupTitle("\(score1)"), for: .normal)
        cupstorage2.setAttributedTitle(cupTitle("\(score2)"), for: .normal)
    }
    
    //MARK: - View Manipulating
    
    ///Creates move by tags (1 -> 2). Implement skipping any hole if need
    func createNormalMove() -> [Int] {
        
        guard
            let cup1 = firstHoleSender,
            cup1.score() > 0
        else {
            print("Error, no CHOOSE cup or current cup have NO_PEBBLES")
            return []
        }
        
        let maxNum = allHoles.count
        var move: [Int] = []
        var step = 0
        let a = cup1.tag
        
        for n in 1...cup1.score() { move.append(a+n) }
        move = move.map ({
            var b = $0 + step
            b.reduceNumber(maxNum: maxNum)
            repeat {
                if skip.contains(b) {
                    step += 1
                    b += 1
                    b.reduceNumber(maxNum: maxNum)
                }
            } while skip.contains(b)
            return b
        })
        return move
    }
    
    ///Creates reversed move by tags (2 -> 1). Implement skipping any hole if need
    func createReversedMove() -> [Int] {
        guard
            let cup1 = firstHoleSender,
            cup1.score() > 0
        else {
            print("Error, no CHOOSE cup or current cup have NO_PEBBLES")
            return []
        }
        
        let num = allHoles.count
        var move: [Int] = []
        var step = 0
        let a = cup1.tag
        
        for n in 1...cup1.score() { move.append(a-n) }
        move = move.map ({
            var b = $0 + step
            b.increaseNumber(on: num)
            repeat {
                if skip.contains(b) {
                    step -= 1
                    b -= 1
                    b.increaseNumber(on: num)
                }
            } while skip.contains(b)
            return b
        })
        return move
    }
    
    func returnBegginingPosition() {
        allHoles.forEach { $0.setAttributedTitle(cupTitle("\(savedPosition[$0.tag-1])"), for: .normal) }
    }
    
    func updateHolesWithoutChanging() {
        allHoles.forEach { hole in
            guard let title = hole.currentAttributedTitle?.string else { return }
            let savedTitle = NSAttributedString(string: title, attributes: [.font: UIFont(name:fontName, size: fontSize / 20)!])
            hole.setAttributedTitle(savedTitle, for: .normal)
        }
    }
    
    func saveBeginningPosition() {
        savedPosition = []
        for n in 1...allHoles.count {
            guard let hole = allHoles.first(where: { $0.tag == n }) else { return }
            savedPosition.append(Int(hole.currentAttributedTitle!.string)!)
        }
    }
    
    func updateRotation() {
        isFirstPlayerMoving ?
        allHoles.forEach({ $0.transform = CGAffineTransform(rotationAngle: 0) }) :
        allHoles.forEach({ $0.transform = CGAffineTransform(rotationAngle: CGFloat.pi) })
    }
    
    //MARK: - Players Holes Active/Deactive
    
    func movingPlayerHolesActive () { allHoles.forEach {
        $0.titleLabel?.alpha = $0.titleLabel?.alpha == 1 ? 0.5 : 1} }
    
    func deactivateAllCups() { allHoles.forEach { $0.titleLabel?.alpha = 0.5 } }
    
    func loadSavedCups() {
        let keyArray = savedKey.components(separatedBy: ".")
        allHoles.forEach { cup in
            let titleNumber = NSAttributedString(string: keyArray[cup.tag - 1], attributes: [.font: UIFont(name:fontName, size: fontSize/20)!])
            cup.setAttributedTitle(titleNumber, for: .normal)
            if isFirstPlayerMoving {
                cup.titleLabel?.alpha = firstPlayerHoles.contains(cup.tag) ? 1 : 0.5
            } else {
                cup.titleLabel?.alpha = firstPlayerHoles.contains(cup.tag) ? 0.5 : 1
            }
        }
    }
    
    func createGivenCups(key: String) {
        let keyArray = key.components(separatedBy: ".")
        allHoles.forEach { cup in
            let titleNumber = NSAttributedString(string: keyArray[cup.tag - 1], attributes: [.font: UIFont(name:fontName, size: fontSize/20)!])
            cup.setAttributedTitle(titleNumber, for: .normal)
            if isFirstPlayerMoving {
                cup.titleLabel?.alpha = firstPlayerHoles.contains(cup.tag) ? 1 : 0.5
                cup.titleLabel?.alpha = cup.tag == cupstorage1.tag ? 1 : cup.titleLabel!.alpha
            } else {
                cup.titleLabel?.alpha = firstPlayerHoles.contains(cup.tag) ? 0.5 : 1
                cup.titleLabel?.alpha = cup.tag == cupstorage2.tag ? 1 : cup.titleLabel!.alpha
            }
        }
    }
    
    //MARK: - Attributed Titles Functions
    
    func cupTitle(_ title: String) -> NSAttributedString {
        let attributedTitle = NSAttributedString(string: title, attributes: [.font: UIFont(name: fontName, size: fontSize / 20)!])
        return attributedTitle
    }
    
    func nameplateTitle(_ title: String) -> NSAttributedString {
        let attributedTitle = NSAttributedString(string: title, attributes: [.font: UIFont(name: fontName, size: fontSize / 30)!])
        return attributedTitle
    }
    
    func setNameInNameplate() {
        nameplate1.setAttributedTitle(nameplateTitle("\(playerNames[0].prefix(1))\(playerNames[0].suffix(1))"), for: .normal)
        nameplate2.setAttributedTitle(nameplateTitle("\(playerNames[1].prefix(1))\(playerNames[1].suffix(1))"), for: .normal)
    }
    
    //MARK: - Some math 0.0
    
    func splitNumberV1(number: Int, split: Int) -> [Int] {
        
        var splitArray: [Int] = [number]
        
        for _ in 1...split-1 {
            splitArray.sort()
            let nextNumForSplit = splitArray[splitArray.count-1]
            let a = Int.random(in: 1..<nextNumForSplit)
            splitArray.removeLast()
            splitArray.append(a)
            splitArray.append(nextNumForSplit - a)
        }
        return splitArray.shuffled()
    }
    
    func createRandomKey(num: Int, cups: Int) -> String {
        let key1 = splitNumberV1(number: num/2, split: cups/2)
        let key2 = splitNumberV1(number: num/2, split: cups/2)
        let key: String = key1.map({"\($0)"}).joined(separator: ".") + ".0." + key2.map({"\($0)"}).joined(separator: ".") + ".0"
        return key
    }
    
    //MARK: - End Game
    
    func endGame() {
        didGameEnds = true
        numOfMove = 0
        deactivateAllCups()
        
        var finalTitle: String = "Draw!"
        let first = cupstorage1Score
        let second = cupstorage2Score
        
        if second > first {
            finalTitle = "\(playerNames[1]) Win!"
        } else if first > second {
            finalTitle = "\(playerNames[0]) Win!"
        }
        
        showInfoAlert(title: finalTitle, message: "", titleAction: "Continue")
        //Coming soon...
        //_Start
        //continue game / new game / exit game
        //_End
    }
    
    func nameplatePressedLogic(tag: Int) {
        let mes1 = isFirstPlayerMoving ? "Moving" : "Waiting"
        let mes2 = !isFirstPlayerMoving ? "Moving" : "Waiting"
        let mes3 = """
        Settings in this game:
        Cake Rule - \(didCakeRuleUsed ? "On" : "Off");
        Changing Rotation - \(didChangeRotationForSecondPlayer ? "On" : "Off");
        Number of attemps - \(numberOfAttems);
        Travel dirrection - \(travelDirrection);
        Scatter of Pebbles - \(scatterOfPebbles);

        Score - \(tag == 1 ? cupstorage1Score : cupstorage2Score);
        Number of move - \(numOfMove).
"""
        tag == 1 ?
        showInfoAlert(title: "\(playerNames[0]) \(mes1)", message: mes3, titleAction: "OK") :
        showInfoAlert(title: "\(playerNames[1]) \(mes2)", message: mes3, titleAction: "OK")
    }
    
    func didMoveIsPossible() -> Bool {
        if
            didMoveEnds == false ||
            didMoveAlreadyCreated == true ||
            firstHoleSender?.score() == 0 ||
            (!isFirstPlayerMoving && firstPlayerHoles.contains(firstHoleSender!.tag)) ||
            (isFirstPlayerMoving && secondPlayerHoles.contains(firstHoleSender!.tag))
        {
            return false
        }
        
        return true
    }
    
    func moveIsImpossible() {
        //Если мы нажимаем на активную лунку или на другую, то возвращаем первоначальную позицию
        timer.invalidate()
        didMoveEnds = true
        didMoveAlreadyCreated = false
        returnBegginingPosition()
    }
    
    func moveIsPossible() {
        //Если мы ещё не ходили, то создаём новый ход
        returnBegginingPosition()
        longMoving()
    }
    
    func manualEndingGamePressedLogic() {
        if !didMoveEnds { return }
        showTwoOptionsAlert(headTitle: K.T.endGameTitle, message: K.M.endGameMessage, noActionTitle: "Continue", action1Title: "Collect", action2Title: "Leave") { UIAlertAction in
            
            self.returnBegginingPosition()
            self.collectingAllOwnSeeds()
            self.endGame()
            
        } doAction2: { [self] UIAlertAction in
            returnBegginingPosition()
            endGame()
        }
    }
    
    func returnToMenuPressedLogic() {
        //dont save game if it was just created cause no sence
        if numOfMove <= 1 {
            showActionAlert(title: K.T.menuReturnTitle, message: "You can't save game that just beggin (min 2 moves)") { UIAlertAction in
                self.dismiss(animated: true, completion: nil)
            }
            return
        }
        
        showTwoOptionsAlert(headTitle: K.T.menuReturnTitle, message: "Save the game?", noActionTitle: "Stay", action1Title: "Quit & Save", action2Title: "Quit") { UIAlertAction in
            //_Start saving data
            self.returnBegginingPosition()
            self.saveNewData(data: self.createData())
            print("Data saves correctly. Maybe")
            //_End savind data
            
            self.dismiss(animated: true, completion: nil)
        } doAction2: { UIAlertAction in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func firstUpdateGameLogic() {
        initialisingStaticValues()
        if didActiveSave() {
            showTwoOptionsAlert(headTitle: "Here's save!", message: "Do you want load last save? If you start new game, you're lost it", noActionTitle: "Quit", action1Title: "Load", action2Title: "New Game") { UIAlertAction in
                //load saved game
                self.loadSavedGame()
                self.context.delete(self.contextGameName!)
                self.saveData()
                
            } doAction2: { UIAlertAction in
                //Creating new game
                //firstly deletingSave
                self.context.delete(self.contextGameName!)
                self.saveData()
                //create new game
                self.fullCreatingNewGame()
            }
            return
        }
        fullCreatingNewGame()
    }
    
    //MARK: - Load Saved Settings
    
    func loadGameSettings() {
        guard
            let loadedNewGameSettings = tryFetchAnySingleData(with: NewGameSettingsExtension.fetchRequest()),
            let loadedNewGameNames = tryFetchAnySingleData(with: MenuNamesData.fetchRequest())
        else {
            showErrorAlert()
            return
        }
        
        didCakeRuleUsed = loadedNewGameSettings.cakeMode
        didChangeRotationForSecondPlayer = loadedNewGameSettings.changingRotationForPlayer2
        numberOfAttems = loadedNewGameSettings.numberOfAttempsForOneMove ?? "Many"
        travelDirrection = loadedNewGameSettings.travelDirection ?? "Standart"
        scatterOfPebbles = loadedNewGameSettings.scatterOfPebbles ?? "Equable"
        
        if loadedNewGameSettings.famineMode == "Yes" {
            didFamineRuleUsed = true
        } else if loadedNewGameSettings.famineMode == "No" {
            didFamineRuleUsed = false
        } // else if (standart it not sets cause it sets by default in each game)
        
        playerNames[0] = (loadedNewGameNames.playerName1 == "" ? "Player1" : loadedNewGameNames.playerName1) ?? "Player1"
        playerNames[1] = (loadedNewGameNames.playerName2 == "" ? "Player2" : loadedNewGameNames.playerName2) ?? "Player2"
    }
    
    //MARK: - Load Saved Game
    
    func loadSavedGame() {
        
        //Loading Data for current game
        guard
            let loadedPlayerData = tryFetchDataForCurrentGame(with: PlayerParameters.fetchRequest()),
            let loadedGameData = tryFetchDataForCurrentGame(with: GameParameters.fetchRequest()),
            let loadedOtherData = tryFetchDataForCurrentGame(with: OtherParameters.fetchRequest()),
            let loadedFamineData = tryFetchDataForCurrentGame(with: FamineRuleParameters.fetchRequest())
        else {
            showErrorAlert()
            fullCreatingNewGame()
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
            fullCreatingNewGame()
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
        numberOfAttems = loadedOtherData.numOfAttemps ?? "Many"
        didFamineRuleUsed = loadedOtherData.didFamineModeUsed  //soon
        travelDirrection = loadedOtherData.travelDirrection ?? "Standart"
        //data loaded, so
        //update UI and show alerts like in createNewGame
        
        //individual for each game!!! Need changes!!!
        //and runs before loadSavedCups()
        setRightDirrection()
        
        loadSavedCups()
        saveBeginningPosition()
        
        if didFamineRuleUsed {
            didCaptureAllowed = loadedFamineData.didCaptureAllowed
            didPlayerFamine = loadedFamineData.didPlayerFamine
            didPlayerWasFamine = loadedFamineData.didPlayerWasFamine
            didPlayerFamine ? playerIsFamineNowWarning() : nil
        }
        
        didChangeRotationForSecondPlayer ? updateRotation() : nil
        if didCakeRuleUsed { cakeButton.alpha = numOfMove == 1 ? 1 : 0.3 }
        
        showWhoMovingNow()
        //_End
    }
    
    //MARK: - Hard Alerts
    
    func playerIsFamineNowWarning() {
        let title = isFirstPlayerMoving ?
        "Oh! \(playerNames[0]) is starving!" :
        "Oh! \(playerNames[1]) is starving!"
        
        showInfoAlert(title: title, message: "Put him some seeds, if you can!", titleAction: "Okay")
    }
    
    func playerIsStillFamineWarning() {
        let title = isFirstPlayerMoving ?
        "\(playerNames[1]) is still starving!" :
        "\(playerNames[0]) is still starving!"
        
        showInfoAlert(title: title, message: "You should put him some seeds! If you can't, end the game", titleAction: "Okay")
    }
    
    func setRightDirrection() {
        guard let std = Mancala(rawValue: gameName) else { return }
        
        switch travelDirrection {
        case K.S.standart:
            switch std {
            case .kalah:
                reverseCupsTags()
            case .oware:
                reverseCupsTags()
            case .congkak:
                return
            case .dakon:
                return
            case .pallanguzhi:
                return //???
            }
        case K.S.clockwise:
            return
        case K.S.anticlockwise:
            reverseCupsTags()
        case K.S.cross:
            return
        default:
            break
        }
    }
}
