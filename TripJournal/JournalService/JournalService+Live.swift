//
//  JournalService+Live.swift
//  TripJournal
//
//  Created by Kevin James on 7/6/25.
//

import Combine
import Foundation

class JournalServiceLive: JournalService {
    @Published private var token: Token?
    private var trips: [Trip] = []
    private var jsonEncoder: JSONEncoder
    private var jsonDecoder: JSONDecoder
    

    init() {
        jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        jsonEncoder.dateEncodingStrategy = .iso8601
        
        jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder.dateDecodingStrategy = .iso8601
    }
    
    var isAuthenticated: AnyPublisher<Bool, Never> {
        $token
            .map { $0 != nil }
            .eraseToAnyPublisher()
    }
    
    func constructUrlRequest(for endpoint: String, authorize: Bool, method: String, content: String?, accept: String?, body: Data?) -> URLRequest {
        var urlRequest = URLRequest(url: URL(string: "http://localhost:8000/\(endpoint)")!)
        urlRequest.httpMethod = method
        if authorize, let token = token {
            urlRequest.setValue("\(token.tokenType) \(token.accessToken)", forHTTPHeaderField: "Authorization")
        }
        if let content = content {
            urlRequest.setValue(content, forHTTPHeaderField: "content-type")
        }
        if let accept = accept {
            urlRequest.setValue(accept, forHTTPHeaderField: "accept")
        }
        if let body = body {
            urlRequest.httpBody = body
        }
        
        return urlRequest
    }
    
    func register(username: String, password: String) async throws -> Token {
        let body = RegisterUser(username: username, password: password)
        //let encoded = try JSONEncoder().encode(body)
        let encoded = try jsonEncoder.encode(body)

        let urlRequest = constructUrlRequest(for: "register", authorize: false, method: "POST", content: "application/json", accept: "application/json", body: encoded)
        
        let (responseData, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        do {
            let token = try jsonDecoder.decode(Token.self, from: responseData)
            return token
        } catch {
            let s = String(data: responseData, encoding: .utf8) ?? "no message"
            print("Token decode failed: \(s)")
        }
        return Token(accessToken: "", tokenType: "none")
    }
    
    func logIn(username: String, password: String) async throws -> Token {
        // Thanks to ChatGPT for this:
        let httpBody = "grant_type=&username=\(username)&password=\(password)".data(using: .utf8)
        
        let urlRequest = constructUrlRequest(for: "token", authorize: false, method: "POST", content: "application/x-www-form-urlencoded", accept: "application/json", body: httpBody)
                
        let (responseData, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        do {
            token = try jsonDecoder.decode(Token.self, from: responseData)
            print("Login token: \(token!)")
            return token!
        } catch {
            let s = String(data: responseData, encoding: .utf8) ?? "no message"
            print("Token decode failed: \(s)")
        }
        return Token(accessToken: "", tokenType: "none")
    }
    
    func logOut() {
        token = nil
    }
    
    func createTrip(with request: TripCreate) async throws -> Trip {
        let encoded = try jsonEncoder.encode(request)
        let urlRequest = constructUrlRequest(for: "trips", authorize: true, method: "POST", content: "application/json", accept: "application/json", body: encoded)
              
        let (responseData, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else { //}, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        do {
            let trip = try jsonDecoder.decode(Trip.self, from: responseData)
            print("Trip: \(trip)")
            trips.append(trip)
            trips.sort()
            return trip
        } catch {
            let s = String(data: responseData, encoding: .utf8) ?? "no message"
            print("Trip decode failed: \(s)")
            throw error
        }
    }
    
    func getTrips() async throws -> [Trip] {
        let urlRequest = constructUrlRequest(for: "trips", authorize: true , method: "GET", content: nil, accept: "application/json", body: nil)
                
        let (responseData, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else { //, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        do {
            let trips: [Trip] = try jsonDecoder.decode([Trip].self, from: responseData)
            print("Trips: \(trips)")
            return trips
        } catch {
            let s = String(data: responseData, encoding: .utf8) ?? "no message"
            print("Trips decode failed: \(s)")
        }
        return []
    }
    
    func getTrip(withId tripId: Trip.ID) async throws -> Trip {
        let urlRequest = constructUrlRequest(for: "trips/\(tripId)", authorize: true, method: "GET", content: nil, accept: "application/json", body: nil)
        
        let (responseData, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        do {
            let trip = try jsonDecoder.decode(Trip.self, from: responseData)
            return trip
        } catch {
            let s = String(data: responseData, encoding: .utf8) ?? "no message"
            print("Trip decode failed: \(s)")
            throw error
        }
    }
    
    func updateTrip(withId tripId: Trip.ID, and request: TripUpdate) async throws -> Trip {
        let urlRequest = constructUrlRequest(for: "trips/\(tripId)", authorize: true, method: "PUT", content: nil, accept: "application/json", body: try jsonEncoder.encode(request))
        
        let (responseData, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        do {
            let trip = try jsonDecoder.decode(Trip.self, from: responseData)
            return trip
        } catch {
            let s = String(data: responseData, encoding: .utf8) ?? "no message"
            print("Trip decode failed: \(s)")
            throw error
        }
    }
    
    func deleteTrip(withId tripId: Trip.ID) async throws {
        let urlRequest = constructUrlRequest(for: "trips/\(tripId)", authorize: true, method: "DELETE", content: nil, accept: "*/*", body: nil)
        
        let (_, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
            throw URLError(.badServerResponse)
        }
    }
    
    func createEvent(with request: EventCreate) async throws -> Event {
        let urlRequest = constructUrlRequest(for: "events", authorize: true, method: "POST", content: "application/json", accept: "application/json", body: try jsonEncoder.encode(request))
        
        let (responseData, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        do {
            let event = try jsonDecoder.decode(Event.self, from:responseData)
            return event
        } catch {
            let s = String(data: responseData, encoding: .utf8) ?? "no message"
            print("Event decode failed: \(s)")
            throw error
        }
    }
    
    func updateEvent(withId eventId: Event.ID, and request: EventUpdate) async throws -> Event {
        let urlRequest = constructUrlRequest(for: "events/\(eventId)", authorize: true, method: "PUT", content: "application/json", accept: "application/json", body: try jsonEncoder.encode(request))
                
        let (responseData, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        do {
            let event = try jsonDecoder.decode(Event.self, from: responseData)
            return event
        } catch {
            let s = String(data: responseData, encoding: .utf8) ?? "no message"
            print("Event decode failed: \(s)")
            throw error
        }
    }
    
    func deleteEvent(withId eventId: Event.ID) async throws {
        let urlRequest = constructUrlRequest(for: "events/\(eventId)", authorize: true, method: "DELETE", content: nil, accept: "*/*", body: nil)
                
        let (_, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
            throw URLError(.badServerResponse)
        }
    }
    
    func createMedia(with request: MediaCreate) async throws -> Media {
        let urlRequest = constructUrlRequest(for: "media", authorize: true, method: "POST", content: "application/json", accept: "application/json", body: try jsonEncoder.encode(request))
        
        let (responseData, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try jsonDecoder.decode(Media.self, from: responseData)
}
    
    func deleteMedia(withId mediaId: Media.ID) async throws {
        let urlRequest = constructUrlRequest(for: "media/\(mediaId)", authorize: true, method: "DELETE", content: nil, accept: "*/*", body: nil)
                
        let (_, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
            throw URLError(.badServerResponse)
        }
    }

}
