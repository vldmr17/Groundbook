//
//  TeamsOfCountryView.swift
//  Groundbook
//
//  Created by admin on 01.12.2020.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct TeamsOfCountryView: View {
    @EnvironmentObject var db: DBService
    
    //ID документа страны команды из которой получаем
    let countryID: String
    
    @Binding var team: Team?
    
    //если false то закроется и родительская вьюха (для выбора страны)
    @Binding var isPresented: Bool
    
    //массив команд из текущей страны
    @State private var teams: [Team] = [Team]()
    
    @State private var searchText = ""
    
    func fetchTeamsOfCountry(countryID: String) {
        Firestore.firestore().collection("teams").whereField("country", isEqualTo: "\(countryID)").order(by: "name")
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        //print("\(document.documentID) => \(document.data())")
                        
                        let documentID = document.documentID
                        
                        let data = document.data()
                        let name = data["name"] as? String ?? ""
                        let venue = data["venue"] as? String ?? ""
                        let country = data["country"] as? String ?? ""
                        
                        let logoPath = data["logo"] as? String ?? ""
                        
                        //создаем экземпляр, инициализируя его полученными из Firestore значениями и с "пустым" URL тк URL к этому моменту еще не подгружен из Storage, он будет асинхронно подгружен позже и заменен на верный
                        let team = Team(id: .init(), documentID: documentID, name: name, logoURL: URL(string: "emptyurl")!, venue: venue, country: Country(id: .init(), documentID: "", name: "", code: ""))
                        teams.append(team)
                        
                        //асинхронно подгружаем URL для загрузки лого команды
                        db.downloadURL(imagePath: logoPath) { data in
                            //data is value return by test function
                            DispatchQueue.main.async {
                                //data - значение, которое возвращает ф-ция downloadURL
                                let logoURL = data
                                
                                //подгрузили URL, теперь ищем нужный элемент в массиве и изменяем поле logoURL, которое ранее было инициализировано "пустым" значением
                                var index = 0
                                for team in teams {
                                    if (team.documentID == documentID){
                                        teams[index].logoURL = logoURL
                                    }
                                    index += 1
                                }
                            }
                        }
                    }
                }
            }
    }
    
    var body: some View {
        VStack{
            SearchBar(text: $searchText)
            Form{
                List (teams.filter({ searchText.isEmpty ? true : $0.name.contains(searchText) })) { team in
                    Button(action: {
                        self.team = team
                        //закрываем вьюху (и родительская с выбором страны тоже закроется)
                        self.isPresented = false
                    }){
                        HStack{
                            WebImage(url: team.logoURL).resizable().scaledToFit().frame(maxWidth: 40, maxHeight: 40)
                            Text(team.name).foregroundColor(Color("TextUniversalColor"))
                        }
                    }
                }
            }.onAppear(perform: {
                fetchTeamsOfCountry(countryID: countryID)
            })
        }
    }
}

/*struct TeamsOfCountryView_Previews: PreviewProvider {
    static var previews: some View {
        TeamsOfCountryView()
    }
}*/
