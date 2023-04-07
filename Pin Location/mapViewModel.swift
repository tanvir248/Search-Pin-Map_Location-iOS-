//
//  mapViewModel.swift
//  Pin Location
//
//  Created by Tanvir Rahman on 07.04.2023.
//

import Foundation
import SwiftUI
import PMJSON
import CoreLocation
import MapKit

struct Location: Identifiable {

    let id = UUID()
    let title: String
    let coordinate: CLLocationCoordinate2D

}
struct mapViewModel: View {
    @Binding var exitMapVie: Bool
    @Binding var searchText: String
    @State var progressBar: Bool = false
    @State private var mapError: Bool = false
    @State private var region =  MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060), span: MKCoordinateSpan(latitudeDelta: 0.009, longitudeDelta: 0.009))
    
    @State private var coordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
    
   @State private var locations = [
            Location(title: "New York", coordinate: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)),
       ]
    
      var body: some View {
          ZStack{
              VStack(spacing: 0){
                  Button{
                      exitMapVie = false
                  }label: {
                      RoundedRectangle(cornerRadius: 10)
                          .frame(width: 55, height: 5, alignment: .center)
                          .padding(5)
                  }
                  Spacer(minLength: 0)
                  if !progressBar {
                      ZStack{
                          if mapError {
                              HStack{
                                  Image(systemName: "ladybug")
                                      .font(.system(size: 35))
                                      .foregroundColor(.secondary)
                                  Text("Location is not available")
                                      .foregroundColor(.secondary)
                              }.minimumScaleFactor(0.5)
                          }else {
                              Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: .constant(.follow), annotationItems: locations) { location in
                                  
                                  MapMarker(coordinate: coordinate, tint: .blue)
                              }
                          }
                      }
                  }
                  Spacer()
              }
              if progressBar {
                  ZStack{
                      Color.gray.opacity(0.3)
                          .ignoresSafeArea()
              ProgressView()
                      .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                      .scaleEffect(2)
                  }

              }
          }.onAppear(){
              DispatchQueue.main.async {
                  getLatitudeAndLangitude(address: searchText)
                  progressBar = true
              }
          }
            
      }
    
    func getLatitudeAndLangitude(address: String){
        let urlString  = "https://maps.googleapis.com/maps/api/geocode/json?address=\(address.replacingOccurrences(of: " ", with: "%20"))&key=\("Use your API key that given from google")&region=us"
        
        guard let url = URL(string: urlString) else {
            print("Map url error")
            return
        }
        
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            //use bundle indentifier if api keys available this
            //String(Bundle.main.bundleIdentifier! ->  auto select bundle identifier
            
            "X-Ios-Bundle-Identifier" : "*****"
        ]
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                print(error!.localizedDescription)
                print("Data Error")
                return
                
            }
            guard let reposonseCode = (response as? HTTPURLResponse)?.statusCode else {
                
                print(error?.localizedDescription ?? "FF")
                return
            }
            print("The response code \(reposonseCode)")
            if reposonseCode == 200 {
                DispatchQueue.main.async {
                    
                    let json = try? JSON.decode(data)
                    print(json!)
                    do {
                        guard let x = try json?.getString("status") else {
                           print("Your status is wrong!")
                           return
                        }
                        print(x)
                        if x == "OK" {
                            if let lat = try json?.getArray("results")[0].getObject("geometry").getObject("location").getDouble("lat"), let lng = try json?.getArray("results")[0].getObject("geometry").getObject("location").getDouble("lng"){
                                DispatchQueue.main.async {
                                    self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lng), span: MKCoordinateSpan(latitudeDelta: 0.009, longitudeDelta: 0.009))
                                }
                                DispatchQueue.main.async {
                                    
                                    self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                                }
                                DispatchQueue.main.async {
                                    
                                    let new_location = Location(title: "Dhaka", coordinate: self.coordinate)
                                    self.locations.insert(new_location, at: 0)
                                    print("The latitude2 \(lat)")
                                    print("The langitude2 \(lng)")
                                    print(self.region)
                                    progressBar = false
                                }
                            }
                        }else{
                            mapError = true
                            progressBar = false
                        }
                        
                    }catch{
                        mapError = true
                        print(error)
                        progressBar = false
                    }
                }
            }else{
                mapError = true
                progressBar = false
            }
        }.resume()
    }
}

struct mapViewModel_Previews: PreviewProvider {
    static var previews: some View {
        mapViewModel(exitMapVie: .constant(true), searchText: .constant(""))
    }
}
