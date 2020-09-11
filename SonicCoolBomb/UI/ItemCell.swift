//
//  ItemCollectionViewCell.swift
//  SonicCoolBomb
//
//  Created by ko on 2020/8/17.
//  Copyright © 2020 SM. All rights reserved.
//

import UIKit
/*
 a. image        : UIImage
 b. title        : UILabel
 c. rank         : UILabel
 d. start date   : UILabel
 e. end date     : UILabel
 f. type         : UILabel
*/

protocol favoriteDelegate: AnyObject {
    func clickFavorite(sender: UIButton)

}

class ItemCell: UITableViewCell {

    weak var delegate : favoriteDelegate?

    var cellImgv :UIImageView!
    var titleLabel : UILabel!
    var rankLabel : UILabel!
    var startDateLabel : UILabel!
    var endDateLabel : UILabel!
    var typeLabel : UILabel!
    var favoirteButton : UIButton!

    var cellStackView: UIStackView!
   private func setupLabel(style: UIFont.TextStyle) -> UILabel {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byCharWrapping
        lbl.textAlignment = .left

        lbl.adjustsFontForContentSizeCategory = true

        let pointSize = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style).pointSize
        lbl.font = UIFont.preferredFont(forTextStyle: style).withSize(pointSize)

        return lbl
    }

   private func setupButton() -> UIButton {
        let btn = UIButton(type: .custom)
        btn.imageView?.contentMode = .scaleAspectFill
        return btn
    }

   private func setupStackView(input: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: input)
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let titleLab = setupLabel(style: .headline)

        self.titleLabel = titleLab

        let rankLab = setupLabel(style:.callout)
        self.rankLabel = rankLab

        let startLab = setupLabel(style:.callout)
        self.startDateLabel = startLab

        let endLab = setupLabel(style:.callout)
        self.endDateLabel = endLab

        let typeLab = setupLabel(style:.callout)
        self.typeLabel = typeLab

        let favoriteBtn = setupButton()
        self.favoirteButton = favoriteBtn

        let stackView = setupStackView(input: [titleLab,rankLab,startLab,endLab,typeLab, favoriteBtn])
        self.cellStackView = stackView
        self.contentView.addSubview(stackView)


        let mainImage = UIImageView.init(frame: .zero)
        mainImage.contentMode = .scaleAspectFit
        mainImage.translatesAutoresizingMaskIntoConstraints = false
        mainImage.clipsToBounds = true

        self.contentView.addSubview(mainImage)
        self.cellImgv = mainImage
        let ctv = self.contentView



        NSLayoutConstraint.activate([

            self.cellImgv.leadingAnchor.constraint(equalTo: ctv.layoutMarginsGuide.leadingAnchor),
            self.cellImgv.topAnchor.constraint(equalTo: ctv.layoutMarginsGuide.topAnchor),
            self.cellImgv.bottomAnchor.constraint(equalTo: ctv.layoutMarginsGuide.bottomAnchor),
            self.cellImgv.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width/3),
            self.cellImgv.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.height/4),

            cellStackView.topAnchor.constraint(equalTo: ctv.topAnchor),
            cellStackView.leadingAnchor.constraint(equalTo: self.cellImgv.trailingAnchor),
            cellStackView.trailingAnchor.constraint(equalTo: ctv.trailingAnchor),
            cellStackView.bottomAnchor.constraint(equalTo: ctv.bottomAnchor)
        ])

        favoirteButton.addTarget(self, action: #selector(clickFavoriteButton), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func layoutSubviews() {
        super.layoutSubviews()

    }

    @objc func clickFavoriteButton(_ sender: UIButton) {
        self.delegate?.clickFavorite(sender: sender)
    }

}

