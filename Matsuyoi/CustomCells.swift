////
////  CustomCells.swift
////  Matsuyoi
////
////  Created by shinkatayama on 2017/08/16.
////  Copyright © 2017年 shinkatayama. All rights reserved.
////
////
//import Foundation
//import UIKit
//import MapKit
//import Eureka
//
////MARK: LocationRow
//
//public final class LocationRow: OptionsRow<PushSelectorCell<CLLocation>>, PresenterRowType, RowType {
//    
//    
//    public typealias PresenterRow = MapViewController
//    
//    /// Defines how the view controller will be presented, pushed, etc.
//    open var presentationMode: PresentationMode<PresenterRow>?
//    
//    /// Will be called before the presentation occurs.
//    open var onPresentCallback: ((FormViewController, PresenterRow) -> Void)?
//    
//    
//    
//    public required init(tag: String?) {
//        super.init(tag: tag)
//        presentationMode = .show(controllerProvider: ControllerProvider.callback { return MapViewController(){ _ in } }, onDismiss: { vc in _ = vc.navigationController?.popViewController(animated: true) })
//        
//        displayValueFor = {
//            guard let location = $0 else { return "" }
//            let fmt = NumberFormatter()
//            fmt.maximumFractionDigits = 4
//            fmt.minimumFractionDigits = 4
//            let latitude = fmt.string(from: NSNumber(value: location.coordinate.latitude))!
//            let longitude = fmt.string(from: NSNumber(value: location.coordinate.longitude))!
//            return  "\(latitude), \(longitude)"
//        }
//    }
//    
//    /**
//     Extends `didSelect` method
//     */
//    open override func customDidSelect() {
//        super.customDidSelect()
//        guard let presentationMode = presentationMode, !isDisabled else { return }
//        if let controller = presentationMode.makeController() {
//            controller.row = self
//            controller.title = selectorTitle ?? controller.title
//            onPresentCallback?(cell.formViewController()!, controller)
//            presentationMode.present(controller, row: self, presentingController: self.cell.formViewController()!)
//        } else {
//            presentationMode.present(nil, row: self, presentingController: self.cell.formViewController()!)
//        }
//    }
//    
//    /**
//     Prepares the pushed row setting its title and completion callback.
//     */
//    open override func prepare(for segue: UIStoryboardSegue) {
//        super.prepare(for: segue)
//        guard let rowVC = segue.destination as? PresenterRow else { return }
//        rowVC.title = selectorTitle ?? rowVC.title
//        rowVC.onDismissCallback = presentationMode?.onDismissCallback ?? rowVC.onDismissCallback
//        onPresentCallback?(cell.formViewController()!, rowVC)
//        rowVC.row = self
//    }
//}
//
//public class MapViewController : UIViewController, TypedRowControllerType, MKMapViewDelegate {
//    
//    var locationManager : CLLocationManager?
//
//    public var row: RowOf<CLLocation>!
//    public var onDismissCallback: ((UIViewController) -> ())?
//    
//    lazy var mapView : MKMapView = { [unowned self] in
//        let v = MKMapView(frame: self.view.bounds)
//        v.autoresizingMask = UIViewAutoresizing.flexibleWidth.union(.flexibleHeight)
//        return v
//        }()
//
//    lazy var pinView: UIImageView = { [unowned self] in
//        let v = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
//        v.image = UIImage(named: "placeholder", in: Bundle(for: MapViewController.self), compatibleWith: nil)
//        v.image = v.image?.withRenderingMode(.alwaysTemplate)
//        v.tintColor = self.view.tintColor
//        v.backgroundColor = .clear
//        v.clipsToBounds = true
//        v.contentMode = .scaleAspectFit
//        v.isUserInteractionEnabled = false
//        return v
//        }()
//    
//    let width: CGFloat = 10.0
//    let height: CGFloat = 5.0
//    
//    lazy var ellipse: UIBezierPath = { [unowned self] in
//        let ellipse = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: self.width, height: self.height))
//        return ellipse
//        }()
//    
//    
//    lazy var ellipsisLayer: CAShapeLayer = { [unowned self] in
//        let layer = CAShapeLayer()
//        layer.bounds = CGRect(x: 0, y: 0, width: self.width, height: self.height)
//        layer.path = self.ellipse.cgPath
//        layer.fillColor = UIColor.gray.cgColor
//        layer.fillRule = kCAFillRuleNonZero
//        layer.lineCap = kCALineCapButt
//        layer.lineDashPattern = nil
//        layer.lineDashPhase = 0.0
//        layer.lineJoin = kCALineJoinMiter
//        layer.lineWidth = 1.0
//        layer.miterLimit = 10.0
//        layer.strokeColor = UIColor.gray.cgColor
//        return layer
//        }()
//    
//    
//    required public init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//    
//    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    convenience public init(_ callback: ((UIViewController) -> ())?){
//        self.init(nibName: nil, bundle: nil)
//        onDismissCallback = callback
//    }
//    
//    public override func viewDidLoad() {
//        super.viewDidLoad()
//        view.addSubview(mapView)
//        
//
//        mapView.delegate = self
//        mapView.addSubview(pinView)
//        mapView.layer.insertSublayer(ellipsisLayer, below: pinView.layer)
//        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(MapViewController.tappedDone(_:)))
//        button.title = "Done"
//        navigationItem.rightBarButtonItem = button
//        
//        if locationManager != nil { return }
//        locationManager = CLLocationManager()
//        
//        locationManager?.requestWhenInUseAuthorization()
//        
//        if CLLocationManager.locationServicesEnabled() {
//            locationManager?.startUpdatingLocation()
//        }
//        // tracking user location
//        mapView.userTrackingMode = MKUserTrackingMode.followWithHeading
//        mapView.showsUserLocation = true
//        
//    
//        if let value = row.value {
//            let region = MKCoordinateRegionMakeWithDistance(value.coordinate, 400, 400)
//            mapView.setRegion(region, animated: true)
//        }
//        else{
//            mapView.showsUserLocation = true
//        }
//        updateTitle()
//        
//    }
//    
//    
//    
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let newLocation = locations.last else {
//            return
//        }
//        
//        let location:CLLocationCoordinate2D
//            = CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude)
//            
//        // update annotation
//        mapView.removeAnnotations(mapView.annotations)
//        
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = newLocation.coordinate
//        mapView.addAnnotation(annotation)
//        mapView.selectAnnotation(annotation, animated: true)
//        
//        // Showing annotation zooms the map automatically.
//        mapView.showAnnotations(mapView.annotations, animated: true)
//        
//    }
//    
//    public override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        let center = mapView.convert(mapView.centerCoordinate, toPointTo: pinView)
//        pinView.center = CGPoint(x: center.x, y: center.y - (pinView.bounds.height/2))
//        ellipsisLayer.position = center
//    }
//    
//    
//    func tappedDone(_ sender: UIBarButtonItem){
//        let target = mapView.convert(ellipsisLayer.position, toCoordinateFrom: mapView)
//        row.value = CLLocation(latitude: target.latitude, longitude: target.longitude)
//        onDismissCallback?(self)
//    }
//    
//    func updateTitle(){
//        let fmt = NumberFormatter()
//        fmt.maximumFractionDigits = 4
//        fmt.minimumFractionDigits = 4
//        let latitude = fmt.string(from: NSNumber(value: mapView.centerCoordinate.latitude))!
//        let longitude = fmt.string(from: NSNumber(value: mapView.centerCoordinate.longitude))!
//        title = "\(latitude), \(longitude)"
//    }
//    
//    public func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
//        ellipsisLayer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
//        UIView.animate(withDuration: 0.2, animations: { [weak self] in
//            self?.pinView.center = CGPoint(x: self!.pinView.center.x, y: self!.pinView.center.y - 10)
//        })
//    }
//    
//    
//    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//        ellipsisLayer.transform = CATransform3DIdentity
//        UIView.animate(withDuration: 0.2, animations: { [weak self] in
//            self?.pinView.center = CGPoint(x: self!.pinView.center.x, y: self!.pinView.center.y + 10)
//        })
//        updateTitle()
//    }
//}
//
//extension MKPlacemark {
//    var address: String {
//        let components = [self.administrativeArea, self.locality, self.thoroughfare, self.subThoroughfare]
//        return components.flatMap { $0 }.joined(separator: "")
//    }
//}

