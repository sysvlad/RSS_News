//
//  NetworkService.swift
//  NewsTestApp
//
//  Created by Vlad Sys on 9.12.24.
//

import Foundation
import UIKit

protocol NetworkServiceProtocol {
    func getResponse(url: String) async throws -> [RSSItem]
}

class NetworkService: NetworkServiceProtocol {
    
    init() {}

    func getResponse(url: String) async throws -> [RSSItem] {
        let url = URL(string: url)

        let (data, _) = try await URLSession.shared.data(from: url!)
        let delegate = RSSXMLParserDelegate()
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        let result: [RSSItem] = parser.parse() ? delegate.rssItems : []
        
        return result
    }
}
