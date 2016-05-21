//
//  MuliLineTextCell.swift
//  TestHarness
//
//  Created by Josh Rooke-Ley on 4/10/15.
//  Copyright (c) 2015 Fossil Group, Inc. All rights reserved.
//

import UIKit

internal class MultiLineTextCell: UITableViewCell {
    struct Constants {
        static let ReuseIdentifier = "MultiLineTextCellReuseIdentifier"
        private static let SmallMargin = CGFloat(10.0)
        private static let MessageButtonHeight = CGFloat(30.0)
    }
    
    private var messageOneTextViewHeightConstraint: NSLayoutConstraint!    
    var levelColor: UIColor = .whiteColor() {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    var customTextColor: UIColor = .blackColor() {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    var dateText: String = "" {
        didSet {
            self.dateLabel.text = dateText
        }
    }
    
    var functionText: String  = "" {
        didSet {
            self.functionLabel.text = functionText
        }
    }
    
    var messageOneText: String? {
        didSet {
            messageOneTextView.text = messageOneText
        }
    }

    
    private let dateLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.boldSystemFontOfSize(14)
        view.textColor = .blackColor()
        view.textAlignment = .Left
        view.numberOfLines = 1
        return view
    }()
    
    private let functionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFontOfSize(12)
        view.textColor = .blackColor()
        view.textAlignment = .Left
        view.numberOfLines = 1
        return view
    }()

    private let messageOneTextView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .whiteColor()
        view.textColor = .blackColor()
        view.font = .systemFontOfSize(12)
        view.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10)
        view.textContainer.lineBreakMode = .ByCharWrapping
        view.editable = false
        
        return view
    }()
    
    private let divider: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .blackColor()
        return view
    }()
    
    required internal init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layout()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        dateLabel.textColor = customTextColor
        functionLabel.textColor = customTextColor
        contentView.backgroundColor = levelColor
    }
}




extension MultiLineTextCell {
    
    private func layout() {
        contentView.backgroundColor = .whiteColor()
        contentView.addSubview(dateLabel)
        contentView.addSubview(functionLabel)        
        contentView.addSubview(messageOneTextView)
        contentView.addSubview(divider)
        
        //dateLabel
        contentView.addConstraint(NSLayoutConstraint(
            item: dateLabel,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: contentView,
            attribute: .Top,
            multiplier: 1.0,
            constant: Constants.SmallMargin)
        )
        contentView.addConstraint(NSLayoutConstraint(
            item: dateLabel,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: contentView,
            attribute: .Left,
            multiplier: 1.0,
            constant: Constants.SmallMargin)
        )
        contentView.addConstraint(NSLayoutConstraint(
            item: dateLabel,
            attribute: .Right,
            relatedBy: .Equal,
            toItem: contentView,
            attribute: .Right,
            multiplier: 1.0,
            constant: -Constants.SmallMargin)
        )
        dateLabel.setContentHuggingPriority(750, forAxis: .Vertical)
        
        //functionLabel
        contentView.addConstraint(NSLayoutConstraint(
            item: functionLabel,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: dateLabel,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 0)
        )
        contentView.addConstraint(NSLayoutConstraint(
            item: functionLabel,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: contentView,
            attribute: .Left,
            multiplier: 1.0,
            constant: Constants.SmallMargin)
        )
        contentView.addConstraint(NSLayoutConstraint(
            item: functionLabel,
            attribute: .Right,
            relatedBy: .Equal,
            toItem: contentView,
            attribute: .Right,
            multiplier: 1.0,
            constant: -Constants.SmallMargin)
        )
        functionLabel.setContentHuggingPriority(750, forAxis: .Vertical)
        
        //messageOneTextView
        contentView.addConstraint(NSLayoutConstraint(
            item: messageOneTextView,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: functionLabel,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: Constants.SmallMargin)
        )
        contentView.addConstraint(NSLayoutConstraint(
            item: messageOneTextView,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: contentView,
            attribute: .Left,
            multiplier: 1.0,
            constant: 0)
        )
        contentView.addConstraint(NSLayoutConstraint(
            item: messageOneTextView,
            attribute: .Right,
            relatedBy: .Equal,
            toItem: contentView,
            attribute: .Right,
            multiplier: 1.0,
            constant: 0)
        )
        
        contentView.addConstraint(NSLayoutConstraint(
            item: messageOneTextView,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: contentView,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 0)
        )

        contentView.addConstraint(NSLayoutConstraint(
            item: divider,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: contentView,
            attribute: .Left,
            multiplier: 1.0,
            constant: 0.0)
        )
        
        contentView.addConstraint(NSLayoutConstraint(
            item: divider,
            attribute: .Right,
            relatedBy: .Equal,
            toItem: contentView,
            attribute: .Right,
            multiplier: 1.0,
            constant: 0.0)
        )
        
        contentView.addConstraint(NSLayoutConstraint(
            item: divider,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .Height,
            multiplier: 1.0,
            constant: 1.0)
        )
        
        contentView.addConstraint(NSLayoutConstraint(
            item: divider,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: contentView,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 0.0)
        )
    }
}

