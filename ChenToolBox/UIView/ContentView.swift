//
//  ContentView.swift
//  ChenToolBox
//
//  Created by 陈依澄 on 2023/9/26.
//

import SwiftUI

struct ContentView: View {
    @State var lessons: [Lesson] = []
    var body: some View {
        if(lessons.isEmpty){
            lessonsEmptyView(lessons: $lessons)
                .background(Color(.systemBackground))
                .transition(.move(edge: .bottom))
        }else{
            lessonsView(lessons: $lessons)
                .background(Color(.systemBackground))
                .transition(.move(edge: .bottom))
        }
    }
}

