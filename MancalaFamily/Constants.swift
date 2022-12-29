//
//  Constants.swift
//  Kalah
//
//  Created by Aliesia Borzik on 11.04.2022.
//

import Foundation

struct K {
    struct T {
        ///Text: "End the game now?"
        static let endGameTitle = "End the game now?"
        ///Text: "Go To Menu?"
        static let menuReturnTitle = "Go To Menu?"
        ///Text: "Restart game?"
        static let restartTitle = "Restart game?"
        ///Text: "End the game now?"
        static let noSynchMove = "No synchronous move"
        ///Text: "You choose not enough cups"
        static let notEnoughCups = "You choose not enough cups"
    }
    
    struct M {
        ///Text: "Do you wanna collect pebbles in each storage or leave"
        static let endGameMessage = "Do you wanna collect pebbles in each storage or leave?"
        ///Text: "There no first synchronous move cause random split of pebbles"
        static let noFirstSynchMoveMessage = "There no first synchronous move cause random split of pebbles"
        ///Text: ""
        static let message0 = ""
        ///Text: ""
        static let message1 = ""
        
    }
    
    struct ErrorMessage {
        static let e1 = "Some text to not forget that there sholud be text. But if there is nothing here, it means the developer messed up. Or this game coming soon..."
        static let e2 = "Ops, something went wrong"
    }
    
    struct S {
        static let standart = "Standart"
        static let cross = "Cross"
        static let clockwise = "Clockwise"
        static let anticlockwise = "Anticlockwise"
        static let equable = "Equable"
        static let random = "Random"
        static let many = "Many"
        static let one = "One"
    }
    
}
