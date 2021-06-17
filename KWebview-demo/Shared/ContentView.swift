//
//  ContentView.swift
//  Shared
//
//  Created by Jordan Cassiano on 16/06/21.
//

import SwiftUI
import KWebview

struct ContentView: View {
    var webviewModel = KWebviewViewModel()

    @State private var text: String = ""

    @State private var status: KWebViewStatus = .init(canGoback: false, title: "", canGoForward: false)

    var body: some View {
        VStack {
            HStack {
                TextField("URL", text: $text, onCommit: {
                    print("on Commit \(text)")
                    webviewModel.openURL(text)
                })
                .keyboardType(.URL)
                .autocapitalization(.none)
                .disableAutocorrection(true)

                Button(action: {}) {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.blue, lineWidth: 2))
            .padding(8)

            VStack {
                KWebview(webviewModel)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            HStack {
                Button(action: { self.webviewModel.goBack() }) {
                    Image(systemName: "chevron.backward")
                }
                .padding()
                .opacity(self.status.canGoback ? 1 : 0.5)
                .disabled(!self.status.canGoback)

                Button(action: { self.webviewModel.goForward() }) {
                    Image(systemName: "chevron.right")
                }
                .padding()
                .opacity(self.status.canGoForward ? 1 : 0.5)
                .disabled(!self.status.canGoForward)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .onReceive(webviewModel.webviewStatus.receive(on: RunLoop.main), perform: { value in
                self.status = value
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
