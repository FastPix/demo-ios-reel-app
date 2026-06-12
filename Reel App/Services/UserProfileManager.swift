import Foundation
import Combine

final class UserProfileManager: ObservableObject {

    static let shared = UserProfileManager()

    @Published var creatorId: String
    @Published var name: String

    private let creatorIdKey = "creator_id"
    private let nameKey = "creator_name"


    private init() {

        let defaults = UserDefaults.standard


        if let storedId = defaults.string(
            forKey: creatorIdKey
        ) {
            creatorId = storedId
        } else {

            let newId = "user_\(Int.random(in: 1000...9999))"

            creatorId = newId

            defaults.set(
                newId,
                forKey: creatorIdKey
            )
        }


        name = defaults.string(
            forKey: nameKey
        ) ?? "Creator"
    }

    var avatarURL: URL? {
        URL(
            string:
            "https://api.dicebear.com/9.x/open-peeps/svg?seed=\(creatorId)"
        )
    }
    
    func getAvatarURL(UCreaterID: String) -> URL?{
        URL(string: "https://api.dicebear.com/9.x/open-peeps/svg?seed=\(UCreaterID)")
    }

    func updateName(
        _ value: String
    ) {

        name = value

        UserDefaults.standard.set(
            value,
            forKey: nameKey
        )
    }
}
