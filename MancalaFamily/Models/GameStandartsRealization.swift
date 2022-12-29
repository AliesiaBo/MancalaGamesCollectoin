//
//  GameStandarts.swift
//  Kalah
//
//  Created by Aliesia Borzik on 02.05.2022.
//

import UIKit

extension MancalaGameStandarts {
    //MARK: - Computed Propeties
    var firstHoleTag: Int {
        return firstHoleSender?.tag ?? 0
    }
    var lastHoleTag: Int {
        return move.last ?? 0
    }
    
    var lastHoleSender: UIButton? {
        return allHoles.first(where: {
            $0.tag == lastHoleTag
        })
    }
    
    ///need update to any game!!!
    var oppositeHoleSender: UIButton? {
        get {
            let hole = allHoles.first(where: {
                $0.tag == allHoles.count - lastHoleTag
            })
            return hole
        }
    }
    
    var nextHoleSender: UIButton? {
        guard let nextHole = allHoles.first(where: {
            if [7, 15].contains(lastHoleTag) {
                var a: Int = lastHoleTag + 2
                a.reduceNumber(maxNum: 16)
                return $0.tag == a
            } else {
                return $0.tag == lastHoleTag + 1
            }
        }) else { return nil }
        
        return nextHole
    }
    
    var throughOneHoleSender: UIButton? {
        guard let throughOneHole = allHoles.first(where: {
            if [6, 7, 14, 15].contains(lastHoleTag) {
                var a: Int = lastHoleTag + 3
                a.reduceNumber(maxNum: 16)
                return $0.tag == a
            } else {
                return $0.tag == lastHoleTag + 2
            }
            
        }) else { return nil }
        return throughOneHole
    }
    
    var throughTwoHoleSender: UIButton? {
        guard let throughOneHole = allHoles.first(where: {
            if [5, 6, 7, 13, 14, 15].contains(lastHoleTag) {
                var a: Int = lastHoleTag + 4
                a.reduceNumber(maxNum: 16)
                return $0.tag == a
            } else {
                return $0.tag == lastHoleTag + 3
            }
            
        }) else { return nil }
        return throughOneHole
    }
    
    var cupstorage1Score: Int {
        guard let scoreStr = cupstorage1.currentAttributedTitle?.string,
              let scoreInt = Int(scoreStr)
        else { return 0 }
        return scoreInt
    }
    
    var cupstorage2Score: Int {
        guard let scoreStr = cupstorage2.currentAttributedTitle?.string,
              let scoreInt = Int(scoreStr)
        else { return 0 }
        return scoreInt
    }
    
    //MARK: - For CoreData
    
    var savingKey: String {
        //calculating saving key
        var keyString: String = ""
        for i in savedPosition {
            keyString += String(i)+"."
        }
        return keyString
    }
    
    //MARK: - Game Name
    
    //<MancalaFamily.KalahGameViewController: 0x14a034c00>
    var gameNameV2: String {
        let name = String(describing: self).components(separatedBy: "GameViewController: ")[0].components(separatedBy: ".")[1]
        return name
    }
    
    var skip: [Int] {
        guard let mancalaGame = Mancala(rawValue: gameName)
            else { return isFirstPlayerMoving ? [14]+changeableSkip : [7]+changeableSkip }
        
        switch mancalaGame {
        case .kalah:
            return isFirstPlayerMoving ? [14]+changeableSkip : [7]+changeableSkip
        case .oware:
            return [7, 14, firstHoleTag] + changeableSkip
        case .congkak, .dakon:
            return isFirstPlayerMoving ? [16]+changeableSkip : [8]+changeableSkip
        case .pallanguzhi:
            return [8, 16] + changeableSkip
        }
    }
    
    //MARK: - Alerts
    
    func showWhoMovingNow() {
        showInfoAlert(title: "\(playerNames[isFirstPlayerMoving ? 0 : 1]) moving", message: "", titleAction: "Ok")
    }
    
}
