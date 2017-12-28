import Foundation

public class DictionaryDataSourceProvider<T, Delegate: DataSourceProviderDelegate>: DataSourceProvider where Delegate.ItemType == T {

    public var delegate: Delegate?

    private var dictionaryItems: [IndexPath: T]

    public init() {
        dictionaryItems = [IndexPath: T]()
    }

    public func isEmpty() -> Bool {

        return dictionaryItems.isEmpty
    }

    public func numberOfSections() -> Int {

        if let lastIndexPath = dictionaryItems.keys.sorted().last {
            return lastIndexPath.section + 1
        }

        return 0
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

        dictionaryItems[indexPath] = item
        delegate?.providerDidInsertItemsAtIndexPaths(items: [item], atIndexPaths: [indexPath])
    }

    public func updateItem(item: T, atIndexPath indexPath: IndexPath) {

        dictionaryItems[indexPath] = item

        delegate?.providerDidUpdateItemsAtIndexPaths(items: [item], atIndexPaths: [indexPath])
    }

    public func deleteAllInSection(section: Int) {

        let keysOfItemsToRemove = dictionaryItems.keys.filter { $0.section == section }

        var items = [T]()

        for key in keysOfItemsToRemove {

            if let itemToRemove = dictionaryItems[key] {

                items.append(itemToRemove)

                dictionaryItems.removeValue(forKey: key)
            }
        }

        delegate?.providerDidDeleteItemsAtIndexPaths(items: items, atIndexPaths: keysOfItemsToRemove)
    }

    public func batchUpdates(updatesBlock: VoidCompletion) {

        objc_sync_enter(self)

        delegate?.providerWillChangeContent()

        updatesBlock()

        delegate?.providerDidEndChangeContent()

        objc_sync_exit(self)
    }

    public func itemsArray(atSection section: Int) -> [T] {

        let items = dictionaryItems.flatMap { (key, value) -> T? in
            if key.section == section {
                return value
            }
            return nil
        }

        return items
    }
}

