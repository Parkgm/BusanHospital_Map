//
//  ViewController.swift
//  BusanElementarySchool
//
//  Created by 김종현 on 2017. 4. 29..
//  Copyright © 2017년 김종현. All rights reserved.
//  XCode 10.1

import UIKit
import MapKit

class ViewController: UIViewController, XMLParserDelegate, MKMapViewDelegate  {
    
    @IBOutlet weak var mapView: MKMapView!
    var item:[String:String] = [:]
    // item 딕셔너리를 저장할 배열
    var elements:[[String:String]] = []
    // 현재의 tag(element)를 저장
    var currentElement = ""
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "부산 종합병원 지도"
        mapView.delegate = self
        dataParsing()
        viewMap()
    }
    
    func  viewMap() {
        for school in elements {
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(school["주소"]! , completionHandler: {
                (placemarks: [CLPlacemark]?, error: Error?) -> Void in
                if let error = error {
                    print(error)
                    return
                }
                
                if placemarks != nil {
                    let placemark = placemarks![0]
                    print(placemarks![0])
                    
                    // pin point 을 저장
                    let annotation = MKPointAnnotation()
                    
                    if let location = placemark.location {
                        // Add annotation
                        annotation.title = school["병원명"]
                        annotation.coordinate = location.coordinate
                        annotation.subtitle = school["전화번호"]
                        self.annotations.append(annotation)
                    }
                }
                self.mapView.showAnnotations(self.annotations, animated: true)
            })
        }
        //mapView.showAnnotations(self.annotations, animated: true)
    }

    
    func dataParsing() {
        if let path = Bundle.main.url(forResource: "busanhospital", withExtension: "xml") {
            if let parser = XMLParser(contentsOf: path) {
                parser.delegate = self
                
                if parser.parse() {
                    print("parsing succed")
                     //print(elements)
                    
                } else {
                    print("parsing failed")
                }
            }
        } else {
            print("xml 화일을 찾지 못함")
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseID = "RE"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKMarkerAnnotationView
        
        if annotation is MKUserLocation {
            return nil
        }
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            annotationView!.canShowCallout = true
            annotationView?.animatesWhenAdded = true
            annotationView?.clusteringIdentifier = "CL"
            
        } else {
            annotationView?.annotation = annotation
        }
        
        let btn = UIButton(type: .detailDisclosure)
        annotationView?.rightCalloutAccessoryView = btn
        return annotationView
    }

    // NSXMLParse delegate method 실행
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentElement = elementName
    }
    
    // <tag> 다음에 </tag> 전에 string이 있을때 호출되는 델리게이트 함수
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        //let data2 = data.components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
        
        //print("data = \(data)")
        
        if !data.isEmpty {
            item[currentElement] = string
        }
    }
    
    // </item>를 만나면 item 딕셔너리를 배열 elements에 저장
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "Row" {
            elements.append(item)
        }
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            
        }
    }

}

