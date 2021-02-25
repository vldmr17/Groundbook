//
//  AddChallengeView.swift
//  Groundbook
//
//  Created by admin on 01.01.2021.
//

import SwiftUI
import Firebase

struct AddChallengeView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var db: DBService
    @StateObject var viewModel = AddChallengeViewModel()
    
    /*@State var name = ""
    @State var description = ""
    
    @State var challenge = Challenge(id: .init(), documentID: "", name: "", description: "", grounds: [])
    
    //для ChallengeGroundPickerView
    @State var isPresented = false
    
    @State var showDeleteAlert = false
    
    @State var showErrorAlert = false
    
    //сохраняем элемент который возможно будет удален (используется в алерте)
    @State var groundToDelete = Ground(id: .init(), documentID: "", name: "", capacity: 0, isDemolished: false, opened: 0, country: Country(id: .init(), documentID: "", name: "", code: ""), photoURL: URL(string: "emptyurl")!, latitude: 0.0, longitude: 0.0, tenants: [])
    
    func addChallenge () {
        var grounds: [[String:Any]] = []
        
        for ground in challenge.grounds {
            let dict: [String : Any] = ["ground":ground.ground.documentID,"isVisited":false]
            grounds.append(dict)
        }
        
        if (name != "" && description != "" && grounds.count != 0){
            Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("challenges").addDocument(data: [
                "name": "\(name)",
                "description": "\(description)",
                "grounds": grounds
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        } else {
            showErrorAlert.toggle()
        }
    }*/
    
    var body: some View {
        Form{
            Section(header: Text("Name")){
                TextField("Type challenge name", text: $viewModel.name)
            }
            
            Section(header: Text("Description")){
                TextEditor(text: $viewModel.description)
            }
            
            Section(header: Text("Grounds")){
                List {
                    ForEach(viewModel.challenge.grounds, id:\.0){ ground in
                        HStack{
                            Text(ground.ground.name)
                            Spacer()
                            Button(action: { viewModel.showDeleteAlert.toggle()
                                viewModel.groundToDelete = ground.ground
                            }){
                                Image(systemName: "minus.circle").foregroundColor(.red)
                            }.buttonStyle(PlainButtonStyle()) //чтобы кнопкой являлась только Image, а не весь HStack
                            .alert(isPresented: $viewModel.showDeleteAlert){
                                Alert(title: Text("Delete ground?"), message: Text(""),
                                      primaryButton: .default (Text("Delete")) {
                                        viewModel.challenge.grounds.removeAll(where: { $0.ground.documentID == viewModel.groundToDelete.documentID})
                                      },
                                      secondaryButton: .cancel()
                                )
                            }
                        }
                    }
                }
                Button(action: { viewModel.isPresented.toggle() }){
                    HStack{
                        Image(systemName: "plus.circle").foregroundColor(Color("AccentColor"))
                        Text("Add ground").bold()
                    }
                }.fullScreenCover(isPresented: $viewModel.isPresented) { ChallengeGroundPickerView(isPresented: $viewModel.isPresented, challenge: $viewModel.challenge).environmentObject(db)
                }
            }
            
            Section{
                Button(action: { viewModel.addChallenge()}){
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
        .onReceive(viewModel.viewDismissalModePublisher) { shouldDismiss in
        if shouldDismiss {
            self.presentationMode.wrappedValue.dismiss()
        }
    }
        
    }
}

/*struct AddChallengeView_Previews: PreviewProvider {
    static var previews: some View {
        AddChallengeView()
    }
}*/

struct ChallengeGrounds: Identifiable {
    let id: UUID = .init()
    var ground: Ground?
    var isVisited: Bool = false
}
