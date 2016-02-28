//
//  CurrentDetailLayout.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 22/02/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import UIKit

class SectionAttributes : UICollectionViewLayoutAttributes {
    var originalX : CGFloat!
}

class CurrentDetailLayout : UICollectionViewLayout {
    
    var totalWidth = CGFloat(0)
    var layoutInfo = [String : AnyObject]()
    var suppsInfo = [String : UICollectionViewLayoutAttributes]()
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }

    override func prepareLayout() {
        
        // Prepare some variables
        guard let numSections = collectionView?.numberOfSections() where numSections > 0 else { return }
        var cellInfo = [NSIndexPath : AnyObject]()
        var sectionInfo = [NSIndexPath : AnyObject]()
        totalWidth = 0
        
        // Table header
        let headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: TitlesCell.kindTableHeader, withIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        headerAttributes.frame = CGRectMake(self.totalWidth, 0, TitlesCell.size.width, TitlesCell.size.height)
        self.suppsInfo[TitlesCell.kindTableHeader] = headerAttributes
        self.totalWidth+=TitlesCell.size.width
        
        for var section = 0; section < numSections; section++ {
            let numItems = collectionView?.numberOfItemsInSection(section)
            var firstAttribute : UICollectionViewLayoutAttributes?
            for var row = 0; row < numItems; row++ {
                let indexPath = NSIndexPath(forRow: row, inSection: section)
                // Cell
                let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                attributes.frame = CGRectMake(totalWidth, 0, ForecastCell.size.width, ForecastCell.size.height)
                attributes.zIndex = 100
                totalWidth+=ForecastCell.size.width
                totalWidth++
                cellInfo[indexPath] = attributes
                // get the first attribute to be used by the section header
                if row == 0 {
                    firstAttribute = attributes
                }
            }
            
            // Section header
            let indexPath = NSIndexPath(forRow: 0, inSection: section)
            let attributes = SectionAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withIndexPath: indexPath)
            attributes.zIndex = section
            attributes.originalX = firstAttribute!.frame.origin.x
            attributes.frame = CGRectMake(xOfHeader(attributes), firstAttribute!.frame.origin.y, TitlesCell.size.width, TitlesCell.size.height)
            sectionInfo[indexPath] = attributes
            
        }
        layoutInfo[ForecastCell.kind] = cellInfo
        layoutInfo[UICollectionElementKindSectionHeader] = sectionInfo
        
        // Table footer
        let footerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: TitlesCell.kindTableFooter, withIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        footerAttributes.frame = CGRectMake(totalWidth, 0, TitlesCell.size.width, TitlesCell.size.height)
        footerAttributes.zIndex = 200
        self.suppsInfo[TitlesCell.kindTableFooter] = footerAttributes
        self.totalWidth+=TitlesCell.size.width
        
    }
    
    override func collectionViewContentSize() -> CGSize {
        return CGSizeMake(totalWidth, 150)
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        var cellInfo = layoutInfo[ForecastCell.kind] as! [NSIndexPath : AnyObject]
        return cellInfo[indexPath] as? UICollectionViewLayoutAttributes
    }
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        switch elementKind {
        case UICollectionElementKindSectionHeader :
            let sectionInfo = layoutInfo[elementKind] as! [NSIndexPath : AnyObject]
            return sectionInfo[indexPath] as? UICollectionViewLayoutAttributes
        default :
            return self.suppsInfo[elementKind]
        }
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        // Forecast cells
        guard let cellInfo = layoutInfo[ForecastCell.kind] as? [NSIndexPath : AnyObject] else { return nil }
        
        var elements = [UICollectionViewLayoutAttributes]()
        for (_, attributes) in cellInfo {
            if CGRectIntersectsRect(rect, attributes.frame) {
                elements.append(attributes as! UICollectionViewLayoutAttributes)
            }
        }
        // SectionHeader
        let sectionKind = UICollectionElementKindSectionHeader
        let sectionInfo = layoutInfo[sectionKind] as! [NSIndexPath : AnyObject]
        for (_, attributes) in sectionInfo {
            if CGRectIntersectsRect(rect, attributes.frame) {
                elements.append(attributes as! UICollectionViewLayoutAttributes)
            }
        }
        // Headers
        let headerAttrs = self.suppsInfo[TitlesCell.kindTableHeader]!
        if (CGRectIntersectsRect(rect, headerAttrs.frame)) {
            elements.append(headerAttrs)
        }
        // Footers
        let footersAttrs = self.suppsInfo[TitlesCell.kindTableFooter]!
        if (CGRectIntersectsRect(rect, footersAttrs.frame)) {
            elements.append(footersAttrs)
        }
        return elements
    }
    
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint) -> CGPoint {
        return targetContentOffsetAdjustment(proposedContentOffset)
    }
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        return targetContentOffsetAdjustment(proposedContentOffset)
    }
    
    func xOfHeader(sectionAttributes : SectionAttributes, proposedContentOffset: CGPoint? = nil) -> CGFloat {

        var leftEdge = self.collectionView!.contentOffset.x
        if let offset = proposedContentOffset {
            leftEdge = offset.x
        }

// compare next item if colliding  sectionAttributes.indexPath ?
        
        // Hold section headers on the left edge if needed
        
        if leftEdge >= sectionAttributes.originalX {
            return leftEdge
        } else {
            return sectionAttributes.originalX
        }
    }
    
    func targetContentOffsetAdjustment(proposedContentOffset: CGPoint) -> CGPoint {
        var newContentOffset = proposedContentOffset
        let titleWidth = TitlesCell.size.width

        // Snap the left titles in place along it's leading and trailing edges
        
        let leftEdge = collectionView!.contentOffset.x
        if leftEdge < 20 {
            newContentOffset.x = 0
            self.collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else if 20 ..< titleWidth ~= leftEdge {
            newContentOffset.x = titleWidth
            UIApplication.delay(0.35, closure: { () -> () in
                self.collectionView?.contentInset = UIEdgeInsets(top: 0, left: -titleWidth, bottom: 0, right: -titleWidth)
            })
        }
        
        // Snap the right titles in place along it's leading and trailing edges
        
        let rightEdge = leftEdge + UIScreen.mainScreen().bounds.size.width
        let rightThreshold = totalWidth - 10
        let rightThresholdLeading = totalWidth - titleWidth
        
        if rightEdge > rightThreshold {
            newContentOffset.x = totalWidth - UIScreen.mainScreen().bounds.size.width
            self.collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else if rightThresholdLeading ..< rightThreshold ~= rightEdge {
            newContentOffset.x = totalWidth - UIScreen.mainScreen().bounds.size.width - titleWidth
        }
        
        return newContentOffset
    }
}
