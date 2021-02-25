//
//  ChallengeDetailsViewModel.swift
//  Groundbook
//
//  Created by admin on 22.02.2021.
//

import SwiftUI
import Firebase
import Combine

class ChallengeDetailsViewModel: ObservableObject{
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    @Published var challenge: Challenge? = Challenge(id: .init(), documentID: "", name: "", description: "", grounds: [])
    
    //для открытия ChallengeGroundPickerView
    @Published var isPresented = false
    
    @Published var isEditingMode = false
    
    @Published var showGroundDeleteAlert = false
    
    @Published var showChallengeDeleteAlert = false
    
    @Published var groundToDelete: Ground = Ground(id: .init(), documentID: "", name: "", capacity: 0, isDemolished: false, opened: 0, country: Country(id: .init(), documentID: "", name: "", code: ""), photoURL: URL(string: "emptyurl")!, latitude: 0.0, longitude: 0.0, tenants: [])
    
    func updateChallenge () {
        var grounds: [[String:Any]] = []
        
        for ground in challenge!.grounds {
            let dict: [String : Any] = ["ground":ground.ground.documentID,"isVisited":ground.isVisited]
            grounds.append(dict)
        }
        
        Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("challenges").document(challenge!.documentID).updateData([
            "name": challenge!.name,
            "description": challenge!.description,
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
        Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("challenges").document(challenge!.documentID).delete() { err in
            if let err = err {
                //print("Error removing document: \(err)")
            } else {
                //self.presentationMode.wrappedValue.dismiss()
                self.shouldDismissView = true
            }
        }
    }
}
