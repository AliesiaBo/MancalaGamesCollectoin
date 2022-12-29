//
//  SettingsViewController.swift
//  Kalah
//
//  Created by Aliesia Borzik on 13.09.2022.
//

import UIKit
import CoreData

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var travelDirectionSegment: UISegmentedControl!
    @IBOutlet weak var scatterOfPebblesSegment: UISegmentedControl!
    @IBOutlet weak var attempsSegment: UISegmentedControl!
    @IBOutlet weak var cakeModeSegment: UISegmentedControl!
    @IBOutlet weak var rotationForPlayer2Segment: UISegmentedControl!
    @IBOutlet weak var famineModeSegment: UISegmentedControl!
    
    var settingsArray = [NewGameSettingsExtension]()
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //show used settings
        //Load data
        fetchData()
        //Show data in segments
        loadSavedData()
    }
    
    func loadSavedData() {
        let n1 = Int(Settings.travelDirrection.name.firstIndex(of: settingsArray[0].travelDirection ?? K.S.standart) ?? 0)
        let n2 = Int(Settings.scatterOfPebbles.name.firstIndex(of: settingsArray[0].scatterOfPebbles ?? K.S.equable) ?? 0)
        let n3 = Int(Settings.attemps.name.firstIndex(of: settingsArray[0].numberOfAttempsForOneMove ?? K.S.many) ?? 0)
        let n4 =  settingsArray[0].cakeMode.intRepresent()
        let n5 = settingsArray[0].changingRotationForPlayer2.intRepresent()
        let n6 = Int(Settings.famineMode.name.firstIndex(of: settingsArray[0].famineMode ?? K.S.standart) ?? 0)
        
        travelDirectionSegment.selectedSegmentIndex = n1
        scatterOfPebblesSegment.selectedSegmentIndex = n2
        attempsSegment.selectedSegmentIndex = n3
        cakeModeSegment.selectedSegmentIndex = n4
        rotationForPlayer2Segment.selectedSegmentIndex = n5
        famineModeSegment.selectedSegmentIndex = n6
    }
    
    @IBAction func travelDirrectionSegmentPressed(_ sender: UISegmentedControl) {
        settingsArray[0].travelDirection = sender.titleForSegment(at: sender.selectedSegmentIndex) ?? K.S.standart
        saveData()
    }
    
    @IBAction func scatterOfPebblesSegmentPressed(_ sender: UISegmentedControl) {
        settingsArray[0].scatterOfPebbles = sender.titleForSegment(at: sender.selectedSegmentIndex) ?? "Equable"
        saveData()
    }
    
    @IBAction func attempsSegmentPressed(_ sender: UISegmentedControl) {
        settingsArray[0].numberOfAttempsForOneMove = sender.titleForSegment(at: sender.selectedSegmentIndex) ?? "Many"
        saveData()
    }
    
    @IBAction func cakeModeSegmentPressed(_ sender: UISegmentedControl) {
        settingsArray[0].cakeMode = sender.selectedSegmentIndex.boolRepresent()
        saveData()
    }
    
    @IBAction func rotationForP2SegmentPressed(_ sender: UISegmentedControl) {
        settingsArray[0].changingRotationForPlayer2 = sender.selectedSegmentIndex.boolRepresent()
        saveData()
    }
    
    @IBAction func famineModeSegmentPressed(_ sender: UISegmentedControl) {
        settingsArray[0].famineMode = sender.titleForSegment(at: sender.selectedSegmentIndex) ?? "Standart"
        saveData()
    }
    
    @IBAction func returnToMenuPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func resetSettingsPressed(_ sender: UIButton) {
        settingsArray[0].travelDirection = K.S.standart
        settingsArray[0].scatterOfPebbles = K.S.equable
        settingsArray[0].numberOfAttempsForOneMove = K.S.many
        settingsArray[0].cakeMode = true
        settingsArray[0].changingRotationForPlayer2 = false
        settingsArray[0].famineMode = K.S.standart
        
        saveData()
        
        travelDirectionSegment.selectedSegmentIndex = 0
        scatterOfPebblesSegment.selectedSegmentIndex = 0
        attempsSegment.selectedSegmentIndex = 0
        cakeModeSegment.selectedSegmentIndex = 0
        rotationForPlayer2Segment.selectedSegmentIndex = 0
        famineModeSegment.selectedSegmentIndex = 0
    }
    
    func saveData() {
        do {
            print("Trying saving context")
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    func fetchData() {
        let request: NSFetchRequest<NewGameSettingsExtension> = NewGameSettingsExtension.fetchRequest()
        
        do {
            settingsArray = try context.fetch(request)
        } catch {
            print("Error fetching settings")
        }
    }
}
