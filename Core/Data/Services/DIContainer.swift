//
//  DIContainer.swift
//  TestNotes
//
//  Created by G G on 08.03.2023.
//

import Foundation

class DIContainer {
    
    enum ContainterErrors: Error {
        case valueNotRegistered
    }
    
    static var standart = DIContainer()
    private var dependencies = [String:Weak]()
    
    public func register<Service>(_ dependency: Service) {
        registerDependency(dependency)
    }
    
    public func resolve<Service>() throws -> Service {
        try resolveDependency()
    }
    
    private func registerDependency<Service>(_ dependency: Service) {
        let key = "\(type(of: Service.self))"
        let weak = Weak(weakValue: dependency as AnyObject)
        dependencies[key] = weak
    }
    
    private func resolveDependency<Service>() throws -> Service {
        let key = "\(type(of: Service.self))"
        let weak = dependencies[key]
        
        if weak != nil {
            return weak?.weakValue as! Service
        } else {
            return ContainterErrors.valueNotRegistered as! Service
        }
    }
}


class Weak {
    
    weak var weakValue: AnyObject?
    
    init(weakValue: AnyObject) {
        self.weakValue = weakValue
    }
}

