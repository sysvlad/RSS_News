//
//  RSSXMLParserDelegate.swift
//  NewsTestApp
//
//  Created by Vlad Sys on 13.12.24.
//

import Foundation

class RSSXMLParserDelegate: NSObject, XMLParserDelegate {
    
    var rssItems: [RSSItem] = []
    private var currentElement = ""
    private var isHeader = true
    
    private var currentTitle = "" {
        didSet {
            currentTitle = currentTitle.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentDescription = "" {
        didSet {
            currentDescription = currentDescription.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentPubDate = "" {
        didSet {
            currentPubDate = currentPubDate.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentEnclosure = "" {
        didSet {
            currentEnclosure = currentEnclosure.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    private var currentNewsResource = "" {
        didSet {
            currentNewsResource = currentNewsResource.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentElement = elementName
        if currentElement == "channel" && isHeader {
            currentNewsResource = ""
        }
        if currentElement == "item" {
            currentTitle = ""
            currentDescription = ""
            currentPubDate = ""
            currentEnclosure = ""
        }
        
        if currentElement == "enclosure" {
            let attrsUrl = attributeDict as [String: String]
            let urlPic = attrsUrl["url"]
            currentEnclosure = urlPic ?? ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
        case "title":
            currentTitle += string

            
        case "description":
            currentDescription += string
            
        case "pubDate":
            currentPubDate += string
            
        case "link":
            if isHeader && !string.isEmpty {
                currentNewsResource += string
                isHeader = false
            }
            
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let rssItem = RSSItem(
                title: currentTitle,
                description: currentDescription,
                pubDate: currentPubDate,
                enclosure: currentEnclosure,
                resource: currentNewsResource
            )
            rssItems.append(rssItem)
        }
    }
}
