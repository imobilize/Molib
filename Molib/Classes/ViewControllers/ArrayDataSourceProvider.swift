import Foundation

public class ArrayDataSourceProvider<T, Delegate: DataSourceProviderDelegate>: DataSourceProvider where Delegate.ItemType == T {

    public weak var delegate: Delegate?

    private var arrayItems: [T]
    private var headerItems: [Int: [String: Any]]

    public init() {

        arrayItems = [T]()
        headerItems = [Int: [String: Any]]()
    }

    public func isEmpty() -> Bool {

        return arrayItems.isEmpty
    }

    public func numberOfSections() -> Int {

        return 1
    }

    public func numberOfRowsInSection(section: Int) -> Int {

        return arrayItems.count
    }

    public func itemAtIndexPath(indexPath: IndexPath) -> T {

        return arrayItems[indexPath.row]
    }

    public func deleteItemAtIndexPath(indexPath: IndexPath) {

        let item = arrayItems[indexPath.row]

        arrayItems.remove(at: indexPath.row)

        delegate?.providerDidDeleteItemsAtIndexPaths(items: [item], atIndexPaths: [indexPath])
    }

    public func insertItem(item: T, atIndexPath indexPath: IndexPath) {

        arrayItems.insert(item, at: indexPath.row)

        delegate?.providerDidInsertItemsAtIndexPaths(items: [item], atIndexPaths: [indexPath])
    }

    public func updateItem(item: T, atIndexPath indexPath: IndexPath) {

        var newItems = [T](arrayItems)

        newItems.remove(at: indexPath.row)

        newItems.insert(item, at: indexPath.row)

        self.arrayItems = newItems

        delegate?.providerDidUpdateItemsAtIndexPaths(items: [item], atIndexPaths: [indexPath])
    }

    public func deleteAllInSection(section: Int) {

        arrayItems.removeAll()

        delegate?.providerDidDeleteAllItemsInSection(section: section)
    }

    public func batchUpdates(updatesBlock: @escaping VoidCompletion) {

        if Thread.isMainThread {
           
            self.delegate?.providerWillChangeContent()

            self.delegate?.providerDidEndChangeContent(updatesBlock: updatesBlock)
            
        } else {
            
            DispatchQueue.main.sync { [weak self] in
                
                self?.delegate?.providerWillChangeContent()

                self?.delegate?.providerDidEndChangeContent(updatesBlock: updatesBlock)
            }
        }
    }
    
    //MARK:- Header
    public func insertHeaderDetails(details: [String : Any], atSection: Int) {
        headerItems[atSection] = details
    }

    public func headerDetailsAtSection(index: Int) -> [String : Any]? {
        return headerItems[index]
    }

    public func itemsArray() -> [T] {

        return arrayItems
    }
}
