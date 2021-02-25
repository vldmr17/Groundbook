//
//  TournamentsOfCountryView.swift
//  Groundbook
//
//  Created by admin on 02.12.2020.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct TournamentsOfCountryView: View {
    @EnvironmentObject var db: DBService
    
    //ID документа страны команды из которой выводим
    let countryID: String
    
    @Binding var tournament: Tournament?
    
    //если false то закроется и родительская вьюха (для выбора страны)
    @Binding var isPresented: Bool
    
    //массив команд из текущей страны
    @State private var tournaments: [Tournament] = [Tournament]()
    
    @State private var searchText = ""
    
    func fetchTournamentsOfCountry(countryID: String) {
        Firestore.firestore().collection("tournaments").whereField("country", isEqualTo: "\(countryID)").order(by: "name")
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        //print("\(document.documentID) => \(document.data())")
                        
                        let documentID = document.documentID
                        
                        let data = document.data()
                        let name = data["name"] as? String ?? ""
                        let country = data["country"] as? String ?? ""
                        
                        let logoPath = (data["logo"] as? String ?? "")
                        
                        //создаем экземпляр, инициализируя его полученными из Firestore значениями и с "пустым" URL тк URL к этому моменту еще не подгружен из Storage, он будет асинхронно подгружен позже и заменен на верный
                        let tournament = Tournament(id: .init(), documentID: documentID, name: name, logoURL: URL(string: "emptyurl")!, country: Country(id: .init(), documentID: "", name: "", code: ""))
                        tournaments.append(tournament)
                        
                        //асинхронно подгружаем URL для загрузки лого команды
                        db.downloadURL(imagePath: logoPath) { data in
                            //data is value return by test function
                            DispatchQueue.main.async {
                                //data - значение, которое возвращает ф-ция downloadURL
                                let logoURL = data
                                
                                //подгрузили URL, теперь ищем нужный элемент в массиве и изменяем поле logoURL, которое ранее было инициализировано "пустым" значением
                                var index = 0
                                for tournament in tournaments {
                                    if (tournament.documentID == documentID){
                                        tournaments[index].logoURL = logoURL
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
                List (tournaments.filter({ searchText.isEmpty ? true : $0.name.contains(searchText) })) { tournament in
                    Button(action: {
                        self.tournament = tournament
                        //закрываем вьюху (и родительская с выбором страны тоже закроется)
                        self.isPresented = false
                    }){
                        HStack{
                            WebImage(url: tournament.logoURL).resizable().scaledToFit().frame(maxWidth: 40, maxHeight: 40)
                            Text(tournament.name).foregroundColor(Color("TextUniversalColor"))
                        }
                    }
                }
            }.onAppear(perform: {
                fetchTournamentsOfCountry(countryID: countryID)
            })
        }
    }
}

/*struct TournamentsOfCountry_Previews: PreviewProvider {
    static var previews: some View {
        TournamentsOfCountry()
    }
}*/
