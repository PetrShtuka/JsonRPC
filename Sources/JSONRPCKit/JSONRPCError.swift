//
//  JSONRPCError.swift
//  JSONRPCKit
//
//  Created by Petr Shtuka 05/10/2023.
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
    case connectionError(String)
	case networkConnectionLost

    public var description: String {
        switch self {
        case .responseError(let code, let message, _):
            return "Response error (\(code)): \(message)"
        case .responseNotFound(let requestId, _):
            return "Response not found for request ID: \(String(describing: requestId))"
        case .resultObjectParseError:
            return "Failed to parse result object."
        case .errorObjectParseError:
            return "Failed to parse error object."
        case .sessionExpired:
            return "Session has expired."
        case .unsupportedVersion(let version):
            if let ver = version {
                return "Unsupported version: \(ver)"
            }
            return "Unsupported version."
        case .unexpectedTypeObject:
            return "Unexpected type for object."
        case .missingBothResultAndError:
            return "Both result and error are missing in the response."
        case .nonArrayResponse:
            return "Expected an array in the response."
        case .connectionError(let message):
            return message
 	case .networkConnectionLost:
        return "The network connection was lost."
        }
    }

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
            if let requestId = response["id"] as? Id? {
                self = .responseNotFound(requestId: requestId, object: response)
            } else {
                return nil
            }
        }
    }
}

public class JSONRPCResponseSerializer {
    public func serializeResponse(_ response: [String: Any]) -> Result<Any, JSONRPCError> {
        if let error = JSONRPCError(response: response) {
            return .failure(error)
        }
        guard let result = response["result"] else {
            return .failure(.missingBothResultAndError(response))
        }
        return .success(result)
    }
}

extension JSONRPCError: Equatable {
    public static func == (lhs: JSONRPCError, rhs: JSONRPCError) -> Bool {
        switch (lhs, rhs) {
        case (.sessionExpired, .sessionExpired):
            return true
        default:
            return false
        }
    }
}


