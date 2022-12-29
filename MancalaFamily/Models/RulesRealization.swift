//
//  RulesManager.swift
//  Kalah
//
//  Created by Aliesia Borzik on 06.04.2022.
//

import UIKit

//MARK: - HalfEmptyHoles Rule


extension HalfEmptyHolesRule {

    func didHalfEmptyHolesRuleIsValid() -> Bool {
        var checkingNum1 = 0
        var checkingNum2 = 0
        
        allHoles.forEach({ hole in
            if firstPlayerHoles.contains(hole.tag) && hole.currentAttributedTitle?.string == "0" {
                checkingNum1 += 1
            }
            if secondPlayerHoles.contains(hole.tag) && hole.currentAttributedTitle?.string == "0" {
                checkingNum2 += 1
            }
        })
        
        if checkingNum1 == 6 || checkingNum2 == 6 {
            return true
        }
        
        return false
    }
    
    func halfEmptyHolesRuleIsValid() {
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
}

//MARK: - Optional Cake Rule Flip Board

extension CakeRule {
    
    /// Used for CakeButton and flip the board
    func cakeRule() {
        var savedPebbles: [NSAttributedString?] = []
        
        for n in 1...allHoles.count { //allHoles
            guard let hole = allHoles.first(where: {
                $0.tag == n
            }) else {
                print("Error, can't find hole")
                continue
            }
            
            savedPebbles.append(hole.currentAttributedTitle!)
        }
        // 1  2  3   4   5  6  7!
        // 8  9  10  11  12 13 14!
        // 7  8  9  10  11  12   1  2  3   4   5  6
        
        savedPebbles.rotateLeft(positions: (allHoles.count) / 2) //: //e.g. 1...14, 7,14 - are storages
        
        for n in 1...allHoles.count {
            guard let hole = allHoles.first(where: {
                $0.tag == n
            }) else { continue }
            hole.setAttributedTitle(savedPebbles[n-1], for: .normal)
        }
    }
    
    func cakeMovingPressedLogic() {
        if !didMoveEnds { return }
        returnBegginingPosition()
        cakeRule()
        saveBeginningPosition()
        
        isFirstPlayerMoving.toggle()
        movingPlayerHolesActive()
        
        cakeButton.alpha = 0.3
        numOfMove += 1
        showWhoMovingNow()
    }
}

//MARK: - Famine Rule

extension FamineRule {
    
    func IsPlayerFamineNow() -> Bool {
        var emptinessCheckNum = 0
        if isFirstPlayerMoving {
            for hole in allHoles {
                if !firstPlayerHoles.contains(hole.tag) { continue }
                emptinessCheckNum += hole.score() == 0 ? 1 : 0
            }
        } else {
            for hole in allHoles {
                if !secondPlayerHoles.contains(hole.tag) { continue }
                emptinessCheckNum += hole.score() == 0 ? 1 : 0
            }
        }
        //now if player which was moving have no pebbles, second player should put pebble to opponent holes
        if emptinessCheckNum != 6 { return false }
        return true
    }
    
    func didPlayerStillFamine() -> Bool {
        var emptinessCheckNum = 0
        if isFirstPlayerMoving {
            for hole in allHoles {
                if !secondPlayerHoles.contains(hole.tag) { continue }
                emptinessCheckNum += hole.score() == 0 ? 1 : 0
            }
        } else {
            for hole in allHoles {
                if !firstPlayerHoles.contains(hole.tag) { continue }
                emptinessCheckNum += hole.score() == 0 ? 1 : 0
            }
        }
        
        if emptinessCheckNum != 6 { return false }
        return true
    }
    
    //MARK: - FamineRule Warnings
    

}

//MARK: - LastPebbleInEmptyHole Rule

extension LastPebbleInYourEmptyHoleRule {
    
    ///If you put last pebble in empty hole, you take pebbles from opposite hole and your one (if it has pebbles).
    ///If pebble in your(!) playable hole.
    ///Comes before we checking half empty holes for moving player (HalfEmptyHolesRule).
    func didLastPebbleInYourEmptyHoleRuleValid() -> Bool {
        guard
            ((firstPlayerHoles.contains(lastHoleTag) && isFirstPlayerMoving) ||
             (secondPlayerHoles.contains(lastHoleTag) && !isFirstPlayerMoving)),
            lastHoleSender?.score() == 1,
            oppositeHoleSender?.score() != 0
        else { return false }
        
        return true
    }
}

extension LastPebbleInAnyEmptyHoleRule {
    
    ///If you put last pebble in empty hole, you take pebbles from opposite hole and your one (if it has pebbles).
    ///If pebble in any playable hole.
    ///Comes before we checking half empty holes for moving player (HalfEmptyHolesRule).
    func didLastPebbleInAnyEmptyHoleRuleValid() -> Bool {
        guard
            lastHoleTag != cupstorage1.tag,
            lastHoleTag != cupstorage2.tag,
            lastHoleSender?.score() == 1,
            oppositeHoleSender?.score() != 0
        else { return false }
        
        return true
    }
}

extension LastPebbleInEmptyHoleRuleIsValid {
    func lastPebbleInEmptyHoleRuleIsValid() {
        var a = 0  // full num of pebbles
        
        a += oppositeHoleSender!.score()
        //need if last one peb sould be leave
        a += isFirstPlayerMoving ? 1 + cupstorage1Score : 1 + cupstorage2Score
        
        isFirstPlayerMoving ?
        cupstorage1.setAttributedTitle(cupTitle("\(a)"), for: .normal) :
        cupstorage2.setAttributedTitle(cupTitle("\(a)"), for: .normal)
        oppositeHoleSender?.setAttributedTitle(cupTitle("0"), for: .normal)
    }
}

//MARK: - CheckingYourKalah Rule


extension YourKalahRule {
    ///If you put last pebble in your kalah, you can continue move
    ///double toggle isFirstPlayerMoving returning move to player which was moving
    func didYourStorageRuleValid() -> Bool {
        if (lastHoleTag == cupstorage1.tag && isFirstPlayerMoving) ||
            (lastHoleTag == cupstorage2.tag && !isFirstPlayerMoving) {
            movingPlayerHolesActive()
            return true
        }
        return false
    }
}

//MARK: - PebblesBehindHole Rule


extension PebblesBehindHoleRule {
    func didPebblesBehindHoleRuleIsValid() -> Bool {
        guard
            lastHoleSender!.score() == 1,
            (isFirstPlayerMoving && secondPlayerHoles.contains(lastHoleTag) ||
               !isFirstPlayerMoving && firstPlayerHoles.contains(lastHoleTag)) &&
                [2, 3, 4, 5, 6, 10, 11, 12, 13, 14].contains(lastHoleTag)
        else { return false }
        
        guard
            let leftHole = allHoles.first(where: {$0.tag == lastHoleTag - 1}),
            let rightHole = allHoles.first(where: {$0.tag == lastHoleTag + 1}),
            leftHole.score() == rightHole.score()
        else { return false }
        
        return true
    }
    
    func pebblesBehindHoleRuleIsValid() {
        
        guard
            let leftHole = allHoles.first(where: {$0.tag == lastHoleTag - 1}),
            let rightHole = allHoles.first(where: {$0.tag == lastHoleTag + 1})
        else { return }
        
        var score = 1
        
        let lhp = leftHole.score()
        let rhp = rightHole.score()
        
        score += lhp + rhp
        
        score += isFirstPlayerMoving ? cupstorage1Score :  cupstorage2Score
        
        isFirstPlayerMoving ?
        cupstorage1.setAttributedTitle(cupTitle(String(score)), for: .normal) :
        cupstorage2.setAttributedTitle(cupTitle(String(score)), for: .normal)
        
        leftHole.setAttributedTitle(cupTitle("0"), for: .normal)
        rightHole.setAttributedTitle(cupTitle("0"), for: .normal)
        lastHoleSender!.setAttributedTitle(cupTitle("0"), for: .normal)
    }
}

//MARK: - EmptyAllHoles Rule

extension EmptyAllHolesRule {
    ///Checking If Empty All Holes
    func didEmptyAllHolesRuleIsValid() -> Bool {
        for hole in allHoles {
            if hole.tag == cupstorage1.tag ||
                hole.tag == cupstorage2.tag ||
                hole.currentAttributedTitle?.string == "0" { continue }
            return false
        }
        return true
    }
}
