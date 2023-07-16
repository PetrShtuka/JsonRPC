//
//  JSONRPCError.swift
//  JSONRPCKit
//
//  Created by Shinichiro Oba on 2015/11/09.
//  Copyright © 2015年 Shinichiro Oba. All rights reserved.
//

// import Foundation

// public enum JSONRPCError: Error {
//     case responseError(code: Int, message: String, data: Any?)
//     case responseNotFound(requestId: Id?, object: Any)
//     case resultObjectParseError(Error)
//     case errorObjectParseError(Error)
//     case sessionExpired
//     case unsupportedVersion(String?)
//     case unexpectedTypeObject(Any)
//     case missingBothResultAndError(Any)
//     case nonArrayResponse(Any)

//     init?(response: [String: Any]) {
//     if let errorObject = response["error"] as? [String: Any],
//        let code = errorObject["code"] as? Int,
//        let message = errorObject["message"] as? String {
//         if code == 100 && message == "Odoo Session Expired" {
//             self = .sessionExpired
//         } else {
//             let data = errorObject["data"]
//             self = .responseError(code: code, message: message, data: data)
//         }
//     } else {
//         // Ensure "id" is of type Id or is null
//         if let requestId = response["id"] as? Id? {
//             self = .responseNotFound(requestId: requestId, object: response)
//         } else {
//             return nil
//         }
//     }
//     }
// }

// public class JSONRPCResponseSerializer {
//     public func serializeResponse(_ response: [String: Any]) -> Result<Any, JSONRPCError> {
//         if let error = JSONRPCError(response: response) {
//             return .failure(error)
//         }
//         // Parse and return the result object here, you may need to customize this based on your response structure
//         guard let result = response["result"] else {
//             return .failure(.missingBothResultAndError(response))
//         }
//         return .success(result)
//     }
// }

// extension JSONRPCError: Equatable {
//     static func == (lhs: JSONRPCError, rhs: JSONRPCError) -> Bool {
//         switch (lhs, rhs) {
//         case (.sessionExpired, .sessionExpired):
//             return true
//         default:
//             return false
//         }
//     }
// }

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

    init?(response: [String: Any]) {
        if let errorObject = response["error"] as? [String: Any],
           let code = errorObject["code"] as? Int,
           let message = errorObject["message"] as? String {
            if code == 100 && message == "Odoo Session Expired" {
                print("Session expired.")
                self = .sessionExpired
            } else {
                let data = errorObject["data"]
                print("Response error: \(code) - \(message)")
                self = .responseError(code: code, message: message, data: data)
            }
        } else {
            if let requestId = response["id"] as? Id? {
                print("Response not found for request ID: \(String(describing: requestId))")
                self = .responseNotFound(requestId: requestId, object: response)
            } else {
                print("Error: unexpected response format.")
                return nil
            }
        }
    }
}

public class JSONRPCResponseSerializer {
    public func serializeResponse(_ response: [String: Any]) -> Result<Any, JSONRPCError> {
        if let error = JSONRPCError(response: response) {
            print("Error occurred: \(error)")
            return .failure(error)
        }
        guard let result = response["result"] else {
            print("Error: result and error both missing from response.")
            return .failure(.missingBothResultAndError(response))
        }
        print("Successfully serialized the response.")
        return .success(result)
    }
}

extension JSONRPCError: Equatable {
    static func == (lhs: JSONRPCError, rhs: JSONRPCError) -> Bool {
        switch (lhs, rhs) {
        case (.sessionExpired, .sessionExpired):
            print("Both errors are session expired errors.")
            return true
        default:
            print("Errors are not equal.")
            return false
        }
    }
}

