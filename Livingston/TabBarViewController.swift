//
//  TabBarViewController.swift
//  Livingston
//
//  Created by Max Vitruk on 09.09.15.
//  Copyright (c) 2015 integer. All rights reserved.
//

import UIKit

protocol MenuCallBackExtantion {
  func bluetoothFromMenu(sender : UIButton)
  func menuFromMenu(sender : UIButton)
}

class TabBarViewController: UITabBarController,UITabBarControllerDelegate, UIPopoverPresentationControllerDelegate,ContactWithFishViewDelegate {
  
  var popoverContent : MenuViewController!
  var deleg : UITabBarControllerDelegate!
  let userDefaults = NSUserDefaults.standardUserDefaults()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("MenuViewController") as? MenuViewController
    popoverContent.delegate = self
    self.delegate = self
    
    let rightView = UIView(frame:  CGRectMake(0, 0, 80, 30))
    rightView.backgroundColor = UIColor.clearColor()
    
    let imageView = UIImageView(frame: CGRectMake(0, 0, 40, 40))
    imageView.contentMode = .ScaleAspectFit
    imageView.image = UIImage(named: "icon")
    self.navigationItem.titleView = imageView
    
    let btn1 = UIButton(frame: CGRectMake(0,0,30, 30))
    btn1.setImage(UIImage(named: "bluetoothicon"), forState: UIControlState.Normal)
    btn1.tag=101
    btn1.addTarget(self, action: "bluetoothFromMenu:", forControlEvents: UIControlEvents.TouchUpInside)
    rightView.addSubview(btn1)
    
    let btn2 = UIButton(frame: CGRectMake(40,0,30, 30))
    btn2.setImage(UIImage(named: "menuIcon"), forState: UIControlState.Normal)
    btn2.tag=102
    btn2.addTarget(self, action: "menuFromMenu:", forControlEvents: UIControlEvents.TouchUpInside)
    rightView.addSubview(btn2)
    
    
    let rightBtn = UIBarButtonItem(customView: rightView)
    self.navigationItem.rightBarButtonItem = rightBtn;
  }
  
  func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
    var changeView = true
    for controller in (viewController as! UINavigationController).viewControllers{
      if controller.isKindOfClass(FishViewController){
        changeView = false
      }
    }
    return changeView
  }
  
  override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
    if item == self.tabBar.items![0]{
      self.selectedIndex = 0
      if let vc = self.selectedViewController as? UINavigationController{
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("CatchLogViewController") as! CatchLogViewController
        vc.pushViewController(controller, animated: true)
      }else{
        print("error")
      }
    }
  }
  
  func logOut(){
    print("\n\nlogOut")
    userDefaults.setBool(false, forKey: "rememberMe")
    //        self.navigationController?.popToRootViewControllerAnimated(true)
    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController
    self.navigationController?.presentViewController(vc!, animated: true, completion: nil)
    
  }
  
  func showMenu() {
    popoverContent!.modalPresentationStyle = UIModalPresentationStyle.Popover
    popoverContent!.preferredContentSize = CGSizeMake(240,260)
    let nav = popoverContent!.popoverPresentationController
    nav?.delegate = self
    nav?.sourceView = self.view
    let xPosition = self.view.frame.width
    let yPosition = self.view.frame.minY + 52
    nav?.permittedArrowDirections = UIPopoverArrowDirection.Up
    nav?.sourceRect = CGRectMake(xPosition, yPosition , 0, 0)
    self.navigationController?.presentViewController(popoverContent!, animated: true, completion: nil)
    
  }
  
  func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
    return .None
  }
}

extension TabBarViewController  : MenuCallBackExtantion {
  func bluetoothFromMenu(sender : UIButton){
    
  }
  func menuFromMenu(sender : UIButton ){
    self.showMenu()
  }
}
