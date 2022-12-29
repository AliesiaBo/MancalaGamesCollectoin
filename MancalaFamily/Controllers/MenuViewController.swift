//
//  MenuViewController.swift
//  Kalah
//
//  Created by Aliesia Borzik on 05.01.2022.
//

import UIKit
import QuartzCore
import CoreData

class MenuViewController: UIViewController {

    @IBOutlet weak var firstPlayerName: UITextField!
    @IBOutlet weak var secondPlayerName: UITextField!
    
    @IBOutlet weak var gameNameplate: UIButton!

    @IBOutlet var chooseGameButton: [UIButton]!
    
    private var currentTextField: UITextField?
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var playersNamesData = [MenuNamesData]()
    
    var firstName: String?
    var secondName: String?
    
    var variableOfGame: [String] = Mancala.allCases.map { $0.rawValue }
    var selectedGameTitle: String = ""
    var gameNum = 1
    
    //var save: GameDataSaves?
    
    //MARK: - View Did Load

    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstPlayerName.delegate = self
        secondPlayerName.delegate = self
        
        setGameplateAttributes()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //create standart parameters for new games if player first invite in game
        createNewSettingsIfNeed()
        createNewNamesIfNeeded()
        fetchNamesData()
    }
    
    deinit { print("MenuViewController removed from memory") }
    
    //MARK: - CoreData
    
    func createNewNamesIfNeeded() {
        let request: NSFetchRequest<MenuNamesData> = MenuNamesData.fetchRequest()
        do {
            let data = try context.fetch(request)
            playersNamesData = data
            if !playersNamesData.isEmpty { return }
        } catch {
            print("Error happend. There's no saved names or it's broken. Should create new names or something else")
            return
        }
        
        let savingNames = MenuNamesData(context: self.context)
        
        savingNames.playerName1 = ""
        savingNames.playerName2 = ""
        
        saveData()
    }
    
    func fetchNamesData() {
        let request: NSFetchRequest<MenuNamesData> = MenuNamesData.fetchRequest()
        
        do {
            playersNamesData = try context.fetch(request)
            if playersNamesData.isEmpty { return }
            firstPlayerName.text = playersNamesData[0].playerName1
            secondPlayerName.text = playersNamesData[0].playerName2
        } catch {
            print("Error fetching settings")
        }
    }
    
    func createNewSettingsIfNeed() {
        let request: NSFetchRequest<NewGameSettingsExtension> = NewGameSettingsExtension.fetchRequest()
        //        var checkingData: [NewGameSettingsExtension] = []
        do {
            let data = try context.fetch(request)
            if !data.isEmpty { return }
        } catch {
            print("Error happend. There's no saved settings or it's broken. Should create new settins or something else")
            return
        }
        
        print("Settings is empty")
        let savingSettings = NewGameSettingsExtension(context: self.context)
        
        savingSettings.cakeMode = true
        savingSettings.travelDirection = "Standart"
        savingSettings.numberOfAttempsForOneMove = "Many"
        savingSettings.changingRotationForPlayer2 = false
        savingSettings.scatterOfPebbles = "Equable"
        savingSettings.famineMode = "Standart"
        
        saveData()
        print("Settings now not empty")
    }
    
    func saveData() {
        do {
            print("Trying saving context")
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    // MARK: - Navigation
    
    @IBAction func startGamePressed(_ sender: UIButton) {
        if let currentTextField = currentTextField {
                currentTextField.resignFirstResponder()
            }
        guard let senderTitle = sender.currentAttributedTitle?.string else { return }
        
        performSegue(withIdentifier: senderTitle, sender: self)
    }
    
    //MARK: - Settings
    
    @IBAction func goToSettingsPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "settings", sender: self)
    }
    
    //MARK: - Info Menu
    
    @IBAction func goToInfoMenuPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToInfo", sender: self)
    }
    
    //MARK: - Change Game
    
    @IBAction func nextOrPreviousGamePressed(_ sender: UIButton) {
        
        // (-1) 1 <- |2| -> 3 (1)
        gameNum += sender.tag == 0 ? -1 : 1
        gameNum = gameNum == variableOfGame.count + 1 ? 1 : gameNum  // n -> 1
        gameNum = gameNum == 0 ? variableOfGame.count : gameNum     // 1 -> n
        
        setGameplateAttributes()
    }
    
    //MARK: - Configuration Manipulating
    
    func setGameplateAttributes() {
        selectedGameTitle = variableOfGame[ gameNum - 1 ]
        
        guard
            let strokeColor = Mancala(rawValue: selectedGameTitle)?.strColor,
            let bgColor = Mancala(rawValue: selectedGameTitle)?.bgColor,
            let fontName = Mancala(rawValue: selectedGameTitle)?.font,
            let fontColor = Mancala(rawValue: selectedGameTitle)?.fontColor
        else { return }
        
        let name = NSAttributedString(string: selectedGameTitle, attributes: [.font: UIFont(name: fontName, size: 40)!])
        
        if #available(iOS 15.0, *) {
            gameNameplate.configuration?.background.strokeColor = UIColor(rgb: strokeColor)
            gameNameplate.configuration?.background.backgroundColor = UIColor(rgb: bgColor)
            chooseGameButton.forEach { $0.tintColor = UIColor(rgb: strokeColor) }
        } else {
            gameNameplate.layer.borderColor = UIColor(rgb: strokeColor).cgColor
            // Fallback on earlier versions
        }
        
        gameNameplate.tintColor = UIColor(rgb: fontColor)
        gameNameplate.setAttributedTitle(name, for: .normal)
    }
}

//MARK: - Text Field Delegate

extension MenuViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
    }
    
    @available(iOS 10.0, *)
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        guard let name = textField.text else { return }
        if textField.tag == 1 {
            firstName = name
            playersNamesData[0].playerName1 = name
        } else {
            secondName = name
            playersNamesData[0].playerName2 = name
        }
        saveData()
    }
    
}
