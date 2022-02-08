//
//  APICaller.swift
//  News
//
//  Created by Юрий Филатов on 05.02.2022.
//

import Foundation


final class APICaller {
    
    static let shared = APICaller()
    
    struct Constants {
        static let topHeadLinesURL = URL(string:
                                            "https://newsapi.org/v2/top-headlines?country=ru&apiKey=74801b3a00474490b66db393720fcf93")
    }
    
    private init(){}
    
    public func getTopStories(complition: @escaping (Result<[Article], Error>) -> Void ) {
        
        guard let url = Constants.topHeadLinesURL else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                complition(.failure(error))
            } else if let data = data {
                do {
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    print("Articles: \(result.articles.count)")
                    complition(.success(result.articles))
                }
                catch {
                    complition(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    public func getImage(url: URL, completion: @escaping (Data)->()){
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error ==  nil else {
                return
            }
            completion(data)
        } .resume()
    }
}


// Models

struct APIResponse: Codable {
    let articles: [Article]
}

struct Article: Codable {
    let source: Source
    let title: String
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String
    
}

struct Source: Codable {
    let name: String
}

