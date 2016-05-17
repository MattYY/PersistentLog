//
//  Label.swift
//  SampleApp
//
//  Created by Matthew Yannascoli on 5/17/16.
//  Copyright © 2016 Fossil Group, Inc. All rights reserved.
//

import UIKit


extension UILabel {
    func height(viewWidth width: CGFloat) -> CGFloat {
        return size(width, height: nil).height
    }
    
    func width(viewHeight height: CGFloat) -> CGFloat {
        return size(nil, height: height).width
    }
    
    func size(width: CGFloat?, height: CGFloat?) -> CGSize {
        var originalHeight : CGFloat = CGFloat.max
        if let height = height {
            originalHeight = height
        }
        var originalWidth : CGFloat = CGFloat.max
        if let width = width {
            originalWidth = width
        }
        
        var size : CGSize = CGSizeZero
        
        if let text = self.text {
            let rect = (text as NSString).boundingRectWithSize(CGSizeMake(originalWidth, originalHeight),
                                                               options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                                                               attributes: [NSFontAttributeName : self.font],
                                                               context: nil)
            
            size = rect.size
        }
        else if let text = self.attributedText {
            let rect = (text as NSAttributedString).boundingRectWithSize(CGSizeMake(originalWidth, originalHeight),
                                                                         options:NSStringDrawingOptions.UsesFontLeading,
                                                                         context: nil)
            
            size = rect.size
        }
        
        return size
    }
}