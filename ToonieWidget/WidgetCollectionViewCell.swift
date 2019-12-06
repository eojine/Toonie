//
//  WidgetCollectionViewCell.swift
//  Toonie
//
//  Created by 양어진 on 26/05/2019.
//  Copyright © 2019 Yapp. All rights reserved.
//

import UIKit

final class WidgetCollectionViewCell: UICollectionViewCell {

    // MARK: - IBOutlet

    @IBOutlet private weak var widgetImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        widgetImageView.image = nil
    }

    // MARK: - Function

    /// widget 컬렉션뷰셀 데이터 설정
    func setWidgetCollectionViewCellProperties(tagName: String) {
        widgetImageView.setCorner(cornerRadius: 5)
        widgetImageView.image = UIImage(named: tagImage(name: tagName,
                                                        storyboardName: "Look"))
    }
}
