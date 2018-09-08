//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by akhil mantha on 23/08/18.
//  Copyright © 2018 akhil mantha. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var downloadingImageActivityView: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setSelected(selected: false)
        imageView.image = nil
    }
    
    func setSelected(selected:Bool){
        if selected {
            layer.borderColor = UIColor.red.cgColor
            layer.borderWidth = 2.0
        }else {
            layer.borderColor = UIColor.clear.cgColor
            layer.borderWidth = 0.0
        }
    }
    
    func loadImage(image:UIImage){
        imageView.image = image
        downloadingImageActivityView.isHidden = true
    }
    
    func setUpForPlaceholder(){
        downloadingImageActivityView.isHidden = false
        activityIndicator.startAnimating()
    }
}


