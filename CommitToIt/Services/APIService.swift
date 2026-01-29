import Foundation

private struct RewardsResponse: Decodable {
    let status: String
    let message: String
    let data: [RewardDTO]
}

private struct RewardDTO:Decodable {
    let reward_id: Int
    let title: String
    let description: String
    let cost: Int
    let icon: String
}

class APIService {
    static var shared = APIService()
    
    private init() {}
    
    func getRewards(baseURL: String, completion: @escaping (Result<[Reward], Error>) -> Void) {
        guard let url = URL(string: "http://localhost:3001/api/reward/") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(RewardsResponse.self, from: data)
                let rewards: [Reward] = response.data.map { dto in
                    Reward(
                        id: UUID(),
                        title: dto.title,
                        description: dto.description,
                        cost: dto.cost,
                        icon: dto.icon,
                        redeemed_at: nil
                    )
                }
                completion(.success(rewards))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

