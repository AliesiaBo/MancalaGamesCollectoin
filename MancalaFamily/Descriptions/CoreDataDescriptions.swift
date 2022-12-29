//
//  CoreDataDescriptions.swift
//  Kalah
//
//  Created by Aliesia Borzik on 12.09.2022.
//

import UIKit
import CoreData

protocol CoreDataManagerForMancala: MancalaGameStandarts {
    var context: NSManagedObjectContext { get set }
    var contextGameName: GameName? { get }
    
    func saveData()
    func didActiveSave() -> Bool
    func tryFetchDataForCurrentGame<T>(with request: NSFetchRequest<T>, predicate: NSPredicate?) -> T?
    func tryFetchAnySingleData<T>(with request: NSFetchRequest<T>, predicate: NSPredicate?) -> T?
    func saveNewData(data: GameDataSaves)
    func createData() -> GameDataSaves
}

extension CoreDataManagerForMancala {
    
    var contextGameName: GameName? {
        let request : NSFetchRequest<GameName> = GameName.fetchRequest()
        do {
            let gn = try context.fetch(request)
            for n in gn {
                if n.gameName == gameName {
                   return n
                }
            }
            return nil
        } catch {
            print("Error happend. There's no save or it's broken. Should create new game")
            return nil
        }
    }
    
    func saveData() {
        do {
            print("Trying saving context")
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    func didActiveSave() -> Bool {
        if contextGameName != nil {
            return true
        }
        return false
    }
    
    func tryFetchDataForCurrentGame<T>(with request: NSFetchRequest<T>, predicate: NSPredicate? = nil) -> T? {
        let gameNamePredicate = NSPredicate(format: "gameNameParent.gameName MATCHES %@", gameName)
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [gameNamePredicate, addtionalPredicate])
        } else {
            request.predicate = gameNamePredicate
        }
        
        do {
            let data = try context.fetch(request)
            if data.isEmpty {
                showErrorAlert()
                return nil
            }
            //multiple saves soon... [0], [1], [2]...
            return data[0]
        } catch {
            print("Error, Theree's no save, should return nil")
            return nil
        }
    }
    
    func tryFetchAnySingleData<T>(with request: NSFetchRequest<T>, predicate: NSPredicate? = nil) -> T? {
        do {
            let data = try context.fetch(request)
            //multiple saves soon... [0], [1], [2]...
            return data[0]
        } catch {
            print("Error, Theree's no save, should return nil")
            return nil
        }
    }
    
    func saveNewData(data: GameDataSaves) {
        print("Creating context and fill")
        
        let nameOfGameForSaving = GameName(context: self.context)
        //first, save name of relationship
        //cause we dont have category, let's create new and make save in it
        nameOfGameForSaving.gameName = gameName
        saveData()
        
        let savingPlayerParameters = PlayerParameters(context: self.context)
        let savingGameParameters = GameParameters(context: self.context)
        let savingOtherParameters = OtherParameters(context: self.context)
        let savingFamineRuleParameters = FamineRuleParameters(context: self.context)
        
        //second, save relationship in parameters data for current game
        savingPlayerParameters.gameNameParent = contextGameName
        savingGameParameters.gameNameParent = contextGameName
        savingOtherParameters.gameNameParent = contextGameName
        savingFamineRuleParameters.gameNameParent = contextGameName
        
        //third, save data in each entity
        //PlayerParameters
        savingPlayerParameters.isFPM = data.playerData.isFPM
        savingPlayerParameters.isSPM = data.playerData.isSPM
        savingPlayerParameters.playerName1 = data.playerData.playerName1
        savingPlayerParameters.playerName2 = data.playerData.playerName2
        
        //GameParameters
        savingGameParameters.attemps = data.gameData.attemps
        savingGameParameters.gameKey = data.gameData.gameKey
        
        //OtherParameters
        savingOtherParameters.didCakeRuleUsed = data.otherData.didCakeRuleUsed
        savingOtherParameters.didChangeRotationForSecondPlayer = data.otherData.didChangeRotation
        savingOtherParameters.travelDirrection = data.otherData.travelDirrection
        savingOtherParameters.numOfAttemps = data.otherData.numOfAttemps
        savingOtherParameters.lastDataSaving = data.otherData.lastDataSaving
        savingOtherParameters.didFamineModeUsed = data.otherData.didFamineRuleUsed
        
        if data.otherData.didFamineRuleUsed {
            savingFamineRuleParameters.didCaptureAllowed = data.famineRuleData!.didCaptureAllowed
            savingFamineRuleParameters.didPlayerFamine = data.famineRuleData!.didPlayerFamine
            savingFamineRuleParameters.didPlayerWasFamine = data.famineRuleData!.didPlayerWasFamine
        }
        
        saveData()
    }
    
    func createData() -> GameDataSaves {
        print("Creating data for saving")
        var famineRuleData: GameDataSaves.FamineRuleParametersData? = nil
        if didFamineRuleUsed {
            famineRuleData = GameDataSaves.FamineRuleParametersData(
                didCaptureAllowed: false,
                didGameShouldEnds: false,
                didPlayerFamine: false,
                didPlayerWasFamine: false)
        }
        
        let data = GameDataSaves(
            playerData:
                GameDataSaves.PlayerParametersData(
                    playerName1: playerNames[0],
                    playerName2: playerNames[1],
                    isFPM: isFirstPlayerMoving,
                    isSPM: !isFirstPlayerMoving),
            gameData:
                GameDataSaves.GameParametersData(
                    gameKey: savingKey,
                    attemps: String(numOfMove)),
            otherData:
                GameDataSaves.OtherParametersData(
                didCakeRuleUsed: didCakeRuleUsed,
                didChangeRotation: didChangeRotationForSecondPlayer,
                didFamineRuleUsed: didFamineRuleUsed,
                lastDataSaving: Date(),
                numOfAttemps: numberOfAttems,
                travelDirrection: travelDirrection),
            famineRuleData: famineRuleData)
        
        return data
    }
}
