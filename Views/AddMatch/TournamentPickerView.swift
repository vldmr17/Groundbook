//
//  TournamentPickerView.swift
//  Groundbook
//
//  Created by admin on 02.12.2020.
//

import SwiftUI
import FlagKit

struct TournamentPickerView: View {
    @EnvironmentObject var db: DBService
    
    @Binding var tournament: Tournament?
    
    @Binding var isPresented: Bool
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack{
                SearchBar(text: $searchText)
            Form{
                List (db.countries.filter({ searchText.isEmpty ? true : $0.name.contains(searchText) })) { country in
                        NavigationLink(destination: TournamentsOfCountryView(countryID: country.documentID, tournament: $tournament, isPresented: $isPresented)) {
                            HStack{
                                Image(uiImage: Flag(countryCode: country.code)!.image(style: .roundedRect)).resizable().scaledToFit().frame(maxWidth: 30, maxHeight: 30)
                                Text(country.name)
                            }
                        }
                }
            }
            }
            .navigationTitle("Countries")
            .navigationBarItems(trailing: Button(action: {isPresented = false }){
                Text("Close")
            })
        }
    }
}

/*struct TournamentPickerView_Previews: PreviewProvider {
    static var previews: some View {
        TournamentPickerView()
    }
}*/
