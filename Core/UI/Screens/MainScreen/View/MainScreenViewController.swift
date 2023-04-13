//
//  MainModule.swift
//  TestTask
//
//  Created by G G on 28.12.2022.
//

import Foundation
import UIKit
import SnapKit

extension MainScreenViewController {
    func success(screenshots: [UIImage]) {
        self.screenshots = screenshots
        self.mainCollectionView.reloadData()
    }
    
    func failure() {
        print("Error")
    }
}

class MainScreenViewController: UIViewController, MainScreenProtocol {
    //MARK: Properties
    var presenter:  MainScreenPresenterProtocol!
    private var cellWidth   = 0
    private var screenshots    = [UIImage]()
    
    var mainCollectionView: UICollectionView = {
        let layout                 = UICollectionViewFlowLayout()
        let collection             = UICollectionView(frame: .zero,
                                                      collectionViewLayout: layout)
        collection.backgroundColor = UIColor.clear
        collection.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.cellId)
        return collection
    }()
    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        viewConfig()
        mainCollectionSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewDidLoad()
        mainCollectionView.reloadData()
    }
    
    private func viewConfig() {
        view.backgroundColor = UIColor.systemBackground
        cellWidth = Int(view.frame.size.width * 0.45)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self, action: #selector(addNewNote))
    }
    
    @objc func addNewNote() {
        presenter.createNewNote()
    }
}


extension MainScreenViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func mainCollectionSetup() {
        mainCollectionView.delegate                       = self
        mainCollectionView.dataSource                     = self
        mainCollectionView.showsVerticalScrollIndicator   = false
        mainCollectionView.showsHorizontalScrollIndicator = false
        mainCollectionView.contentInset                   = UIEdgeInsets(top: 10, left: 10,
                                                                         bottom: 0, right: 10)
        
        view.addSubview(mainCollectionView)
        mainCollectionView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        screenshots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.cellId, for: indexPath) as? CollectionViewCell
        else { return UICollectionViewCell() }
        cell.notePreview.image = screenshots[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.editNote(noteIndex: indexPath.row)
    }
}
