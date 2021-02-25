//
//  AddMatchView.swift
//  Groundbook
//
//  Created by admin on 30.11.2020.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct AddMatchView: View {
    @EnvironmentObject var db: DBService
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel = AddMatchViewModel()
    
    var body: some View {
        VStack{
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
                    Button(action: { viewModel.addMatch()}){
                        HStack{
                            Spacer()
                            Text("Submit").bold()
                            Spacer()
                        }
                    }
                }
                
            }.alert(isPresented: $viewModel.showErrorAlert){
            Alert(title: Text("Please, set all values!"))
        }
        }.onReceive(viewModel.viewDismissalModePublisher) { shouldDismiss in
            if shouldDismiss {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

/*struct AddMatchView_Previews: PreviewProvider {
    static var previews: some View {
        AddMatchView()
    }
}*/
