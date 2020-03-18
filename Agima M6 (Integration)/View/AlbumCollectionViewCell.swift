//
//  AlbumCollectionViewCell.swift
//  Agima M6 (Integration)
//
//  Created by Kravchuk Sergey on 17.03.2020.
//  Copyright © 2020 Kravchuk Sergey. All rights reserved.
//

import UIKit

class AlbumCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var imageURL: URL?
    
    func setImage(url: URL) {
        imageURL = url
        updateImage()
    }
    
    private func updateImage() {
        guard let url = imageURL else {
            imageView.image = nil
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard self.imageURL == url else { return }
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self.imageView.image = nil
                }
                return
            }
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }.resume()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
