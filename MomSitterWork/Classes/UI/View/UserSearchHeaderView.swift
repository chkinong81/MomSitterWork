//
//  UserSearchHeaderView.swift
//  MomSitterWork
//
//  Created by Dong-Eon Kim on 2020/12/18.
//  Copyright © 2020 Dong-Eon Kim. All rights reserved.
//

import UIKit

/**
* LocalSearchViewController에서 Section HeaderView
*/
class UserSearchHeaderView: UITableViewHeaderFooterView {
    static var identifier: String = "UserSearchHeaderView"
    @IBOutlet var headerTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func configureHeaderView(_ title: String) {
        headerTitleLabel.text = title
    }
}
