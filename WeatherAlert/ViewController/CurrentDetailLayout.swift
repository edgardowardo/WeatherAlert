//
//  CurrentDetailLayout.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 22/02/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import UIKit
//import Foundation

class CurrentDetailLayout : UICollectionViewLayout {
    
    var totalWidth = CGFloat(0)
    var layoutInfo = [String : AnyObject]()
    var suppsInfo = [String : UICollectionViewLayoutAttributes]()
    
    override func prepareLayout() {
        
        // Prepare some variables
        guard let numSections = collectionView?.numberOfSections() where numSections > 0 else { return }
        var cellInfo = [NSIndexPath : AnyObject]()
        var sectionInfo = [NSIndexPath : AnyObject]()
        
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
            let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withIndexPath: indexPath)
            attributes.frame = CGRectMake(firstAttribute!.frame.origin.x, firstAttribute!.frame.origin.y, TitlesCell.size.width, TitlesCell.size.height)
            sectionInfo[indexPath] = attributes
            
        }
        layoutInfo[ForecastCell.kind] = cellInfo
        layoutInfo[UICollectionElementKindSectionHeader] = sectionInfo
        
        // Table footer
        let footerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: TitlesCell.kindTableFooter, withIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        footerAttributes.frame = CGRectMake(totalWidth, 0, TitlesCell.size.width, TitlesCell.size.height)
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
            let matchInfo = layoutInfo[elementKind] as! [NSIndexPath : AnyObject]
            return matchInfo[indexPath] as? UICollectionViewLayoutAttributes
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
    
}
