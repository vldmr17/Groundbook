//
//  TeamsView.swift
//  Groundbook
//
//  Created by admin on 22.01.2021.
//

import SwiftUI
import FlagKit
import SDWebImageSwiftUI

struct TeamsView: View {
    @EnvironmentObject var db: DBService
    
    @State private var teams: VisitedTeams?
    
    var arrayOfTeams: [Team]
    
    var body: some View {
        List{
            if(teams != nil){
            ForEach(teams!.sections){section in
                Section(header: HStack {
                            Image(uiImage: Flag(countryCode: section.teams[0].country.code)!.image(style: .roundedRect)).resizable().scaledToFit().frame(maxWidth: 30, maxHeight: 30)
                            Text(section.country)}){
                    ForEach(section.teams){ team in
                        HStack{
                            SGNavigationLink(destination: TeamMatchesView(team: team, allMatches: db.matches)){
                                HStack{
                                WebImage(url: team.logoURL).resizable().scaledToFit().frame(maxWidth: 40, maxHeight: 40)
                                Text(team.name)
                                }
                            }
                        }
                    }
                }
            }
            }
        }.onAppear(){
            self.teams = VisitedTeams(arrayOfTeams: arrayOfTeams)
        }
        .navigationTitle(Text("My Teams"))
    }
}

struct VisitedTeams{
    var sections: [Countries] = []
    
    init(arrayOfTeams: [Team]){
        let teams = arrayOfTeams.sorted { $0.name < $1.name }
        
        let grouped = Dictionary(grouping: teams) { (team: Team) -> String in
            (team.country.name) //тут страна стадиона
        }
        
        self.sections = grouped.map { countries -> Countries in
            Countries(country: countries.key, teams: countries.value)
        }
        
        sections.sort(by: {$0.country < $1.country} )
    }
    
    struct Countries: Identifiable {
        let id = UUID()
        let country: String
        let teams: [Team]
    }
}

/*struct TeamsView_Previews: PreviewProvider {
    static var previews: some View {
        TeamsView()
    }
}*/
