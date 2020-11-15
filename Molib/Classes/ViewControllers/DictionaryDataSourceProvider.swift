import Foundation

public class DictionaryDataSourceProvider<T, Delegate: DataSourceProviderDelegate>: DataSourceProvider where Delegate.ItemType == T {

    public weak var delegate: Delegate?

    private var sectionsInserted: [Int]
    private var dictionaryItems: [IndexPath: T]
    private var headerItems: [Int: [String: Any]]
    
    public init() {
        sectionsInserted = [Int]()
        dictionaryItems = [IndexPath: T]()
        headerItems =  [Int: [String: Any]]()
    }

    public func isEmpty() -> Bool {

        return dictionaryItems.isEmpty
    }

    public func numberOfSections() -> Int {
        return sectionsInserted.count
    }

    public func numberOfRowsInSection(section: Int) -> Int {

        let indexPathsInSection = dictionaryItems.keys.filter { $0.section == section }

        return indexPathsInSection.count
    }

    public func itemAtIndexPath(indexPath: IndexPath) -> T {

        guard let item = dictionaryItems[indexPath] else {
            preconditionFailure("There was no item at indexPath \(indexPath)")
        }

        return item
    }

    public func deleteItemAtIndexPath(indexPath: IndexPath) {

        var items = [T]()

        if let item = dictionaryItems[indexPath] {

            items.append(item)

            dictionaryItems[indexPath] = nil

            delegate?.providerDidDeleteItemsAtIndexPaths(items: items, atIndexPaths: [indexPath])
        }
    }

    public func insertItem(item: T, atIndexPath indexPath: IndexPath) {

        for i in 0...indexPath.section {

            if sectionsInserted.contains(i) == false {

                sectionsInserted.append(i)
                delegate?.providerDidInsertSectionAtIndex(index: i)
            }
        }

        dictionaryItems[indexPath] = item

        delegate?.providerDidInsertItemsAtIndexPaths(items: [item], atIndexPaths: [indexPath])
    }

    public func updateItem(item: T, atIndexPath indexPath: IndexPath) {

        dictionaryItems[indexPath] = item

        delegate?.providerDidUpdateItemsAtIndexPaths(items: [item], atIndexPaths: [indexPath])
    }

    public func deleteAllInSection(section: Int) {

        guard sectionsInserted.isEmpty == false else { return }
        
        if sectionsInserted.contains(section) {
            sectionsInserted.removeAll(where: { $0 == section })
            delegate?.providerDidDeleteSectionAtIndex(index: section)
        }
        
        let keysOfItemsToRemove = dictionaryItems.keys.filter { $0.section == section }

        var items = [T]()

        if(keysOfItemsToRemove.count > 0) {

            for key in keysOfItemsToRemove {

                if let itemToRemove = dictionaryItems[key] {

                    items.append(itemToRemove)

                    dictionaryItems.removeValue(forKey: key)
                }
            }

            delegate?.providerDidDeleteItemsAtIndexPaths(items: items, atIndexPaths: keysOfItemsToRemove)
        }
    }

    public func batchUpdates(updatesBlock: @escaping VoidCompletion) {
        
        objc_sync_enter(self)
        delegate?.providerWillChangeContent()

        delegate?.providerDidEndChangeContent(updatesBlock: updatesBlock)
        
        objc_sync_exit(self)

    }
    
    //MARK:- Header
    public func insertHeaderDetails(details: [String : Any], atSection: Int) {
        headerItems[atSection] = details
    }

    public func headerDetailsAtSection(index: Int) -> [String : Any]? {
        return headerItems[index]
    }


    public func itemsArray(atSection section: Int) -> [T] {

        let items = dictionaryItems.compactMap { (key, value) -> T? in
            if key.section == section {
                return value
            }
            return nil
        }

        return items
    }
}

