//
//  EditMatchViewModel.swift
//  Groundbook
//
//  Created by admin on 22.02.2021.
//

import SwiftUI
import Combine
import Firebase

class EditMatchViewModel: ObservableObject{
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    @Published var home: Team?
    @Published var away: Team?
    @Published var ground: Ground?
    @Published var tournament: Tournament?
    @Published var date = Date()
    @Published var homeScore: Int = 0
    @Published var awayScore: Int = 0
    
    @Published var match: Match?
    
    //for team, ground and tournament pickers
    @Published var isPresented = false
    //for date picker
    @Published var isDatePickerPresented = false
    //for score picker
    @Published var isScorePickerPresented = false
    @Published var integers: [Int] = Array(0...100)
    
    @Published var showDeleteAlert = false
    
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()
    
    func editMatch () {
        Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("matches").document(match!.documentID).updateData([
            "home": "\(home!.documentID)",
            "away": "\(away!.documentID)",
            "homeScore": homeScore,
            "awayScore": awayScore,
            "ground": "\(ground!.documentID)",
            "tournament": "\(tournament!.documentID)",
            "date": date
        ]) { err in
            if let err = err {
                //print("Error adding document: \(err)")
            } else {
                self.shouldDismissView = true
                //self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    func deleteMatch () {
        Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("matches").document(match!.documentID).delete() { err in
            if let err = err {
                //print("Error removing document: \(err)")
            } else {
                //self.presentationMode.wrappedValue.dismiss()
                self.shouldDismissView = true
            }
        }
    }
}
