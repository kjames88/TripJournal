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

    var isAuthenticated: AnyPublisher<Bool, Never> {
        $token
            .map { $0 != nil }
            .eraseToAnyPublisher()
    }
    
    func register(username: String, password: String) async throws -> Token {
        let body = RegisterUser(username: username, password: password)
        let encoded = try JSONEncoder().encode(body)
        
        var urlRequest = URLRequest(url: URL(string: "http://localhost:8000/register")!)
        urlRequest.setValue("application/json", forHTTPHeaderField: "content-type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = encoded
        
        let (responseData, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else { //}, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        print("status code: \(httpResponse.statusCode)")
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
        
            let token = try decoder.decode(Token.self, from: responseData)
            return token
        } catch {
            let s = String(data: responseData, encoding: .utf8) ?? "no message"
            print("Token decode failed: \(s)")
        }
        return Token(accessToken: "", tokenType: "none")
    }
    
    func logIn(username: String, password: String) async throws -> Token {
        var urlRequest = URLRequest(url: URL(string: "http://localhost:8000/token")!)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.httpMethod = "POST"
        // Thanks to ChatGPT for this:
        urlRequest.httpBody = "grant_type=&username=\(username)&password=\(password)".data(using: .utf8)
        
        let (responseData, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else { //}, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        print("status code: \(httpResponse.statusCode)")
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
        
            token = try decoder.decode(Token.self, from: responseData)
            print("Login token: \(token!)")
            return token!
        } catch {
            let s = String(data: responseData, encoding: .utf8) ?? "no message"
            print("Token decode failed: \(s)")
        }
        return Token(accessToken: "", tokenType: "none")
    }
    
    func logOut() {
        fatalError("Unimplemented logOut")
    }
    
    func createTrip(with request: TripCreate) async throws -> Trip {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        let encoded = try encoder.encode(request)
        var urlRequest = URLRequest(url: URL(string: "http://localhost:8000/trips")!)
        urlRequest.setValue("application/json", forHTTPHeaderField: "content-type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.setValue("\(token!.tokenType) \(token!.accessToken)", forHTTPHeaderField: "Authorization")
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = encoded
        
        let (responseData, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else { //}, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        print("status code: \(httpResponse.statusCode)")
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        do {
            let trip = try decoder.decode(Trip.self, from: responseData)
            print("Trip: \(trip)")
            //let newTrip = Trip(from: request)
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
        print("token: \(token!.accessToken)")
        
        var urlRequest = URLRequest(url: URL(string: "http://localhost:8000/trips")!)
        //urlRequest.setValue("application/json", forHTTPHeaderField: "content-type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.setValue("\(token!.tokenType) \(token!.accessToken)", forHTTPHeaderField: "Authorization")
        urlRequest.httpMethod = "GET"
        
        print("urlRequest Authorization: \(urlRequest.value(forHTTPHeaderField: "Authorization")!)")
        
        let (responseData, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else { //, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        print("status code: \(httpResponse.statusCode)")
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        do {
            let trips: [Trip] = try decoder.decode([Trip].self, from: responseData)
            print("Trips: \(trips)")
            return trips
        } catch {
            let s = String(data: responseData, encoding: .utf8) ?? "no message"
            print("Trips decode failed: \(s)")
        }
        return []
    }
    
    func getTrip(withId tripId: Trip.ID) async throws -> Trip {
        fatalError("Unimplemented getTrip")
    }
    
    func updateTrip(withId tripId: Trip.ID, and request: TripUpdate) async throws -> Trip {
        fatalError("Unimplemented updateTrip")
    }
    
    func deleteTrip(withId tripId: Trip.ID) async throws {
        fatalError("Unimplemented deleteTrip")
    }
    
    func createEvent(with request: EventCreate) async throws -> Event {
        fatalError("Unimplemented createEvent")
    }
    
    func updateEvent(withId eventId: Event.ID, and request: EventUpdate) async throws -> Event {
        fatalError("Unimplemented updateEvent")
    }
    
    func deleteEvent(withId eventId: Event.ID) async throws {
        fatalError( "Unimplemented deleteEvent")
    }
    
    func createMedia(with request: MediaCreate) async throws -> Media {
        fatalError("Unimplemented createMedia")
    }
    
    func deleteMedia(withId mediaId: Media.ID) async throws {
        fatalError("Unimplemented deleteMedia")
    }

}
