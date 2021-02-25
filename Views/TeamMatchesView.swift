//
//  TeamMatchesView.swift
//  Groundbook
//
//  Created by admin on 02.02.2021.
//

import SwiftUI
import SDWebImageSwiftUI

struct TeamMatchesView: View {
    @EnvironmentObject var db: DBService
    
    var team: Team
    
    @State private var alertItem: Match?
    @State private var selectedMatch: Match?
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()
    
    var matches: [Match] = []
    
    init(team: Team, allMatches: [Match]) {
        self.team = team
        for match in allMatches {
            if match.home?.documentID == team.documentID {
                self.matches.append(match)
            }
            if match.away?.documentID == team.documentID {
                self.matches.append(match)
            }
        }
    }
    
    var body: some View {
        List {
            ForEach(matches){ match in
                VStack{
                    Text(dateFormatter.string(from: match.date))
                    HStack{
                        WebImage(url: match.home?.logoURL).resizable().scaledToFit().frame(maxWidth: 25, maxHeight: 25)
                        Text(match.home?.name ?? "Home")
                        Spacer()
                        Text("\(match.homeScore)")
                    }
                    HStack{
                        WebImage(url: match.away?.logoURL).resizable().scaledToFit().frame(maxWidth: 25, maxHeight: 25)
                        Text(match.away?.name ?? "Away")
                        Spacer()
                        Text("\(match.awayScore)")
                    }
                }.onTapGesture(){ self.alertItem = match }
            }
            //Spacer()
        }
        .alert(item: $alertItem){ item in
            Alert(title: Text("Edit this match?"), message: Text("You can edit or delete this match"),
                  primaryButton: .default (Text("Edit")) {
                    selectedMatch = item
                  },
                  secondaryButton: .cancel()
            )
        }
        .fullScreenCover(item: $selectedMatch){ EditMatchView(match: $0).environmentObject(db) }
        .navigationTitle(team.name)
    }
}

/*struct TeamMatchesView_Previews: PreviewProvider {
    static var previews: some View {
        TeamMatchesView()
    }
}*/
