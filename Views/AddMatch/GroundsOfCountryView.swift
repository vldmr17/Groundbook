//
//  GroundsOfCountryView.swift
//  Groundbook
//
//  Created by admin on 02.12.2020.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct GroundsOfCountryView: View {
    @EnvironmentObject var db: DBService
    
    //ID документа страны команды из которой выводим
    let countryID: String
    
    @Binding var ground: Ground?
    
    //если false то закроется и родительская вьюха (для выбора страны)
    @Binding var isPresented: Bool
    
    //массив команд из текущей страны
    @State private var grounds: [Ground] = [Ground]()
    
    @State private var searchText = ""
    
    func fetchGroundsOfCountry(countryID: String) {
        Firestore.firestore().collection("grounds").whereField("country", isEqualTo: "\(countryID)").order(by: "name")
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
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
                        grounds.append(ground)
                        
                        //асинхронно подгружаем URL для загрузки лого команды
                        db.downloadURL(imagePath: photoPath) { data in
                            //data is value return by test function
                            DispatchQueue.main.async {
                                //data - значение, которое возвращает ф-ция downloadURL
                                let photoURL = data
                                
                                //подгрузили URL, теперь ищем нужный элемент в массиве и изменяем поле logoURL, которое ранее было инициализировано "пустым" значением
                                var index = 0
                                for ground in grounds {
                                    if (ground.documentID == documentID){
                                        grounds[index].photoURL = photoURL
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
                List (grounds.filter({ searchText.isEmpty ? true : $0.name.contains(searchText) })) { ground in
                    Button(action: {
                        self.ground = ground
                        //закрываем вьюху (и родительская с выбором страны тоже закроется)
                        self.isPresented = false
                    }){
                        Text(ground.name).foregroundColor(Color("TextUniversalColor"))
                    }
                }
            }.onAppear(perform: {
                fetchGroundsOfCountry(countryID: countryID)
            })
        }
    }
}
/*struct GroundsOfCountry_Previews: PreviewProvider {
 static var previews: some View {
 GroundsOfCountry()
 }
 }*/
