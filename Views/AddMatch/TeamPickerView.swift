//
//  TeamPickerView.swift
//  Groundbook
//
//  Created by admin on 01.12.2020.
//

import SwiftUI
import FlagKit

struct TeamPickerView: View {
    @EnvironmentObject var db: DBService
    
    @Binding var team: Team?
    
    @Binding var isPresented: Bool
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack{
                SearchBar(text: $searchText)
                Form{
                    List (db.countries.filter({ searchText.isEmpty ? true : $0.name.contains(searchText) })) { country in
                        NavigationLink(destination: TeamsOfCountryView(countryID: country.documentID, team: $team, isPresented: $isPresented)) {
                            HStack{
                                Image(uiImage: Flag(countryCode: country.code)!.image(style: .roundedRect)).resizable().scaledToFit().frame(maxWidth: 30, maxHeight: 30)
                                Text(country.name)
                            }
                        }
                    }
                }
                
            }
            .navigationBarTitle(Text("Countries"))
            .navigationBarItems(trailing: Button(action: {isPresented = false }){
                Text("Close")
            })
        }
    }
}

/*struct TeamPickerView_Previews: PreviewProvider {
    static var previews: some View {
        TeamPickerView()
    }
}*/
