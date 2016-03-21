//
//  ExampleTableViewController.swift
//  Molib
//
//  Created by Andre Barrett on 14/09/2015.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import Molib

class ExampleTableViewControllerFactory {
    
    let kExampleTableViewControllerIdentifier = "ExampleTableViewController"
    
    class func exampleTableViewController() -> ExampleTableViewController {
    
        let storyBoard = UIStoryboard.init(name: "Main", bundle: NSBundle.mainBundle())
        
        let controller = storyBoard.instantiateViewControllerWithIdentifier(kExampleTableViewControllerIdentifier) as! ExampleTableViewController
        
        controller.dataSource = ExampleTableViewControllerDataSource
        
        return controller
    }
    
}


struct TestItem {
    
    let name: String
    let description: String
}


struct ExampleTableViewControllerDataSource : DataSourceProvider {
    
    typealias ItemType = TestItem
    
    let fetchedResultsDataProvider: FetchedResultsDataSourceProvider
    
    func numberOfSections() -> Int {
        
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        
    }
    
    func itemAtIndexPath(indexPath: NSIndexPath) -> ItemType {
        
    }
    
    func deleteItemAtIndexPath(indexPath: NSIndexPath) {
        
    }
    
    func insertItem(item: ItemType, atIndexPath: NSIndexPath) {
        
    }
    
    func updateItem(item: ItemType, atIndexPath: NSIndexPath) {
        
    }
}



class ExampleTableViewController: UIViewController, UITableViewDelegate {

    typealias DataSource = DataSourceProvider
    
    @IBOutlet weak var table: UITableView!
    
    var dataSource: DataSource!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
    }
    
}