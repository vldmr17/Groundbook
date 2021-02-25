//
//  CountriesView.swift
//  Groundbook
//
//  Created by admin on 23.01.2021.
//

import SwiftUI
import FlagKit

struct CountriesView: View {
    @EnvironmentObject var db: DBService
    
    @State var arrayOfCountries: [Country]
    
    var body: some View {
        List{
            ForEach(arrayOfCountries){country in
                SGNavigationLink(destination: CountryMatchesView(country: country, allMatches: db.matches)){
                HStack{
                    Image(uiImage: Flag(countryCode: country.code)!.image(style: .roundedRect)).resizable().scaledToFit().frame(maxWidth: 30, maxHeight: 30)
                    Text(country.name)
                }
                }
            }
        }.navigationTitle("My Countries")
        .onAppear(){
            arrayOfCountries.sort(by: {$0.name < $1.name})
        }
    }
}

/*struct CountriesView_Previews: PreviewProvider {
    static var previews: some View {
        CountriesView()
    }
}*/
