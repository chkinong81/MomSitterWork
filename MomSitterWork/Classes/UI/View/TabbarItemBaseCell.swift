//
//  TabbarItemBaseCell.swift
//  MomSitterWork
//
//  Created by Dong-Eon Kim on 2020/12/17.
//  Copyright © 2020 Dong-Eon Kim. All rights reserved.
//

import UIKit

/**
* TabbarView Item 상속 Cell
*/
class TabbarItemBaseCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var underLineView: UIView!
    
    private func hiddenUnderLine(_ hidden: Bool) {
        self.underLineView.isHidden = hidden
    }
    
    public func configureInfo(_ title: String, selected: Bool) {
        self.titleLabel.text = title
        self.hiddenUnderLine(!selected)
    }
}
