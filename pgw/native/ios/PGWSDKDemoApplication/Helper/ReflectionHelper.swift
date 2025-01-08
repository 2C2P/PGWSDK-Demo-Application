//
//  ReflectionHelper.swift
//  PGWSDKDemoApplication
//
//  Created by DavidBilly on 1/6/25.
//


import Foundation

enum ReflectionError: LocalizedError {
    
    case classNotFound(className: String)
    case methodNotFound(methodName: String)
    case methodInvocationFailed
    
    var errorDescription: String? {
        switch self {
        case .classNotFound(let className):
            return "Class not found: \(className)"
        case .methodNotFound(let methodName):
            return "Method not found: \(methodName)"
        case .methodInvocationFailed:
            return "Failed to invoke method"
        }
    }
}

class ReflectionHelper {
    
    static func callStaticMethod(className: String, methodName: String, parameters: [Any]? = nil) throws -> Any? {
        
        let bundleName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
        let fullClassName = bundleName + "." + className
        
        guard let classType = NSClassFromString(fullClassName) as? NSObject.Type else {
            
            throw ReflectionError.classNotFound(className: fullClassName)
        }
        
        var selectorName = methodName
        if let params = parameters, !params.isEmpty {
            
            selectorName += ":"
            for _ in 1..<params.count {
                
                selectorName += ":"
            }
        }
        
        let selector = NSSelectorFromString(selectorName)
        
        guard classType.responds(to: selector) else {
            
            throw ReflectionError.methodNotFound(methodName: selectorName)
        }
        
        if let params = parameters, !params.isEmpty {
            
            return classType.perform(selector, with: params[0])
        }
        
        return classType.perform(selector)
    }
}
