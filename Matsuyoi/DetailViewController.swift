//
//  DetailViewController.swift
//  Matsuyoi
//
//  Created by shinkatayama on 2017/07/29.
//  Copyright © 2017年 shinkatayama. All rights reserved.
//

import UIKit
import ZKCarousel
import MapKit


class DetailViewController: UIViewController {

    @IBOutlet weak var mapPoint: MKMapView!
    var SelectedList:[SpotList] = []
    var SelectedUrl:String? = nil
    var SelectedInfo:String? = nil
    var SelectedName:String? = nil
    
    // Instantiated and used with Storyboards
    @IBOutlet var carousel: ZKCarousel! = ZKCarousel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let coordinate = CLLocationCoordinate2DMake(37.331652997806785, -122.03072304117417)
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(coordinate, span)
        mapPoint.setRegion(region, animated:true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(37.331652997806785, -122.03072304117417)
        self.mapPoint.addAnnotation(annotation)
        
        SelectedUrl = SelectedList[0].url
        SelectedInfo = SelectedList[0].info
        SelectedName = SelectedList[0].name
        
        print(SelectedUrl)
        
        if(SelectedUrl != nil){
            // Setup
            self.setupCarousel()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    func setupCarousel() {
        
        let url: NSURL = NSURL(string:SelectedUrl!)!  //urlの文字列を与えてNSURLのインスタンスを作成
        let imageData = try? Data(contentsOf: url as URL)
        let image = UIImage(data:imageData!)

        // Create as many slides as you'd like to show in the carousel
        let slide = ZKCarouselSlide(image: image!,  title: "", description: SelectedName!)
        let slideArray = [slide]
        // Add the slides to the carousel
        self.carousel.slides = slideArray
    
    }

}

