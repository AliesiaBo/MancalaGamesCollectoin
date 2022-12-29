//
//  Enums.swift
//  Kalah
//
//  Created by Aliesia Borzik on 18.04.2022.
//

import UIKit

enum Mancala: String, CaseIterable, RawRepresentable {
    
    //MARK: - Enum Cases
    
    case kalah = "Kalah"                        //30.12.2021 -> ??.04.2022
    case oware = "Oware"                        //05.04.2022 -> 11.04.2022
    case congkak = "Congkak"                    //11.04.2022 -> 02.05.2022
    case dakon = "Dakon"                        //21.04.2022 -> 02.05.2022
    case pallanguzhi = "Pallanguzhi"
    
    //MARK: - name
    
    var name: String {
        switch self {
        case .kalah: return "Kalah"
        case .oware: return "Oware"
        case .congkak: return "Congkak"
        case .dakon: return "Dakon"
        case .pallanguzhi: return "Pallanguzhi"
        }
    }
    
    var CName: String {
        switch self {
        case .kalah:
            return ""
        case .oware:
            return ""
        case .congkak:
            return ""
        case .dakon:
            return ""
        case .pallanguzhi:
            return ""
        }
    }
    
    //MARK: - bgColor
    
    var bgColor: Int {
        switch self {
        case .kalah: return 0x906C3C
        case .oware: return 0x941100
        case .congkak: return 0x3E2514
        case .dakon: return 0x55557C
        case .pallanguzhi: return 0xFFD479
        }
    }
    
    //MARK: - strColor
    
    var strColor: Int {
        switch self {
        case .kalah: return 0x683F15
        case .oware: return 0xB0412D
        case .congkak: return 0x704934
        case .dakon: return 0x7C80BA
        case .pallanguzhi: return 0xD3B97C
        }
    }
    
    //MARK: - font
    
    var font: String {
        switch self {
        case .kalah: return "Marker Felt"
        case .oware: return "Kefa"
        case .congkak: return "Noteworthy"
        case .dakon: return "Cochin"
        case .pallanguzhi: return "Didot"
        }
    }
    
    //MARK: - fontColor
    
    var fontColor: Int {
        switch self {
        case .kalah: return 0x12
        case .oware: return 0x12
        case .congkak: return 0x12
        case .dakon: return 0x12
        case .pallanguzhi: return 0x12
        }
    }
    
    //MARK: - numOfPebbles
    
    var numOfPebbles: String {
        switch self {
        case .kalah: return "6" // 6 x 12 = 72
        case .oware: return "4" // 4 x 12 = 48
        case .congkak: return "7" // 7 x 14 = 98
        case .dakon: return "7" // 7 x 14 = 98
        case .pallanguzhi: return "12" // 12 x 12 + 2 = 146
        }
    }
    
    var firstPH: [Int] {
        switch self {
        case .kalah: return [1, 2, 3, 4, 5, 6]
        case .oware: return [6, 5, 4, 3, 2, 1]
        case .congkak: return [1, 2, 3, 4, 5, 6, 7]
        case .dakon: return [1, 2, 3, 4, 5, 6, 7]
        case .pallanguzhi: return [1, 2, 3, 4, 5, 6, 7]
        }
    }
    
    var secondPH: [Int] {
        switch self {
        case .kalah: return [8, 9, 10, 11, 12, 13]
        case .oware: return [12, 11, 10, 9, 8, 7]
        case .congkak: return [9, 10, 11, 12, 13, 14, 15]
        case .dakon: return [9, 10, 11, 12, 13, 14, 15]
        case .pallanguzhi: return [9, 10, 11, 12, 13, 14, 15]
        }
    }
    
    var travelDirrection: String {
        switch self {
        case .kalah:
            return "Anticlockwise"
        case .oware:
            return "Anticlockwise"
        case .congkak:
            return "Clockwise"
        case .dakon:
            return "Clockwise"
        case .pallanguzhi:
            return "Anticlockwise"
        }
    }
}

enum Settings {
    case travelDirrection
    case scatterOfPebbles
    case attemps
    case cakeMode
    case rotationForP2
    case famineMode
    
    var name: [String] {
        switch self {
        case .travelDirrection:
            return ["Standart", "Cross", "Clockwise", "Anticlockwise"]
        case .scatterOfPebbles:
            return ["Equable", "Random"]
        case .attemps:
            return ["Many", "One"]
        case .cakeMode:
            return ["On", "Off"]
        case .rotationForP2:
            return []
        case .famineMode:
            return []
        }
    }
    
}

enum TravelDirrection: String {
    case Standart = "Standart"
    case Cross = "Cross"
    case Clockwise = "Clockwise"
    case Anticlockwise = "Anticlockwise"
    
    var name: String {
        switch self {
        case .Standart:
            return "Standart"
        case .Cross:
            return "Cross"
        case .Clockwise:
            return "Clockwise"
        case .Anticlockwise:
            return "Anticlockwise"
        }
    }
}
