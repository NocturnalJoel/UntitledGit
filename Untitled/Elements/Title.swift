//
//  Title.swift
//  Untitled
//
//  Created by Joël Lacoste-Therrien on 2023-09-12.
//

import SwiftUI

struct Title: View {
    
    @EnvironmentObject var model:ContentModel
    
    var subTitle: String
    

    
    
    var body: some View {
        VStack {
            ZStack{
                
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [model.customColor1, model.customColor2]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .ignoresSafeArea()
                    .frame(height: 70)
               
                Text("UNTITLED")
                    .foregroundColor(.white)
                    .font(.custom("AvenirNext-Bold", size: 50))
                    .italic()
            }
            Text(subTitle)
                .foregroundColor(.black)
                .font(.custom("AvenirNext-Bold", size: 30))
                .italic()
           
         
           
        }
      
    }
        
}

struct Title_Previews: PreviewProvider {
    static var previews: some View {
        Title(subTitle: "SubTitle")
    }
}
