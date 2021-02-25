//
//  EditMatchView.swift
//  Groundbook
//
//  Created by admin on 24.12.2020.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct EditMatchView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var db: DBService
    @StateObject var viewModel = EditMatchViewModel()
    
    var match: Match //получаем от родительской вьюхи, в onAppear используем для передачи значений viewModel
    
    var body: some View {
        VStack{
            HStack(){
                Spacer()
                Button(action: {self.presentationMode.wrappedValue.dismiss()}){
                    Text("Close").bold().foregroundColor(Color("AccentColor"))
                }.padding(.top, 10).padding(.trailing, 10)
            }
            Form {
                Section (header: Text("Match Info")) {
                    
                    //Set Home Team
                    Button(action: { viewModel.isPresented.toggle() }){
                        HStack{
                            Text("Home").foregroundColor(.gray)
                            Spacer()
                            if(viewModel.home != nil){
                                WebImage(url: viewModel.home?.logoURL).resizable().scaledToFit().frame(maxWidth: 40, maxHeight: 40)
                                Text(viewModel.home?.name ?? "").foregroundColor(.gray)
                            }
                            if(viewModel.home == nil){
                                Image(systemName: "chevron.right").foregroundColor(.gray)
                            }
                            
                        }
                    }.fullScreenCover(isPresented: $viewModel.isPresented) { TeamPickerView(team: $viewModel.home, isPresented: $viewModel.isPresented).environmentObject(db)
                    }
                    
                    //Set Away Team
                    Button(action: { viewModel.isPresented.toggle() }){
                        HStack{
                            Text("Away").foregroundColor(.gray)
                            Spacer()
                            if(viewModel.away != nil){
                                WebImage(url: viewModel.away?.logoURL).resizable().scaledToFit().frame(maxWidth: 40, maxHeight: 40)
                                Text(viewModel.away?.name ?? "").foregroundColor(.gray)
                            }
                            if(viewModel.away == nil){
                                Image(systemName: "chevron.right").foregroundColor(.gray)
                            }
                            
                        }
                    }.fullScreenCover(isPresented: $viewModel.isPresented) { TeamPickerView(team: $viewModel.away, isPresented: $viewModel.isPresented).environmentObject(db)
                    }
                    
                    //set score
                    Button(action: {viewModel.isScorePickerPresented.toggle()}){
                        HStack{
                            Text("Match Score").foregroundColor(.gray)
                            Spacer()
                            Text("\(viewModel.homeScore):\(viewModel.awayScore)").foregroundColor(.gray)
                        }
                    }
                    if viewModel.isScorePickerPresented {
                        HStack {
                            VStack{
                                Text("Home")
                                Picker(selection: $viewModel.homeScore, label: Text("Numbers")) {
                                    ForEach(viewModel.integers, id:\.self) { integer in
                                        Text("\(integer)")
                                    }
                                }.pickerStyle(WheelPickerStyle())
                            }.frame(width: 110)
                            Spacer()
                            VStack{
                                Text("Away")
                                Picker(selection: $viewModel.awayScore, label: Text("Numbers")) {
                                    ForEach(viewModel.integers, id:\.self) { integer in
                                        Text("\(integer)")
                                    }
                                }.pickerStyle(WheelPickerStyle())
                            }.frame(width: 110)
                        }
                    }
                    
                    //Set Ground
                    Button(action: { viewModel.isPresented.toggle() }){
                        HStack{
                            Text("Ground").foregroundColor(.gray)
                            Spacer()
                            if(viewModel.ground != nil){
                                Text(viewModel.ground?.name ?? "").foregroundColor(.gray)
                            }
                            if(viewModel.ground == nil){
                                Image(systemName: "chevron.right").foregroundColor(.gray)
                            }
                            
                        }
                    }.fullScreenCover(isPresented: $viewModel.isPresented) { GroundPickerView(ground: $viewModel.ground, isPresented: $viewModel.isPresented).environmentObject(db)
                    }
                    
                    //Set Tournament
                    Button(action: { viewModel.isPresented.toggle() }){
                        HStack{
                            Text("Tournament").foregroundColor(.gray)
                            Spacer()
                            if(viewModel.tournament != nil){
                                WebImage(url: viewModel.tournament?.logoURL).resizable().scaledToFit().frame(maxWidth: 40, maxHeight: 40)
                                Text(viewModel.tournament?.name ?? "").foregroundColor(.gray)
                            }
                            if(viewModel.tournament == nil){
                                Image(systemName: "chevron.right").foregroundColor(.gray)
                            }
                            
                        }
                    }.fullScreenCover(isPresented: $viewModel.isPresented) { TournamentPickerView(tournament: $viewModel.tournament, isPresented: $viewModel.isPresented).environmentObject(db)
                    }
                    
                    //Set Date
                    Button(action: {viewModel.isDatePickerPresented.toggle()}){
                        HStack{
                            Text("Date").foregroundColor(.gray)
                            Spacer()
                            Text(viewModel.dateFormatter.string(from: viewModel.date)).foregroundColor(.gray)
                        }
                    }
                    if viewModel.isDatePickerPresented {
                        DatePicker("", selection: $viewModel.date, displayedComponents: .date)
                            .datePickerStyle(WheelDatePickerStyle())
                            .animation(.default)
                    }
                }
                Section{
                    Button(action: { viewModel.editMatch()}){
                        HStack{
                            Spacer()
                            Text("Submit").bold().foregroundColor(Color("AccentColor"))
                            Spacer()
                        }
                    }
                }
                Section{
                    Button(action: { viewModel.showDeleteAlert.toggle()}){
                        HStack{
                            Spacer()
                            Text("Delete").bold().foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }.alert(isPresented: $viewModel.showDeleteAlert){
                Alert(title: Text("Are you sure?"), message: Text("This match will be deleted"),
                      primaryButton: .default (Text("Delete")) {
                        viewModel.deleteMatch()
                      },
                      secondaryButton: .cancel()
                )
            }
            //Spacer()
        }.onAppear(){
            viewModel.home = match.home
            viewModel.away = match.away
            viewModel.ground = match.ground
            viewModel.tournament = match.tournament
            viewModel.date = match.date
            viewModel.homeScore = match.homeScore
            viewModel.awayScore = match.awayScore
            
            viewModel.match = self.match
        }
        .onReceive(viewModel.viewDismissalModePublisher) { shouldDismiss in
            if shouldDismiss {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

/*struct EditMatchView_Previews: PreviewProvider {
    static var previews: some View {
        EditMatchView()
    }
}*/
