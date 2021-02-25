//
//  AddChallengeViewModel.swift
//  Groundbook
//
//  Created by admin on 21.02.2021.
//

import SwiftUI
import Firebase
import Combine

class AddChallengeViewModel: ObservableObject{
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    @Published var name = ""
    @Published var description = ""
    
    @Published var challenge = Challenge(id: .init(), documentID: "", name: "", description: "", grounds: [])
    
    //для ChallengeGroundPickerView
    @Published var isPresented = false
    
    @Published var showDeleteAlert = false
    
    @Published var showErrorAlert = false
    
    //сохраняем элемент который возможно будет удален (используется в алерте)
    @Published var groundToDelete = Ground(id: .init(), documentID: "", name: "", capacity: 0, isDemolished: false, opened: 0, country: Country(id: .init(), documentID: "", name: "", code: ""), photoURL: URL(string: "emptyurl")!, latitude: 0.0, longitude: 0.0, tenants: [])
    
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
                    self.shouldDismissView = true
                }
            }
        } else {
            showErrorAlert.toggle()
        }
    }
}
