//
//  StateDraw.swift
//  CoronaContact
//

import UIKit
import GEOSwift

class StateDrawer {
    
    private struct DistrictWithPathAndColor {
        let iso: Int
        let color: UIColor
        let path: [UIBezierPath]
    }
    
    static let shared = StateDrawer()
    
    private var state: Bundesland = .österreich
    
    private var jsonResource: String {
        return state == .österreich ? "laender_95_geo" : "bezirke_95_geo"
    }
    private var scale: Double {
        // The states from Austria are smaller than the Land
        return state == .österreich ? 2000 : 1000
    }

    private var districtWithPathAndColors = [DistrictWithPathAndColor]()
    
    func drawImage(from state: Bundesland, with covidStatistics: CovidStatistics) throws -> UIImage? {
        // We dont need the Array after the Image is created
        defer { districtWithPathAndColors = [DistrictWithPathAndColor]() }
        
        self.state = state
        
        do {
            guard let geoJSONURL = Bundle.main.url(forResource: jsonResource, withExtension: "json") else { return nil }
            
            let data = try Data(contentsOf: geoJSONURL)
            let geoJSON = try JSONDecoder().decode(GeoJSON.self, from: data)
            
            switch geoJSON {
            // The Geo json we use had only featureCollection.
            case.featureCollection(let featureCollection):
                for oneFeature in featureCollection.features {
                    
                    guard let geometries = oneFeature.geometry,
                          let isoString = oneFeature.properties?["iso"]?.untypedValue as? String,
                          let iso = Int(isoString) else { continue }
                    
                    var incidenceState: IncidenceState?
                    if state != .österreich {
                        
                        // The GeoJSON we use had more GKZ's for Vienna but the Data we get from AGES had only one GKZ for Vienna
                        guard try state.getGKZRange().contains(iso),
                              let covidFaelleGKZ = covidStatistics.covidFaelleGKZ.first(where: { $0.gkz == (iso > 900 ? 900 : iso) }) else { continue }
                        
                        incidenceState = IncidenceState(covidFaelleGKZ.incidenceValue)
                        
                    } else {
                        let covidFaelleTimeline = covidStatistics.covidFaelleTimeline.filter({ $0.bundeslandID == iso })
                        guard let lastDayCovidFaelleTimeline = covidFaelleTimeline.lastTwoElements()?.lastDay as? CovidFaelleTimeline else { continue }
                        
                        incidenceState = IncidenceState(lastDayCovidFaelleTimeline.siebenTageInzidenzFaelle)
                    }
                    
                    guard let color = incidenceState?.color else { continue }
                    districtWithPathAndColors.append(DistrictWithPathAndColor(iso: iso, color: color, path: checkGeometry(with: geometries)))
                }
            default: break
                
            }
            
            let img = renderImage()
            
            img.accessibilityLabel = state.localized
            return img
        } catch {
            throw AGESError.invalidValidation
        }
    }
    
    private func renderImage() -> UIImage {
        
        // This is important when we start to draw that we start with the lowest iso we have
        let sorted = districtWithPathAndColors.sorted(by: { $0.iso < $1.iso })
        
        let fullPath = sorted.flatMap({ $0.path }).reduce(into: UIBezierPath()) { fullPath, path in
            fullPath.append(path)
        }
        
        return UIGraphicsImageRenderer(bounds: fullPath.bounds).image { ctx in
            for onDistrict in sorted {
                ctx.cgContext.setFillColor(onDistrict.color.cgColor)
                ctx.cgContext.setStrokeColor(UIColor.ccBrownGrey.cgColor)
                ctx.cgContext.setLineWidth(1)
                onDistrict.path.forEach({ ctx.cgContext.addPath($0.cgPath) })
                ctx.cgContext.drawPath(using: .fillStroke)}
        }
    }
    
    // MARK: - GEOSwift
    private func checkGeometry(with geometry: Geometry) -> [UIBezierPath] {
        switch geometry {
        // The Geo json we use had only multiPolygon and polygons.
        case .polygon(let polygon):
            return [createPath(polygonPoints: polygon.exterior.points)]
        case .multiPolygon(let multiPolygon):
            return multiPolygon.polygons.flatMap({ checkGeometry(with: $0.geometry )})
        default:
            return []
        }
    }
    
    private func createPath(polygonPoints: [Point]) -> UIBezierPath {
        
        let path = UIBezierPath()
        
        for onePoint in polygonPoints {
            let mPoint = mercator(point: onePoint)
            
            let scaledPoint = CGPoint(x: mPoint.x / scale, y: mPoint.y / scale)
            
            if onePoint == polygonPoints.first {
                path.move(to: scaledPoint)
            } else {
                path.addLine(to: scaledPoint)
            }
        }
        
        let mirror = CGAffineTransform(scaleX: 1, y: -1)
        let translate = CGAffineTransform(translationX: 1, y: 1)
        let concatenated = mirror.concatenating(translate)
        
        path.apply(concatenated)
        
        return path
    }
    
    private func mercator(point: Point) -> Point {
        return Point(x: lon2x(aLong: point.x), y: lat2y(aLat: point.y))
    }
    
    // https://wiki.openstreetmap.org/wiki/Mercator#Swift
    //This is the Earth Radius!
    private let radius: Double = 6378137.0; /* in meters on the equator */
    /* These functions take their length parameter in meters and return an angle in degrees */
    
    private func y2lat(yValue: Double) -> Double {
        (atan(exp(yValue / radius)) * 2 - Double.pi/2).radiansToDegrees
    }
    
    private func x2lon(xValue: Double) -> Double {
        (xValue / radius).radiansToDegrees
    }
    
    /* These functions take their angle parameter in degrees and return a length in meters */
    
    private func lat2y(aLat: Double) -> Double {
        log(tan(Double.pi / 4 + (aLat.degreesToRadians / 2))) * radius
    }
    
    private func lon2x(aLong: Double) -> Double {
        (aLong).degreesToRadians * radius
    }
}
