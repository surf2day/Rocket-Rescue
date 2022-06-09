//
//  IAPHelper.swift
//  Rocket Rescue
//
//  Created by Christopher Bunn on 25/3/19.
//  Copyright © 2019 Christopher Bunn. All rights reserved.
//

import StoreKit

public typealias ProductIdentifier = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void

extension Notification.Name
{
    static let IAPHelperPurchaseNotification = Notification.Name("IAPHelperPurchaseNotification")
    static let IAPHelperFailedPurchaseNotification = Notification.Name("IAPHelperFailedPurchaseNotification")
}

open class IAPHelper: NSObject
{
    private let productIdentifiers: Set<ProductIdentifier>
    private var purchasedProductIdentifiers: Set<ProductIdentifier> = []
    private var productsRequest:SKProductsRequest?
    private var productsRequestCompletionHandler:ProductsRequestCompletionHandler?
    
    public init(productIds: Set<ProductIdentifier>)
    {
        productIdentifiers = productIds
        for productIdentifier in productIds
        {
            let purchased = UserDefaults.standard.bool(forKey: productIdentifier)
            if purchased
            {
                purchasedProductIdentifiers.insert(productIdentifier)
            }
        }
        super.init()
        SKPaymentQueue.default().add(self)  // add transaction observer
    }
}

 // MARK: StoreKit delegate handlers

extension IAPHelper: SKProductsRequestDelegate
{
    public func requestProducts(_ completionHandler: @escaping ProductsRequestCompletionHandler)
    {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
    }
    
    public func buyProduct(_ product: SKProduct)
    {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    public func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool
    {
        return purchasedProductIdentifiers.contains(productIdentifier)
    }
    
    public class func canMakePayments() -> Bool
    {
        return SKPaymentQueue.canMakePayments()
    }
    
    public func restorePurchase()
    {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse)
    {
        let products = response.products
        productsRequestCompletionHandler?(true, products)
        clearRequestAndHandler()
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error)
    {
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }
    
    private func clearRequestAndHandler()
    {
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
}

extension IAPHelper: SKPaymentTransactionObserver
{
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])
    {
        for transaction in transactions
        {
            switch (transaction.transactionState)
            {
            case .purchased:
                complete(transaction: transaction)
            case .failed:
                fail(transaction: transaction)
            case .restored:
                restore(transaction: transaction)
            case .deferred:
                break
            case .purchasing:
                break
            }
        }
    }
    
    private func complete(transaction: SKPaymentTransaction)
    {
        delieverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func fail(transaction: SKPaymentTransaction)
    {
        let errorMsg = transaction.error! as NSError
        print("failed transaction: Error: \(errorMsg.localizedDescription)")
        if errorMsg.domain == SKErrorDomain
        {
            switch (errorMsg.code)
            {
            case SKError.unknown.rawValue:
                break;
            case SKError.paymentCancelled.rawValue:
                NotificationCenter.default.post(name: .IAPHelperFailedPurchaseNotification, object: transaction.payment.productIdentifier)
            case SKError.paymentInvalid.rawValue:
                NotificationCenter.default.post(name: .IAPHelperFailedPurchaseNotification, object: transaction.payment.productIdentifier)
            case SKError.paymentNotAllowed.rawValue:
                NotificationCenter.default.post(name: .IAPHelperFailedPurchaseNotification, object: transaction.payment.productIdentifier)
            case SKError.clientInvalid.rawValue:
                NotificationCenter.default.post(name: .IAPHelperFailedPurchaseNotification, object: transaction.payment.productIdentifier)
            default:
                break;
            }
        }
            
        if let txnError = transaction.error as NSError?, let localDescription = transaction.error?.localizedDescription, txnError.code != SKError.paymentCancelled.rawValue
        {
            print("failed transaction: Error: \(localDescription)")
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restore(transaction: SKPaymentTransaction)
    {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        delieverPurchaseNotificationFor(identifier: productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func delieverPurchaseNotificationFor(identifier: String?)
    {
        guard let identifier = identifier else { return }
        purchasedProductIdentifiers.insert(identifier)
        UserDefaults.standard.set(true, forKey: identifier)
        NotificationCenter.default.post(name: .IAPHelperPurchaseNotification, object: identifier)
    }
}
