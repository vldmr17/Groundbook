//
//  ChallengesView.swift
//  Groundbook
//
//  Created by admin on 04.12.2020.
//

import SwiftUI

struct ChallengesView: View {
    @EnvironmentObject var db: DBService
    var stats = StatisticsProvider()
    
    var body: some View {
        NavigationView{
            VStack{
                List {
                    ForEach(db.challenges){ challenge in
                        ZStack{
                            HStack{
                                VStack (alignment: .leading){
                                    Text(challenge.name)
                                    if (challenge.description != ""){
                                        Text(challenge.description).foregroundColor(.gray).scaledToFit()
                                    }
                                    if (challenge.description == ""){
                                        Text("-").foregroundColor(.gray).scaledToFit()
                                    }
                                }
                                Spacer()
                                if(stats.isChallengeComplete(grounds: challenge.grounds)){
                                    Image(systemName: "checkmark.circle.fill").foregroundColor(Color("AccentColor"))
                                }
                                Text(stats.numberOfVistedGrounds(grounds: challenge.grounds)).bold().padding(.trailing)
                            }
                            NavigationLink(destination: ChallengeDetailsView(challenge: challenge)){
                                //EmptyView()
                            }.buttonStyle(PlainButtonStyle())
                        }
                        
                    }
                }
            }
            .onAppear(){}
            .navigationTitle(Text("Challenges"))
            .navigationBarItems(trailing: NavigationLink(destination: AddChallengeView()){
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 22, height: 22)
                    .padding()
            })
        }
    }
}

/*struct ChallengesView_Previews: PreviewProvider {
    static var previews: some View {
        ChallengesView()
    }
}*/
