//
//  AddMatchViewModel.swift
//  Groundbook
//
//  Created by admin on 19.02.2021.
//

import SwiftUI
import Firebase
import Combine

class AddMatchViewModel: ObservableObject{
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
    
    @Published var showErrorAlert = false
    
    //for team, ground and tournament pickers
    @Published var isPresented = false
    //for date picker
    @Published var isDatePickerPresented = false
    //for score picker
    @Published var isScorePickerPresented = false
    @Published var integers: [Int] = Array(0...100)
    
    let dateFormatter: DateFormatter = {
            let df = DateFormatter()
            df.dateStyle = .medium
            return df
    }()
    
    func addMatch () {
        if (away != nil && home != nil && ground != nil && tournament != nil){
            Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("matches").addDocument(data: [
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
                }
            }
        } else {
            showErrorAlert.toggle()
        }
    }
}
