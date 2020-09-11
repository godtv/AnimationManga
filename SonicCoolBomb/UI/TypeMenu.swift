//
//  typeMenu.swift
//  SonicCoolBomb
//
//  Created by ko on 2020/9/9.
//  Copyright © 2020 SM. All rights reserved.
//

import UIKit

class TypeMenu: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
     
    var typeButton: UIButton!
    var subTypeButton: UIButton!
    var mystackView: UIStackView!
    
    var myTypeHandler: ((_ button: UIButton) -> ())?
    var mySubTypeHandler: ((_ button: UIButton) -> ())?
    
    private var typeInit: String!
    private var subTypeInit: String!
    
    private func setupStackView(input: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: input)
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 0.5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    private func setupButton(text: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(text, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        return button
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
     
    init(typeInit: String, subTypeInit: String, selectType typeHandler: @escaping (_ button: UIButton) -> (), selectSubType subTypeHandler: @escaping (_ button: UIButton) -> ()){
         
        super.init(frame: .zero)
       
        self.typeInit = typeInit
        self.subTypeInit = subTypeInit
        
        self.myTypeHandler = typeHandler
        self.mySubTypeHandler = subTypeHandler
        
        
        typeButton = setupButton(text: self.typeInit)
        typeButton.addTarget(self, action: #selector(typeSelected), for: .touchUpInside)
       
        
        subTypeButton = setupButton(text: self.subTypeInit)
        subTypeButton.addTarget(self, action: #selector(subTypeSelected), for: .touchUpInside)
        
        
        let stackView = setupStackView(input: [typeButton,subTypeButton])
        self.mystackView = stackView
        self.addSubview(mystackView)
        
        NSLayoutConstraint.activate([
            mystackView.topAnchor.constraint(equalTo: self.topAnchor),
            mystackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            mystackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            mystackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

   
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func typeSelected(_ sender: UIButton) {
        self.myTypeHandler!(sender)
    }
    
    @objc func subTypeSelected(_ sender: UIButton) {
        self.mySubTypeHandler!(sender)
    }
    
   
}

 
