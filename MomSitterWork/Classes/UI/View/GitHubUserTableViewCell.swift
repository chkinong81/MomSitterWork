//
//  GitHubUserTableViewCell.swift
//  MomSitterWork
//
//  Created by Dong-Eon Kim on 2020/12/18.
//  Copyright © 2020 Dong-Eon Kim. All rights reserved.
//

import UIKit
import Kingfisher
/**
* SearchUser Cell UI
*/
class GitHubUserTableViewCell: UITableViewCell {
    static var identifier: String = "GitHubUserTableViewCell"
    static var height: CGFloat = 100
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var starIconButton: UIButton!
    @IBOutlet var nameLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    public func configureCell(_ profileURL: String, favorite: Bool, name: String) {
        updateProfileImageView(profileURL)
        updateStartIconButton(favorite)
        updatNameLabelView(name)
    }
    
    private func updateProfileImageView(_ profileURL: String) {
        DispatchQueue.main.async {
            let options : KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.1))]
            self.profileImageView.kf.setImage(with: URL(string: profileURL), options: options)
        }
    }
    
    public func updateStartIconButton(_ favorite: Bool) {
        starIconButton.isSelected = favorite
    }
    
    public func toggleStartIconButton() {
        starIconButton.isSelected = !starIconButton.isSelected
    }
    
    private func updatNameLabelView(_ name: String) {
        nameLabel.text = name
    }
    
    @IBAction func startIconButtonClicked(_ sender: UIButton) {
        starIconButton.isSelected = !starIconButton.isSelected
        updateStartIconButton(starIconButton.isSelected)
    }
}
