//
//  ViewController.swift
//  LaunchesX
//
//  Created by Denys Shkola on 12.07.2022.
//

import UIKit
import SDWebImage


class LaunchDetailController: UIViewController {

    var imageArray: [String]?
    var launchName: String?
    var details: String?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var launchLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        launchLabel.alpha = 0.0
        textView.alpha = 0.0
        
        launchLabel.text = launchName
        if let details = details {
            textView.text = details
        } else {
            textView.removeFromSuperview()
        }
        UIView.animate(withDuration: 1.5, delay: 0.5, animations: {
            self.launchLabel.alpha = 1.0
        })
        UIView.animate(withDuration: 1.5, delay: 1.0, animations: {
            self.textView.alpha = 1.0
        })
        
        if imageArray!.isEmpty {
            collectionView.removeFromSuperview()
            let constraint = NSLayoutConstraint(item: launchLabel, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view.safeAreaLayoutGuide, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 5)
            launchLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([constraint])
            
            
        }
    }


}

extension LaunchDetailController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return imageArray?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.imgCell, for: indexPath) as! ImageCell
        if let images = imageArray {
            cell.launchImageView.sd_setImage(with: URL(string: images[indexPath.row]))
            cell.launchImageView.layer.cornerRadius = 50.0
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 1.5, delay: 0.5, animations: {
            (cell as! ImageCell).launchImageView.alpha = 1.0
        })
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 1.5, delay: 0.5, animations: {
            (cell as! ImageCell).launchImageView.alpha = 1.0
        })
        return true
    }
    
}
