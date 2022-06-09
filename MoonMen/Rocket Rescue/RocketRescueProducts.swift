//
//  RocketRescueProducts.swift
//  Rocket Rescue
//
//  Created by Christopher Bunn on 25/3/19.
//  Copyright © 2019 Christopher Bunn. All rights reserved.
//

import Foundation

public struct RocketRescueProducts
{
    public static let addFree = "com.bigtoelabs.RocketRescue.AddFree"
    private static let productIdentifiers: Set<ProductIdentifier> = [RocketRescueProducts.addFree]
    public static let store = IAPHelper(productIds: RocketRescueProducts.productIdentifiers)
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String?
{
    return productIdentifier.components(separatedBy: ".").last
}
