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
    
        let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        
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
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        
    }
    
    func itemAtIndexPath(_ indexPath: IndexPath) -> ItemType {
        
    }
    
    func deleteItemAtIndexPath(_ indexPath: IndexPath) {
        
    }
    
    func insertItem(_ item: ItemType, atIndexPath: IndexPath) {
        
    }
    
    func updateItem(_ item: ItemType, atIndexPath: IndexPath) {
        
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
