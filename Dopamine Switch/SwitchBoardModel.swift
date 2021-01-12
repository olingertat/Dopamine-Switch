//
//  SwitchBoardModel.swift
//  Dopamine Switch
//
//  Created by Oliver's probook on 1/12/21.
//

import Foundation

class SwitchBoardModel: ObservableObject {
    @Published var theSwitches = [SwitchInfo]()
    {
        didSet {
            if let data = try? PropertyListEncoder().encode(theSwitches) {
                UserDefaults.standard.set(data, forKey: "theSwitches")
            }
            let df = DateFormatter()
            df.dateFormat = "dd/MM/yyyy"
            UserDefaults.standard.set(df.string(from: Date()), forKey: "lastSwitchDate")
        }
    }
    private var theSwitchValues: [Bool] {
        return theSwitches.map { $0.on }
    }
    var allCompleted: Bool {
        return theSwitchValues.allSatisfy({$0})
    }
    init() {
        if let data = UserDefaults.standard.data(forKey: "theSwitches") {
            self.theSwitches = try! PropertyListDecoder().decode([SwitchInfo].self, from: data)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.resetSwitches(notification:)), name: .NSCalendarDayChanged, object: nil)
    }
    func addSwitch(_ theSwitch: SwitchInfo) {
        self.theSwitches.append(theSwitch)
    }
    func removeLastSwitchWithName(_ switchName: String) {
        for i in 1...theSwitches.count {
            if theSwitches[theSwitches.count - i].label == switchName {
                theSwitches.remove(at: theSwitches.count - i)
                return
            }
        }
    }
    @objc func resetSwitches(notification: NSNotification? = nil) {
        for i in 0...theSwitches.count-1 {
            theSwitches[i].on = false
        }
    }
}

struct SwitchInfo: Identifiable, Codable {
    public var on: Bool = false
    var id = UUID()
    var label: String
}
