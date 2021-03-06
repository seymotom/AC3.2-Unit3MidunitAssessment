//
//  AlbumsTableViewController.swift
//  AC3.2-Unit3MidunitAssessment
//
//  Created by Tom Seymour on 10/28/16.
//  Copyright © 2016 C4Q-3.2. All rights reserved.
//

import UIKit

class AlbumsTableViewController: UITableViewController {
    
    var albums = [Album]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTableViewData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        loadTableViewData()
    }

    func loadTableViewData() {
        navigationItem.title = SearchManager.manager.searchTitle
        let myEndpoint = SearchManager.manager.searchString
        APIHelper.manager.getData(endPoint: myEndpoint) { (data: Data?) in
            guard let unwrappedData = data else { return }
            self.albums = AlbumFactory.buildAlbumArray(from: unwrappedData)!
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCellIdentifyer", for: indexPath)
        let thisAlbum = albums[indexPath.row]
        cell.textLabel?.text = thisAlbum.albumName
        
        APIHelper.manager.getData(endPoint: thisAlbum.Images.thumnail) { (returnedData: Data?) in
            guard let validData = returnedData else { return }
            DispatchQueue.main.async {
                cell.imageView?.image = UIImage(data: validData)
                //this content mode stuff doesn' work in this default cell, make a custom cell.
                cell.imageView?.contentMode = .scaleAspectFill
                cell.imageView?.clipsToBounds = true
                cell.setNeedsLayout()
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let thisAlbum  = albums[indexPath.row]
        performSegue(withIdentifier: "AlbumDetailPageSegue", sender: thisAlbum)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AlbumDetailPageSegue" {
            if let destiationVC = segue.destination as? AlbumDetailViewController {
                destiationVC.thisAlbum = sender as? Album
            }
        }
    }

}
