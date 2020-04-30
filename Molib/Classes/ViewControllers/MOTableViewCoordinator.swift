
import UIKit

public protocol TableViewCellProvider: class {

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
}

public protocol TableViewEditingDelegate: class {

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    func tableView(_ tableView: UITableView, didDeleteRowAt indexPath: IndexPath)
}


public class DataSourceProviderTableViewAdapter<ItemType>: DataSourceProviderDelegate {
    
    private unowned let tableView: UITableView

    init(tableView: UITableView) {
        self.tableView = tableView
    }

    // conformance to the DataSourceProviderDelegate
    public func providerWillChangeContent() {
        
        self.tableView.beginUpdates()
    }
    
    public func providerDidEndChangeContent(updatesBlock: VoidCompletion) {
        
        updatesBlock()
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



public class TableViewCoordinator<CollectionType, DataSource: DataSourceProvider> : NSObject, UITableViewDataSource where DataSource.ItemType == CollectionType, DataSource.DataSourceDelegate == DataSourceProviderTableViewAdapter<CollectionType> {

    var dataSource: DataSource
    private var sectionNames: [String: String]

    private let dataSourceProviderTableViewAdapter: DataSourceProviderTableViewAdapter<CollectionType>
    
    private unowned let tableViewCellProvider: TableViewCellProvider
    public weak var tableViewEditingDelegate: TableViewEditingDelegate?
    
    public init(tableView: UITableView, dataSource: DataSource, cellProvider: TableViewCellProvider) {

        self.dataSource = dataSource
        self.tableViewCellProvider = cellProvider
        self.dataSourceProviderTableViewAdapter = DataSourceProviderTableViewAdapter<CollectionType>(tableView: tableView)
        self.sectionNames = [String: String]()

        super.init()
        
        tableView.dataSource = self
        self.dataSource.delegate = self.dataSourceProviderTableViewAdapter
    }

    public func setName(_ name: String, forSection section: Int) {
        sectionNames["\(section)"] = name
    }

    // MARK: - Table View
    
    public func numberOfSections(in tableView: UITableView) -> Int {

        return self.dataSource.numberOfSections()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.dataSource.numberOfRowsInSection(section: section)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return tableViewCellProvider.tableView(tableView: tableView, cellForRowAtIndexPath: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        var canEdit = false

        if let editable = tableViewEditingDelegate?.tableView(tableView, canEditRowAt: indexPath) {
            canEdit = editable
        }

        return canEdit
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {

            tableViewEditingDelegate?.tableView(tableView, didDeleteRowAt: indexPath)
        }
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionNames["\(section)"]
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

