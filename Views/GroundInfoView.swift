//
//  GroundInfo.swift
//  Groundbook
//
//  Created by admin on 31.12.2020.
//

import SwiftUI
import SDWebImageSwiftUI
import FlagKit

struct GroundInfoView: View {
    var ground: Ground
    
    var body: some View {
        Form{
            Section(header: Text("Photo")){
                WebImage(url: ground.photoURL).resizable().scaledToFit().frame(maxWidth: 300, maxHeight: 300)
            }
            Section(header: Text("Capacity")){
                    Text(String(ground.capacity))
            }
            Section(header: Text("Opened")){
                Text(String(ground.opened))
            }
            Section(header: Text(ground.tenants.isEmpty ? "" : (ground.tenants.count == 1 ? "Tenant" : "Tenants"))){
                ForEach(ground.tenants){tenant in
                    HStack{
                        WebImage(url: tenant.logoURL).resizable().scaledToFit().frame(maxWidth: 40, maxHeight: 40)
                        Text(tenant.name)
                    }
                }
            }
        }.navigationTitle(ground.name)
        
    }
}

/*struct GroundInfo_Previews: PreviewProvider {
    static var previews: some View {
        GroundInfo()
    }
}*/
