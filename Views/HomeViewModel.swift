//
//  HomeViewModel.swift
//  Groundbook
//
//  Created by admin on 22.02.2021.
//

import SwiftUI

class HomeViewModel: ObservableObject{
    
    init(){
        //заполняем массив (чтобы выбирать период для которого отображается статистика)
        let date = Date()
        
        let calendar = Calendar.current
        var year = calendar.component(.year, from: date)
        
        periodOptions.append("Overall")
        
        repeat{
            periodOptions.append(String(year))
            year -= 1
        }while(year >= 1970)
    }
    
    //для AddMatch
    @Published var isPresented = false
    
    //Для остального (выйти из аккаунта, написать разработчику)
    @Published var showingActionSheet = false
    
    //для выбора периода
    @Published var showPeriodPicker = false
    var periodOptions: [String] = [] //массив вариантов
    @Published var choosedPeriod = "Overall" //переменная для хранения актуального значения выбранного пользователем
}
