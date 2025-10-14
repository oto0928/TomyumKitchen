import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class FirebaseService: ObservableObject {
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    // MARK: - メニューデータ取得
    func fetchDishes() async throws -> [Dish] {
        let snapshot = try await db.collection("dishes").getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Dish.self)
        }
    }
    
    func fetchCategories() async throws -> [Category] {
        let snapshot = try await db.collection("categories").getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Category.self)
        }
    }
    
    // MARK: - 予約管理
    func createReservation(_ reservation: Reservation) async throws -> String {
        let docRef = try await db.collection("reservations").addDocument(from: reservation)
        return docRef.documentID
    }
    
    func fetchReservations() async throws -> [Reservation] {
        let snapshot = try await db.collection("reservations").getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Reservation.self)
        }
    }
    
    // MARK: - 注文管理
    func createOrder(_ order: Order) async throws -> String {
        let docRef = try await db.collection("orders").addDocument(from: order)
        return docRef.documentID
    }
    
    func fetchOrders() async throws -> [Order] {
        let snapshot = try await db.collection("orders").getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Order.self)
        }
    }
    
    // MARK: - クーポン管理
    func fetchCoupons() async throws -> [Coupon] {
        let snapshot = try await db.collection("coupons").getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Coupon.self)
        }
    }
    
    // MARK: - 認証（将来の拡張用）
    func signInAnonymously() async throws -> AuthDataResult {
        return try await Auth.auth().signInAnonymously()
    }
    
    func signInWithPhoneNumber(_ phoneNumber: String) async throws -> String {
        // 電話番号認証の実装（将来の拡張）
        return "verification_id"
    }
    
    // MARK: - ストレージ（画像アップロード用）
    func uploadImage(_ imageData: Data, path: String) async throws -> String {
        let storageRef = storage.reference().child(path)
        let _ = try await storageRef.putDataAsync(imageData)
        return try await storageRef.downloadURL().absoluteString
    }
}

