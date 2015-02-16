//
//  LocalPins_TableViewController.swift
//  Local_Foto
//
//  Created by Tony on 2/12/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

import UIKit
import CoreLocation

class LocalPins_TableViewController: UITableViewController {
// Local variables
    var localPins = [LocalPinsModel]()
    
// Outlets and Actions
    @IBOutlet var myTableView: UITableView!


    override func viewWillAppear(animated: Bool) {
        // If location is saved then
        if let curLoc = NSUserDefaults.standardUserDefaults().objectForKey("userLocation") as? NSData{
            var coordinate: CLLocationCoordinate2D!
            curLoc.getBytes(&coordinate, length: sizeofValue(coordinate))
            self.getDataFromInstagram(coordinate.latitude, longitude: coordinate.longitude)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

// MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return localPins.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("localPinsReuseID", forIndexPath: indexPath) as UITableViewCell

        cell.textLabel?.text = localPins[indexPath.row].name

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        self.performSegueWithIdentifier("showLocalPinPhotos", sender: indexPath)
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showLocalPinPhotos"){
            let destVC: MainScreen_ViewController = segue.destinationViewController as MainScreen_ViewController
            let indexPath: NSIndexPath = (sender as NSIndexPath)
            destVC.requestedPin = localPins[indexPath.row]
            destVC.controllerState = .Pin
        }
    }
    
    func getDataFromInstagram(latitude: CLLocationDegrees!, longitude: CLLocationDegrees!){
        let lat  = NSString(format: "%f", latitude)
        let long = NSString(format: "%f", longitude)
        
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("accessToken") as NSString
        // getDataFromInstagram
        let requestURL = NSString(format: "https://api.instagram.com/v1/locations/search?lat=%@&lng=%@&distance=4000&access_token=%@",lat, long, accessToken)
        
        DataManager.getDataFromInstagramWithSuccess(requestURL, success: {(instagramData, error)->Void in
            if(error != nil){
                println("Some error occurred")
            }else{
                if let pinsArray = instagramData["data"].array{
                    for val in pinsArray {
                        var name        = val["name"].string
                        var id          = val["id"].string
                        var coord       = val["latitude"].double
                        var latitude    = NSString(format: "%f", val["latitude"].double!)
                        var longitude   = NSString(format: "%f", val["longitude"].double!)
                        
                        self.localPins.append(LocalPinsModel(lat: latitude, long: longitude, Name: name, ID: id))
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.myTableView.reloadData()
                    })
                }
            }
        })
    }
}
