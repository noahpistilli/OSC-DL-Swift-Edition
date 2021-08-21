//
//  ContentView.swift
//  Open Shop Channel Downloader
//
//  Created by Noah Pistilli on 2021-06-17.
//

import SwiftUI


struct RoundedRectangleButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    HStack {
      Spacer()
      configuration.label.foregroundColor(.black)
      Spacer()
    }
    .padding()
    .background(Color.yellow.cornerRadius(8))
    .scaleEffect(configuration.isPressed ? 0.95 : 1)
  }
}

struct OSC_DB: View {
    @State var data: [OSCData] = []
    
    var body: some View {
        NavigationView {
            List(data) { data in
                NavigationLink(destination: AppData(data: data)) {
                    HStack {
                        Image("\(data.category)")
                        Text(data.display_name)
                            .font(.headline)
                        
                        Text(data.coder)
                            .font(.subheadline)
                    }
                    .navigationTitle(Text("Open Shop Channel"))
                }
            }
            .listStyle(.sidebar)
            .onAppear() {
                    if Reachability.isConnectedToNetwork(){
                        OSCAPI().getData { data in
                            self.data = data
                        }
                    } else {
                        OSCAPI().offlineData { data in
                            self.data = data
                        }
                    }
                }
            }
        #if os(macOS)
        .frame(minWidth: 1000, minHeight: 530)
        #endif
        }
    }
