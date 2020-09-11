 //
//  AllenRequestCenter.swift
//  SonicCoolBomb
//
//  Created by ko on 2020/7/29.
//  Copyright © 2020 SM. All rights reserved.
//

import UIKit
import Alamofire

public class AllenRequestCenter: NSObject {
    
    static let sharedInstance = AllenRequestCenter()
    
    
    var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
    
    func apiErrorResut(response: AFDataResponse<Any>, failure failureCallbac:@escaping (AFError, _ code: Int, _ desc: String) -> ()) {
        
        switch response.result {
            
        case .failure(let error):
            
            
            let statusCode = response.response?.statusCode
            var description = ""
            switch error {
            case .invalidURL(let url):
                description = "Invalid URL: \(url) - \(error.localizedDescription)"
            case .parameterEncodingFailed(let reason):
                description = "Parameter encoding failed: \(error.localizedDescription)" + "Failure Reason: \(reason)"
            case .multipartEncodingFailed(let reason):
                description = "Multipart encoding failed: \(error.localizedDescription)" + "Failure Reason: \(reason)"
                
            case .responseValidationFailed(let reason):
                description  = "Response validation failed: \(error.localizedDescription)" + "Failure Reason: \(reason)"
                
                switch reason {
                case .dataFileNil, .dataFileReadFailed:
                    description = "Downloaded file could not be read"
                case .missingContentType(let acceptableContentTypes):
                    description = "Content Type Missing: \(acceptableContentTypes)"
                case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                    description = "Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)"
                    
                case .unacceptableStatusCode(let code):
                    description = "Response status code was unacceptable: \(code)"
                case .customValidationFailed(error: _):
                    description = "CustomValidationFailed"
                @unknown default:
                    print("unknown default")
                }
            case .createUploadableFailed(error: let error):
                description = "UploadableFailed: \(error.localizedDescription)"
            case .createURLRequestFailed(error: let error):
                description = "URLRequestFailed: \(error.localizedDescription)"
            case .downloadedFileMoveFailed(error: let error, source: _, destination: _):
                description = "URLRequestFailed: \(error.localizedDescription)"
            case .explicitlyCancelled:
                description = "explicitlyCancelled"
            case .parameterEncoderFailed(reason: let reason):
                description = "URLRequestFailed: \(reason)"
            case .requestAdaptationFailed(error: let error):
                description = "requestAdaptationFailed: \(error.localizedDescription)"
            case .requestRetryFailed(retryError: let retryError, originalError: _):
                description = "RetryFailed: \(retryError.localizedDescription)"
            case .responseSerializationFailed(reason: let reason):
                description = "SerializationFailed: \(reason)"
            case .serverTrustEvaluationFailed(reason: let reason):
                description = "TrustEvaluationFailed: \(reason)"
            case .sessionDeinitialized:
                description = "sessionDeinitialized"
            case .sessionInvalidated(error: let error):
                description = "sessionInvalidated: \(error!.localizedDescription)"
            case .sessionTaskFailed(error: let error):
                description = "sessionTaskFailed: \(error.localizedDescription)"
            case .urlRequestValidationFailed(reason: let reason):
                description = "urlRequestValidationFailed: \(reason)"
            @unknown default:
                description = "unknown default"
            }
            if let code = statusCode  {
                failureCallbac(error, code, description)
                print("ok") }
            else {  failureCallbac(error, 500, description) }
           
            
        case .success(_):
            print("")
        }
    }
    
    
    func getWithUrl(url urlString:String,
                    success successCallback: @escaping (Dictionary<String,Any>, _ code: Int) -> (),
                    failure failureCallbac:@escaping (AFError, _ code: Int, _ desc: String) -> ()) {
        
        if self.isConnectedToInternet {
            print("Yes! internet is available.")
            
        }
        else {
            failureCallbac(AFError.invalidURL(url: ""), 503, "No! internet is not available.")
            
            return
        }
        
        let urlStr = urlString
        let headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        
        AF.request(urlStr, headers: headers)
            .validate(statusCode: 200..<511)
            .responseJSON { (response) in
                switch response.result {
                    
                    
                case .success(let json):
                    let statusCode = response.response?.statusCode
                    successCallback(json as! Dictionary<String,Any>, statusCode!)
                    
                case .failure( _):
                    
                    self.apiErrorResut(response: response, failure: failureCallbac)
                    
                     
                    
                }
        }
        
    }
    
    
    
}





