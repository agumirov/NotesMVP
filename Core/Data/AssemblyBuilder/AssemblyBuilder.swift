//
//  AssemblyBuilder.swift
//  TestTask
//
//  Created by G G on 28.12.2022.
//

import Foundation
import UIKit


protocol AssemblyBuilderProtocol {
    func buildMainModule(router: RouterProtocol) -> MainScreenViewController
    func buildDetailsModule(router: RouterProtocol, noteIndex: Int?) -> DetailsScreenViewController
}

class AssemblyBuilder: AssemblyBuilderProtocol {
    
    func buildMainModule(router: RouterProtocol) -> MainScreenViewController {
        let view        = MainScreenViewController()
        let notesService: NotesServiceProtocol = try! DIContainer.standart.resolve()
        let presenter   = MainScreenPresenter(view: view, router: router, notesService: notesService)
        view.presenter  = presenter
        return view
    }
    
    func buildDetailsModule(router: RouterProtocol, noteIndex: Int?) -> DetailsScreenViewController {
        let notesService: NotesServiceProtocol = try! DIContainer.standart.resolve()
        let styleKeyboardService: StyleKeyboardService = try! DIContainer.standart.resolve()
        
        let view        = DetailsScreenViewController()
        let presenter   = DetailsScreenPresenter(view: view,
                                           router: router,
                                           notesService: notesService)
        
        presenter.notesService = notesService
        styleKeyboardService.view = view
        view.styleKeyboardService = styleKeyboardService
        view.noteIndex = noteIndex
        view.presenter  = presenter
        return view
    }
}
