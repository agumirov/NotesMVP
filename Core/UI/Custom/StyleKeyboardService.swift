//
//  KeyboardService.swift
//  TestNotes
//
//  Created by G G on 23.03.2023.
//

import Foundation
import UIKit

protocol ViewControllerProtocol: AnyObject {
    func changeFont(attribute: Int)
    func changeSize(action: Int)
}

class StyleKeyboardService: UIView{
    weak var view: ViewControllerProtocol?
    
    let styleKeyboardView: UIView = {
        let keyboard = UIView()
        keyboard.backgroundColor = .systemGray4
        return keyboard
    }()
    
    let buttonColumn: UIStackView = {
        let column = UIStackView()
        column.axis = .vertical
        column.spacing = 5
        column.alignment = .fill
        column.backgroundColor = .clear
        column.distribution = .fillEqually
        return column
    }()
    
    let sizeButtonsRow: UIStackView = {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 5
        row.backgroundColor = .clear
        row.layer.cornerRadius = CGFloat(Constants.buttonCornerRadius)
        row.alignment = .fill
        row.distribution = .fillEqually
        return row
    }()
    
    let increaseSizeButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "plus", withConfiguration: Constants.imageConfig)
        button.setImage(image, for: .normal)
        button.backgroundColor = .systemGray5
        button.layer.cornerRadius = CGFloat(Constants.buttonCornerRadius)
        button.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        button.addTarget(nil, action: #selector(changeSize), for: .touchUpInside)
        button.tag = FontSize.increase.rawValue
        return button
    }()
    
    let decreaseSizeButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "minus", withConfiguration: Constants.imageConfig)
        button.setImage(image, for: .normal)
        button.backgroundColor = .systemGray5
        button.layer.cornerRadius = CGFloat(Constants.buttonCornerRadius)
        button.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                button.addTarget(nil, action: #selector(changeSize), for: .touchUpInside)
        button.tag = FontSize.decrease.rawValue
        return button
    }()
    
    let fontButtonsRow: UIStackView = {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 5
        row.backgroundColor = .clear
        row.layer.cornerRadius = CGFloat(Constants.buttonCornerRadius)
        row.alignment = .fill
        row.distribution = .fillEqually
        return row
    }()
    
    let boldButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "bold", withConfiguration: Constants.imageConfig)
        button.setImage(image, for: .normal)
        button.backgroundColor = .systemGray5
        button.layer.cornerRadius = CGFloat(Constants.buttonCornerRadius)
        button.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
                button.addTarget(nil, action: #selector(changeFont), for: .touchUpInside)
        button.tag = Fonts.bold.rawValue
        return button
    }()
    
    
    let italicButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "italic", withConfiguration: Constants.imageConfig)
        button.setImage(image, for: .normal)
        button.backgroundColor = .systemGray5
        button.target(forAction: #selector(changeFont),
                      withSender: DetailsScreenViewController.self)
                button.addTarget(nil, action: #selector(changeFont), for: .touchUpInside)
        button.tag = Fonts.italic.rawValue
        return button
    }()
    
    let underlinedButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "underline", withConfiguration: Constants.imageConfig)
        button.setImage(image, for: .normal)
        button.backgroundColor = .systemGray5
        button.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                button.addTarget(nil, action: #selector(changeFont), for: .touchUpInside)
        button.tag = Fonts.underlined.rawValue
        return button
    }()
    
    let strikethroughButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "strikethrough", withConfiguration: Constants.imageConfig)
        button.setImage(image, for: .normal)
        button.backgroundColor = .systemGray5
        button.layer.cornerRadius = CGFloat(Constants.buttonCornerRadius)
        button.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        button.addTarget(nil, action: #selector(changeFont), for: .touchUpInside)
        button.tag = Fonts.strikethrough.rawValue
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addFontButtonsToRow()
        addSizeButtonsToRow()
        addRowsToColumn()
        addColumnToKeyboard()
        
        backgroundColor = .systemGray4
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addRowsToColumn() {
        buttonColumn.addArrangedSubviews(views: [
            fontButtonsRow,
            sizeButtonsRow,
        ])
    }
    
    func addColumnToKeyboard() {
        addSubview(buttonColumn)
        
        buttonColumn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(Constants.columnHeigh)
            make.top.equalToSuperview().inset(40)
        }
    }
    
    func addFontButtonsToRow() {
        fontButtonsRow.addArrangedSubviews(views: [
            boldButton,
            italicButton,
            underlinedButton,
            strikethroughButton
        ])
    }
    
    
    func addSizeButtonsToRow() {
        sizeButtonsRow.addArrangedSubviews(views: [
            increaseSizeButton,
            decreaseSizeButton,
        ])
    }
    
    @objc public func changeFont(sender: UIBarButtonItem) {
        view?.changeFont(attribute: sender.tag)
    }
    
    @objc public func changeSize(sender: UIBarButtonItem) {
        view?.changeSize(action: sender.tag)
    }
}
