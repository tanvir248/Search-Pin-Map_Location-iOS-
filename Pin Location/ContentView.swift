//
//  ContentView.swift
//  Pin Location
//
//  Created by Tanvir Rahman on 01.04.2023.
//

import SwiftUI
import CoreLocation
import MapKit

struct ContentView: View {
    @State private var locationText: String = ""
    @State var openMap: Bool = false
    
    var body: some View {
        VStack{
            TextField("Type a place...", text: $locationText)
                .padding(10)
                .background{
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.gray.opacity(0.3))
                }
                .padding(10)
            
            Button("Search") {

                openMap = true
            }
        }.sheet(isPresented: $openMap) {
           // mapViewModel(exitMapVie: $openMap, searchText: $locationText)
            mapViewModel()
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
