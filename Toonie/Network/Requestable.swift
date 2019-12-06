//
//  Requestable.swift
//  Toonie
//
//  Created by 양어진 on 30/03/2019.
//  Copyright © 2019 Yapp. All rights reserved.
//

import Alamofire

protocol Requestable {
    associatedtype NetworkData: Codable
    typealias NetworkSuccessResult = (resCode: Int, resResult: NetworkData)
    func get(_ URL: String,
             params: Parameters?,
             completion: @escaping (NetworkResult<NetworkSuccessResult>) -> Void)
    
    func post(_ URL: String,
              params: Parameters?,
              completion: @escaping (NetworkResult<NetworkSuccessResult>) -> Void) 
}

extension Requestable {
    
    func get(_ URL: String,
             params: Parameters? = nil,
             completion: @escaping (NetworkResult<NetworkSuccessResult>) -> Void) {
        guard let encodedUrl = URL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("networking - invalid url")
            return
        }
        
        Alamofire.request(encodedUrl,
                          method: .get,
                          parameters: nil).responseData { (res) in
                            switch res.result {
                            case .success:
                                if let value = res.result.value {
                                    let decoder = JSONDecoder()
                                    do {
                                        let resCode = res.response?.statusCode ?? 0
                                        let datas = try decoder.decode(NetworkData.self, from: value)
                                        let result: NetworkSuccessResult = (resCode, datas)
                                        completion(.networkSuccess(result))
                                    } catch {
                                        print("Decoding Err")
                                    }
                                }
                            case .failure(let err):
                                if let error = err as NSError?, error.code == -1009 {
                                    completion(.networkFail)
                                } else {
                                    let resCode = res.response?.statusCode ?? 0
                                    completion(.networkError((resCode, err.localizedDescription)))
                                }
                            }
        }
    }
    
    func unprocessedGet(_ URL: String,
                        params: Parameters? = nil,
                        completion: @escaping (NetworkResult<Data>) -> Void) {
        guard let encodedUrl = URL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("networking - invalid url")
            return
        }
        
        Alamofire.request(encodedUrl,
                          method: .get,
                          parameters: nil).responseData { (res) in
                            switch res.result {
                            case .success:
                                if let value = res.result.value { 
                                    completion(.networkSuccess(value))
                                }
                            case .failure(let err):
                                if let error = err as NSError?, error.code == -1009 {
                                    completion(.networkFail)
                                } else {
                                    let resCode = res.response?.statusCode ?? 0
                                    completion(.networkError((resCode, err.localizedDescription)))
                                }
                            }
        }
    }
    
    func post(_ URL: String,
              params: Parameters? = nil,
              completion: @escaping (NetworkResult<NetworkSuccessResult>) -> Void) {
        guard let encodedUrl = URL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("networking - invalid url")
            return
        } 
        
        Alamofire.request(encodedUrl,
                          method: .post,
                          parameters: params,
                          encoding: JSONEncoding.default).responseData { (res) in
                            switch res.result {
                            case .success:
                                if let value = res.result.value {
                                    let decoder = JSONDecoder()
                                    do {
                                        let resCode = res.response?.statusCode ?? 0
                                        let datas = try decoder.decode(NetworkData.self, from: value)
                                        let result: NetworkSuccessResult = (resCode, datas)
                                        completion(.networkSuccess(result))
                                    } catch {
                                        print("Decoding Err")
                                    }
                                }
                            case .failure(let err):
                                if let error = err as NSError?, error.code == -1009 {
                                    completion(.networkFail)
                                } else {
                                    let resCode = res.response?.statusCode ?? 0
                                    completion(.networkError((resCode, err.localizedDescription)))
                                }
                            }
        }
    }
    
    func unprocessedPost(_ URL: String,
                         params: Parameters? = nil,
                         completion: @escaping (NetworkResult<Data>) -> Void) {
        guard let encodedUrl = URL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("networking - invalid url")
            return
        }
        
        Alamofire.request(encodedUrl,
                          method: .post,
                          parameters: params,
                          encoding: JSONEncoding.default).responseData { (res) in
                            switch res.result {
                            case .success:
                                if let value = res.result.value {
                                    completion(.networkSuccess(value))
                                }
                            case .failure(let err):
                                if let error = err as NSError?, error.code == -1009 {
                                    completion(.networkFail)
                                } else {
                                    let resCode = res.response?.statusCode ?? 0
                                    completion(.networkError((resCode, err.localizedDescription)))
                                }
                            }
        }
    }
    
    func anyTypeParamsPost<T>(_ URL: String,
                              params: T,
                              completion: @escaping (NetworkResult<Data>) -> Void) {
        guard let encodedUrl = URL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("networking - invalid url")
            return
        }
        
        let headers: HTTPHeaders = [
            "Content-Type":"application/json",
        ]
        //리턴값이 읎음.. 걍 이것만 호출
        SessionManager
            .default
            .paramArrayRequest(encodedUrl,
                               method: .post,
                               parameters: params,
                               encoding: JSONEncoding.default,
                               headers: headers)?.responseData { (res) in
                                switch res.result {
                                case .success:
                                    if let value = res.result.value {
                                        completion(.networkSuccess(value))
                                    }
                                case .failure(let err):
                                    if let error = err as NSError?, error.code == -1009 {
                                        completion(.networkFail)
                                    } else {
                                        let resCode = res.response?.statusCode ?? 0
                                        completion(.networkError((resCode, err.localizedDescription)))
                                    }
                                }
        }
        
        
    }
    
    
    
}

extension SessionManager {
    func paramArrayRequest<T>(_ url: URLConvertible,
                              method: HTTPMethod = .post,
                              parameters: T, //제네릭타입, paramArrayRequest가 호출될때 타입이 결정된다.
                              encoding: ParameterEncoding = URLEncoding.default,
                              headers: HTTPHeaders? = nil) -> DataRequest? {
        do {
            var originalRequest = try URLRequest(url: url, method: method, headers: headers)
    
            let data = try JSONSerialization.data(withJSONObject: parameters, options: [])
            originalRequest.httpBody = data
     
            return request(originalRequest)
        } catch {
            return nil
        }
    }
}
