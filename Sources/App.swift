//
//  MapsApp.swift
//  Karte
//
//  Created by Kilian Költzsch on 13.04.17.
//  Copyright © 2017 Karte. All rights reserved.
//

import Foundation

public enum App: String {
    case appleMaps
    case googleMaps // https://developers.google.com/maps/documentation/ios/urlscheme
    case citymapper
    case transit // http://thetransitapp.com/developers
    case lyft
    case uber
    case navigon // http://www.navigon.com/portal/common/faq/files/NAVIGON_AppInteract.pdf
    case waze
    case dbnavigator
    case yandex
    case moovit
    case olacabs // https://developers.olacabs.com/docs/deep-linking

    static var all: [App] {
        return [
            .appleMaps,
            .googleMaps,
            .citymapper,
            .transit,
            .lyft,
            .uber,
            .navigon,
            .waze,
            .dbnavigator,
            .yandex,
            .moovit,
            .olacabs
        ]
    }

    var urlScheme: String {
        switch self {
        case .appleMaps: return "" // Uses System APIs, so this is just a placeholder
        case .googleMaps: return "comgooglemaps"
        case .citymapper: return "citymapper"
        case .transit: return "transit"
        case .lyft: return "lyft"
        case .uber: return "uber"
        case .navigon: return "navigon"
        case .waze: return "waze"
        case .dbnavigator: return "dbnavigator"
        case .yandex: return "yandexnavi"
        case .moovit: return "moovit"
        case .olacabs: return "olacabs"
        }
    }

    public var name: String {
        switch self {
        case .appleMaps: return "Apple Maps"
        case .googleMaps: return "Google Maps"
        case .citymapper: return "Citymapper"
        case .transit: return "Transit App"
        case .lyft: return "Lyft"
        case .uber: return "Uber"
        case .navigon: return "Navigon"
        case .waze: return "Waze"
        case .dbnavigator: return "DB Navigator"
        case .yandex: return "Yandex.Navi"
        case .moovit: return "Moovit"
        case.olacabs: return "Ola"
        }
    }

    /// Validates if an app supports a mode. The given mode is optional and this defaults to `true`
    /// if the mode is `nil`.
    func supports(mode: Mode?) -> Bool {
        guard let mode = mode else {
            return true
        }

        switch self {
        case .appleMaps:
            return mode != .bicycling
        case .googleMaps:
            return true
        case .citymapper, .transit:
            return mode == .transit
        case .lyft, .uber, .olacabs:
            return mode == .taxi
        case .navigon:
            return mode == .driving || mode == .walking
        case .waze:
            return mode == .driving
        case .dbnavigator:
            return mode == .transit
        case .yandex:
            return true
        case .moovit:
            return true
        }
    }

    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    /// Build a query string for this app using the parameters. Returns nil if a mode is specified,
    /// but not supported by this app.
    func url(origin: LocationRepresentable?,
                     destination: LocationRepresentable,
                     mode: Mode?) -> URL? {
        guard self.supports(mode: mode) else {
            // if a mode is present, validate if the app supports it, otherwise we don't care
            return nil
        }

        var urlComponents = URLComponents()
        
        //var parameters = [String: String]()

        urlComponents.scheme = self.urlScheme
        
        let oLat = origin?.latitude == nil ? "" : String(describing: origin?.latitude)
        let oLong = origin?.longitude == nil ? "" : String(describing: origin?.longitude)
        let dLat = String(describing: destination.latitude)
        let dLong = String(describing: destination.longitude)

        switch self {
        case .appleMaps:
            // Apple Maps gets special handling, since it uses System APIs
            return nil
        case .googleMaps:
            urlComponents.path = "maps"
            urlComponents.queryItems?.append(
                URLQueryItem(name: "saddr", value: origin?.coordString))
            urlComponents.queryItems?.append(URLQueryItem(name: "saddr", value: origin?.coordString))
            urlComponents.queryItems?.append(URLQueryItem(name: "daddr", value: destination.coordString))

            let modeIdentifier = mode?.identifier(for: self) as? String
            urlComponents.queryItems?.append(URLQueryItem(name: "directionsmode", value: modeIdentifier))
        case .citymapper:
            urlComponents.path = "directions"
            urlComponents.queryItems?.append(URLQueryItem(name: "endcoord", value: destination.coordString))
            urlComponents.queryItems?.append(URLQueryItem(name: "startcoord", value: origin?.coordString))
            urlComponents.queryItems?.append(URLQueryItem(name: "startname", value: origin?.name))
            urlComponents.queryItems?.append(URLQueryItem(name: "startaddress", value: origin?.address))
            urlComponents.queryItems?.append(URLQueryItem(name: "endname", value: destination.name))
            urlComponents.queryItems?.append(URLQueryItem(name: "endaddress", value: destination.address))
        case .transit:
            urlComponents.path = "directions"
            urlComponents.queryItems?.append(URLQueryItem(name: "from", value: origin?.coordString))
            urlComponents.queryItems?.append(URLQueryItem(name: "to", value: destination.coordString))
        case .lyft:
            urlComponents.path = "ridetype"
            urlComponents.queryItems?.append(URLQueryItem(name: "id", value: "lyft"))

            urlComponents.queryItems?.append(URLQueryItem(name: "pickup[latitude]", value: oLat))
            urlComponents.queryItems?.append(URLQueryItem(name: "pickup[longitude]", value: String(describing: origin?.longitude)))
            urlComponents.queryItems?.append(URLQueryItem(name: "destination[latitude]", value: String(describing: destination.latitude)))
            urlComponents.queryItems?.append(URLQueryItem(name: "destination[longitude]", value: String(describing: destination.longitude)))
        case .olacabs:
            urlComponents.path = "app/launch"
            urlComponents.queryItems?.append(URLQueryItem(name: "lat", value: oLat))
            urlComponents.queryItems?.append(URLQueryItem(name: "lng", value: oLong))
            urlComponents.queryItems?.append(URLQueryItem(name: "drop_lat", value: dLat))
            urlComponents.queryItems?.append(URLQueryItem(name: "drop_long", value: dLong))
            urlComponents.queryItems?.append(URLQueryItem(name: "drop_address", value: destination.address))
            urlComponents.queryItems?.append(URLQueryItem(name: "drop_name", value: destination.name))
        case .uber:
            
            urlComponents.queryItems?.append(URLQueryItem(name: "action", value: "setPickup"))
            if origin != nil {
                urlComponents.queryItems?.append(URLQueryItem(name: "pickup[latitude]", value: oLat))
                urlComponents.queryItems?.append(URLQueryItem(name: "pickup[longitude]", value: oLong))
            } else {
                urlComponents.queryItems?.append(URLQueryItem(name: "pickup", value: "my_location"))
            }
            urlComponents.queryItems?.append(URLQueryItem(name: "dropoff[latitude]", value: dLat))
            urlComponents.queryItems?.append(URLQueryItem(name: "dropoff[longitude]", value: dLong))
            urlComponents.queryItems?.append(URLQueryItem(name: "dropoff[nickname]", value: destination.name))
        case .navigon:
            // Docs are unclear about the name being omitted
            let name = destination.name ?? "Destination"
            // swiftlint:disable:next line_length
            urlComponents.path = "coordinate/\(name.urlQuery ?? "")/\(destination.longitude)/\(destination.latitude)"
        case .waze:
            // swiftlint:disable:next line_length
            urlComponents.queryItems?.append(URLQueryItem(name: "ll", value: "\(destination.latitude),\(destination.longitude)"))
            urlComponents.queryItems?.append(URLQueryItem(name: "navigate", value: "yes"))
        case .dbnavigator:
            urlComponents.path = "query"
            if let origin = origin {
                urlComponents.queryItems?.append(URLQueryItem(name: "SKOORD", value: "1"))
                urlComponents.queryItems?.append(URLQueryItem(name: "SNAME", value: origin.name))
                urlComponents.queryItems?.append(URLQueryItem(name: "SY", value: "\(Int(origin.latitude * 1_000_000))"))
                urlComponents.queryItems?.append(URLQueryItem(name: "SX", value: "\(Int(origin.longitude * 1_000_000))"))
            }
            urlComponents.queryItems?.append(URLQueryItem(name: "ZKOORD", value: "1"))
            urlComponents.queryItems?.append(URLQueryItem(name: "ZNAME", value: destination.name))
            urlComponents.queryItems?.append(URLQueryItem(name: "ZY", value: "\(Int(destination.latitude * 1_000_000))"))
            urlComponents.queryItems?.append(URLQueryItem(name: "ZX", value: "\(Int(destination.longitude * 1_000_000))"))
        case .yandex:
            urlComponents.path = "build_route_on_map"
            urlComponents.queryItems?.append(URLQueryItem(name: "lat_from", value: oLat))
            urlComponents.queryItems?.append(URLQueryItem(name: "lon_from", value: oLong))
            urlComponents.queryItems?.append(URLQueryItem(name: "lat_to", value: dLat))
            urlComponents.queryItems?.append(URLQueryItem(name: "lon_to", value: dLong))
        case .moovit:
            urlComponents.path = "directions"

            urlComponents.queryItems?.append(URLQueryItem(name: "origin_lat", value: oLat))
            urlComponents.queryItems?.append(URLQueryItem(name: "origin_lon", value: oLong))
            urlComponents.queryItems?.append(URLQueryItem(name: "orig_name", value: origin?.name))
            urlComponents.queryItems?.append(URLQueryItem(name: "dest_lat", value: dLat))
            urlComponents.queryItems?.append(URLQueryItem(name: "dest_lon", value: dLong))
            urlComponents.queryItems?.append(URLQueryItem(name: "dest_name", value: destination.name))
        }
        
        return urlComponents.url
    }
    // swiftlint:enable function_body_length
    // swiftlint:enable cyclomatic_complexity
}
