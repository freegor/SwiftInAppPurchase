//
//  SwiftInAppPurchase.swift
//  Pods
//
//  Created by Suraphan on 12/13/2558 BE.
//  Repaired by freegor 08/16/3506
//
//

import Foundation
import StoreKit

open class SwiftInAppPurchase: NSObject {
    
    open static let sharedInstance = SwiftInAppPurchase()
    
    open let productRequestHandler:ProductRequestHandler
    open let paymentRequestHandler:PaymentRequestHandler
    open let receiptRequestHandler:ReceiptRequestHandler
    
    override init() {
        self.productRequestHandler = ProductRequestHandler.init()
        self.paymentRequestHandler = PaymentRequestHandler.init()
        self.receiptRequestHandler = ReceiptRequestHandler.init()
        super.init()
    }
    
    deinit{
    }
    open func setProductionMode(_ isProduction:Bool){
        self.receiptRequestHandler.isProduction = isProduction
    }
    open func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    open func receiptURL() -> URL {
        return self.receiptRequestHandler.receiptURL() as URL
    }
    
    //  MARK: - Product
    open func productForIdentifier(_ productIdentifier:String) -> SKProduct{
        return self.productRequestHandler.products[productIdentifier]!
    }
    open func requestProducts(_ productIDS:Set<String>,completion:RequestProductCallback){
        self.productRequestHandler.requestProduc(productIDS, requestCallback: completion)
    }
    //  MARK: - Purchase
    open func addPayment(_ productIDS: String,userIdentifier:String?, addPaymentCallback: AddPaymentCallback){
        let product = self.productRequestHandler.products[productIDS]
        if product != nil {
            self.paymentRequestHandler.addPayment(product: product!, userIdentifier: userIdentifier, addPaymentCallback: addPaymentCallback)
        }else{
            addPaymentCallback(.failed(error: NSError.init(domain: "AddPayment Unknow Product identifier", code: 0, userInfo: nil)))
        }
    }
    //  MARK: - Restore
    open func restoreTransaction(_ userIdentifier:String?,addPaymentCallback: AddPaymentCallback){
        self.paymentRequestHandler.restoreTransaction(userIdentifier: userIdentifier, addPaymentCallback: addPaymentCallback)
    }
    open func checkIncompleteTransaction(_ addPaymentCallback: AddPaymentCallback){
        self.paymentRequestHandler.checkIncompleteTransaction(addPaymentCallback: addPaymentCallback)
    }
    //  MARK: - Receipt
    open func refreshReceipt(_ requestCallback: RequestReceiptCallback){
        self.receiptRequestHandler.refreshReceipt(requestCallback)
    }
    open func verifyReceipt(_ autoRenewableSubscriptionsPassword:String?,receiptVerifyCallback:ReceiptVerifyCallback){
        self.receiptRequestHandler.verifyReceipt(autoRenewableSubscriptionsPassword, receiptVerifyCallback: receiptVerifyCallback)
    }
}
