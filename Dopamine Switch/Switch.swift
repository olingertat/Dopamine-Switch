//
//  Switch.swift
//  Dopamine Switch
//
//  Created by Oliver's probook on 12/4/20.
//

import Foundation
import SwiftUI

struct SwitchBoard: View {
    var statusBarItem: NSStatusItem?
    @ObservedObject private var theSwitches = SwitchGroup()
    private var allCompleted: Bool {
        return theSwitches.allCompleted
    }
    var body: some View {
        ScrollView {
            VStack{
//                ForEach(0..<theSwitches.count-1/3+1) { row in
                    HStack {
                        ForEach(0..<theSwitches.theSwitches.count, id: \.self) { theSwitch in
                            SwitchView(switchInfo: theSwitches.theSwitches[theSwitch])
                                .onTapGesture {
                                    theSwitches.theSwitches[theSwitch].on.toggle()
                                }
                        }
                    }
//                }
                Button(action:{self.addSwitch(SwitchInfo(label: "test"))}) {
                    Text("Add Switch")
                }
                Button(action: {self.resetSwitches()}) {Text("reset")}
            }
        }
        .onChange(of: allCompleted, perform: { _ in
            updateStatusBar()
        })
    }
    init(statusBarItem: NSStatusItem?) {
        self.statusBarItem = statusBarItem
        updateStatusBar() // needed to set icon if allCompleted is true
    }
    func updateStatusBar() {
        statusBarItem?.button?.image = allCompleted ?
            NSImage(named:NSImage.Name("GreenLED")) :
            NSImage(named:NSImage.Name("RedLED"))
    }
    func addSwitch(_ theSwitch: SwitchInfo) {
        self.theSwitches.theSwitches.append(theSwitch)
    }
    func resetSwitches() {
        theSwitches.resetSwitches()
    }
}

class SwitchGroup: ObservableObject {
    @Published var theSwitches = [SwitchInfo]()
    {
        didSet {
            if let data = try? PropertyListEncoder().encode(theSwitches) {
                UserDefaults.standard.set(data, forKey: "theSwitches")
            }
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

struct SwitchView: View {
    var switchInfo: SwitchInfo
    var body: some View {
        VStack {
            Image(switchInfo.on ? "OnSwitch" : "OffSwitch")
                .resizable()
                .frame(width: 50.0, height: 50.0)
            Text(switchInfo.label)
        }.padding()
    }
}
