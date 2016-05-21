//
//  FilterView.swift
//  SampleApp
//
//  Created by Matthew Yannascoli on 5/17/16.
//

import UIKit
import PersistentLog

protocol FilterViewDelegate: class {
    func filterViewDidUpdateLevel(level: LogLevel)
    func filterViewDidUpdateFilter(filter: String?)
}


class FilterView: UIView {
    
    private let picker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.backgroundColor = .whiteColor()
        return picker
    }()
    private let filters: [String]
    private struct Level {
        let title:String
        let value: LogLevel?
    }
    
    private let levels: [Level] = [
        Level(title: "All", value: nil),
        Level(title: "Debug", value: .Debug),
        Level(title: "Info", value: .Info),
        Level(title: "Warn", value: .Warn),
        Level(title: "Error", value: .Error)
    ]
    
    weak var delegate: FilterViewDelegate? = nil
    
    init(filters: [String]) {
        self.filters = filters
        super.init(frame: CGRect.zero)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension FilterView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        if self.filters.count > 0 {
            return 2
        }
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 1 {
            return filters.count + 1
        }
        return levels.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 1 {
            if row == 0 {
                return "All"
            } else {
                return filters[row - 1]
            }
        }
        return levels[row].title
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 1 {
            var filter: String? = nil
            if row > 0 {
                filter = filters[row - 1]
            }
            delegate?.filterViewDidUpdateFilter(filter)
        }
        else {
            if let level = levels[row].value {
                delegate?.filterViewDidUpdateLevel(level)
            }
        }
    }
}


extension FilterView {
    private func layout() {
         picker.delegate = self
         picker.dataSource = self
         addSubview(picker)
        
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[picker]|", options: [], metrics: nil, views: ["picker": picker]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[picker]|", options: [], metrics: nil, views: ["picker": picker]))
    }
}