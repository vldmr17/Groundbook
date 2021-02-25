//
//  MapView.swift
//  Groundbook
//
//  Created by admin on 25.01.2021.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    var annotations: [GroundAnnotation]
    
    @Binding var isActive: Bool
    @Binding var selectedAnnotation: GroundAnnotation
    
    func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: UIViewRepresentableContext<MapView>) {
        view.delegate = context.coordinator
            view.removeAnnotations(view.annotations)
            view.addAnnotations(annotations)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }
        
        //обрабатываем нажатие кнопки в аннотации
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            let anno = view.annotation as! GroundAnnotation
            
            parent.selectedAnnotation = anno
            parent.isActive = true
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
            view.canShowCallout = true
                
                if let groundAnnotation = annotation as? GroundAnnotation{
                    if groundAnnotation.isVisited {
                        view.pinTintColor = .green
                        //view.image = UIImage(named: "GreenPin")
                    }
                    if !groundAnnotation.isVisited {
                        view.pinTintColor = .red
                        //view.image = UIImage(named: "RedPin")
                    }
                }
                
               //добавляем кнопку в аннтотацию, обработка нажатия происходит в функции mapView(mapView:view:control:)
                let btn = UIButton(type: .detailDisclosure)
                view.rightCalloutAccessoryView = btn
            
                return view
        }
    }
}

/*struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}*/

class GroundAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    let isVisited: Bool
    let ground: Ground
    
    init(ground: Ground, isVisited: Bool, basic: MKPointAnnotation)  {
        self.ground = ground
        self.isVisited = isVisited
        title = basic.title
        subtitle = basic.subtitle
        coordinate = basic.coordinate
    }
}
