//
//  SplashView.swift
//  MiniBudget_New
//
//  Created by Erandi Pathirana on 2026-04-26.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                Image("Mini Pig Bank")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                
                Spacer()
                
                VStack(spacing: 6) {
                    Text("Welcome to")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 4) {
                        Text("Mini")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary) 
                        
                        Text("Budget")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.green)
                    }
                }
                .padding(.bottom, 60)
            }
        }
    }
}

#Preview {
    SplashView()
}

