//
//  NetworkWeatherManager.swift
//  Sunny
//
//  Created by Андрей on 30.09.2020.
//  Copyright © 2020 Ivan Akulov. All rights reserved.
//

import Foundation
import CoreLocation

protocol NetworkWeatherManagerDelegate: class {
    func updateInterface(_: NetworkWeatherManager, with currentWeather: CurrentWeather)
}

class NetworkWeatherManager {
    
    enum RequestType {
        case ciltyName(city: String)
        case coordinate(latitude: CLLocationDegrees, longitude: CLLocationDegrees)
    }
    
    private let coreUrlString = "https://api.openweathermap.org/data/2.5/weather?appid=\(apiKey)&units=metric"
    weak var delegate: NetworkWeatherManagerDelegate?
    
    func fetchCurrentWeather(forRequestType requestType: RequestType) {
        var urlString = ""
        
        switch requestType {
        case .ciltyName(let city):
            urlString = "\(coreUrlString)&q=\(city)"
        case .coordinate(let latitude, let longitude):
            urlString = "\(coreUrlString)&lat=\(latitude)&lon=\(longitude)"
        }
        
        performRequest(withUrlString: urlString)
    }
    
    private func performRequest(withUrlString urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { (data, response, error) in
            if let data = data {
                guard let currentWeather = self.parseJSON(withData: data) else { return }
                self.delegate?.updateInterface(self, with: currentWeather)
            }
        }
        task.resume()
    }
    
    private func parseJSON(withData data: Data) -> CurrentWeather? {
        let decoder = JSONDecoder()
        
        do {
            let currentWeatherData = try decoder.decode(CurrentWeatherData.self, from: data)
            guard let currentWeather = CurrentWeather(currentWeatherData: currentWeatherData) else {
                return nil
            }
            
            return currentWeather
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        return nil
    }
}
