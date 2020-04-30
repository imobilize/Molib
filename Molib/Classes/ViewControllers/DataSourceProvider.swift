
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

    func deleteItemAtIndexPath(indexPath: IndexPath)
    
    func insertItem(item: ItemType, atIndexPath: IndexPath)
    
    func updateItem(item: ItemType, atIndexPath: IndexPath)
 
    func deleteAllInSection(section: Int)
    
    func insertHeaderDetails(details: [String: Any], atSection: Int)

}


public protocol DataSourceProviderDelegate : class {
    
    associatedtype ItemType

    
    func providerWillChangeContent()
    
    func providerDidEndChangeContent(completion: @escaping VoidCompletion)
    
    
    func providerDidInsertSectionAtIndex(index: Int)
    
    func providerDidDeleteSectionAtIndex(index: Int)
    
    
    func providerDidInsertItemsAtIndexPaths(items: [ItemType], atIndexPaths: [IndexPath])
    
    func providerDidDeleteItemsAtIndexPaths(items: [ItemType], atIndexPaths: [IndexPath])
    
    func providerDidUpdateItemsAtIndexPaths(items: [ItemType], atIndexPaths: [IndexPath])
    
    func providerDidMoveItem(item: ItemType, atIndexPath: IndexPath, toIndexPath: IndexPath)
    
    func providerDidDeleteAllItemsInSection(section: Int)
}
