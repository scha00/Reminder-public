//
//  ReminderLayout.swift
//  Reminder
//
//  Created by Sahn Cha on 30/05/2017.
//  Copyright © 2017 Soncode. All rights reserved.
//

import UIKit

protocol ReminderLayoutDelegate: class {
    
    func collectionView(_ collectionView: UICollectionView, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize
    func cellPaddingForCollectionView(_ collectionView: UICollectionView) -> CGFloat
    
}

class ReminderLayout: UICollectionViewLayout {

    weak var delegate: ReminderLayoutDelegate!
    
    private var attributesCache: [IndexPath: UICollectionViewLayoutAttributes] = [:]
    private var contentHeight: CGFloat = 0.0
    private var contentWidth: CGFloat = Constants.Screen.Width
    
    private var insertedIndexPaths: [IndexPath] = []
    private var deletedIndexPaths: [IndexPath] = []
    private var movedIndexPaths: [(from: IndexPath, to: IndexPath)] = []
//    private var reloadedIndexPaths: [IndexPath] = []
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        Logger.MSG()
        guard updateItems.count > 0 else {
            attributesCache.removeAll()
            prepare()
            return
        }
        
        insertedIndexPaths = []
        deletedIndexPaths = []
        movedIndexPaths = []
//        reloadedIndexPaths = []
        
        for item in updateItems {
            if item.updateAction == .insert, let index = item.indexPathAfterUpdate {
                insertedIndexPaths.append(index)
            }
            
            else if item.updateAction == .delete, let index = item.indexPathBeforeUpdate {
                deletedIndexPaths.append(index)
            }
            
            else if item.updateAction == .move, let from = item.indexPathBeforeUpdate, let to = item.indexPathAfterUpdate {
                movedIndexPaths.append((from: from, to: to))
            }
            
            else if item.updateAction == .reload, let index = item.indexPathAfterUpdate {
                attributesCache[index] = nil
//                prepare()
            }
        }
    }
    
    override func finalizeCollectionViewUpdates() {
        insertedIndexPaths = []
        deletedIndexPaths = []
    }
    
    override func prepare() {
        guard attributesCache.isEmpty else { return }
        
        Logger.MSG()
        let cellPadding = delegate.cellPaddingForCollectionView(collectionView!)
        var currentHeight: CGFloat = cellPadding
        
        for item in 0 ..< collectionView!.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            // get cell size through delegate
            let size = delegate.collectionView(collectionView!, sizeForItemAtIndexPath: indexPath)
            
            attributes.frame = CGRect(x: cellPadding, y:currentHeight, width: size.width, height: size.height)
            attributesCache[indexPath] = attributes
            
            currentHeight += (size.height + cellPadding)
        }
        
        contentHeight = currentHeight
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if attributesCache.count != collectionView!.numberOfItems(inSection: 0) {
            attributesCache.removeAll()
            prepare()
        }
        
        var list = [UICollectionViewLayoutAttributes]()
        for attributes in attributesCache.values {
            if attributes.frame.intersects(rect) { list.append(attributes) }
        }
        return list
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard attributesCache.count > indexPath.item else { return nil }
        return attributesCache[indexPath]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if contentWidth != newBounds.width {
            contentWidth = newBounds.width
            attributesCache.removeAll()
            Logger.MSG("Clear cache")
        }
        return true
    }
    
    var movedFromCenter: [IndexPath: CGPoint] = [:]
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if insertedIndexPaths.contains(itemIndexPath) {
            let attributes = attributesCache[itemIndexPath]?.copy() as! UICollectionViewLayoutAttributes?
            attributes?.center = CGPoint(x: -(self.collectionView?.bounds.width)! / 2.0, y: attributes!.center.y)
            return attributes
        }
        
        else if movedIndexPaths.map({$0.to}).contains(itemIndexPath) {
            
            if let moved = movedIndexPaths.filter({$0.to == itemIndexPath}).first, let center = movedFromCenter[moved.from] {
                let attributes = attributesCache[itemIndexPath]?.copy() as! UICollectionViewLayoutAttributes?
                attributes?.center = center
                movedFromCenter[moved.from] = nil
            }
        }
        
        return super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if deletedIndexPaths.contains(itemIndexPath) {
            let attributes = attributesCache[itemIndexPath]?.copy() as! UICollectionViewLayoutAttributes?
            attributes?.center = CGPoint(x: attributes!.center.x + 100, y: attributes!.center.y)
            attributes?.alpha = 0.0
            let transform = CATransform3DMakeScale(0.6, 0.6, 1.0)
            attributes?.transform3D = transform;
            return attributes
        }
        
        else if movedIndexPaths.map({$0.from}).contains(itemIndexPath) {
            let attributes = attributesCache[itemIndexPath]?.copy() as! UICollectionViewLayoutAttributes?
            movedFromCenter[itemIndexPath] = attributes?.center
        }
        
        return super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
    }
    
}
