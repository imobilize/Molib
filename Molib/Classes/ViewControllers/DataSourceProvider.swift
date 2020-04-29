
import Foundation

public protocol DataSourceProvider {
    
    associatedtype DataSourceDelegate: DataSourceProviderDelegate
    
    associatedtype ItemType
    
    
    var delegate: DataSourceDelegate? { get set }

    
    func isEmpty() -> Bool
    
    func numberOfSections() -> Int
    
    func numberOfRowsInSection(section: Int) -> Int
    
    func itemAtIndexPath(indexPath: IndexPath) -> ItemType
    
    func headerDetailsAtSection(index: Int) -> [String: Any]?

    mutating func deleteItemAtIndexPath(indexPath: IndexPath)
    
    mutating func insertItem(item: ItemType, atIndexPath: IndexPath)
    
    mutating func updateItem(item: ItemType, atIndexPath: IndexPath)
 
    mutating func deleteAllInSection(section: Int)
    
    mutating func insertHeaderDetails(details: [String: Any], atSection: Int)

}


public protocol DataSourceProviderDelegate {
    
    associatedtype ItemType

    
    mutating func providerWillChangeContent()
    
    mutating func providerDidEndChangeContent(completion: @escaping VoidCompletion)
    
    
    mutating func providerDidInsertSectionAtIndex(index: Int)
    
    mutating func providerDidDeleteSectionAtIndex(index: Int)
    
    
    mutating func providerDidInsertItemsAtIndexPaths(items: [ItemType], atIndexPaths: [IndexPath])
    
    mutating func providerDidDeleteItemsAtIndexPaths(items: [ItemType], atIndexPaths: [IndexPath])
    
    mutating func providerDidUpdateItemsAtIndexPaths(items: [ItemType], atIndexPaths: [IndexPath])
    
    mutating func providerDidMoveItem(item: ItemType, atIndexPath: IndexPath, toIndexPath: IndexPath)
    
    mutating func providerDidDeleteAllItemsInSection(section: Int)
}
