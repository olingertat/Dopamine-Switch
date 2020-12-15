//
//  Switch.swift
//  Dopamine Switch
//
//  Created by Oliver's probook on 12/4/20.
//

import Foundation
import SwiftUI

struct SwitchBoard: View {
    @State private var theSwitches = [SwitchInfo]()
    private var theSwitchValues: [Bool] {
        return theSwitches.map { $0.on }
    }
    var body: some View {
        ScrollView {
            VStack{
//                ForEach(0..<theSwitches.count-1/3+1) { row in
                    HStack {
                        ForEach(theSwitches) { theSwitch in
                            SwitchView(switchInfo: theSwitch)
                        }
                    }
//                }
                Button(action:{self.addSwitch(SwitchInfo(imageName: "StatusBarButtonImage"))}) {
                    Text("Add Switch")
                }
                Button(action: {self.resetSwitches()}) {Text("reset")}
            }
        }
    }
    func addSwitch(_ theSwitch: SwitchInfo) {
        self.theSwitches.append(theSwitch)
    }
    func resetSwitches() {
        for i in 0...theSwitches.count-1 {
            theSwitches[i].on = false
        }
    }
}

class SwitchInfo: Identifiable, ObservableObject {
    @Published public var on: Bool = false
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
    @ObservedObject var switchInfo: SwitchInfo
    var body: some View {
        VStack {
            Toggle("asdf", isOn: $switchInfo.on)
                .toggleStyle(SwitchToggleStyle())
                .onHover(perform: {_ in print(self.switchInfo.on)})
            switchInfo.label
        }.padding()
    }
}


struct SwitchToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        return Image(configuration.isOn ? "OnSwitch" : "OffSwitch")
                .resizable()
                .frame(width: 50.0, height: 50.0)
            .onTapGesture { configuration.isOn.toggle() }
    }
}
