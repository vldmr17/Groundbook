//
//  ChallengeGroundsOfCountryView.swift
//  Groundbook
//
//  Created by admin on 07.01.2021.
//
import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct ChallengeGroundsOfCountryView: View {
    @EnvironmentObject var db: DBService
    
    //ID документа страны команды из которой выводим
    let countryID: String
    
    //переданный массив (св-во grounds) из родительской вьюхи, предполагается что в него буде добавлен новый элемент
    @Binding var challenge: Challenge
    
    //если false то закроется и родительская вьюха (для выбора страны)
    @Binding var isPresented: Bool
    
    //массив команд из текущей страны
    @State private var groundsOfCountry: [Ground] = [Ground]()
    
    @State private var searchText = ""
    
    func fetchGroundsOfCountry(countryID: String) {
        Firestore.firestore().collection("grounds").whereField("country", isEqualTo: "\(countryID)").order(by: "name")
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        
                        let documentID = document.documentID
                        
                        let data = document.data()
                        let name = data["name"] as? String ?? ""
                        let capacity = data["capacity"] as? Int ?? 0
                        let country = data["country"] as? String ?? ""
                        let photoPath = (data["photo"] as? String ?? "")
                        let coordinates = data["coordinates"] as? GeoPoint
                        let tenants = data["tenants"] as? [String]
                        
                        let latitude = coordinates?.latitude
                        let longitude = coordinates?.longitude
                        
                        //создаем экземпляр, инициализируя его полученными из Firestore значениями и с "пустым" URL тк URL к этому моменту еще не подгружен из Storage, он будет асинхронно подгружен позже и заменен на верный
                        let ground = Ground(id: .init(), documentID: documentID, name: name, capacity: capacity, isDemolished: false, opened: 0, country: Country(id: .init(), documentID: "", name: "", code: ""), photoURL: URL(string: "emptyurl")!, latitude: latitude!, longitude: longitude!, tenants: [])
                        groundsOfCountry.append(ground)
                        
                        //асинхронно подгружаем URL для загрузки лого команды
                        db.downloadURL(imagePath: photoPath) { data in
                            //data is value return by test function
                            DispatchQueue.main.async {
                                //data - значение, которое возвращает ф-ция downloadURL
                                let photoURL = data
                                
                                //подгрузили URL, теперь ищем нужный элемент в массиве и изменяем поле logoURL, которое ранее было инициализировано "пустым" значением
                                var index = 0
                                for ground in groundsOfCountry {
                                    if (ground.documentID == documentID){
                                        groundsOfCountry[index].photoURL = photoURL
                                    }
                                    index += 1
                                }
                            }
                        }
                    }
                }
            }
    }
    
    func isAlreadyPartOfChallenge(groundToCheck: Ground) -> Bool {
        var toReturn = false
        for ground in challenge.grounds {
            if(ground.ground.documentID == groundToCheck.documentID){
                toReturn = true
            }
        }
        
        return toReturn
    }
    
    var body: some View {
        VStack{
            SearchBar(text: $searchText)
            Form{
                List (groundsOfCountry.filter({ searchText.isEmpty ? true : $0.name.contains(searchText) })) { ground in
                    Button(action: {
                        self.challenge.grounds.append((id: .init(),ground: ground,isVisited: false))
                        //закрываем вьюху (и родительская с выбором страны тоже закроется)
                        self.isPresented = false
                    }){
                        Text(ground.name).foregroundColor(Color("TextUniversalColor"))
                    }
                    .disabled(isAlreadyPartOfChallenge(groundToCheck: ground)) //убираем возможность выбрать стадион если он уже используется для челленджа
                }.buttonStyle(PlainButtonStyle()) //чтобы disabled ячейки списка были серыми
            }.onAppear(perform: {
                fetchGroundsOfCountry(countryID: countryID)
            })
        }
    }
}

/*struct ChallengeGroundsOfCountryView_Previews: PreviewProvider {
 static var previews: some View {
        ChallengeGroundsOfCountryView()
    }
}*/
