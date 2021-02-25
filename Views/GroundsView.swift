//
//  GroundsView.swift
//  Groundbook
//
//  Created by admin on 04.12.2020.
//

import SwiftUI
import FlagKit

struct GroundsView: View {
    @EnvironmentObject var db: DBService
    
    @State private var grounds: VisitedGrounds?
    
    var arrayOfGrounds: [Ground]
    
    var body: some View {
        List{
            if(grounds != nil){
            ForEach(grounds!.sections){section in
                Section(header: HStack {
                            Image(uiImage: Flag(countryCode: section.grounds[0].country.code)!.image(style: .roundedRect)).resizable().scaledToFit().frame(maxWidth: 30, maxHeight: 30)
                            Text(section.country)}){
                    ForEach(section.grounds){ ground in
                        HStack{
                            SGNavigationLink(destination: GroundMatchesView(ground: ground, allMatches: db.matches)){
                                Text(ground.name)
                            }
                            Spacer()
                            SGNavigationLink(destination: GroundInfoView(ground: ground)){
                                Image(systemName: "info.circle")
                            }
                        }
                    }
                }
            }
            }
        }.onAppear(){
            self.grounds = VisitedGrounds(arrayOfGrounds: arrayOfGrounds)
        }
        .navigationTitle(Text("My Grounds"))
    }
}



struct VisitedGrounds{
    var sections: [Countries] = []
    
    init(arrayOfGrounds: [Ground]){
        let grounds = arrayOfGrounds.sorted { $0.name < $1.name }
        
        let grouped = Dictionary(grouping: grounds) { (ground: Ground) -> String in
            (ground.country.name) //тут страна стадиона
        }
        
        self.sections = grouped.map { countries -> Countries in
            Countries(country: countries.key, grounds: countries.value)
        }
        
        sections.sort(by: {$0.country < $1.country} )
    }
    
    struct Countries: Identifiable {
        let id = UUID()
        let country: String
        let grounds: [Ground]
    }
}

//SGNaviagtionLink позволяет использовать несколько нав линкс в одном ряду списка
struct SGNavigationLink<Content, Destination>: View where Destination: View, Content: View {
    let destination:Destination?
    let content: () -> Content


    @State private var isLinkActive:Bool = false

    init(destination: Destination, title: String = "", @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.destination = destination
    }

    var body: some View {
        return ZStack (alignment: .leading){
            if self.isLinkActive{
                NavigationLink(destination: destination, isActive: $isLinkActive){Color.clear}.frame(height:0)
            }
            content()
        }
        .onTapGesture {
            self.pushHiddenNavLink()
        }
    }

    func pushHiddenNavLink(){
        self.isLinkActive = true
    }
}

/*struct GroundsView_Previews: PreviewProvider {
    static var previews: some View {
        GroundsView()
    }
}*/
