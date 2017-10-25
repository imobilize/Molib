
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
        
        self.tableView.insertSections(IndexSet(integer: index), with: UITableViewRowAnimation.automatic)
    }
    
    public func providerDidDeleteSectionAtIndex(index: Int) {
        
        self.tableView.deleteSections(IndexSet(integer: index), with: UITableViewRowAnimation.automatic)
    }
    
    
    public func providerDidInsertItemsAtIndexPaths(items: [ItemType], atIndexPaths indexPaths: [IndexPath]) {
        
        self.tableView.insertRows(at: indexPaths, with: UITableViewRowAnimation.automatic)
    }
    
    public func providerDidDeleteItemsAtIndexPaths(items: [ItemType], atIndexPaths indexPaths: [IndexPath]) {
        
        self.tableView.deleteRows(at: indexPaths, with: UITableViewRowAnimation.automatic)
    }
    
    public func providerDidUpdateItemsAtIndexPaths(items: [ItemType], atIndexPaths indexPaths: [IndexPath]) {
        
        self.tableView.reloadRows(at: indexPaths, with: UITableViewRowAnimation.automatic)
    }
    
    public func providerDidMoveItem(item: ItemType, atIndexPath: IndexPath, toIndexPath: IndexPath) {
        
        self.tableView.deleteRows(at: [atIndexPath], with: UITableViewRowAnimation.automatic)

        self.tableView.insertRows(at: [toIndexPath], with: UITableViewRowAnimation.automatic)
    }
    
    public func providerDidDeleteAllItemsInSection(section: Int) {
        
        let sectionSet = IndexSet(integer: section)
        
        self.tableView.reloadSections(sectionSet, with: UITableViewRowAnimation.automatic)
    }

}

public protocol TableViewCellProvider {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
}


public class TableViewCoordinator<CollectionType, DataSource: DataSourceProvider> : NSObject, UITableViewDataSource where DataSource.ItemType == CollectionType, DataSource.DataSourceDelegate == DataSourceProviderTableViewAdapter<CollectionType> {
        
    
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
        
        return self.dataSource.numberOfSections()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.dataSource.numberOfRowsInSection(section: section)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return tableViewCellProvider.tableView(tableView: tableView, cellForRowAtIndexPath: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            self.dataSource.deleteItemAtIndexPath(indexPath: indexPath)
        }
    }
}

public class PlaceholderTableViewCoordinator<CollectionType, DataSource: DataSourceProvider>:TableViewCoordinator<CollectionType, DataSource> where DataSource.ItemType == CollectionType, DataSource.DataSourceDelegate == DataSourceProviderTableViewAdapter<CollectionType> {
    
    let placeholderCells: Int
    
    public init(tableView: UITableView, dataSource: DataSource, placeholderCells: Int, cellProvider: TableViewCellProvider) {
        
        self.placeholderCells = placeholderCells
        
        super.init(tableView: tableView, dataSource: dataSource, cellProvider: cellProvider)
        
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return dataSource.isEmpty() ? placeholderCells : dataSource.numberOfRowsInSection(section: section)
        
    }
    
}

