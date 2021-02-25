//
//  MatchesView.swift
//  Groundbook
//
//  Created by admin on 04.12.2020.
//

import SwiftUI
import SDWebImageSwiftUI

struct MatchesView: View {
    @EnvironmentObject var db: DBService
    
    var arrayOfMatches: [Match]
    
    //for edit match alert
    @State private var alertItem: Match?
    @State private var selectedMatch: Match?
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()
    
    var body: some View {
        VStack{
            List {
                ForEach(arrayOfMatches){ match in
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
            }.listStyle(InsetGroupedListStyle())
            .alert(item: $alertItem){ item in
                Alert(title: Text("Edit this match?"), message: Text("You can edit or delete this match"),
                      primaryButton: .default (Text("Edit")) {
                        selectedMatch = item
                      },
                      secondaryButton: .cancel()
                )
            }
            .fullScreenCover(item: $selectedMatch){ EditMatchView(match: $0).environmentObject(db) }
            .navigationTitle(Text("Matches"))
        }
    }
}

/*struct MatchesView_Previews: PreviewProvider {
 static var previews: some View {
 MatchesView()
 }
 }*/
