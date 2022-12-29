//
//  Extentions.swift
//  Kalah
//
//  Created by Aliesia Borzik on 16.04.2022.
//

import UIKit

//MARK: - RangeReplaceableCollection

extension RangeReplaceableCollection {
    func rotatingLeft(positions: Int) -> SubSequence {
        let index = self.index(startIndex, offsetBy: positions, limitedBy: endIndex) ?? endIndex
        return self[index...] + self[..<index]
    }
    mutating func rotateLeft(positions: Int) {
        let index = self.index(startIndex, offsetBy: positions, limitedBy: endIndex) ?? endIndex
        let slice = self[..<index]
        removeSubrange(..<index)
        insert(contentsOf: slice, at: endIndex)
    }
}

//MARK: - UIViewController

extension UIViewController {
    
    var fontSize: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    ///Simple function that show informational alert 'Ok"
    
    
    func movingPlayerHolesActive (_ allHoles: inout [UIButton]) {
        allHoles.forEach { $0.titleLabel?.alpha = $0.titleLabel?.alpha == 1 ? 0.5 : 1}
    }
    
    func deactivate(_ holes: inout [UIButton]) { holes.forEach { $0.titleLabel?.alpha = 0.5 } }
}

//MARK: - UIColor

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}

//MARK: - Bool

extension Bool {
    mutating func toggle() { self = !self }
    
    //Return 0 for true and 1 to false
    func intRepresent() -> Int {
        if self == true {
            return 0
        }
        return 1
    }
}

extension Int {
    mutating func reduceNumber(maxNum: Int) {
        if self > maxNum {
            repeat {
                self -= maxNum
            } while self > maxNum
        }
    }
    
    mutating func increaseNumber(on num: Int) {
        if self <= 0 {
            repeat {
                self += num
            } while self < 0
        }
    }
    
    func boolRepresent() -> Bool {
        if self == 0 {
            return true
        }
        return false
    }
}

extension UIButton {
    func score() -> Int {
        guard let scoreStr = self.currentAttributedTitle?.string,
              let scoreInt = Int(scoreStr)
        else { return 0 }
        return scoreInt
    }
    
    func setCupTitle(_ title: NSAttributedString) {
        self.setAttributedTitle(title, for: .normal)
    }

}
//MARK: - [UIButton]
//@inlinable public func forEach(_ body: (Element) throws -> Void) rethrows
//@inlinable public func first(where predicate: (Element) throws -> Bool) rethrows -> Element?



