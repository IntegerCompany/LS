//
//  SortMenuViewController.swift
//  Livingston
//
//  Created by Dmytro Lohush on 10/16/15.
//  Copyright © 2015 integer. All rights reserved.
//

import UIKit

protocol SortMenuItemSelectedDelegate {
  func sortMenuItemSelected(selectedItem: SortMenuItem)
}

enum SortMenuItem : Int{
  case SortByName = 0
  case SortByType = 1
  case Search = 2
}

class SortMenuViewController : UIViewController {
  
  var delegate: SortMenuItemSelectedDelegate?
  
  @IBAction func sortByName(sender: UIButton) {
    delegate?.sortMenuItemSelected(.SortByName)
  }
  
  @IBAction func sortByType(sender: AnyObject) {
    delegate?.sortMenuItemSelected(.SortByType)
  }
  
  @IBAction func search(sender: UIButton) {
    delegate?.sortMenuItemSelected(.Search)
  }
  
}