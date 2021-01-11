//
//  Switch.swift
//  Dopamine Switch
//
//  Created by Oliver's probook on 12/4/20.
//

import SwiftUI

struct SwitchBoard: View {
    var statusBarItem: NSStatusItem?
    @ObservedObject private var theSwitches: SwitchGroup
    private var allCompleted: Bool {
        return theSwitches.allCompleted
    }
    @State private var showAddPopover: Bool = false
    @State private var showRemovePopover: Bool = false
    @State private var switchName: String = ""
    var body: some View {
        VStack{
            ScrollView {
                VStack{
                    ForEach(0..<theSwitches.theSwitches.count-1/3+1, id: \.self) { row in
                        HStack {
                            ForEach(0...2, id: \.self) { col in
                                if (3*row+col < theSwitches.theSwitches.count) {
                                    SwitchView(switchInfo: theSwitches.theSwitches[3*row+col])
                                        .onTapGesture {
                                            theSwitches.theSwitches[3*row+col].on.toggle()
                                        }
                                }
                            }
                        }
                    }
                }
            }
            .onChange(of: allCompleted, perform: { _ in
                updateStatusBar()
            })
            HStack {
                Button("Add") {
                    self.showAddPopover = true
                    switchName = ""
                }.popover(isPresented: self.$showAddPopover, arrowEdge: .bottom) {
                    VStack {
                        TextField("Activity Name", text: $switchName)
                            .padding()
                        Button("Add Switch", action: { addSwitch(switchName) })
                    }
                        .frame(width:150, height: 100)
                }
                Button("Remove") {
                    self.showRemovePopover = true
                    switchName = ""
                }.popover(isPresented: self.$showRemovePopover, arrowEdge: .bottom) {
                    VStack {
                        TextField("Activity Name", text: $switchName)
                            .padding()
                        Button("Remove Switch", action: { removeLastSwitchWithName(switchName) })
                    }
                        .frame(width:150, height: 100)
                }
                Button("Quit", action: quitClicked)
            }
            .padding(.bottom)
        }
        .frame(width: 280, height: 260)
    }
    func quitClicked() {
        NSApplication.shared.terminate(self)
    }
    init(statusBarItem: NSStatusItem?) {
        var dateChangeSinceLastRun = true
        if let lastSwitchDate = UserDefaults.standard.string(forKey: "lastSwitchDate") {
            let df = DateFormatter()
            df.dateFormat = "dd/MM/yyyy"
            if df.string(from: Date()) == lastSwitchDate {
                dateChangeSinceLastRun = false
            }
        }
        self.statusBarItem = statusBarItem
        self.theSwitches = SwitchGroup()
        if dateChangeSinceLastRun { resetSwitches() }
        updateStatusBar() // needed to set green icon if allCompleted is true
    }
    func updateStatusBar() {
        statusBarItem?.button?.image = allCompleted ?
            NSImage(named:NSImage.Name("GreenLED")) :
            NSImage(named:NSImage.Name("RedLED"))
        statusBarItem?.button?.image?.size = NSSize(width:16, height: 16)
    }
    func addSwitch(_ theSwitch: SwitchInfo) {
        self.theSwitches.addSwitch(theSwitch)
    }
    func addSwitch(_ theSwitch: String) {
        let newSwitchInfo = SwitchInfo(label: theSwitch)
        self.theSwitches.addSwitch(newSwitchInfo)
    }
    func removeLastSwitchWithName(_ switchName: String) {
        self.theSwitches.removeLastSwitchWithName(switchName)
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

struct SwitchView: View {
    var switchInfo: SwitchInfo
    var body: some View {
        VStack {
            Image(switchInfo.on ? "GreenLED" : "RedLED")
                .resizable()
                .frame(width: 50.0, height: 50.0)
            Text(switchInfo.label)
        }.padding()
    }
}
