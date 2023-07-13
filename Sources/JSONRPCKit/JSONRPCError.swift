//
//  JSONRPCError.swift
//  JSONRPCKit
//
//  Created by Shinichiro Oba on 2015/11/09.
//  Copyright © 2015年 Shinichiro Oba. All rights reserved.
//

import Foundation

//public enum JSONRPCError: Error {
//    case responseError(code: Int, message: String, data: Any?)
//    case responseNotFound(requestId: Id?, object: Any)
//    case resultObjectParseError(Error)
//    case sessionExpired
//    case unsupportedVersion(String?)
//    case unexpectedTypeObject(Any)
//    case missingBothResultAndError(Any)
//    case nonArrayResponse(Any)
//
//    public init(errorObject: Any) {
//        enum ParseError: Error {
//            case nonDictionaryObject(object: Any)
//            case missingKey(key: String, errorObject: Any)
//            case sessionExpired(errorObject: Any)
//        }
//
//        var tempError: JSONRPCError? = nil
//
//        do {
//            if let dictionary = errorObject as? [String: Any] {
//                guard let code = dictionary["code"] as? Int else {
//                    throw ParseError.missingKey(key: "code", errorObject: errorObject)
//                }
//
//                guard let message = dictionary["message"] as? String else {
//                    throw ParseError.missingKey(key: "message", errorObject: errorObject)
//                }
//
//                if code == 100 && message == "Odoo Session Expired" {
//                    tempError = .sessionExpired
//                    throw ParseError.sessionExpired(errorObject: message)
//                } else {
//                    tempError = .responseError(code: code, message: message, data: dictionary["data"])
//                }
//            } else if let error = errorObject as? JSONRPCKit.JSONRPCError,
//                      case .responseError(let code, let message, _) = error,
//                      code == 100 && message == "Odoo Session Expired" {
//                tempError = .sessionExpired
//                throw ParseError.sessionExpired(errorObject: error)
//            } else {
//                print("Unhandled error object: \(errorObject)")  // Add debug print here
//                throw ParseError.nonDictionaryObject(object: errorObject)
//            }
//        } catch let error as ParseError {
//            switch error {
//            case .nonDictionaryObject(let _):
//                break
//            case .missingKey(_, _):
//                break
//            case .sessionExpired(let _):
//                // Обрабатывайте ошибку сессии здесь
//                tempError = .sessionExpired
//            }
//        } catch {
//            tempError = .unsupportedVersion("Unknown error")
//        }
//
//        self = tempError ?? .unsupportedVersion("Unknown error")
//    }
//}

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

    // init?(response: [String: Any]) {
    //     guard let code = response["code"] as? Int, let message = response["message"] as? String else {
    //         return nil
    //     }
    //     if code == 100 && message == "Odoo Session Expired" {
    //         self = .sessionExpired
    //     } else {
    //         let data = response["data"]
    //         self = .responseError(code: code, message: message, data: data)
    //     }
    // }

    init?(response: [String: Any]) {
    if let errorObject = response["error"] as? [String: Any],
       let code = errorObject["code"] as? Int,
       let message = errorObject["message"] as? String {
        if code == 100 && message == "Odoo Session Expired" {
            self = .sessionExpired
        } else {
            let data = errorObject["data"]
            self = .responseError(code: code, message: message, data: data)
        }
    } else {
        return nil
    }
}
}

public class JSONRPCResponseSerializer {
    public func serializeResponse(_ response: [String: Any]) -> Result<Any, JSONRPCError> {
        if let error = JSONRPCError(response: response) {
            return .failure(error)
        }
        // Parse and return the result object here, you may need to customize this based on your response structure
        guard let result = response["result"] else {
            return .failure(.missingBothResultAndError(response))
        }
        return .success(result)
    }
}
