import UIKit
import SDWebImage
import youtube_ios_player_helper

class LaunchDetailController: UIViewController, WKUIDelegate {

    var imageArray: [String]?
    var launchName: String?
    var details: String?
    
    var youtubeURL: String?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var playerView: YTPlayerView!
        // Specific view that can show YouTube videos using ID
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = launchName
        
        if let id = youtubeURL {
            playerView.load(withVideoId: id)
            
        }
        if let details = details {
            label.text = details
        } else {
            label.removeFromSuperview() // Delete views from main
        }
        
        if let images = imageArray {
            if images.isEmpty {
                collectionView.removeFromSuperview()
            }
        } else {
            collectionView.removeFromSuperview()
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
            cell.launchImageView.layer.cornerRadius = 10.0
            
        }
        
        return cell
    }
}
