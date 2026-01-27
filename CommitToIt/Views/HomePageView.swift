//
//  HomePageView.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/26/26.
//

import SwiftUI

struct HomePageView: View {
    var body: some View {
        ZStack{
            LinearGradient(
                colors: [
                    Color(red: 0.627, green: 0.761, blue: 0.455, opacity: 1),
                    Color(red: 0.741, green: 0.91, blue: 0.522, opacity: 1)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            VStack{
                VStack {
                    ProgressBarView(value: 50, total: 100)
                }
                .padding(10)
                .background(.white)
                .cornerRadius(15)
                .shadow(radius: 10)
                
                Spacer(minLength: 40)
                
                
                
                VStack() {
                    Text("Today's Tasks")
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                    Color.gray.opacity(0.2).frame(height: 1)
                    TaskListView()
                }
                .padding(10)
                .background(.white)
                .cornerRadius(15)
                .shadow(radius: 10)
                
                
            }
            .padding(20)
            .padding(.bottom, 60)
        }
    }
}

#Preview {
    HomePageView()
}

