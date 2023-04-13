//
//  MainPresenter.swift
//  TestTask
//
//  Created by G G on 28.12.2022.
//

import Foundation
import UIKit

protocol MainScreenProtocol: AnyObject {
    func success(screenshots: [UIImage])
    func failure()
}

protocol MainScreenPresenterProtocol {
    func viewDidLoad()
    func createNewNote()
    func editNote(noteIndex: Int)
}

class MainScreenPresenter: MainScreenPresenterProtocol {
    weak var view: MainScreenProtocol?
    weak var notesService: NotesServiceProtocol?
    var router: RouterProtocol?
    
    required init(view: any MainScreenProtocol,
                  router: RouterProtocol,
                  notesService: NotesServiceProtocol) {
        self.view   = view
        self.router = router
        self.notesService = notesService
    }
    
    func viewDidLoad() {
        var screenshots = [UIImage]()
        notesService?.getAllNotes(completion: { data in
            guard let image = UIImage(data: data) else { return }
            screenshots.append(image)
        })
        view?.success(screenshots: screenshots)
    }
    
    func createNewNote() {
        router?.noteDetailsRoute(noteIndex: nil)
    }
    
    func editNote(noteIndex: Int) {
        router?.noteDetailsRoute(noteIndex: noteIndex)
    }
}
