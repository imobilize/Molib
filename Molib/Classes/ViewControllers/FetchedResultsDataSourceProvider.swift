import Foundation
import CoreData

public class FetchedResultsDataSourceProvider<ObjectType: NSManagedObject, Delegate: DataSourceProviderDelegate> : DataSourceProvider where Delegate.ItemType == ObjectType {

    private var headerItems: [Int: [String: Any]]

    public weak var delegate: Delegate? { didSet {

        fetchedResultsControllerDelegate = FetchedResultsControllerDelegate<ObjectType, Delegate>(delegate: delegate!)

        fetchedResultsController.delegate = fetchedResultsControllerDelegate
        }
    }

    public let fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>

    var fetchedResultsControllerDelegate: FetchedResultsControllerDelegate<ObjectType, Delegate>?

    public init(fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>) {

        self.fetchedResultsController = fetchedResultsController
        self.headerItems = [Int: [String: Any]]()
    }

    public func reload() {
        do {
            try self.fetchedResultsController.performFetch()
        } catch {}
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

        let sectionInfo = self.fetchedResultsController.sections?[section]
        return sectionInfo?.numberOfObjects ?? 0
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
    
    //MARK:- Header
    public func insertHeaderDetails(details: [String : Any], atSection: Int) {
        headerItems[atSection] = details
    }

    public func headerDetailsAtSection(index: Int) -> [String : Any]? {
        return headerItems[index]
    }

    deinit {
       debugPrint("FetchedResultsDataSourceProvider dying")
    }
}


class FetchedResultsControllerDelegate<ObjectType: NSManagedObject, Delegate: DataSourceProviderDelegate>: NSObject, NSFetchedResultsControllerDelegate where Delegate.ItemType == ObjectType {

    unowned var delegate: Delegate

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

        self.delegate.providerDidEndChangeContent {}
    }

    deinit {
       debugPrint("FetchedResultsControllerDelegate dying")
    }
}

