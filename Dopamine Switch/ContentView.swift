//
//  ContentView.swift
//  Dopamine Switch
//
//  Created by Oliver's probook on 12/1/20.
//

import SwiftUI

struct ContentView: View {
//    var myswitch = MySwitch(imageName: "StatusBarButtonImage")
    var SB = SwitchBoard()
    var body: some View {
        VStack {
            SB
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
