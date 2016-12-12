//
//  InteractiveAlignViewController.swift
//  BrickKit-Example
//
//  Created by Ruben Cagnie on 12/9/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class ScaleInsert: BrickAppearBehavior {
    let scale: CGFloat

    init(scale: CGFloat) {
        self.scale = scale
    }

    func configureAttributesForAppearing(attributes: UICollectionViewLayoutAttributes, in collectionView: UICollectionView) {
        attributes.transform = CGAffineTransformMakeScale(scale, scale)
        attributes.alpha = 0
    }

    func configureAttributesForDisappearing(attributes: UICollectionViewLayoutAttributes, in collectionView: UICollectionView) {
        attributes.transform = CGAffineTransformMakeScale(scale, scale)
        attributes.alpha = 0
    }

}

class MyFlow: UICollectionViewFlowLayout {

    override func collectionViewContentSize() -> CGSize {
        let contentSize = super.collectionViewContentSize()
        print("collectionViewContentSize: \(contentSize)")

        return contentSize
    }

    override func invalidateLayoutWithContext(context: UICollectionViewLayoutInvalidationContext) {
        print("invalidateLayoutWithContext: \(context.invalidatedItemIndexPaths)")
        print("invalidateLayoutWithContext: \(context.invalidateDataSourceCounts)")

        super.invalidateLayoutWithContext(context)
    }

    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElementsInRect(rect) where !attributes.isEmpty else {
            return nil
        }

        print("layoutAttributesForElementsInRect: \(attributes.count)")

        var newAttributes = [UICollectionViewLayoutAttributes]()

        var row = [UICollectionViewLayoutAttributes]()
        var y: CGFloat = attributes.first!.frame.origin.y
        for a in attributes {
            if y != a.frame.origin.y {
                newAttributes.appendContentsOf(offsetAttributes(row))
                row = []
                y = a.frame.origin.y
            }
            row.append(a)
        }
        newAttributes.appendContentsOf(offsetAttributes(row))

        return newAttributes
    }

    func offsetAttributes(attributes: [UICollectionViewLayoutAttributes]) -> [UICollectionViewLayoutAttributes] {
        let first = attributes.minElement { $0.0.frame.minX < $0.1.frame.minX }!
        let last = attributes.maxElement { $0.0.frame.maxX < $0.1.frame.maxX }!
        let total = last.frame.maxX - first.frame.minX
        let offset = collectionView!.frame.midX - (total / 2)

        var newAttributes = [UICollectionViewLayoutAttributes]()
        for a in attributes {
            let newA = a.copy() as! UICollectionViewLayoutAttributes
            newA.frame.origin.x += offset
            newAttributes.append(newA)
        }
        return newAttributes
    }

    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        print("layoutAttributesForItemAtIndexPath: \(indexPath)")
        return super.layoutAttributesForItemAtIndexPath(indexPath)
    }

    var inserted: [NSIndexPath] = []
    var deleted: [NSIndexPath] = []
    override func prepareForCollectionViewUpdates(updateItems: [UICollectionViewUpdateItem]) {
        for update in updateItems {
            if update.updateAction == .Insert {
                inserted.append(update.indexPathAfterUpdate!)
            } else if update.updateAction == .Delete {
                deleted.append(update.indexPathBeforeUpdate!)
            }
        }
    }

    override func finalizeCollectionViewUpdates() {
        inserted = []
        deleted = []
    }

    override func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        print("initialLayoutAttributesForAppearingItemAtIndexPath: \(itemIndexPath)")
        let attributes = super.initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath)?.copy() as? UICollectionViewLayoutAttributes
        guard inserted.contains(itemIndexPath) else {
            return attributes
        }
        attributes?.transform = CGAffineTransformMakeScale(0.5, 0.5)
        attributes?.alpha = 0
        return attributes
    }

    override func finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        print("finalLayoutAttributesForDisappearingItemAtIndexPath: \(itemIndexPath)")
        let attributes = super.finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath)?.copy() as? UICollectionViewLayoutAttributes
        guard deleted.contains(itemIndexPath) else {
            return attributes
        }

        attributes?.transform = CGAffineTransformMakeScale(0.5, 0.5)
        attributes?.alpha = 0
        return attributes
    }

}

class InteractiveAlignViewController: UICollectionViewController {
    var numberOfItems: Int = 1

    init() {
        let flow = MyFlow()
        super.init(collectionViewLayout: flow)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView?.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(InteractiveAlignViewController.add))
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)

        cell.backgroundColor = .purpleColor()

        return cell
    }

    func add() {
        numberOfItems += 1
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .CurveEaseIn, animations: {
            self.collectionView?.performBatchUpdates({
                self.collectionView?.insertItemsAtIndexPaths([NSIndexPath(forItem: self.numberOfItems - 1, inSection: 0)])
//                self.collectionView?.reloadSections(NSIndexSet(index: 0))
                }, completion: nil)
            }, completion: nil)

    }

    func remove(indexPath: NSIndexPath) {
        numberOfItems -= 1
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .CurveEaseIn, animations: {
            self.collectionView?.performBatchUpdates({ 
                self.collectionView?.deleteItemsAtIndexPaths([indexPath])
                }, completion: nil)
            }, completion: nil)
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.remove(indexPath)
    }


}

class InteractiveAlignViewController2: BrickViewController {

    override class var title: String {
        return "Interactive Align"
    }

    override class var subTitle: String {
        return "Change height dynamically"
    }


    var numberOfItems: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(InteractiveAlignViewController.add))

        self.registerBrickClass(LabelBrick.self)
        self.brickCollectionView.layout.appearBehavior = ScaleInsert(scale: 0.5)

        let labelBrick = LabelBrick("Label", width: .Ratio(ratio: 1/3), height: .Fixed(size: 100), backgroundColor: UIColor.lightGrayColor().colorWithAlphaComponent(0.3), dataSource: self)

        let section = BrickSection(bricks: [
            labelBrick,
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), alignment: .Center)
        section.repeatCountDataSource = self
        setSection(section)
    }

    func add() {
        numberOfItems += 1
        updateCounts()
    }

    func remove(indexPath: NSIndexPath) {
        numberOfItems -= 1
        updateCounts([indexPath])
    }

    func updateCounts(fixedDeletedIndexPaths: [NSIndexPath]? = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .CurveEaseIn, animations: {
            self.brickCollectionView.invalidateRepeatCounts(false, fixedDeletedIndexPaths: fixedDeletedIndexPaths)
            }, completion: nil)
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        remove(indexPath)
    }

}

extension InteractiveAlignViewController2: LabelBrickCellDataSource {
    func configureLabelBrickCell(cell: LabelBrickCell) {
        cell.label.text = "BRICK \(cell.index)"
        cell.configure()
    }
}


extension InteractiveAlignViewController2: BrickRepeatCountDataSource {

    func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
        if identifier == "Label" {
            return numberOfItems
        } else {
            return 1
        }
    }
    
}
