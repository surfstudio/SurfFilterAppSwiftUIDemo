//
//  MainPlaceholderView.swift
//  ImageFiltersSwiftUI
//
//  Created by Gregory Berngardt on 26.10.2020.
//

import SwiftUI

struct MainPlaceholderView: View {
    
    var action: (() -> ())? = nil
        
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Consts.contentCornerRadius)
                .fill(Color("SecondaryColor"))
            
            VStack {
                Text("No photo selected").padding()
                Button(action: {
                    action?()
                }){
                    Label("Open form library", systemImage: "photo.on.rectangle.angled")
                }
            }
        }
    }
}

struct MainPlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        MainPlaceholderView()
    }
}
