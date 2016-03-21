
import UIKit

struct DataSourceProviderTableViewAdapter<ItemType>: DataSourceProviderDelegate {
    
    let tableView: UITableView
    
    
    // conformance to the DataSourceProviderDelegate
    func providerWillChangeContent() {
        
        self.tableView.beginUpdates()
    }
    
    func providerDidEndChangeContent() {
        
        self.tableView.endUpdates()
    }
        
    func providerDidInsertSectionAtIndex(index: Int) {
        
        self.tableView.insertSections(NSIndexSet(index: index), withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func providerDidDeleteSectionAtIndex(index: Int) {
        
        self.tableView.deleteSections(NSIndexSet(index: index), withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    
    func providerDidInsertItemsAtIndexPaths(items: [ItemType], atIndexPaths: [NSIndexPath]) {
        
        self.tableView.insertRowsAtIndexPaths(atIndexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func providerDidDeleteItemsAtIndexPaths(items: [ItemType], atIndexPaths: [NSIndexPath]) {
        
        self.tableView.deleteRowsAtIndexPaths(atIndexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func providerDidUpdateItemsAtIndexPaths(items: [ItemType], atIndexPaths: [NSIndexPath]) {
        
        self.tableView.reloadRowsAtIndexPaths(atIndexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func providerDidMoveItem(item: ItemType, atIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        
        self.tableView.deleteRowsAtIndexPaths([atIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)

        self.tableView.insertRowsAtIndexPaths([toIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func providerDidDeleteAllItemsInSection(section: Int) {
        
        let sectionSet = NSIndexSet(index: section)
        
        self.tableView.reloadSections(sectionSet, withRowAnimation: UITableViewRowAnimation.Automatic)
    }

}

protocol TableViewCellProvider {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
}


class TableViewCoordinator<CollectionType, DataSource: DataSourceProvider where DataSource.ItemType == CollectionType, DataSource.DataSourceDelegate == DataSourceProviderTableViewAdapter<CollectionType>> : NSObject, UITableViewDataSource {
        
    
    let table: UITableView
    
    var dataSource: DataSource
    
    let dataSourceProviderTableViewAdapter: DataSourceProviderTableViewAdapter<CollectionType>
    
    let tableViewCellProvider: TableViewCellProvider
    
    
    init(tableView: UITableView, dataSource: DataSource, cellProvider: TableViewCellProvider) {

        self.table = tableView
        self.dataSource = dataSource
        self.tableViewCellProvider = cellProvider
        self.dataSourceProviderTableViewAdapter = DataSourceProviderTableViewAdapter<CollectionType>(tableView: self.table)
        
        super.init()
        
        self.table.dataSource = self
        self.dataSource.delegate = self.dataSourceProviderTableViewAdapter

    }
    
    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return self.dataSource.numberOfSections() ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.dataSource.numberOfRowsInSection(section) ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        return tableViewCellProvider.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            
            self.dataSource.deleteItemAtIndexPath(indexPath)
        }
    }
}

