//
//  MainMapView.swift
//  Groundbook
//
//  Created by admin on 04.12.2020.
//

import SwiftUI
import MapKit

struct MainMapView: View {
    @EnvironmentObject var db: DBService
    
    @State private var locations = [GroundAnnotation]()
    @State private var showingMapOptions = false
    
    @State private var currentFilter = "Initial"
    
    //для нав линка из аннотации карты
    @State var isActive: Bool = false
    @State var selectedAnnotation: GroundAnnotation = GroundAnnotation(ground: Ground(id: .init(), documentID: "", name: "", capacity: 0, isDemolished: false, opened: 0, country: Country(id: .init(), documentID: "", name: "", code: ""), photoURL: URL(string: "empty")!, latitude: 0.0, longitude: 0.0, tenants: []), isVisited: false, basic: MKPointAnnotation())
    
    var body: some View {
        NavigationView{
        ZStack{
            MapView(annotations: locations, isActive: $isActive, selectedAnnotation: $selectedAnnotation).edgesIgnoringSafeArea(.all)
            NavigationLink(destination: GroundInfoView(ground: selectedAnnotation.ground), isActive: self.$isActive) {
                    EmptyView()
            }
            BottomSheetView(
                isOpen: self.$showingMapOptions,
                maxHeight: 245
            ) {
                MapFiltersView(locations: $locations, currentFilter: $currentFilter)
            }
        }.onAppear(){
            var groundIDs = Set<String>()
            if(currentFilter == "Initial"){
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
            currentFilter = "Overall"
        }
    }
        }
    }
}

/*struct MainMapView_Previews: PreviewProvider {
    static var previews: some View {
        MainMapView()
    }
}*/
