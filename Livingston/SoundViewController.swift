//
//  SoundViewController.swift
//  Livingston
//
//  Created by Max Vitruk on 03.09.15.
//  Copyright (c) 2015 integer. All rights reserved.
//

import UIKit

class SoundViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let segueId = "goToCurrentSoundVIew"
    
    let sounds = ["#1 EBS CREW","#2 EBS CREW MAX","#3 EBS FRESHWATER SHRIMP","#10 EBS AMERICAN SHAD","#11 EBS TENNESSEE SHAD", "#12 EBS HICKORY SHAD", "#13 EBS BLUE GILL", "#14 EBS PANFISH", "#15 EBS SUNFISH", "#16 EBS MINNOW", "#17 EBS TILIPIA", "#18 EBS BREAM" , "#19 EBS SCULPIN", "#20 EBS GOBY 1", "#21 EBS G PERCH 2", "#22 EBS LONG GOBY 3", "#23 EBS SMELT", "#24 EBS HITCH", "#25 EBS FROG 1", "#26 EBS AQUATIC ISECT 1", "#27 EBS BUG", "#28 EBS SACEDA", "#29 EBS MOUSE", "#30 GILL PLATES MAX"]
    
    let imagesNames = ["bluegill","lizard", "snail","shad","amiphods","goby","spider","minnow","worm","leech","grasshopper","frog","salamander","snake","bird","mice","rat","fruitbat","squirrel","duck","alligator","amiphods", "isopod","clam"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let img = UIImage(named: "background")
        self.collectionView.backgroundColor = UIColor(patternImage: img!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func record(sender: UIButton) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("RecordACatchViewController") as! RecordACatchViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func tackle(sender: UIButton) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TackleBoxViewController") as! TackleBoxViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension SoundViewController : UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sounds.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("soundGridViewCell", forIndexPath: indexPath) as! SoundListCell
        cell.image.image = UIImage(named: self.imagesNames[indexPath.item])
        cell.name.text = self.sounds[indexPath.item]
        
        return cell
    }
    
}

extension SoundViewController : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier(self.segueId, sender: self)
    }
}
