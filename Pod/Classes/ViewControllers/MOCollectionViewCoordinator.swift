
import Foundation
import UIKit

enum DataSourceChangeType {
    
    case Insert
    case Delete
    case Move
    case Update
}


public class DataSourceProviderCollectionViewAdapter<ItemType>: DataSourceProviderDelegate {
    
    var collectionView: UICollectionView?
  
    private var objectChanges: Array<(DataSourceChangeType,[NSIndexPath])>!
    private var sectionChanges: Array<(DataSourceChangeType,Int)>!
    
    
    init(collectionView: UICollectionView) {
        
        self.collectionView = collectionView
        self.objectChanges = Array()
        self.sectionChanges = Array()

    }
    
    //MARK:  conformance to the DataSourceProviderDelegate
    public func providerWillChangeContent() {
        
    }
    
    public func providerDidEndChangeContent() {
        
        if sectionChanges.count > 0 {
            
            collectionView?.performBatchUpdates( {  () -> Void in
                
                for (type, obj) in self.sectionChanges {
                    
                    let set = NSIndexSet(index: obj)
                    
                    switch (type) {
                        
                    case .Insert:
                        
                        self.collectionView?.insertSections(set)
                        break
                        
                    case .Delete:
                        
                        self.collectionView?.deleteSections(set)
                        break
                        
                    case .Update:
                        
                        self.collectionView?.reloadSections(set)
                        break
                        
                    default:
                        break
                    }
                }
                }, completion: { (_) -> Void in
                    
                    
            })
        }
        
        if self.objectChanges.count > 0 && self.sectionChanges.count == 0 {
            
            let shouldReload = shouldReloadCollectionViewToPreventKnownIssue()
            
            if shouldReload || self.collectionView?.window == nil {
                // This is to prevent a bug in UICollectionView from occurring.
                // The bug presents itself when inserting the first object or deleting the last object in a collection view.
                // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
                // This code should be removed once the bug has been fixed, it is tracked in OpenRadar
                // http://openradar.appspot.com/12954582
                self.collectionView?.reloadData()
                
            } else {
                
                self.collectionView?.performBatchUpdates({ () -> Void in
                    
                    for (type, obj) in self.objectChanges {
                        
                        switch type {
                            
                        case .Insert:
                            
                            self.collectionView?.insertItemsAtIndexPaths(obj)
                            
                        case .Delete:
                            
                            self.collectionView?.deleteItemsAtIndexPaths(obj)
                            
                        case .Update:
                            
                            self.collectionView?.reloadItemsAtIndexPaths(obj)
                            
                        case .Move:
                            
                            let oldIndexPath = obj.first
                            let newIndexPath = obj.last
                            
                            self.collectionView?.moveItemAtIndexPath(oldIndexPath!, toIndexPath: newIndexPath!)
                        }
                    }
                    }, completion: { (_) -> Void in
                        
                })
            }
        }
        
        self.sectionChanges.removeAll(keepCapacity: true)
        self.objectChanges.removeAll(keepCapacity: true)
    }
    
    
    public func providerDidInsertSectionAtIndex(index: Int) {
        
        let change = (DataSourceChangeType.Insert, index)
        
        sectionChanges.append(change)
    }
    
    public func providerDidDeleteSectionAtIndex(index: Int) {
        
        let change = (DataSourceChangeType.Delete, index)
        
        sectionChanges.append(change)
    }
    
    
    public func providerDidInsertItemsAtIndexPaths(items: [ItemType], atIndexPaths: [NSIndexPath]) {

        updateWithItemChange(.Insert, indexPaths: atIndexPaths)
    }
    
    public func providerDidDeleteItemsAtIndexPaths(items: [ItemType], atIndexPaths: [NSIndexPath]) {

        
        updateWithItemChange(.Delete, indexPaths: atIndexPaths)
    }
    
    public func providerDidUpdateItemsAtIndexPaths(items: [ItemType], atIndexPaths indexPaths: [NSIndexPath]) {
        
        updateWithItemChange(.Update, indexPaths: indexPaths)
    }
    
    public func providerDidMoveItem(item: ItemType, atIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        
        self.collectionView?.moveItemAtIndexPath(atIndexPath, toIndexPath: toIndexPath)
    }
    
    public func providerDidDeleteAllItemsInSection(section: Int) {
        
        let indexSet = NSIndexSet(index: section)
        
        self.collectionView?.reloadSections(indexSet)
    }
    
    
    private func updateWithItemChange(type: DataSourceChangeType, indexPaths: [NSIndexPath]) {
            
        let change = (type, indexPaths)
            
        objectChanges.append(change)
    }
    
    private func handleObjectChanges() {
        
        
        if self.objectChanges.count > 0 && self.sectionChanges.count == 0 {
            
            let shouldReload = shouldReloadCollectionViewToPreventKnownIssue()
            
            if shouldReload || self.collectionView?.window == nil {
                // This is to prevent a bug in UICollectionView from occurring.
                // The bug presents itself when inserting the first object or deleting the last object in a collection view.
                // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
                // This code should be removed once the bug has been fixed, it is tracked in OpenRadar
                // http://openradar.appspot.com/12954582
                self.collectionView?.reloadData()
                
            } else {
                
                self.collectionView?.performBatchUpdates({ () -> Void in
                    
                    for (type, obj) in self.objectChanges {
                        
                        switch type {
                            
                        case .Insert:
                            
                            self.collectionView?.insertItemsAtIndexPaths(obj)
                            
                        case .Delete:
                            
                            self.collectionView?.deleteItemsAtIndexPaths(obj)
                            
                        case .Update:
                            
                            self.collectionView?.reloadItemsAtIndexPaths(obj)
                            
                        case .Move:
                            
                            let oldIndexPath = obj.first
                            let newIndexPath = obj.last
                            
                            self.collectionView?.moveItemAtIndexPath(oldIndexPath!, toIndexPath: newIndexPath!)
                        }
                    }
                    }, completion: { (_) -> Void in
                        
                })
            }
        }
        
        self.sectionChanges.removeAll(keepCapacity: true)
        self.objectChanges.removeAll(keepCapacity: true)
    }
    
    public func shouldReloadCollectionViewToPreventKnownIssue() -> Bool {
        
        var shouldReload: Bool = false
        
        for (type, obj) in self.objectChanges {
            
            let indexPaths = obj
            
            switch type {
                
            case .Insert:
                
                let indexPath = indexPaths.first
                
                if self.collectionView?.numberOfItemsInSection(indexPath!.section) == 0 {
                    
                    shouldReload = true
                    
                } else {
                    
                    shouldReload = false
                }
                break
                
            case .Delete:
                
                let indexPath = indexPaths.first
                
                if self.collectionView?.numberOfItemsInSection(indexPath!.section) == 1 {
                    
                    shouldReload = true
                } else {
                    
                    shouldReload = false
                }
                break
                
            case .Update:
                shouldReload = false
                break
                
            case .Move:
                shouldReload = false
                break
            }
            
        }
        
        return shouldReload
    }
}

@objc public protocol CollectionViewCellProvider {
    
    func collectionView(collectionView: UICollectionView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    
    optional func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    
    optional func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool
    

}


public class CollectionViewCoordinator<CollectionType, DataSource: DataSourceProvider where DataSource.ItemType == CollectionType, DataSource.DataSourceDelegate == DataSourceProviderCollectionViewAdapter<CollectionType>> : NSObject, UICollectionViewDataSource {
    
    let collectionView: UICollectionView
    
    var dataSource: DataSource
    
    var dataSourceProviderCollectionViewAdapter: DataSourceProviderCollectionViewAdapter<CollectionType>
    
    let collectionViewCellProvider: CollectionViewCellProvider
    
    
    public init(collectionView: UICollectionView, dataSource: DataSource, cellProvider: CollectionViewCellProvider) {
        
        self.collectionView = collectionView
        self.dataSource = dataSource
        self.collectionViewCellProvider = cellProvider
        self.dataSourceProviderCollectionViewAdapter = DataSourceProviderCollectionViewAdapter<CollectionType>(collectionView: collectionView)
        
        super.init()
        
        self.collectionView.dataSource = self
        self.dataSource.delegate = self.dataSourceProviderCollectionViewAdapter
    }
    
    // MARK: - Collection View Datasource
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return self.dataSource.numberOfSections() ?? 0
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.dataSource.numberOfRowsInSection(section) ?? 0
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        return collectionViewCellProvider.collectionView(collectionView, cellForRowAtIndexPath: indexPath)
    }
    
    
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        return (collectionViewCellProvider.collectionView?(collectionView, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath))!
    }
    
    public func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return (collectionViewCellProvider.collectionView?(collectionView, canMoveItemAtIndexPath: indexPath))!
    }
 
    public func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        let item = self.dataSource.itemAtIndexPath(sourceIndexPath)
        
        self.dataSource.insertItem(item, atIndexPath: destinationIndexPath)
        
        self.dataSource.deleteItemAtIndexPath(sourceIndexPath)
    }

}

