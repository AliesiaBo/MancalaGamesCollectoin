//
//  InfoViewController.swift
//  Kalah
//
//  Created by Aliesia Borzik on 15.04.2022.
//

import UIKit

class InfoViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var gameNameplate: UIButton!
    @IBOutlet var chooseGameButton: [UIButton]!
    @IBOutlet weak var gameRuleTextView: UITextView!
    
    @IBOutlet weak var gamePictureImageView: UIImageView!
    
    var variableOfGame: [String] = Mancala.allCases.map { $0.rawValue }
    var selectedGameTitle: String = "Kalah"
    var gameNum = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setGameInfoAttributes()
        self.gameRuleTextView.text = load(file: "KalahRules")
        // Do any additional setup after loading the view.
    }
    
    @IBAction func nextOrPreviousGamePressed(_ sender: UIButton) {
        // (-1) 1 <- |2| -> 3 (+1)
        gameNum += sender.tag == 0 ? -1 : 1
        gameNum = gameNum == variableOfGame.count + 1 ? 1 : gameNum  // n -> 1
        gameNum = gameNum == 0 ? variableOfGame.count : gameNum     // 1 -> n
        
        selectedGameTitle = variableOfGame[ gameNum - 1 ]
        
        setCurrentGameTextToTextView()
        setGameInfoAttributes()
    }
    
    func setCurrentGameTextToTextView() {
        let textFileName = selectedGameTitle + "Rules"
        self.gameRuleTextView.text =  load(file: textFileName)
    }
    
    //В собственный «амбар» в процессе посева также бросается камешек, «амбар» противника пропускается.
    
    func setGameInfoAttributes() {
        
        guard
            let strokeColor = Mancala(rawValue: selectedGameTitle)?.strColor,
            let bgColor = Mancala(rawValue: selectedGameTitle)?.bgColor,
            let fontName = Mancala(rawValue: selectedGameTitle)?.font,
            let fontColor = Mancala(rawValue: selectedGameTitle)?.fontColor
        else { return }

        let name = NSAttributedString(string: selectedGameTitle, attributes: [.font: UIFont(name: fontName, size: 20)!])

        if #available(iOS 15.0, *) {
            gameNameplate.configuration?.background.strokeColor = UIColor(rgb: strokeColor)
            gameNameplate.configuration?.background.backgroundColor = UIColor(rgb: bgColor)
            chooseGameButton.forEach { $0.tintColor = UIColor(rgb: strokeColor) }
            
        } else {
            gameNameplate.layer.borderColor = UIColor(rgb: strokeColor).cgColor
        }

        gameNameplate.tintColor = UIColor(rgb: fontColor)
        gameNameplate.setAttributedTitle(name, for: .normal)
        gamePictureImageView.image = UIImage(named: selectedGameTitle+"Board.svg")
    }
    
    func load(file name: String) -> String {
        guard
            let path = Bundle.main.path(forResource: name, ofType: "txt")
        else {
            print("Error! - This file doesn't exist.")
            return K.ErrorMessage.e1
        }
        
        do {
            let contents = try String(contentsOfFile: path)
            return contents
            
        } catch {
            print("Error! - This file doesn't contain any text.")
        }
        
        return K.ErrorMessage.e1
    }
    
    @IBAction func backToMenuPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendLetterToDeveloperPressed(_ sender: UIButton) {
        showInfoAlert(title: "Soon", message: "Have questions or find error? You can use this email to send message to developer!", titleAction: "Ok")
    }
    
    @IBAction func questionMarkPressed(_ sender: UIButton) {
    }
    
}
