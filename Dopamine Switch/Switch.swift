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
                Button(action:{self.addSwitch(SwitchInfo(imageName: "StatusBarButtonImage"))}) {
                    Text("Add Switch")
                }
                Button(action: {self.resetSwitches()}) {Text("reset")}
            }
        }
        .onChange(of: allCompleted, perform: { _ in
            updateStatusBar()
        })
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
        for i in 0...theSwitches.theSwitches.count-1 {
            theSwitches.theSwitches[i].on = false
        }
    }
}

class SwitchGroup: ObservableObject {
    @Published var theSwitches = [SwitchInfo(imageName: "StatusBarButtonImage"), SwitchInfo(imageName: "StatusBarButtonImage")]
    private var theSwitchValues: [Bool] {
        return theSwitches.map { $0.on }
    }
    var allCompleted: Bool {
        return theSwitchValues.allSatisfy({$0})
    }
}

struct SwitchInfo: Identifiable {
    public var on: Bool = false
    let id = UUID()
    var label: AnyView
    init(text: String) {
        label = AnyView(Text(text))
    }
    init(imageName: String) {
        label = AnyView(Image(imageName))
    }
}

struct SwitchView: View {
    var switchInfo: SwitchInfo
    var body: some View {
        VStack {
            Image(switchInfo.on ? "OnSwitch" : "OffSwitch")
                .resizable()
                .frame(width: 50.0, height: 50.0)
            switchInfo.label
        }.padding()
    }
}
