//
//  HomeView.swift
//  Groundbook
//
//  Created by admin on 04.12.2020.
//

import SwiftUI
import SDWebImageSwiftUI
import MessageUI

struct HomeView: View {
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var db: DBService
    @StateObject var stats = StatisticsProvider()
    @StateObject var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView{
            ZStack{
                Form{
                    Section{
                        ZStack{
                            HStack{
                                Text("Add match").bold().foregroundColor(Color("AccentColor"))
                                Spacer()
                                Image(systemName: "plus.circle").foregroundColor(Color("AccentColor"))
                            }
                            NavigationLink(destination: AddMatchView()){}
                        }
                    }
                    Section(header: Text("Statistics")){
                        Button(action: {viewModel.showPeriodPicker.toggle()}){
                            HStack{
                                Text("Period").foregroundColor(Color("TextUniversalColor"))
                                Spacer()
                                Text(viewModel.choosedPeriod).foregroundColor(.gray)
                            }
                        }
                    }
                    Section{
                        NavigationLink(destination: MatchesView(arrayOfMatches: stats.getMatchesForPeriod(period: viewModel.choosedPeriod, db: db))){
                            HStack{
                                Text("Matches").foregroundColor(Color("TextUniversalColor"))
                                Spacer()
                                Text(String(stats.numberOfMatches(period: viewModel.choosedPeriod, db: db))).foregroundColor(.gray)
                            }
                        }
                        NavigationLink(destination: GroundsView(arrayOfGrounds: stats.getGroundsForPeriod(period: viewModel.choosedPeriod, db: db))){
                            HStack{
                                Text("Grounds").foregroundColor(Color("TextUniversalColor"))
                                Spacer()
                                Text(String(stats.numberOfGrounds(period: viewModel.choosedPeriod, db: db))).foregroundColor(.gray)
                            }
                        }
                        NavigationLink(destination: TeamsView(arrayOfTeams: stats.getTeamsForPeriod(period: viewModel.choosedPeriod, db: db))){
                            HStack{
                                Text("Teams").foregroundColor(Color("TextUniversalColor"))
                                Spacer()
                                Text(String(stats.numberOfTeams(period: viewModel.choosedPeriod, db: db))).foregroundColor(.gray)
                            }
                        }
                        NavigationLink(destination: CountriesView(arrayOfCountries: stats.getCountriesForPeriod(period: viewModel.choosedPeriod, db: db))){
                            HStack{
                                Text("Countries").foregroundColor(Color("TextUniversalColor"))
                                Spacer()
                                Text(String(stats.numberOfCountries(period: viewModel.choosedPeriod, db: db))).foregroundColor(.gray)
                            }
                        }
                    }
                    
                    HStack{
                            VStack{
                                Text("Favorite team").bold().foregroundColor(Color("TextUniversalColor"))
                                Divider()
                                .background(Color.gray.opacity(0.8))
                                .padding(.horizontal)
                                //если все данные еще не подгружены или за период нет матчей показываем что команды нет ("empty" - дефолтное значение для logoURL, таким значение оно инициализируется сразу при запуске приложения или когда за период нет матчей)
                                if(stats.mostVisitedTeam.logoURL == URL(string: "empty")){
                                    Image(systemName: "shield.fill").resizable().scaledToFit().frame(maxWidth: 40, maxHeight: 40).foregroundColor(.gray)
                                    Text("No team").foregroundColor(.gray)
                                }else{
                                WebImage(url: stats.mostVisitedTeam.logoURL).resizable().scaledToFit().frame(maxWidth: 40, maxHeight: 40)
                                    Text(stats.mostVisitedTeam.name).foregroundColor(.gray)
                                }
                            }.frame(maxWidth: .infinity)
                        
                            VStack{
                                Text("Favorite ground").bold().foregroundColor(Color("TextUniversalColor"))
                                Divider()
                                .background(Color.gray.opacity(0.8))
                                .padding(.horizontal)
                                //если все данные еще не подгружены или за период нет матчей показываем что команды нет ("empty" - дефолтное значение для photoURL, таким значение оно инициализируется сразу при запуске приложения или когда за период нет матчей)
                                if(stats.mostVisitedTeam.logoURL == URL(string: "empty")){
                                    Image(systemName: "sportscourt.fill").resizable().scaledToFit().frame(maxWidth: 40, maxHeight: 40)
                                    Text("No ground").foregroundColor(.gray)
                                }else{
                                    Image(systemName: "sportscourt.fill").resizable().scaledToFit().frame(maxWidth: 40, maxHeight: 40)
                                    Text(stats.mostVisitedGround.name).foregroundColor(.gray)
                                }
                            }.frame(maxWidth: .infinity)
                    }
                }
                
                if viewModel.showPeriodPicker {
                    ZStack{
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.vertical)
                        // This VStack is the popup
                        VStack(spacing: 20) {
                            Text("Choose period")
                                .bold().padding()
                                .frame(maxWidth: .infinity)
                                .background(Color("AccentColor"))
                                .foregroundColor(Color.white)
                            Picker(selection: $viewModel.choosedPeriod, label: Text("Numbers")) {
                                ForEach(viewModel.periodOptions, id:\.self) { integer in
                                    Text("\(integer)")
                                }
                            }.pickerStyle(WheelPickerStyle()).frame(width: 260, height: 50).padding(.top, 45).animation(.none)
                            
                            Spacer()
                            Button(action: {
                                viewModel.showPeriodPicker = false
                                stats.getMostVisitedTeam(period: viewModel.choosedPeriod, db: db)
                                stats.getMostVisitedGround(period: viewModel.choosedPeriod, db: db)
                            }) {
                                Text("Close")
                            }.padding()
                        }
                        .frame(width: 300, height: 290)
                        .background(Color.white)
                        .cornerRadius(20).shadow(radius: 20)
                    }
                }
                
            }
            .navigationTitle(Text("Home"))
            .navigationBarItems(leading: Button(action: { viewModel.showingActionSheet.toggle() }){
                Image(systemName: "gear")
            })
        }
        .onAppear{
            stats.getMostVisitedTeam(period: viewModel.choosedPeriod, db: db)
            stats.getMostVisitedGround(period: viewModel.choosedPeriod, db: db)
        }
        .actionSheet(isPresented: $viewModel.showingActionSheet) {
            ActionSheet(title: Text("Change background"), message: Text("Select a new color"), buttons: [
                .destructive(Text("Sign Out")) { session.signOut() },
                .cancel()
            ])
        }
        
    }
}

/*struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}*/
