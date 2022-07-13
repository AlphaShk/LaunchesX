//
//  ListViewController.swift
//  LaunchesX
//
//  Created by Denys Shkola on 12.07.2022.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class ListViewController: UITableViewController {
   
    var json: JSON?
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.register(UINib(nibName: "ListCell", bundle: nil), forCellReuseIdentifier: K.cell)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchRequest()
        
    }
    
    func fetchRequest() {
        
        Alamofire.request(K.url, method: .get).responseJSON() { response in
            if response.result.isSuccess {
                self.json = JSON(response.result.value!)
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if json != nil {
            return 1
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return json?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cell, for: indexPath) as! ListCell
        
        cell.label.text = self.json?[indexPath.row]["name"].stringValue
        cell.patchImageView.sd_setImage(with: URL(string: (self.json?[indexPath.row]["links"]["patch"]["small"].stringValue)!))
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.segue, sender: self)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == K.segue {
            let ldc = segue.destination as! LaunchDetailController
            if let indexPath = tableView.indexPathForSelectedRow {
                ldc.imageArray = self.json?[indexPath.row]["links"]["flickr"]["original"].arrayObject as! [String]?
                ldc.launchName = self.json?[indexPath.row]["name"].stringValue
                ldc.details = self.json?[indexPath.row]["details"].stringValue
            }
        }
        
    }
    

}
