//
//  String+Size.swift
//  SampleApp
//
//  Created by Matthew Yannascoli on 5/19/16.
//  Copyright © 2016 Fossil Group, Inc. All rights reserved.
//

import UIKit


extension String {
    
    ///convenience for determining text bounds width
    func height(viewWidth width: CGFloat, font: UIFont) -> CGFloat {
        let rect = self.boundingRectWithSize(CGSize(width: width, height: CGFloat.max),
                                             options: [.UsesLineFragmentOrigin, .UsesFontLeading],
                                             attributes: [NSFontAttributeName: font],
                                             context: nil)
        
        return rect.height
    }
    
//    func width(viewHeight height: CGFloat, font: UIFont) -> CGFloat {
//        let rect = self.boundingRectWithSize(CGSize(width: CGFloat.max, height: height),
//                                             options: .UsesLineFragmentOrigin | .UsesFontLeading,
//                                             attributes: [NSFontAttributeName: font],
//                                             context: nil)
//        
//        return rect.width
//    }
}

