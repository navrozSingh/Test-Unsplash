//
//  ImageCell.swift
//  Unsplash
//
//  Created by Navroz on 15/05/21.
//

import Foundation
import UIKit

class ImageCell: UITableViewCell {
    var cellImageView: UIImageView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    func initialize() {
        cellImageView = UIImageView()
        contentView.addSubview(cellImageView)
        cellImageView.translatesAutoresizingMaskIntoConstraints = false
        cellImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        cellImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        cellImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        cellImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImageView.image = nil
    }
}
