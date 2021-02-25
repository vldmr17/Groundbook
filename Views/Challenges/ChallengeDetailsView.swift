//
//  ChallengeDetailsView.swift
//  Groundbook
//
//  Created by admin on 08.01.2021.
//

import SwiftUI
import Firebase

struct ChallengeDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var db: DBService
    @StateObject var viewModel = ChallengeDetailsViewModel()
    
    var challenge: Challenge //для инициализации challenge во viewModel
    
    //для открытия ChallengeGroundPickerView
    /*@State var isPresented = false
    
    @State var isEditingMode = false
    
    @State var showGroundDeleteAlert = false
    
    @State var showChallengeDeleteAlert = false
    
    @State var groundToDelete: Ground = Ground(id: .init(), documentID: "", name: "", capacity: 0, isDemolished: false, opened: 0, country: Country(id: .init(), documentID: "", name: "", code: ""), photoURL: URL(string: "emptyurl")!, latitude: 0.0, longitude: 0.0, tenants: [])
    
    func updateChallenge () {
        var grounds: [[String:Any]] = []
        
        for ground in challenge.grounds {
            let dict: [String : Any] = ["ground":ground.ground.documentID,"isVisited":ground.isVisited]
            grounds.append(dict)
        }
        
        Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("challenges").document(challenge.documentID).updateData([
            "name": challenge.name,
            "description": challenge.description,
            "grounds": grounds
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                //self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    func deleteChallenge(){
        Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("challenges").document(challenge.documentID).delete() { err in
            if let err = err {
                //print("Error removing document: \(err)")
            } else {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }*/
    
    var body: some View {
        Form{
            Section(header: Text("Name")){
                if(!viewModel.isEditingMode){
                    Text(viewModel.challenge!.name)
                }
                if(viewModel.isEditingMode){
                    TextField("Type challenge name", text: Binding($viewModel.challenge)!.name)
                }
            }
            Section(header: Text("Description")){
                if(!viewModel.isEditingMode){
                    Text(viewModel.challenge!.description)
                }
                if(viewModel.isEditingMode){
                    TextEditor(text: Binding($viewModel.challenge)!.description)
                }
            }
            Section(header: Text("Grounds")){
                List {
                    ForEach(viewModel.challenge!.grounds, id:\.0){ ground in
                        HStack{
                            Text(ground.ground.name)
                            Spacer()
                            if(!viewModel.isEditingMode){
                            Button(action: {
                                for i in 0 ..< viewModel.challenge!.grounds.count {
                                    if(ground.ground.documentID == viewModel.challenge!.grounds[i].ground.documentID){
                                        viewModel.challenge!.grounds[i].isVisited.toggle()
                                    }
                                }
                            }){
                                if(ground.isVisited){
                                    HStack{
                                        Text("Visited").foregroundColor(Color("AccentColor"))
                                        Image(systemName: "checkmark.circle.fill").foregroundColor(Color("AccentColor"))
                                    }
                                }
                                if(!ground.isVisited){
                                    HStack{
                                        Text("Not visited").foregroundColor(.red)
                                        Image(systemName: "xmark.circle.fill").foregroundColor(.red)
                                    }
                                }
                            }
                            }
                            if(viewModel.isEditingMode){
                                Button(action: { viewModel.showGroundDeleteAlert.toggle()
                                    viewModel.groundToDelete = ground.ground
                                }){
                                    Image(systemName: "minus.circle").foregroundColor(.red)
                                }.buttonStyle(PlainButtonStyle()) //чтобы кнопкой являлась только Image, а не весь HStack
                                .alert(isPresented: $viewModel.showGroundDeleteAlert){
                                    Alert(title: Text("Delete ground?"), message: Text(""),
                                          primaryButton: .default (Text("Delete")) {
                                            viewModel.challenge!.grounds.removeAll(where: { $0.ground.documentID == viewModel.groundToDelete.documentID})
                                          },
                                          secondaryButton: .cancel()
                                    )
                                }
                            }
                            
                            
                            
                        }
                    }
                }
                if(viewModel.isEditingMode){
                    Button(action: { viewModel.isPresented.toggle() }){
                    HStack{
                        Image(systemName: "plus.circle").foregroundColor(Color("AccentColor"))
                        Text("Add ground").bold()
                    }
                    }.fullScreenCover(isPresented: $viewModel.isPresented) { ChallengeGroundPickerView(isPresented: $viewModel.isPresented, challenge: Binding($viewModel.challenge)!).environmentObject(db)
                }
                }
            }
            if(viewModel.isEditingMode){
            Section{
                Button(action: { viewModel.showChallengeDeleteAlert.toggle()}){
                    HStack{
                        Spacer()
                        Text("Delete").bold().foregroundColor(.red)
                        Spacer()
                    }
                }
            }.alert(isPresented: $viewModel.showChallengeDeleteAlert){
                Alert(title: Text("Are you sure?"), message: Text("This match will be deleted"),
                      primaryButton: .default (Text("Delete")) {
                        viewModel.deleteChallenge()
                      },
                      secondaryButton: .cancel()
                )
            }
            }
        }
        .onReceive(viewModel.viewDismissalModePublisher){ shouldDismiss in
            if shouldDismiss{
                presentationMode.wrappedValue.dismiss()
            }
            
        }
        .onAppear{
            viewModel.challenge = self.challenge
        }
        .onDisappear(){ viewModel.updateChallenge() }
        .navigationBarItems(trailing: Button(action: {viewModel.isEditingMode.toggle()}){
            if(!viewModel.isEditingMode){
                Text("Edit")
                    .padding()
            }
            if(viewModel.isEditingMode){
                Text("Done")
                    .padding()
            }
        })
    }
}

/*struct ChallengeDetailsView_Previews: PreviewProvider {
 static var previews: some View {
 ChallengeDetailsView()
 }
 }*/
