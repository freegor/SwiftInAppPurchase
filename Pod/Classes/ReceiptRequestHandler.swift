//
//  ReceiptRequestHandler.swift
//  IAPMaster
//
//  Created by Suraphan on 12/2/2558 BE.
//  Repaired by freegor 08/16/3506
//  Copyright © 2558 irawd. All rights reserved.
//
import StoreKit

public typealias RequestReceiptCallback = (error:NSError?) -> ()
public typealias ReceiptVerifyCallback = (receipt:NSDictionary?,error:NSError?) -> ()

let productionVerifyURL = "http://buy.itunes.apple.com/verifyReceipt"
let sandboxVerifyURL = "https://sandbox.itunes.apple.com/verifyReceipt"

public class ReceiptRequestHandler: NSObject ,SKRequestDelegate{

    private var requestCallback: RequestReceiptCallback?
    private var receiptVerifyCallback: ReceiptVerifyCallback?
    var isProduction:Bool
    
    override init() {
        isProduction = false
        super.init()
        
    }
    deinit {
        
    }
    func receiptURL() -> NSURL {
        return Bundle.main.appStoreReceiptURL!
    }
    
    func refreshReceipt(requestCallback: RequestReceiptCallback){
        self.requestCallback = requestCallback
        let receiptRequest = SKReceiptRefreshRequest.init(receiptProperties: nil)
        receiptRequest.delegate = self
        receiptRequest.start()
    }

    public func requestDidFinish(request: SKRequest) {
       requestCallback!(error: nil)
    }
    public func request(request: SKRequest, didFailWithError error: NSError) {
        requestCallback!(error: error)
    }

    func verifyReceipt(autoRenewableSubscriptionsPassword:String?,receiptVerifyCallback:ReceiptVerifyCallback){
        self.receiptVerifyCallback = receiptVerifyCallback
        
        let session = URLSession.shared
        let receipt = try? Data.init(contentsOf: self.receiptURL() as URL)

        let requestContents :NSMutableDictionary = [ "receipt-data" : (receipt?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)))!]
        
        if (autoRenewableSubscriptionsPassword != nil) {
            requestContents.setValue(autoRenewableSubscriptionsPassword, forKey: "password")
        }
        
        let storeURL = NSURL.init(string: isProduction ? productionVerifyURL:sandboxVerifyURL)
        
        let storeRequest = NSMutableURLRequest.init(url: storeURL! as URL)
        
        do {
            storeRequest.httpBody = try JSONSerialization.data(withJSONObject: requestContents, options: [])
        } catch {
            
            print(error)
            receiptVerifyCallback(receipt: nil, error: NSError.init(domain: "JsonError", code: 0, userInfo: nil))
            return
        }
        
        storeRequest.httpMethod = "POST"
        

        let task = session.dataTask(with: storeRequest as URLRequest, completionHandler: {data, response, error -> Void in
            
            guard error == nil else { return }
            let json: NSDictionary?
            do {
                json = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as? NSDictionary
            } catch let dataError {
                print(dataError)
                receiptVerifyCallback(receipt: nil, error: NSError.init(domain: "JsonError", code: 0, userInfo: nil))
                return
            }
            
            if let parseJSON = json {
                let success = parseJSON["success"] as? Int
                print("Succes: \(success)")
                receiptVerifyCallback(receipt: parseJSON, error: nil)
            
            }
            else {
                let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print("Error could not parse JSON: \(jsonStr)")
                
                receiptVerifyCallback(receipt: nil, error: error)
            }
            
        })
        
        task.resume()
    }
}
