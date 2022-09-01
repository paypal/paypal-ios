//
//  LinkResponse.swift
//  Demo
//
//  Created by Jose Noriega on 31/08/2022.
//

import UIKit

struct LinkResponse: Codable {

    let href: String?
    let rel: String?
    let method: String?
    let encType: String?
}
