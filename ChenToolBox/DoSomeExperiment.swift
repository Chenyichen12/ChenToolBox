//
//  DoSomeExperiment.swift
//  ChenToolBox
//
//  Created by 陈鹏宇 on 2023/9/28.
//

import SwiftUI
import UIKit
struct NodeView: View {
    var text: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue)
                .frame(width: 100, height: 100)
            Text(text)
                .foregroundColor(.white)
        }
    }
}

struct LineView: View {
    var from: CGPoint
    var to: CGPoint
    
    var body: some View {
        Path { path in
            path.move(to: from)
            path.addLine(to: to)
        }
        .stroke(Color.black, lineWidth: 2)
    }
}

struct ContentView1: View {
    @State var node1Position = CGPoint(x: 100, y: 100)
    @State var node2Position = CGPoint(x: 300, y: 100)
    
    var body: some View {
        ZStack {
            LineView(from: node1Position, to: node2Position)
            NodeView(text: "Node 1")
                .position(node1Position)
                .gesture(DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        node1Position = value.location
                    }
                    .onEnded { value in
                        node1Position = value.location
                    }
                )
            NodeView(text: "Node 2")
                .position(node2Position)
        }
        
    }
}
struct MyView: View {
    @State var mframe: CGRect = CGRect()
    var body: some View {
        Text("Hello, World!")
            .background(GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        self.mframe = geometry.frame(in: .global)
                        
                    }
            })
        Text(String(Float(mframe.minX)))
    }
}
#Preview {
    MyView()
}
