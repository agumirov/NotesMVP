//
//  DetailsPresenter.swift
//  TestTask
//
//  Created by G G on 28.12.2022.
//

import Foundation


//MARK: Protocol

protocol DetailsScreenPresenterProtocol {
    
    func viewDidLoad(noteIndex: Int?)
    func saveNote(attributedString: NSAttributedString,
                  screenshot: Data,
                  noteIndex: Int?)
    func deleteNote(noteIndex: Int)
}

class DetailsScreenPresenter: DetailsScreenPresenterProtocol {
    //MARK: Properites
    
    weak var notesService: NotesServiceProtocol?
    weak var view: DetailsScreenProtocol?
    var router: RouterProtocol?
    
    init(view: DetailsScreenProtocol,
         router: RouterProtocol,
         notesService: NotesServiceProtocol) {
        self.view       = view
        self.router     = router
        self.notesService = notesService
    }
    
    //MARK: Methods
    
    func viewDidLoad(noteIndex: Int?) {
        noteIndex == nil ? view?.success(attString: NSAttributedString()) :
        notesService?.getNoteByIndex(noteIndex: noteIndex!, completion: { [weak self] note in
            self?.view?.success(attString: note)
        })
    }
        
    func saveNote(attributedString: NSAttributedString, screenshot: Data, noteIndex: Int?) {
        notesService?.saveNote(attributedString: attributedString, screenshot: screenshot, noteIndex: noteIndex)
        router?.goBack()
    }
    
    func deleteNote(noteIndex: Int) {
        notesService?.deleteNote(noteIndex: noteIndex)
        router?.goBack()
    }
}
