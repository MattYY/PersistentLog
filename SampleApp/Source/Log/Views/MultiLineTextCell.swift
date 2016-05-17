//
//  MuliLineTextCell.swift
//  TestHarness
//
//  Created by Josh Rooke-Ley on 4/10/15.
//  Copyright (c) 2015 Fossil Group, Inc. All rights reserved.
//

import UIKit

protocol MultiLineTextCellDelegate: class {
    func multiLineTextCell(cell: MultiLineTextCell, messageOneOpen: Bool, messageTwoOpen: Bool)
}

internal class MultiLineTextCell: UITableViewCell {
    struct Constants {
        static let ReuseIdentifier = "MultiLineTextCellReuseIdentifier"
        private static let SmallMargin = CGFloat(10.0)
        private static let MessageButtonHeight = CGFloat(30.0)
        private static let TextViewExpandedHeight = CGFloat(160.0)
        private static let TextViewCollapsedHeight = CGFloat(30.0)
    }
    
    private var messageOneTextViewHeightConstraint: NSLayoutConstraint!
    private var messageTwoTextViewHeightConstraint: NSLayoutConstraint!
    weak var delegate: MultiLineTextCellDelegate?
    
    
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
    
    var messageTwoText: String? {
        didSet {
            messageTwoTextView.text = messageTwoText
        }
    }
    
    var expandMessageOne = true {
        didSet {
            self.setNeedsLayout()
        }
    }
    var expandMessageTwo = false {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    private let dateLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFontOfSize(14)
        view.textColor = .blackColor()
        view.textAlignment = .Left
        view.numberOfLines = 1
        view.backgroundColor = UIColor.orangeColor()
        return view
    }()
    
    private let functionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFontOfSize(14)
        view.textColor = .blackColor()
        view.textAlignment = .Left
        view.numberOfLines = 1
        return view
    }()

    private let divider: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGrayColor()
        return view
    }()
    
    private let messageOneButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let title = "Show"
        button.setTitle(title, forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(14)
        
        button.backgroundColor = .yellowColor()
        button.contentHorizontalAlignment = .Left
        
        return button
    }()
    
    private let messageOneTextView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .greenColor()
        return view
    }()
    
    
    private let messageTwoButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let title = "Show"
        button.setTitle(title, forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(14)
        button.setTitleColor(.blackColor(), forState: .Normal)
        button.backgroundColor = .yellowColor()
        button.contentHorizontalAlignment = .Left
        
        return button
    }()
    
    private let messageTwoTextView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .greenColor()
        return view
    }()
    
    
    required internal init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layout()
        bindEvents()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layout()
        bindEvents()
    }
    
    /*
    private let buffer = NSMutableAttributedString()
    
    var color:UIColor {
        get { return self.label.textColor }
        set { self.label.textColor = newValue }
    }
    
    private let label: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.lineBreakMode = .ByWordWrapping
        view.translatesAutoresizingMaskIntoConstraints = false
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
    
    internal func clear() {
        buffer.setAttributedString(NSAttributedString(string:""))
        label.attributedText = buffer
    }
    
    internal func append(str:String, font:UIFont) {
        let trimmed = str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let astr = NSAttributedString(
            string: trimmed,
            attributes: [NSFontAttributeName : font]
        )
        
        buffer.appendAttributedString(astr)
        buffer.appendAttributedString(NSAttributedString(string:"\n"))
        label.attributedText = buffer
    }
    
    internal func append(str:String, style:String) {
        append(str, font: UIFont.preferredFontForTextStyle(style))
    }
    
    internal func layout() {
        
        selectionStyle = .Gray
        contentView.addSubview(label)
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-10-[view]|", options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view":label]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-15-[view]-15-|", options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view":label]))

        
    }
    */
    
    override func layoutSubviews() {
        super.layoutSubviews()

        dateLabel.textColor = customTextColor
        functionLabel.textColor = customTextColor
        messageOneButton.setTitleColor(customTextColor, forState: .Normal)
        messageTwoButton.setTitleColor(customTextColor, forState: .Normal)
        
        
        if expandMessageOne {
            messageOneTextView.hidden = false
            messageOneButton.hidden = true
            messageOneTextViewHeightConstraint.constant = Constants.TextViewExpandedHeight
        }
        else {
            messageOneButton.hidden = false
            messageOneTextView.hidden = true
            messageOneTextViewHeightConstraint.constant = Constants.TextViewCollapsedHeight
        }
        
        if expandMessageTwo {
            messageTwoTextView.hidden = false
            messageTwoButton.hidden = true
            messageTwoTextViewHeightConstraint.constant = Constants.TextViewExpandedHeight
        }
        else {
            messageTwoButton.hidden = false
            messageTwoTextView.hidden = true
            messageTwoTextViewHeightConstraint.constant = Constants.TextViewCollapsedHeight
        }
    }
}




extension MultiLineTextCell {
    
    private func layout() {
        contentView.addSubview(dateLabel)
        contentView.addSubview(functionLabel)
        
        contentView.addSubview(messageOneTextView)
        contentView.addSubview(messageOneButton)
        contentView.addSubview(messageTwoTextView)
        contentView.addSubview(messageTwoButton)
        
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
        
        //functionLabel
        contentView.addConstraint(NSLayoutConstraint(
            item: functionLabel,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: dateLabel,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: Constants.SmallMargin)
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
        messageOneTextViewHeightConstraint = NSLayoutConstraint(
            item: messageOneTextView,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .Height,
            multiplier: 1.0,
            constant: Constants.TextViewCollapsedHeight
        )
        contentView.addConstraint(messageOneTextViewHeightConstraint)
        
        
        //messageOneButton
        contentView.addConstraint(NSLayoutConstraint(
            item: messageOneButton,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: messageOneTextView,
            attribute: .Top,
            multiplier: 1.0,
            constant: 0)
        )
        contentView.addConstraint(NSLayoutConstraint(
            item: messageOneButton,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: messageOneTextView,
            attribute: .Left,
            multiplier: 1.0,
            constant: 0)
        )
        contentView.addConstraint(NSLayoutConstraint(
            item: messageOneButton,
            attribute: .Right,
            relatedBy: .Equal,
            toItem: messageOneTextView,
            attribute: .Right,
            multiplier: 1.0,
            constant: 0)
        )
        contentView.addConstraint(NSLayoutConstraint(
            item: messageOneButton,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: messageOneTextView,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 0)
        )
        
        //divider
        contentView.addConstraint(NSLayoutConstraint(
            item: divider,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: messageOneTextView,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 0)
        )
        contentView.addConstraint(NSLayoutConstraint(
            item: divider,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: messageOneTextView,
            attribute: .Left,
            multiplier: 1.0,
            constant: 0)
        )
        contentView.addConstraint(NSLayoutConstraint(
            item: divider,
            attribute: .Right,
            relatedBy: .Equal,
            toItem: messageOneTextView,
            attribute: .Right,
            multiplier: 1.0,
            constant: 0)
        )
        contentView.addConstraint(NSLayoutConstraint(
            item: divider,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .Height,
            multiplier: 1.0,
            constant: 1)
        )
        
        
        //messageTwoTextView
        contentView.addConstraint(NSLayoutConstraint(
            item: messageTwoTextView,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: divider,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 0)
        )
        contentView.addConstraint(NSLayoutConstraint(
            item: messageTwoTextView,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: self.contentView,
            attribute: .Left,
            multiplier: 1.0,
            constant: 0)
        )
        contentView.addConstraint(NSLayoutConstraint(
            item: messageTwoTextView,
            attribute: .Right,
            relatedBy: .Equal,
            toItem: self.contentView,
            attribute: .Right,
            multiplier: 1.0,
            constant: 0)
        )
        messageTwoTextViewHeightConstraint = NSLayoutConstraint(
            item: messageTwoTextView,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .Height,
            multiplier: 1.0,
            constant: Constants.TextViewCollapsedHeight
        )
        contentView.addConstraint(messageTwoTextViewHeightConstraint)
        
        
        //messageTwoButton
        contentView.addConstraint(NSLayoutConstraint(
            item: messageTwoButton,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: messageTwoTextView,
            attribute: .Top,
            multiplier: 1.0,
            constant: 0)
        )
        contentView.addConstraint(NSLayoutConstraint(
            item: messageTwoButton,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: messageTwoTextView,
            attribute: .Left,
            multiplier: 1.0,
            constant: 0)
        )
        contentView.addConstraint(NSLayoutConstraint(
            item: messageTwoButton,
            attribute: .Right,
            relatedBy: .Equal,
            toItem: messageTwoTextView,
            attribute: .Right,
            multiplier: 1.0,
            constant: 0)
        )
        contentView.addConstraint(NSLayoutConstraint(
            item: messageTwoButton,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: messageTwoTextView,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 0)
        )
    }
    
    
    private func bindEvents() {
        //messageOneButton
        messageOneButton.addTarget(self, action: #selector(showMessageOneTextView), forControlEvents: .TouchUpInside)
        let messageOneTap = UITapGestureRecognizer(target: self, action: #selector(messageOneTextViewTapped))
        messageOneTextView.addGestureRecognizer(messageOneTap)
        
        //messageTwoButton
        messageTwoButton.addTarget(self, action: #selector(showMessageTwoTextView), forControlEvents: .TouchUpInside)
        let messageTwoTap = UITapGestureRecognizer(target: self, action: #selector(messageTwoTextViewTapped))
        messageTwoTextView.addGestureRecognizer(messageTwoTap)
    }

    
    func messageOneTextViewTapped(sender: UITextView) {
        expandMessageOne = false

        self.setNeedsLayout()
        delegate?.multiLineTextCell(self, messageOneOpen: expandMessageOne, messageTwoOpen: expandMessageTwo)
    }
    
    func showMessageOneTextView(sender: UIButton) {
        expandMessageOne = true

        self.setNeedsLayout()
        delegate?.multiLineTextCell(self, messageOneOpen: expandMessageOne, messageTwoOpen: expandMessageTwo)
    }
    
    func messageTwoTextViewTapped(sender: UITextView) {
        expandMessageTwo = false
        
        self.setNeedsLayout()
        delegate?.multiLineTextCell(self, messageOneOpen: expandMessageOne, messageTwoOpen: expandMessageTwo)
    }
    
    func showMessageTwoTextView(sender: UIButton) {
        expandMessageTwo = true
        
        self.setNeedsLayout()
        delegate?.multiLineTextCell(self, messageOneOpen: expandMessageOne, messageTwoOpen: expandMessageTwo)
    }
}


extension MultiLineTextCell {

    func calculateHeight(messageOneIsOpen: Bool, messageTwoIsOpen: Bool) -> CGFloat {
        let smallMargins = Constants.SmallMargin * 3
        
        let bw = self.bounds.width
        let dateLabelHeight = dateLabel.height(viewWidth: bw - Constants.SmallMargin * 2)
        let functionLabelHeight = functionLabel.height(viewWidth: bw - Constants.SmallMargin * 2)
        
        let messageOneHeight = messageOneIsOpen ? Constants.TextViewExpandedHeight : Constants.TextViewCollapsedHeight
        let messageTwoHeight = messageTwoIsOpen ? Constants.TextViewExpandedHeight : Constants.TextViewCollapsedHeight

        let heights = [
            smallMargins,
            dateLabelHeight,
            functionLabelHeight,
            messageOneHeight,
            messageTwoHeight
        ]
        
        return heights.reduce(0, combine: +)
    }
    
}
