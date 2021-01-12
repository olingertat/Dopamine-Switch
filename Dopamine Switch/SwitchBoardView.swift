//
//  SwitchBoardView.swift
//  Dopamine Switch
//
//  Created by Oliver's probook on 12/4/20.
//

import SwiftUI

struct SwitchBoardView: View {
    var statusBarItem: NSStatusItem?
    @ObservedObject private var theSwitches: SwitchBoardModel
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
        self.theSwitches = SwitchBoardModel()
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
