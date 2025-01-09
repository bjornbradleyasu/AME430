//
//  ContentView.swift
//  Hello
//
//  Created by Bjorn Bradley on 8/27/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var message = "Ready"
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    message = "Hello"
                }, label: {
                    Text("Hello")
                })
                Button(action: {
                    message = ""
                }, label: {
                    Text("Clear")
                })
            }
            Text(message)
                .font(.largeTitle)
                .frame(minWidth: 100, minHeight: 50)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
