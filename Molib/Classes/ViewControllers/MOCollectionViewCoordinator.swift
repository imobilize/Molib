
import Foundation
import UIKit

enum DataSourceChangeType {
    
    case Insert
    case Delete
    case Move
    case Update
}

public protocol DataSourceProviderCollectionViewAdapterDelegate: class {
        
    func collectionViewWillUpdateContent(_ collectionView: UICollectionView)
    func collectionViewDidUpdateContent(_ collectionView: UICollectionView)
}

public class DataSourceProviderCollectionViewAdapter<ItemType>: DataSourceProviderDelegate {
    
    private unowned let collectionView: UICollectionView
    public weak var delegate: DataSourceProviderCollectionViewAdapterDelegate? = nil
    
    private var objectChanges: Array<(DataSourceChangeType,[IndexPath])>!
    private var sectionChanges: Array<(DataSourceChangeType,Int)>!
    var updating = false
    
    init(collectionView: UICollectionView) {
        
        self.collectionView = collectionView
        self.objectChanges = Array()
        self.sectionChanges = Array()
    }
    
    //MARK:  conformance to the DataSourceProviderDelegate
    public func providerWillChangeContent() {

        delegate?.collectionViewWillUpdateContent(collectionView)
    }

    
    public func providerDidEndChangeContent(updatesBlock: @escaping VoidCompletion) {

        guard updating == false else {
            return
        }
        
        updating = true
        
        DispatchQueue.main.async { [weak self] in
            
            guard let `self` = self else {
                return
            }
            
            self.collectionView.performBatchUpdates( { [weak self] () -> Void in

                guard let `self` = self else {
                    return
                }
                
                updatesBlock()

                self.handleSectionChanges()

                self.handleObjectChanges()
            
            }, completion: { [weak self] (_) -> Void in
                
                guard let `self` = self else {
                    return
                }
                
                self.sectionChanges.removeAll(keepingCapacity: true)
                self.objectChanges.removeAll(keepingCapacity: true)
                
                self.delegate?.collectionViewDidUpdateContent(self.collectionView)
                self.updating = false
            })
        }
    }
    
    fileprivate func handleSectionChanges() {
        
        if sectionChanges.count > 0 {
            
                for (type, section) in self.sectionChanges {
                    
                    let set = IndexSet (integer: section)
                    
                    switch (type) {
                        
                    case .Insert:
                        
                        self.collectionView.insertSections(set)
                        break
                        
                    case .Delete:
                        self.collectionView.deleteSections(set)
                        break
                        
                    case .Update:
                        
                        self.collectionView.reloadSections(set)
                        break
                        
                    default:
                        break
                    }
                }
        }
    }
    
    fileprivate func handleObjectChanges() {
        if self.objectChanges.count > 0 && self.sectionChanges.count == 0 {
            
            let shouldReload = shouldReloadCollectionViewToPreventKnownIssue()
            
            if shouldReload || self.collectionView.window == nil {
                // This is to prevent a bug in UICollectionView from occurring.
                // The bug presents itself when inserting the first object or deleting the last object in a collection view.
                // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
                // This code should be removed once the bug has been fixed, it is tracked in OpenRadar
                // http://openradar.appspot.com/12954582
                self.collectionView.reloadData()
                
            } else {
                                    
                    for (type, obj) in self.objectChanges {
                        
                        switch type {
                            
                        case .Insert:
                            
                            self.collectionView.insertItems(at: obj)
                            
                        case .Delete:
                            
                            self.collectionView.deleteItems(at: obj)
                            
                        case .Update:
                            
                            self.collectionView.reloadItems(at: obj)
                            
                        case .Move:
                            
                            let oldIndexPath = obj.first
                            let newIndexPath = obj.last
                            
                            self.collectionView.moveItem(at: oldIndexPath!, to: newIndexPath!)
                        }
                    }

            }
        }
    }
    
    public func providerDidInsertSectionAtIndex(index: Int) {
        
        let change = (DataSourceChangeType.Insert, index)
        sectionChanges.append(change)
    }
    
    public func providerDidDeleteSectionAtIndex(index: Int) {
        
        let change = (DataSourceChangeType.Delete, index)
        
        sectionChanges.append(change)
    }
    
    
    public func providerDidInsertItemsAtIndexPaths(items: [ItemType], atIndexPaths: [IndexPath]) {
        
        updateWithItemChange(type: .Insert, indexPaths: atIndexPaths)
    }
    
    public func providerDidDeleteItemsAtIndexPaths(items: [ItemType], atIndexPaths: [IndexPath]) {
        
        
        updateWithItemChange(type: .Delete, indexPaths: atIndexPaths)
    }
    
    public func providerDidUpdateItemsAtIndexPaths(items: [ItemType], atIndexPaths indexPaths: [IndexPath]) {
        
        updateWithItemChange(type: .Update, indexPaths: indexPaths)
    }
    
    public func providerDidMoveItem(item: ItemType, atIndexPath: IndexPath, toIndexPath: IndexPath) {
        
        self.collectionView.moveItem(at: atIndexPath, to: toIndexPath)
    }
    
    public func providerDidDeleteAllItemsInSection(section: Int) {
        
        let indexSet = IndexSet(integer: section)
        
        self.collectionView.reloadSections(indexSet)
    }
    
    
    private func updateWithItemChange(type: DataSourceChangeType, indexPaths: [IndexPath]) {
        
        let change = (type, indexPaths)
        
        objectChanges.append(change)
    }
    
    public func shouldReloadCollectionViewToPreventKnownIssue() -> Bool {
        
        var shouldReload: Bool = false
        
        for (type, obj) in self.objectChanges {
            
            let indexPaths = obj
            
            switch type {
                
            case .Insert:
                
                let indexPath = indexPaths.first
                
                if self.collectionView.numberOfItems(inSection: indexPath!.section) == 0 {
                    
                    shouldReload = true
                    
                } else {
                    
                    shouldReload = false
                }
                break
                
            case .Delete:
                
                let indexPath = indexPaths.first
                
                if self.collectionView.numberOfItems(inSection: indexPath!.section) == 1 {
                    
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

@objc public protocol CollectionViewCellProvider: class {
    
    func collectionView(collectionView: UICollectionView, cellForRowAtIndexPath indexPath: IndexPath) -> UICollectionViewCell
    
    @objc optional func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: IndexPath) -> UICollectionReusableView
    
    @objc optional func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: IndexPath) -> Bool
    
    
}

@objc public protocol CollectionViewCoordinatorDelegate: class {
    
    func collectionViewWillUpdateContent(collectionView: UICollectionView)
    func collectionViewDidUpdateContent(collectionView: UICollectionView)
}


public class CollectionViewCoordinator<CollectionType, DataSource: DataSourceProvider> : NSObject, UICollectionViewDataSource where DataSource.ItemType == CollectionType, DataSource.DataSourceDelegate == DataSourceProviderCollectionViewAdapter<CollectionType> {
    
    var dataSource: DataSource
    
    public var delegate: CollectionViewCoordinatorDelegate? = nil
    
    var dataSourceProviderCollectionViewAdapter: DataSourceProviderCollectionViewAdapter<CollectionType>
    
    unowned let collectionViewCellProvider: CollectionViewCellProvider
    
    
    public init(collectionView: UICollectionView, dataSource: DataSource, cellProvider: CollectionViewCellProvider) {
        
        self.dataSource = dataSource
        self.collectionViewCellProvider = cellProvider
        self.dataSourceProviderCollectionViewAdapter = DataSourceProviderCollectionViewAdapter<CollectionType>(collectionView: collectionView)
        
        super.init()
        
        collectionView.dataSource = self
        self.dataSource.delegate = self.dataSourceProviderCollectionViewAdapter
        self.dataSourceProviderCollectionViewAdapter.delegate = self
    }
    
    // MARK: - Collection View Datasource
    public func numberOfSections(in: UICollectionView) -> Int {
        
        return self.dataSource.numberOfSections()
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.dataSource.numberOfRowsInSection(section: section)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        return collectionViewCellProvider.collectionView(collectionView: collectionView, cellForRowAtIndexPath: indexPath)
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let view = collectionViewCellProvider.collectionView?(collectionView: collectionView, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath)
        
        return view ?? UICollectionReusableView()
    }
    
    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        
        let canMove = collectionViewCellProvider.collectionView!(collectionView: collectionView, canMoveItemAtIndexPath: indexPath)
        
        return canMove
    }
    
    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let item = self.dataSource.itemAtIndexPath(indexPath: sourceIndexPath)
        
        self.dataSource.insertItem(item: item, atIndexPath: destinationIndexPath)
        
        self.dataSource.deleteItemAtIndexPath(indexPath: sourceIndexPath)
    }
}


extension CollectionViewCoordinator: DataSourceProviderCollectionViewAdapterDelegate {

    public func collectionViewWillUpdateContent(_ collectionView: UICollectionView) {
        delegate?.collectionViewWillUpdateContent(collectionView: collectionView)
    }
    
    public func collectionViewDidUpdateContent(_ collectionView: UICollectionView) {
        delegate?.collectionViewDidUpdateContent(collectionView: collectionView)
    }
}


public class CollectionViewCoordinatorWithItemCountLimit<CollectionType, DataSource: DataSourceProvider>: CollectionViewCoordinator<CollectionType, DataSource> where DataSource.ItemType == CollectionType, DataSource.DataSourceDelegate == DataSourceProviderCollectionViewAdapter<CollectionType> {
    
    let itemCountLimit: Int
    
    public init(collectionView: UICollectionView, dataSource: DataSource, itemCountLimit: Int, cellProvider: CollectionViewCellProvider) {
        
        self.itemCountLimit = itemCountLimit
        
        super.init(collectionView: collectionView, dataSource: dataSource, cellProvider: cellProvider)
        
    }
    
    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return dataSource.numberOfRowsInSection(section: section) > itemCountLimit ? itemCountLimit : dataSource.numberOfRowsInSection(section: section)
    }
}
