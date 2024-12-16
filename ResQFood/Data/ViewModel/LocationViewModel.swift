//
//  LocationViewModel.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 16.12.24.
//

import SwiftUI
import CoreLocation


class LocationViewModel: ObservableObject {
    
    @Published var address: String = ""
    
    var locationM = LocationManager.shared
    var geoCodingM = GeocodingManager.shared
    
    
    
}
