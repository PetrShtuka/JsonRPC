//
//  JSONRPCError.swift
//  JSONRPCKit
//
//  Created by Shinichiro Oba on 2015/11/09.
//  Copyright © 2015年 Shinichiro Oba. All rights reserved.
//

import Foundation

public enum JSONRPCError: Error {
    case responseError(code: Int, message: String, data: Any?)
    case responseNotFound(requestId: Id?, object: Any)
    case resultObjectParseError(Error)
    case errorObjectParseError(Error)
    case sessionExpired
    case unsupportedVersion(String?)
    case unexpectedTypeObject(Any)
    case missingBothResultAndError(Any)
    case nonArrayResponse(Any)
    
    public init(errorObject: Any) {
        enum ParseError: Error {
            case nonDictionaryObject(object: Any)
            case missingKey(key: String, errorObject: Any)
        }

        var tempError: JSONRPCError? = nil

        do {
            guard let dictionary = errorObject as? [String: Any] else {
                throw ParseError.nonDictionaryObject(object: errorObject)
            }

            guard let code = dictionary["code"] as? Int else {
                throw ParseError.missingKey(key: "code", errorObject: errorObject)
            }

            guard let message = dictionary["message"] as? String else {
                throw ParseError.missingKey(key: "message", errorObject: errorObject)
            }

            if code == 100 && message == "Odoo Session Expired" {
                tempError = .sessionExpired
            } else {
                tempError = .responseError(code: code, message: message, data: dictionary["data"])
            }
        } catch let error as ParseError {
            switch error {
            case .nonDictionaryObject(let object):
                // Check if object contains session expired error information and set tempError accordingly
                if let errorInfo = object as? [String: Any],
                   let code = errorInfo["code"] as? Int,
                   let message = errorInfo["message"] as? String,
                   code == 100 && message == "Odoo Session Expired" {
                    tempError = .sessionExpired
                } else {
                    tempError = .errorObjectParseError(error)
                }
            case .missingKey(_, _):
                // Similar check here if necessary
                tempError = .errorObjectParseError(error)
            }
        } catch {
            tempError = .unsupportedVersion("Unknown error")
        }

        self = tempError ?? .sessionExpired
    }

}

