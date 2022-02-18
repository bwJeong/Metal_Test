//
//  ContentView.swift
//  MetalVideo
//
//  Created by BYUNGWOOK JEONG on 2022/01/03.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MetalView()
            .edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
