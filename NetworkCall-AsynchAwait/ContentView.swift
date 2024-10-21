//
//  ContentView.swift
//  NetworkCall-AsynchAwait
//
//  Created by Rohan Patel on 10/21/24.
//

import SwiftUI

struct ContentView: View {
    @State private var user: GHUser?
    
    var body: some View {
        VStack {
            
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            }placeholder: {
                Circle()
                    .foregroundStyle(.secondary)
                    
                    .padding()
            }
            .frame(width: 120, height: 120)
            
            Text(user?.login ?? "Loading...")
                .bold()
                .font(.title3)
            
            Text(user?.bio ?? "This is where Github bio will be displayed. Please wait while we fetch it...")
                .padding()
            
            Spacer()
        }
        .padding()
        .task {
            do{
                user = try await getuser()
            }catch GHError.invalidURL{
                print("Check URL")
            }catch GHError.invalidResponse{
                print("Failed to receive response")
            }catch GHError.invalidData{
                print("Failed to decode data")
            }catch{
                print("Unexpected Error Occurred")
            }
        }
    }
    
    func getuser() async throws -> GHUser{
        guard let url = URL(string: "https://api.github.com/users/patelrohan") else{
            throw GHError.invalidURL
        }
            
        let (data, response) = try await URLSession.shared.data(from: url)
            
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else{
                throw GHError.invalidResponse
        }
           
        do{
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let user = try decoder.decode(GHUser.self, from: data)
            return user
        }catch{
            throw GHError.invalidData
        }
    }
}


struct GHUser: Codable{
    let login: String
    let avatarUrl: String
    let bio: String
}

enum GHError: Error{
    case invalidURL
    case invalidResponse
    case invalidData
}

#Preview {
    ContentView()
}
