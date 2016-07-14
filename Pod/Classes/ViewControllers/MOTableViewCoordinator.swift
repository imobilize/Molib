
import UIKit

public struct DataSourceProviderTableViewAdapter<ItemType>: DataSourceProviderDelegate {
    
    let tableView: UITableView
    
    
    // conformance to the DataSourceProviderDelegate
    public func providerWillChangeContent() {
        
        self.tableView.beginUpdates()
    }
    
    public func providerDidEndChangeContent() {
        
        self.tableView.endUpdates()
    }
        
    public func providerDidInsertSectionAtIndex(index: Int) {
        
        self.tableView.insertSections(NSIndexSet(index: index), withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    public func providerDidDeleteSectionAtIndex(index: Int) {
        
        self.tableView.deleteSections(NSIndexSet(index: index), withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    
    public func providerDidInsertItemsAtIndexPaths(items: [ItemType], atIndexPaths: [NSIndexPath]) {
        
        self.tableView.insertRowsAtIndexPaths(atIndexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    public func providerDidDeleteItemsAtIndexPaths(items: [ItemType], atIndexPaths: [NSIndexPath]) {
        
        self.tableView.deleteRowsAtIndexPaths(atIndexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    public func providerDidUpdateItemsAtIndexPaths(items: [ItemType], atIndexPaths: [NSIndexPath]) {
        
        self.tableView.reloadRowsAtIndexPaths(atIndexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    public func providerDidMoveItem(item: ItemType, atIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        
        self.tableView.deleteRowsAtIndexPaths([atIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)

        self.tableView.insertRowsAtIndexPaths([toIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    public func providerDidDeleteAllItemsInSection(section: Int) {
        
        let sectionSet = NSIndexSet(index: section)
        
        self.tableView.reloadSections(sectionSet, withRowAnimation: UITableViewRowAnimation.Automatic)
    }

}

public protocol TableViewCellProvider {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
}


public class TableViewCoordinator<CollectionType, DataSource: DataSourceProvider where DataSource.ItemType == CollectionType, DataSource.DataSourceDelegate == DataSourceProviderTableViewAdapter<CollectionType>> : NSObject, UITableViewDataSource {
        
    
    let table: UITableView
    
    var dataSource: DataSource
    
    let dataSourceProviderTableViewAdapter: DataSourceProviderTableViewAdapter<CollectionType>
    
    let tableViewCellProvider: TableViewCellProvider
    
    
    public init(tableView: UITableView, dataSource: DataSource, cellProvider: TableViewCellProvider) {

        self.table = tableView
        self.dataSource = dataSource
        self.tableViewCellProvider = cellProvider
        self.dataSourceProviderTableViewAdapter = DataSourceProviderTableViewAdapter<CollectionType>(tableView: self.table)
        
        super.init()
        
        self.table.dataSource = self
        self.dataSource.delegate = self.dataSourceProviderTableViewAdapter

    }
    
    // MARK: - Table View
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return self.dataSource.numberOfSections() ?? 0
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.dataSource.numberOfRowsInSection(section) ?? 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        return tableViewCellProvider.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            
            self.dataSource.deleteItemAtIndexPath(indexPath)
        }
    }
}

public class PlaceholderTableViewCoordinator<CollectionType, DataSource: DataSourceProvider where DataSource.ItemType == CollectionType, DataSource.DataSourceDelegate == DataSourceProviderTableViewAdapter<CollectionType>>:TableViewCoordinator<CollectionType, DataSource> {
    
    let placeholderCells: Int
    
    public init(tableView: UITableView, dataSource: DataSource, placeholderCells: Int, cellProvider: TableViewCellProvider) {
        
        self.placeholderCells = placeholderCells
        
        super.init(tableView: tableView, dataSource: dataSource, cellProvider: cellProvider)
        
    }
    
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return dataSource.isEmpty() ? placeholderCells : dataSource.numberOfRowsInSection(section)
        
    }
    
}

