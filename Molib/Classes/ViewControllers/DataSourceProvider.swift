
import Foundation
import CoreData


public protocol DataSourceProvider {
    
    associatedtype DataSourceDelegate: DataSourceProviderDelegate
    
    associatedtype ItemType
    
    
    var delegate: DataSourceDelegate? { get set }

    
    func isEmpty() -> Bool
    
    func numberOfSections() -> Int
    
    func numberOfRowsInSection(section: Int) -> Int
    
    func itemAtIndexPath(indexPath: IndexPath) -> ItemType
    
    mutating func deleteItemAtIndexPath(indexPath: IndexPath)
    
    mutating func insertItem(item: ItemType, atIndexPath: IndexPath)
    
    mutating func updateItem(item: ItemType, atIndexPath: IndexPath)
 
    mutating func deleteAllInSection(section: Int)
    
    func titleForHeaderAtSection(section: Int) -> String?
    
}


public protocol DataSourceProviderDelegate {
    
    associatedtype ItemType
    
    
    mutating func providerWillChangeContent()
    
    mutating func providerDidEndChangeContent()
    
    
    mutating func providerDidInsertSectionAtIndex(index: Int)
    
    mutating func providerDidDeleteSectionAtIndex(index: Int)
    
    
    mutating func providerDidInsertItemsAtIndexPaths(items: [ItemType], atIndexPaths: [IndexPath])
    
    mutating func providerDidDeleteItemsAtIndexPaths(items: [ItemType], atIndexPaths: [IndexPath])
    
    mutating func providerDidUpdateItemsAtIndexPaths(items: [ItemType], atIndexPaths: [IndexPath])
    
    mutating func providerDidMoveItem(item: ItemType, atIndexPath: IndexPath, toIndexPath: IndexPath)
    
    mutating func providerDidDeleteAllItemsInSection(section: Int)
}


public class ArrayDataSourceProvider<T, Delegate: DataSourceProviderDelegate>: DataSourceProvider where Delegate.ItemType == T {
    
    public var delegate: Delegate?

    private var arrayItems: [[T]?]

    private var objectChanges: Array<(DataSourceChangeType,[IndexPath], [T])>!
    private var sectionChanges: Array<(DataSourceChangeType,Int)>!
    
    public init() {
        
        self.objectChanges = Array()
        self.sectionChanges = Array()

        arrayItems = [[T]?]()
    }
    
    public func isEmpty() -> Bool {
        
        return arrayItems.isEmpty
    }
    
    public func numberOfSections() -> Int {
        
        return arrayItems.count
    }
    
    public func numberOfRowsInSection(section: Int) -> Int {

        var itemCount = 0

        if arrayItems.count > section, let array = arrayItems[section] {
            itemCount = array.count
        }

        return itemCount
    }
    
    public func itemAtIndexPath(indexPath: IndexPath) -> T {

        guard arrayItems.count > indexPath.section, let array = arrayItems[indexPath.section] else {
            preconditionFailure("There was no item at indexPath \(indexPath)")
        }

        return array[indexPath.row]
    }
    
    public func deleteItemAtIndexPath(indexPath: IndexPath) {

        var items = [T]()
        if arrayItems.count > indexPath.section, var array = arrayItems[indexPath.section] {

            let item = array[indexPath.row]
            items.append(item)
            array.remove(at: indexPath.row)
            arrayItems[indexPath.section] = array

            delegate?.providerDidDeleteItemsAtIndexPaths(items: items, atIndexPaths: [indexPath])
        }
    }

    public func insertItem(item: T, atIndexPath indexPath: IndexPath) {

        if arrayItems.count > indexPath.section, var array = arrayItems[indexPath.section] {

            array.insert(item, at: indexPath.row)
            arrayItems[indexPath.section] = array

        } else {

            var array = [T]()
            array.insert(item, at: 0)
            arrayItems.insert(array, at: indexPath.section)
        }

        delegate?.providerDidInsertItemsAtIndexPaths(items: [item], atIndexPaths: [indexPath])
    }
    
    public func updateItem(item: T, atIndexPath indexPath: IndexPath) {

        if arrayItems.count > indexPath.section, var array = arrayItems[indexPath.section] {

            array[indexPath.row] = item
            arrayItems[indexPath.section] = array

            delegate?.providerDidUpdateItemsAtIndexPaths(items: [item], atIndexPaths: [indexPath])
        }
    }
    
    public func deleteAllInSection(section: Int) {

        if arrayItems.count > section, var array = arrayItems[section] {

            array.removeAll()
            arrayItems[section] = array

            delegate?.providerDidDeleteAllItemsInSection(section: 0)
        }
    }
    
    public func batchUpdates(updatesBlock: VoidCompletion) {
        
        objc_sync_enter(self)
        
        delegate?.providerWillChangeContent()
        
        updatesBlock()
        
        delegate?.providerDidEndChangeContent()

        objc_sync_exit(self)

    }
    
    public func titleForHeaderAtSection(section: Int) -> String? {
        return nil
    }
    
    public func itemsArray(atSection section: Int) -> [T] {

        guard let itemsArray = arrayItems[section] else { return [T]() }

        return itemsArray
    }
}

public class FetchedResultsDataSourceProvider<ObjectType: NSManagedObject, Delegate: DataSourceProviderDelegate> : DataSourceProvider where Delegate.ItemType == ObjectType {
    
    public var delegate: Delegate? { didSet {
        
            fetchedResultsControllerDelegate = FetchedResultsControllerDelegate<ObjectType, Delegate>(delegate: delegate!)
        
            fetchedResultsController.delegate = fetchedResultsControllerDelegate
        }
    }
    
    public let fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>
    
    var fetchedResultsControllerDelegate: FetchedResultsControllerDelegate<ObjectType, Delegate>?
    
    public init(fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>) {
        
        self.fetchedResultsController = fetchedResultsController
    }
    
    
    public func isEmpty() -> Bool {
        
        var empty = true
        
        if let count = self.fetchedResultsController.fetchedObjects?.count {
            empty = (count == 0)
        }
        
        return empty
    }
    
    public func numberOfSections() -> Int {
        
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    public func numberOfRowsInSection(section: Int) -> Int {
        
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    public func itemAtIndexPath(indexPath: IndexPath) -> ObjectType {
        
        return self.fetchedResultsController.object(at: indexPath) as! ObjectType
    }
    
    public func deleteItemAtIndexPath(indexPath: IndexPath) {
        
        let context = self.fetchedResultsController.managedObjectContext
        
        context.delete(self.fetchedResultsController.object(at: indexPath) as! ObjectType)
        
        do {
            try context.save()
        } catch _ {
        }
    }
    
    public func insertItem(item: ObjectType, atIndexPath: IndexPath) {
        
        let context = self.fetchedResultsController.managedObjectContext
        
        context.insert(item)
        
        do {
            try context.save()
        } catch _ {
        }
    }
    
    public func updateItem(item: ObjectType, atIndexPath: IndexPath) {
        
        let context = self.fetchedResultsController.managedObjectContext
        
        //MARK: TODO update the item here
        do {
            try context.save()
        } catch _ {
        }
    }
    
    public func deleteAllInSection(section: Int) {
        
        let context = self.fetchedResultsController.managedObjectContext

        let sectionInfo = self.fetchedResultsController.sections![section]

        if let objects = sectionInfo.objects {

            for object in objects {
        
                context.delete(object as! NSManagedObject)
            }
        }
    }
    
    public func titleForHeaderAtSection(section: Int) -> String? {
        
        return self.fetchedResultsController.sections?[section].name
    }

    deinit {
        print("FetchedResultsDataSourceProvider dying")
    }
}


class FetchedResultsControllerDelegate<ObjectType: NSManagedObject, Delegate: DataSourceProviderDelegate>: NSObject, NSFetchedResultsControllerDelegate where Delegate.ItemType == ObjectType {
    
    var delegate: Delegate
    
    init(delegate: Delegate) {
        
        self.delegate = delegate
    }
    
    // MARK: - Fetched results controller
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.delegate.providerWillChangeContent()
    }
    
    func controller(controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        switch type {
            
        case .insert:
            self.delegate.providerDidInsertSectionAtIndex(index: sectionIndex)
            
        case .delete:
            self.delegate.providerDidDeleteSectionAtIndex(index: sectionIndex)
            
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        let obj = anObject as! ObjectType

        switch type {
            
        case .insert:
            
            self.delegate.providerDidInsertItemsAtIndexPaths(items: [obj], atIndexPaths: [newIndexPath!])
            
        case .delete:
            
            self.delegate.providerDidDeleteItemsAtIndexPaths(items: [obj], atIndexPaths: [indexPath!])
            
        case .update:
            
            self.delegate.providerDidUpdateItemsAtIndexPaths(items: [obj], atIndexPaths: [indexPath!])
            
        case .move:
            
            if let initiaIndexPath = indexPath, let finalIndexPath = newIndexPath {
            
                if initiaIndexPath != finalIndexPath {
               
                    self.delegate.providerDidMoveItem(item: anObject as! ObjectType, atIndexPath: indexPath!, toIndexPath: newIndexPath!)
                }
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        self.delegate.providerDidEndChangeContent()
    }
    
    deinit {
        print("FetchedResultsControllerDelegate dying")
    }
}

