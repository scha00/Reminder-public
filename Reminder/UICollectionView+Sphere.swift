//
//  UICollectionView+Sphere.swift
//  Reminder
//
//  Created by Sahn Cha on 30/05/2017.
//  Copyright © 2017 Soncode. All rights reserved.
//

import UIKit
import Sphere

extension UICollectionView {
    func applySphereChanges(changes: SPCollectionChange) {
        switch changes {
        case .initial:
            self.reloadData()
            
        case .change(let deletes, let inserts, let updates, let moves):
            Logger.MSG("d: \(deletes.count), i: \(inserts.count), u: \(updates.count), m: \(moves.count)")
            let itemPath = { (item: Int) in return IndexPath(item: item, section: 0) }
            let movePath = (old: { (move: (Int, Int)) in return IndexPath(item: move.0, section: 0) },
                            new: { (move: (Int, Int)) in return IndexPath(item: move.1, section: 0) })
            
            self.performBatchUpdates({
//                for move in moves {
//                    self.moveItem(at: IndexPath(item: move.0, section: 0), to: IndexPath(item: move.1, section: 0))
//                }
                
                self.deleteItems(at: deletes.map(itemPath) + moves.map(movePath.old))
                self.insertItems(at: inserts.map(itemPath) + moves.map(movePath.new))
                self.reloadItems(at: updates.map(itemPath))// + moves.map(movePath.new))
            }, completion: { _ in })
        }
    }
}
