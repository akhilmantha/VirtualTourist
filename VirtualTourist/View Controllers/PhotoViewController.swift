//
//  PhotoViewController.swift
//  VirtualTourist
//
//  Created by akhil mantha on 23/08/18.
//  Copyright © 2018 akhil mantha. All rights reserved.
//

import UIKit

class PhotoViewController: CoreDataViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    var selectedPin:Pin?
    
    
    private var pageNumber = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.allowsMultipleSelection = true
        messageLabel.isHidden = true
        
        if fetchedResultsController!.fetchedObjects!.count == 0 {
            getImagesFromFlickr()
        }else {
            collectionView.reloadData()
        }
    }
    
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        if (collectionView.indexPathsForSelectedItems?.count)! > 0 {
            deleteSelectedItems()
        }else {
            loadNewPhotoSet()
        }
    }
    
    private func deleteSelectedItems(){
        
        for indexPath in collectionView.indexPathsForSelectedItems! {
            let photo = fetchedResultsController!.object(at: indexPath)
            fetchedResultsController!.managedObjectContext.delete(photo as! Photo)
        }
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        do {
            try stack.saveContext()
        }catch {
            print("Error while saving in deleteSelectedItems()")
        }
        
        collectionView.deleteItems(at: self.collectionView.indexPathsForSelectedItems!)
        
        
        actionButton.setTitle("Load New Photo Set", for: .normal)
    }
    
    private func loadNewPhotoSet() {
        
        //Delete all photos in core date
        for photo in fetchedResultsController!.fetchedObjects! {
            fetchedResultsController!.managedObjectContext.delete(photo as! Photo)
        }
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        do {
            try stack.saveContext()
        }catch {
            print("Error while saving in loadNewPhotoSet")
        }
        
        collectionView.reloadData()
        getImagesFromFlickr()
    }
    
    private func getImagesFromFlickr(){
        actionButton.isEnabled = false
        pageNumber += 1
        
        FlickrApi.sharedInstance().getImageUrlsForCoordinates(latitude: selectedPin!.latitude, longitude:selectedPin!.longitude, page:pageNumber){ urls, error in
            func displayError(error:String) {
                
                let alert = UIAlertController(title: "Photo Download Error", message: error, preferredStyle:.alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                
                alert.addAction(defaultAction)
                
                self.present(alert, animated: true, completion: nil)
            }
            
            guard error == nil else {
                performUIUpdatesOnMain {
                    displayError(error: (error?.localizedDescription)!)
                    self.actionButton.isEnabled = true
                }
                return
            }
            
            guard urls!.count != 0 else{
                performUIUpdatesOnMain {
                    self.messageLabel.text = "There are no photos for this pin."
                    self.messageLabel.isHidden = false
                    self.actionButton.isEnabled = true
                }
                return
            }
            
            performUIUpdatesOnMain {
                self.messageLabel.isHidden = true
                var order = 0
                for url in urls! {
                    self.addNewPhoto(url: url.absoluteString, order: Int16(order))
                    order += 1
                }
                
                let delegate = UIApplication.shared.delegate as! AppDelegate
                let stack = delegate.stack
                
                do {
                    try stack.saveContext()
                }catch {
                    print("Error while saving in getImagesFromFlickr")
                }
                self.collectionView.reloadData()
                self.actionButton.isEnabled = true
            }
        }
    }
    
    private func addNewPhoto(url:String, order:Int16){
        let newPhoto = Photo(url: url, order: order, context: fetchedResultsController!.managedObjectContext)
        newPhoto.pin = selectedPin!
    }
    
    
    
}

extension PhotoViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let fc = fetchedResultsController {
            return (fc.sections?.count)!
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let fc = fetchedResultsController {
            return fc.sections![section].numberOfObjects
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoViewCell", for: indexPath) as! PhotoCollectionViewCell
        
        let photo = fetchedResultsController!.object(at: indexPath) as! Photo
        
        if let imageData = photo.imageData {
            let image = UIImage(data: imageData)
            cell.loadImage(image: image!)
        }else {
            cell.setUpForPlaceholder()
            loadImageFromUrl(photo:photo, cell:cell)
        }
        
        if let selectedIndexPaths = collectionView.indexPathsForSelectedItems {
            cell.setSelected(selected: selectedIndexPaths.contains(indexPath))
        }
        
        return cell
    }
    
    private func loadImageFromUrl(photo:Photo, cell:PhotoCollectionViewCell){
        FlickrApi.sharedInstance().getPhotoForUrl(url: URL(string:photo.url!)!){data, error in
            
            if error == nil {
                performUIUpdatesOnMain {
                    cell.loadImage(image: UIImage(data: data!)!)
                    photo.imageData = data!
                    
                    let delegate = UIApplication.shared.delegate as! AppDelegate
                    let stack = delegate.stack
                    
                    do {
                        try stack.saveContext()
                    }catch {
                        print("Error while saving in loadImageFromUrl ")
                    }
                }
            }else {
                print(error!.description)
            }
        }
        
    }
    
}

extension PhotoViewController: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        cell.setSelected(selected: true)
        actionButton.setTitle("Delete Selected Photos", for: .normal)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        cell.setSelected(selected: false)
        if collectionView.indexPathsForSelectedItems == nil || collectionView.indexPathsForSelectedItems?.count == 0 {
            actionButton.setTitle("Load New Photo Set", for: .normal)
        }
    }
}

