//
//  ContentView.swift
//  Dopamine Switch
//
//  Created by Oliver's probook on 12/1/20.
//

import SwiftUI

struct ContentView: View {
    var SB: SwitchBoard
    init(statusBarItem: NSStatusItem?) {
        SB = SwitchBoard(statusBarItem: statusBarItem)
    }
    var body: some View {
        VStack {
            SB
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
