//
//  DirectionSearchViewController.swift
//  MockMap
//
//  Created by IvanLe on 6/29/15.
//  Copyright (c) 2015 SiliconstraitsSaigon. All rights reserved.
//

import Foundation


class DirectionSearchViewController : UIViewController, UISearchBarDelegate ,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var originSearchBar: UISearchBar!
    @IBOutlet weak var destinationSearchBar: UISearchBar!
    @IBOutlet weak var resultTableView: UITableView!
    
    
    let googleDataProvider = GoogleDataProvider()
    var iBarButtonItemDidTouch: IBarButtonItemDidTouch?
    
    //    var places = NSMutableArray()
    var places = [String]()
    
    override func viewDidLoad() {
        originSearchBar.placeholder = "Origin"
        destinationSearchBar.placeholder = "Destination"
        originSearchBar.delegate = self
        destinationSearchBar.delegate = self
        
        resultTableView.delegate = self
        resultTableView.dataSource = self
    }
    
    // MARK: SearchView Delegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        places = [String]()
        if !searchText.isEmpty {
            resultTableView.hidden = false
            // How to wait for this to finished
            googleDataProvider.placesAutocomplete(searchText, completionHandler: { (status, success, places) -> Void in
                self.places = places
                self.resultTableView.reloadData()
            })
            
        } else {
            resultTableView.hidden = true
        }
        
    }
    
    
    // MARK: TableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        if !places.isEmpty {
            var text: String? = places[indexPath.row]
            cell.textLabel?.text = text
        }
        return cell as UITableViewCell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    // MARK: TableView Delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if originSearchBar.isFirstResponder() {
            originSearchBar.text = places[indexPath.row]
        }else{
            destinationSearchBar.text = places[indexPath.row]
        }
    }
    
    @IBAction func barBtnItemOKDidTouch(sender: UIBarButtonItem) {
        
        if originSearchBar.text.isEmpty || destinationSearchBar.text.isEmpty {
            return
        }

        if iBarButtonItemDidTouch != nil {
            iBarButtonItemDidTouch?.barButtonItemOKDidTouch(originSearchBar.text, destination: destinationSearchBar.text)
            self.navigationController?.popViewControllerAnimated(true)
        }
        
        
    }
    
    
}
