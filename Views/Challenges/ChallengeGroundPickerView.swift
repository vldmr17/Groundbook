//
//  ChallengeGroundPickerView.swift
//  Groundbook
//
//  Created by admin on 07.01.2021.
//

import SwiftUI
import FlagKit

struct ChallengeGroundPickerView: View {
    @EnvironmentObject var db: DBService
    
    @Binding var isPresented: Bool
    
    @Binding var challenge: Challenge
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack{
                SearchBar(text: $searchText)
                Form{
                    List (db.countries.filter({ searchText.isEmpty ? true : $0.name.contains(searchText) })) { country in
                        NavigationLink(destination: ChallengeGroundsOfCountryView(countryID: country.documentID, challenge: $challenge, isPresented: $isPresented)) {
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

/*struct ChallengeGroundPickerView_Previews: PreviewProvider {
 static var previews: some View {
 ChallengeGroundPickerView()
 }
 }*/
