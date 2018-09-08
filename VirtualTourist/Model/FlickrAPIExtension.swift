//
//  FlickrAPIExtension.swift
//  VirtualTourist
//
//  Created by akhil mantha on 08/09/18.
//  Copyright © 2018 akhil mantha. All rights reserved.
//

import Foundation


extension FlickrApi {
    
    
    // MARK: Flickr
    struct UrlConstants {
        static let ApiScheme = "https"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest"
        
    }
    
    // MARK: Flickr Parameter Keys
    struct UrlParameterKeys {
        static let Method = "method"
        static let ApiKey = "api_key"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Text = "text"
        static let BoundingBox = "bbox"
        static let Page = "page"
        static let PerPage = "per_page"
    }
    
    // MARK: Flickr Parameter Values
    struct UrlParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let ApiKey = "8f8e21024a3687814aa3072fe5b9e5fd"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
        static let MediumURL = "url_m"
        static let ThumbnailURL = "url_t"
        static let UseSafeSearch = "1"
        static let PerPage = "21"
    }
    
    // MARK: Flickr Response Keys
    struct ResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let ThumbailURL = "url_t"
        static let Pages = "pages"
        static let Total = "total"
    }
    
    // MARK: Flickr Response Values
    struct ResponseValues {
        static let OKStatus = "ok"
    }
    
    // MARK: BBox
    struct BBox {
        static let SearchBBoxHalfWidth = 1.0
        static let SearchBBoxHalfHeight = 1.0
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
    }
    
    struct ErrorStrings {
        static let NoConnectionError = "Could not connect to service. Please check your network connection and try again."
        static let ServerResponseError = "Error status code received from server."
        static let InvalidDataError = "Invalid data received"
        static let NoResultsError = "No results"
    }
    
}

