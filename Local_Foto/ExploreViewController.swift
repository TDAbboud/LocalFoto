//
//  FirstViewController.swift
//  Demo-iOS
//
//  Created by Constantine Fry on 08/11/14.
//  Copyright (c) 2014 Constantine Fry. All rights reserved.
//

import UIKit

/** Shows result from `explore` endpoint. And has search controller to search in nearby venues. */
class ExploreViewController: UITableViewController, SearchTableViewControllerDelegate, UISearchBarDelegate {
    
    private enum exploreSections: String{
        case Food       = "Food"
        case Drinks     = "Drinks"
        case Coffee     = "Coffee"
        case Shops      = "Shops"
        case Arts       = "Arts"
        case Outdoors   = "Outdoor Sights"
        case Trending   = "Trending"
        case Specials   = "Specials"
        case TopPicks   = "Top Picks"
        
        static let allValues = [Food, Drinks, Coffee, Shops, Arts, Outdoors, Trending, Specials, TopPicks]
        static let count = allValues.count
    }

    private let iconDictionary: [exploreSections: String] =
    [   .Food:      "Food-48.png",
        .Drinks:    "Drinks-64.png",
        .Coffee:    "Coffee-64.png",
        .Shops:     "Shop-64.png",
        .Arts:      "Art-64.png",
        .Outdoors:  "Outdoor-128.png",
        .Trending:  "Trending-128.png",
        .Specials:  "Specials-128.png",
        .TopPicks:  "TopPicks-128.png"
    ]

    
    var category: String!
    var venueInfo: JSON!
    var searchController: UISearchController!
    var resultsTableViewController: SearchTableViewController!
    let ManagerSingleton = Manager.sharedInstance
    let sharedIGEngine = InstagramEngine.sharedEngine()

    let numberFormatter = NSNumberFormatter()
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showCollection"{
            let dVC = segue.destinationViewController as venuePhoto_CollectionViewController
            dVC.venueDetails = self.venueInfo
        }else if(segue.identifier == "showExploreDetails"){
            let destVC = segue.destinationViewController as ExploreDetails_TableViewController
            destVC.category = self.category
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        
        numberFormatter.numberStyle = .DecimalStyle
        
        resultsTableViewController = Storyboard.create("venueSearch") as SearchTableViewController
        resultsTableViewController.delegate = self
        resultsTableViewController.location = ManagerSingleton.currentLocation
        searchController = UISearchController(searchResultsController: resultsTableViewController)
        searchController.searchResultsUpdater = resultsTableViewController
        searchController.searchBar.sizeToFit()
        searchController.searchBar.delegate = resultsTableViewController
        tableView.tableHeaderView = searchController.searchBar
        self.definesPresentationContext = true
        
    }
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exploreSections.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: ExploreCell_TableViewCell = tableView.dequeueReusableCellWithIdentifier("exploreTableViewCell", forIndexPath: indexPath) as ExploreCell_TableViewCell

        
        let section: exploreSections = exploreSections.allValues[indexPath.row]
        let cellCategory = section.rawValue
        
        cell.setCategoryName(cellCategory)
        cell.setCategoryPhoto(self.iconDictionary[section])
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as ExploreCell_TableViewCell
        self.category = cell.categoryName.text
        self.performSegueWithIdentifier("showExploreDetails", sender: self)
    }
    
    

    
    // Search Delegate
    func searchTableViewController(controller: SearchTableViewController, didSelectVenue venue:JSON) {
        self.venueInfo = venue
    }
    // perform segue now that search has finished dismissing
    func searchTableViewController(controller: SearchTableViewController, viewDidDisappear venueSelected: Bool!) {
        if(venueSelected == true){
            self.performSegueWithIdentifier("showCollection", sender: self)
        }
    }

}


class Storyboard: UIStoryboard {
    class func create(name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(name) as UIViewController
    }
}

