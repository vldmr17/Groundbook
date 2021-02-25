//
//  MapFiltersView.swift
//  Groundbook
//
//  Created by admin on 26.01.2021.
//

import SwiftUI
import MapKit

struct MapFiltersView: View {
    @EnvironmentObject var db: DBService
    
    @Binding var locations: [GroundAnnotation]
    
    @State private var periodOptions: [String] = [] //массив вариантов
    
    var selectedColor = Color(.green)
    
    @Binding var currentFilter: String
    
    var body: some View {
        VStack{
            HStack{
                Text("Filters").font(.title).bold()
            }
            Divider().padding(.horizontal)
            HStack{
                Text("Period").bold().padding(.leading)
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false){
                HStack(spacing: 15){
                    ForEach(periodOptions, id:\.self){period in
                        Button(action: {
                            currentFilter = period //устанавливаем значение текущего фильтра
                            
                            self.locations.removeAll()
                            var groundIDs = Set<String>()
                            
                            if (period == "Overall" ){
                                for match in db.matches {
                                    let annotation = MKPointAnnotation()
                                    annotation.title = match.ground!.name
                                    annotation.subtitle = match.ground!.country.name
                                    annotation.coordinate = CLLocationCoordinate2D(latitude: match.ground!.latitude, longitude: match.ground!.longitude)
                                    let groundAnnotation = GroundAnnotation(ground: match.ground!, isVisited: true, basic: annotation)
                                    if(groundIDs.insert(match.ground!.documentID).inserted){
                                        self.locations.append(groundAnnotation)
                                    }
                                }
                                
                            } else {
                                
                                
                                let calendar = Calendar.current
                                
                                for match in db.matches {
                                    if(calendar.component(.year, from: match.date) == Int(period)){
                                        let annotation = MKPointAnnotation()
                                        annotation.title = match.ground!.name
                                        annotation.subtitle = match.ground!.country.name
                                        annotation.coordinate = CLLocationCoordinate2D(latitude: match.ground!.latitude, longitude: match.ground!.longitude)
                                        let groundAnnotation = GroundAnnotation(ground: match.ground!, isVisited: true, basic: annotation)
                                        if(groundIDs.insert(match.ground!.documentID).inserted){
                                            self.locations.append(groundAnnotation)
                                        }
                                    }
                                }
                            }
                        }){
                            ZStack{
                                if(period == currentFilter){
                                    VStack{
                                        Text(period).bold().foregroundColor(Color("AccentColor")).frame(height: 15)
                                        Rectangle().frame(width: 60, height: 3).foregroundColor(Color("AccentColor"))
                                    }
                                    
                                } else {
                                    VStack{
                                    Text(period).bold().foregroundColor(.gray).frame(height: 15)
                                        Rectangle().frame(width: 60, height: 3).foregroundColor(Color.gray.opacity(0))
                                    }
                                    
                                }
                            }
                        }
                    }
                }.frame(maxHeight: 80).padding([.leading, .trailing])
            }.padding([.leading, .trailing])
            
            HStack{
                Text("Challenges").bold().padding(.leading)
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false){
                HStack(spacing: 20){
                    ForEach(db.challenges){challenge in
                        Button(action: {
                            currentFilter = challenge.documentID
                            
                            self.locations.removeAll()
                            
                            for ground in challenge.grounds{
                                let annotation = MKPointAnnotation()
                                annotation.title = ground.ground.name
                                annotation.subtitle = ground.ground.country.name
                                annotation.coordinate = CLLocationCoordinate2D(latitude: ground.ground.latitude, longitude: ground.ground.longitude)
                                let groundAnnotation = GroundAnnotation(ground: ground.ground, isVisited: ground.isVisited, basic: annotation)
                                self.locations.append(groundAnnotation)
                            }
                        }){
                            ZStack{
                                if(challenge.documentID == currentFilter){
                                    
                                    VStack{
                                        Text(challenge.name).bold().foregroundColor(Color("AccentColor")).frame(height: 15)
                                        Rectangle().frame(width: 60, height: 3).foregroundColor(Color("AccentColor"))
                                    }
                                } else {
                                    VStack{
                                        Text(challenge.name).bold().foregroundColor(.gray).frame(height: 15)
                                        Rectangle().frame(width: 60, height: 3).foregroundColor(Color.gray.opacity(0))
                                    }
                                }
                            }
                        }
                    }
                }.frame(maxHeight: 80).padding([.leading, .trailing])
            }.padding([.leading, .trailing])
        }.onAppear(){
            //заполняем массив (чтобы выбирать период для которого отображается статистика)
            let date = Date()
            
            let calendar = Calendar.current
            var year = calendar.component(.year, from: date)
            
            periodOptions.append("Overall")
            
            repeat{
                periodOptions.append(String(year))
                year -= 1
            }while(year >= 1970)
        }
    }
}

/*struct MapFiltersView_Previews: PreviewProvider {
 static var previews: some View {
 MapFiltersView()
 }
 }*/
