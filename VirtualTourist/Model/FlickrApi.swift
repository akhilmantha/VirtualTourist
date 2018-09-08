//
//  FlickrApi.swift
//  VirtualTourist
//
//  Created by akhil mantha on 08/09/18.
//  Copyright © 2018 akhil mantha. All rights reserved.
//

import Foundation
import UIKit

class FlickrApi {
    
    class func sharedInstance() -> FlickrApi {
        struct Singleton {
            static var sharedInstance = FlickrApi()
        }
        return Singleton.sharedInstance
    }
    
    func getImageUrlsForCoordinates(latitude:Double, longitude:Double,page:Int, completionHandlerforGetImageUlrsForCoordinates:@escaping ([URL]?, NSError?) -> Void) -> Void {
        let methodParameters = [
            FlickrApi.UrlParameterKeys.Method: FlickrApi.UrlParameterValues.SearchMethod,
            FlickrApi.UrlParameterKeys.ApiKey: FlickrApi.UrlParameterValues.ApiKey,
            FlickrApi.UrlParameterKeys.BoundingBox: boundingBoxFromCoordinates(latitude: latitude,longitude: longitude),
            FlickrApi.UrlParameterKeys.SafeSearch: FlickrApi.UrlParameterValues.UseSafeSearch,
            FlickrApi.UrlParameterKeys.Extras: FlickrApi.UrlParameterValues.MediumURL,
            FlickrApi.UrlParameterKeys.Format: FlickrApi.UrlParameterValues.ResponseFormat,
            FlickrApi.UrlParameterKeys.NoJSONCallback: FlickrApi.UrlParameterValues.DisableJSONCallback,
            FlickrApi.UrlParameterKeys.PerPage:FlickrApi.UrlParameterValues.PerPage,
            FlickrApi.UrlParameterKeys.Page:page
            ] as [String : Any]
        
        let request = URLRequest(url: flickrURLFromParameters(parameters:methodParameters as [String : AnyObject]?))
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            func sendError(error:String) {
                print(error)
                
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerforGetImageUlrsForCoordinates(nil,NSError(domain: "GetImageUrlsForCoordinates", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError(error: FlickrApi.ErrorStrings.NoConnectionError)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (statusCode >= 200 && statusCode <= 299) else {
                sendError(error: FlickrApi.ErrorStrings.ServerResponseError)
                return
            }
            
            guard let parsedResult = self.parseResponse(data: data!) else {
                sendError(error: FlickrApi.ErrorStrings.InvalidDataError)
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[FlickrApi.ResponseKeys.Status] as? String, stat == FlickrApi.ResponseValues.OKStatus else {
                sendError(error: "Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Is the "photos" key in our result? */
            guard let photosDictionary = parsedResult[FlickrApi.ResponseKeys.Photos] as? [String:AnyObject] else {
                sendError(error: "Cannot find key '\(FlickrApi.ResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            /* GUARD: Is the "photo" key in photosDictionary? */
            guard let photosArray = photosDictionary[FlickrApi.ResponseKeys.Photo] as? [[String: AnyObject]] else {
                sendError(error: "Cannot find key '\(FlickrApi.ResponseKeys.Photo)' in \(photosDictionary)")
                return
            }
            
            var photoUrls = [URL]()
            
            for photo in photosArray {
                if let urlString = photo[FlickrApi.ResponseKeys.MediumURL] as? String{
                    if let url = URL(string: urlString) {
                        photoUrls.append(url)
                    }
                }
            }
            
            completionHandlerforGetImageUlrsForCoordinates(photoUrls,nil)
            
        }
        
        task.resume()
    }
    
    func getPhotoForUrl(url:URL, completionHandlerForGetPhotoForURL:@escaping (Data?,NSError?) -> Void) -> Void{
        
        func sendError(error:String) {
            print(error)
            
            let userInfo = [NSLocalizedDescriptionKey : error]
            completionHandlerForGetPhotoForURL(nil,NSError(domain: "GetPhotoForUrl", code: 1, userInfo: userInfo))
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error == nil {
                
                completionHandlerForGetPhotoForURL(data,nil)
                
            } else {
                sendError(error: "No image to download for url: \(url.absoluteString)")
            }
        }
        
        // start network request
        task.resume()
        
        
    }
    
    private func parseResponse(data:Data) -> AnyObject? {
        
        let parsedResult: AnyObject!
        
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            
            return nil
        }
        
        return parsedResult
    }
    
    private func flickrURLFromParameters(parameters: [String:Any]?, withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = FlickrApi.UrlConstants.ApiScheme
        components.host = FlickrApi.UrlConstants.ApiHost
        components.path = FlickrApi.UrlConstants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        if let parameters = parameters {
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        
        return components.url!
    }
    
    private func boundingBoxFromCoordinates(latitude:Double, longitude:Double) -> String {
        
        let minimumLon = max(longitude - FlickrApi.BBox.SearchBBoxHalfWidth, FlickrApi.BBox.SearchLonRange.0)
        let minimumLat = max(latitude - FlickrApi.BBox.SearchBBoxHalfHeight, FlickrApi.BBox.SearchLatRange.0)
        let maximumLon = min(longitude + FlickrApi.BBox.SearchBBoxHalfWidth, FlickrApi.BBox.SearchLonRange.1)
        let maximumLat = min(latitude + FlickrApi.BBox.SearchBBoxHalfHeight, FlickrApi.BBox.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
}

