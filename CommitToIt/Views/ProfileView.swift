//
//  ProfileView.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 2/1/26.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var first_name : String = ""
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.627, green: 0.761, blue: 0.455, opacity: 1),
                    Color(red: 0.741, green: 0.91, blue: 0.522, opacity: 1)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            VStack{
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 250))
                    //.foregroundColor()
                
                VStack {
                    HStack {
                        TextField("First Name", text: $first_name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Last Name", text: $first_name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    TextField("Email", text: $first_name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                }
                .padding(10)
                .background(.background)
                .cornerRadius(10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(20)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppState(load_mock_data: true))
}


