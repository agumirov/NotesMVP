//
//  Router.swift
//  TestTask
//
//  Created by G G on 28.12.2022.
//

import Foundation
import UIKit
import SwiftUI

protocol RouterProtocol: AnyObject {
    func noteDetailsRoute(noteIndex: Int?)
    func mainModuleRoute()
    func goBack()
}

class Router: RouterProtocol {
    let assemblyBuilder:      AssemblyBuilderProtocol!
    let navigationController: UINavigationController!
    
    func mainModuleRoute() {
        let view = assemblyBuilder.buildMainModule(router: self)
        navigationController.viewControllers = [view]
    }
    
    func noteDetailsRoute(noteIndex: Int?) {
        let view = assemblyBuilder.buildDetailsModule(router: self, noteIndex: noteIndex)
        navigationController.pushViewController(view, animated: true)
    }
    
    required init(assemblyBuilder: AssemblyBuilderProtocol,
                  navigationController: UINavigationController) {
        self.assemblyBuilder        = assemblyBuilder
        self.navigationController   = navigationController
    }
    
    func goBack() {
        navigationController.popViewController(animated: true)
    }
}
