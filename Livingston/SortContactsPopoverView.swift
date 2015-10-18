//
//  SortContactsPopoverView.swift
//  Livingston
//
//  Created by Max Vitruk on 19.10.15.
//  Copyright © 2015 integer. All rights reserved.
//

import UIKit

protocol SortContactSelectedDelegate {
    func sortMenuItemSelected(selectedItem: SortCOntactItem)
    func searchByCharters(searchStrig : String)
    func cancelSortFiltes()
    
}

enum SortCOntactItem : Int{
    case SortByName = 0
    case SortByType = 1
}

class SortContactsPopViewController : UIViewController {
    
    @IBOutlet weak var searchText: UITextField!
    var delegate: SortContactSelectedDelegate?
    
    @IBAction func cancelFilters(sender: UIButton) {
        delegate?.cancelSortFiltes()
    }
    @IBAction func searchButtonAction(sender: UIButton) {
        if !(self.searchText.text!.isEmpty) {
            delegate?.searchByCharters(searchText.text!)
        }
    }
}
