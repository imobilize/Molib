
import Foundation
import CoreData


protocol DataSourceProvider {
    
    typealias DataSourceDelegate: DataSourceProviderDelegate
    
    typealias ItemType
    
    
    var delegate: DataSourceDelegate? { get set }

    
    func isEmpty() -> Bool
    
    func numberOfSections() -> Int
    
    func numberOfRowsInSection(section: Int) -> Int
    
    func itemAtIndexPath(indexPath: NSIndexPath) -> ItemType
    
    mutating func deleteItemAtIndexPath(indexPath: NSIndexPath)
    
    mutating func insertItem(item: ItemType, atIndexPath: NSIndexPath)
    
    mutating func updateItem(item: ItemType, atIndexPath: NSIndexPath)
 
    mutating func deleteAllInSection(section: Int)
    
    func titleForHeaderAtSection(section: Int) -> String?
    
}


protocol DataSourceProviderDelegate {
    
    typealias ItemType
    
    
    mutating func providerWillChangeContent()
    
    mutating func providerDidEndChangeContent()
    
    
    mutating func providerDidInsertSectionAtIndex(index: Int)
    
    mutating func providerDidDeleteSectionAtIndex(index: Int)
    
    
    mutating func providerDidInsertItemsAtIndexPaths(items: [ItemType], atIndexPaths: [NSIndexPath])
    
    mutating func providerDidDeleteItemsAtIndexPaths(items: [ItemType], atIndexPaths: [NSIndexPath])
    
    mutating func providerDidUpdateItemsAtIndexPaths(items: [ItemType], atIndexPaths: [NSIndexPath])
    
    mutating func providerDidMoveItem(item: ItemType, atIndexPath: NSIndexPath, toIndexPath: NSIndexPath)
    
    mutating func providerDidDeleteAllItemsInSection(section: Int)
}


class ArrayDataSourceProvider<T, Delegate: DataSourceProviderDelegate where Delegate.ItemType == T>: DataSourceProvider {
    
    var delegate: Delegate?

    private var arrayItems: [T]
    
    private var objectChanges: Array<(DataSourceChangeType,[NSIndexPath], [T])>!
    private var sectionChanges: Array<(DataSourceChangeType,Int)>!
    
    init() {
        
        self.objectChanges = Array()
        self.sectionChanges = Array()

        arrayItems = [T]()
    }
    
    func isEmpty() -> Bool {
        
        return arrayItems.isEmpty
    }
    
    func numberOfSections() -> Int {
        
        return 1
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        
        return arrayItems.count
    }
    
    func itemAtIndexPath(indexPath: NSIndexPath) -> T {
        
        return arrayItems[indexPath.row]
    }
    
    
    func deleteItemAtIndexPath(indexPath: NSIndexPath) {
        
        let item = arrayItems[indexPath.row]
        
        arrayItems.removeAtIndex(indexPath.row)
        
        delegate?.providerDidDeleteItemsAtIndexPaths([item], atIndexPaths: [indexPath])
    }

    func insertItem(item: T, atIndexPath indexPath: NSIndexPath) {
        
        arrayItems.insert(item, atIndex: indexPath.row)
        
        delegate?.providerDidInsertItemsAtIndexPaths([item], atIndexPaths: [indexPath])
        
    }
    
    func updateItem(item: T, atIndexPath indexPath: NSIndexPath) {
        
        var newItems = [T](arrayItems)
    
        newItems.removeAtIndex(indexPath.row)
        
        newItems.insert(item, atIndex: indexPath.row)
        
        self.arrayItems = newItems
        
        delegate?.providerDidUpdateItemsAtIndexPaths([item], atIndexPaths: [indexPath])

    }
    
    func deleteAllInSection(section: Int) {

        arrayItems.removeAll()
        
        delegate?.providerDidDeleteAllItemsInSection(0)
    }
    
    func batchUpdates(updatesBlock: VoidCompletion) {
        
        objc_sync_enter(self)
        
        delegate?.providerWillChangeContent()
        
        updatesBlock()
        
        delegate?.providerDidEndChangeContent()

        objc_sync_exit(self)

    }
    
    func titleForHeaderAtSection(section: Int) -> String? {
        return nil
    }
}


class FetchedResultsDataSourceProvider<ObjectType: NSManagedObject, Delegate: DataSourceProviderDelegate where Delegate.ItemType == ObjectType> : DataSourceProvider {
    
    var delegate: Delegate? { didSet {
        
            fetchedResultsControllerDelegate = FetchedResultsControllerDelegate<ObjectType, Delegate>(delegate: delegate!)
        
            fetchedResultsController.delegate = fetchedResultsControllerDelegate
        }
    }
    
    let fetchedResultsController: NSFetchedResultsController
    
    var fetchedResultsControllerDelegate: FetchedResultsControllerDelegate<ObjectType, Delegate>?
    
    init(fetchedResultsController: NSFetchedResultsController) {
        
        self.fetchedResultsController = fetchedResultsController
    }
    
    
    func isEmpty() -> Bool {
        
        var empty = true
        
        if let count = self.fetchedResultsController.fetchedObjects?.count {
            empty = (count == 0)
        }
        
        return empty
    }
    
    func numberOfSections() -> Int {
        
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func itemAtIndexPath(indexPath: NSIndexPath) -> ObjectType {
        
        return self.fetchedResultsController.objectAtIndexPath(indexPath) as! ObjectType
    }
    
    func deleteItemAtIndexPath(indexPath: NSIndexPath) {
        
        let context = self.fetchedResultsController.managedObjectContext
        
        context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! ObjectType)
        
        do {
            try context.save()
        } catch _ {
        }
    }
    
    func insertItem(item: ObjectType, atIndexPath: NSIndexPath) {
        
        let context = self.fetchedResultsController.managedObjectContext
        
        context.insertObject(item)
        
        do {
            try context.save()
        } catch _ {
        }
    }
    
    func updateItem(item: ObjectType, atIndexPath: NSIndexPath) {
        
        let context = self.fetchedResultsController.managedObjectContext
        
        //MARK: TODO update the item here
        do {
            try context.save()
        } catch _ {
        }
    }
    
    func deleteAllInSection(section: Int) {
        
        let context = self.fetchedResultsController.managedObjectContext

        let sectionInfo = self.fetchedResultsController.sections![section]

        if let objects = sectionInfo.objects {

            for object in objects {
        
                context.deleteObject(object as! NSManagedObject)
            }
        }
    }
    
    func titleForHeaderAtSection(section: Int) -> String? {
        
        return self.fetchedResultsController.sections?[section].name
    }

    
    deinit {
        print("FetchedResultsDataSourceProvider dying")
    }
}


class FetchedResultsControllerDelegate<ObjectType: NSManagedObject, Delegate: DataSourceProviderDelegate where Delegate.ItemType == ObjectType>: NSObject, NSFetchedResultsControllerDelegate {
    
    var delegate: Delegate
    
    init(delegate: Delegate) {
        
        self.delegate = delegate
    }
    
    // MARK: - Fetched results controller
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.delegate.providerWillChangeContent()
        
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        switch type {
            
        case .Insert:
            self.delegate.providerDidInsertSectionAtIndex(sectionIndex)
            
        case .Delete:
            self.delegate.providerDidDeleteSectionAtIndex(sectionIndex)
            
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        let obj = anObject as! ObjectType

        switch type {
            
        case .Insert:
            
            
            self.delegate.providerDidInsertItemsAtIndexPaths([obj], atIndexPaths: [newIndexPath!])
            
        case .Delete:
            
            self.delegate.providerDidDeleteItemsAtIndexPaths([obj], atIndexPaths: [indexPath!])
            
        case .Update:
            
            self.delegate.providerDidUpdateItemsAtIndexPaths([obj], atIndexPaths: [indexPath!])
            
        case .Move:
            
            if let initiaIndexPath = indexPath, finalIndexPath = newIndexPath {
            
                if initiaIndexPath != finalIndexPath {
               
                    self.delegate.providerDidMoveItem(anObject as! ObjectType, atIndexPath: indexPath!, toIndexPath: newIndexPath!)
                }
            }
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        self.delegate.providerDidEndChangeContent()
    }
    
    deinit {
        print("FetchedResultsControllerDelegate dying")
    }
}

