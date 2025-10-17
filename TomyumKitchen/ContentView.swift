//
//  ContentView.swift
//  TomyumKitchen
//
//  Created by 竹内音碧 on 2025/09/27.
//

import SwiftUI
import Firebase
import FirebaseFirestore

// MARK: - Cart Manager
class CartManager: ObservableObject {
    @Published var cartItems: [(dish: Dish, quantity: Int)] = []
    
    func addToCart(dish: Dish, quantity: Int = 1) {
        if let index = cartItems.firstIndex(where: { $0.dish.id == dish.id }) {
            cartItems[index].quantity += quantity
        } else {
            cartItems.append((dish: dish, quantity: quantity))
        }
    }
    
    func removeFromCart(dish: Dish) {
        cartItems.removeAll { $0.dish.id == dish.id }
    }
    
    func updateQuantity(dish: Dish, quantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.dish.id == dish.id }) {
            if quantity > 0 {
                cartItems[index].quantity = quantity
            } else {
                cartItems.remove(at: index)
            }
        }
    }
    
    var subtotal: Int {
        cartItems.reduce(0) { $0 + ($1.dish.price * $1.quantity) }
    }
    
    var totalItems: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }
}

// MARK: - Design System
struct DesignSystem {
    // Colors
    static let primaryRed = Color(red: 0.77, green: 0.18, blue: 0.18) // #C42F2F
    static let primaryDark = Color(red: 0.56, green: 0.12, blue: 0.12) // #8F1F1F
    static let accent = Color(red: 0.18, green: 0.49, blue: 0.40) // #2E7D66
    static let gold = Color(red: 0.81, green: 0.62, blue: 0.24) // #CF9F3E
    static let background = Color(red: 1.0, green: 0.97, blue: 0.95) // #FFF8F3
    static let textPrimary = Color(red: 0.13, green: 0.13, blue: 0.13) // #222222
    static let textSecondary = Color(red: 0.42, green: 0.42, blue: 0.42) // #6B6B6B
    
    // Spicy Scale Colors
    static let spicyColors = [
        0: Color(red: 0.50, green: 0.69, blue: 0.41), // #7FB069
        1: Color(red: 0.95, green: 0.76, blue: 0.31), // #F2C14E
        2: Color(red: 0.95, green: 0.76, blue: 0.31), // #F2C14E
        3: Color(red: 0.90, green: 0.49, blue: 0.13), // #E67E22
        4: Color(red: 0.91, green: 0.30, blue: 0.24), // #E74C3C
        5: Color(red: 0.76, green: 0.09, blue: 0.03)  // #C21807
    ]
    
    // Spacing
    static let spacing = (xs: 4.0, s: 8.0, m: 12.0, l: 16.0, xl: 24.0, xxl: 32.0)
    
    // Corner Radius
    static let cornerRadius = (card: 12.0, button: 8.0, pill: 20.0)
}

// MARK: - Models
struct Dish: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    let detailedDescription: String
    let price: Int
    let imageName: String
    let spicyLevel: Int
    let isVegetarian: Bool
    let allergens: [String]
    let category: String
    let calories: Int
    let cookingTime: String
    let ingredients: [String]
    let nutritionInfo: NutritionInfo
    
    struct NutritionInfo: Hashable, Equatable, Codable {
        let protein: String
        let fat: String
        let carbs: String
        let sodium: String
    }
}

// MARK: - Codable Extensions
extension Dish: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, description, price, imageName, spicyLevel, allergens, isVegetarian, category
        case detailedDescription, calories, cookingTime, ingredients, nutritionInfo
    }
}

struct Category: Identifiable, Codable {
    let id = UUID()
    let name: String
    let icon: String
}

struct Coupon: Identifiable, Hashable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let discountType: DiscountType
    let discountValue: Int // 割引額（円）または割引率（%）
    let minimumAmount: Int? // 最小利用金額
    let expiryDate: Date
    let isUsed: Bool
    let code: String
    
    enum DiscountType: String, Codable {
        case percentage = "percentage" // パーセント割引
        case fixedAmount = "fixedAmount" // 固定額割引
        case freeShipping = "freeShipping" // 送料無料
    }
    
    var isExpired: Bool {
        Date() > expiryDate
    }
    
    var isAvailable: Bool {
        !isUsed && !isExpired
    }
    
    var discountText: String {
        switch discountType {
        case .percentage:
            return "\(discountValue)%OFF"
        case .fixedAmount:
            return "¥\(discountValue)OFF"
        case .freeShipping:
            return "送料無料"
        }
    }
}

// MARK: - Sample Data
extension Dish {
    static let sampleDishes = [
        Dish(
            name: "トムヤムクン",
            description: "エビの旨味たっぷりの酸辣スープ",
            detailedDescription: "新鮮なエビとマッシュルーム、トマトを使用した本格的なタイの酸辣スープです。レモングラス、カフィアライムリーフ、ガランガルなどのハーブが香り豊かで、酸味と辛味のバランスが絶妙です。",
            price: 1200,
            imageName: "トムヤムクン",
            spicyLevel: 3,
            isVegetarian: false,
            allergens: ["エビ", "魚醤"],
            category: "スープ",
            calories: 180,
            cookingTime: "15分",
            ingredients: ["エビ", "マッシュルーム", "トマト", "レモングラス", "カフィアライムリーフ", "ガランガル", "唐辛子", "ライム汁", "魚醤"],
            nutritionInfo: NutritionInfo(protein: "12g", fat: "8g", carbs: "15g", sodium: "1200mg")
        ),
        Dish(
            name: "グリーンカレー",
            description: "ココナッツミルクの甘さと青唐辛子の辛さが絶妙",
            detailedDescription: "タイ料理の代表格、濃厚なココナッツミルクベースのカレーです。青唐辛子、バジル、ガランガルなどの香辛料を使用し、鶏肉とナスが入っています。辛さの中にもまろやかさがあり、ジャスミンライスとの相性は抜群です。",
            price: 1400,
            imageName: "グリーンカレー",
            spicyLevel: 4,
            isVegetarian: false,
            allergens: ["乳製品"],
            category: "カレー",
            calories: 420,
            cookingTime: "25分",
            ingredients: ["鶏肉", "ココナッツミルク", "青唐辛子", "バジル", "ナス", "ガランガル", "レモングラス", "魚醤", "パームシュガー"],
            nutritionInfo: NutritionInfo(protein: "25g", fat: "32g", carbs: "18g", sodium: "980mg")
        ),
        Dish(
            name: "パッタイ",
            description: "タイ風焼きそば、甘酸っぱいタマリンドソース",
            detailedDescription: "タイの国民的料理として愛される米粉麺の炒め物です。タマリンドの酸味、パームシュガーの甘味、魚醤の旨味が絶妙にブレンドされたソースで炒めた麺に、エビ、豆腐、もやし、ニラが入り、ピーナッツとライムで仕上げます。",
            price: 1100,
            imageName: "パッタイ",
            spicyLevel: 2,
            isVegetarian: false,
            allergens: ["卵", "エビ", "ピーナッツ", "魚醤"],
            category: "麺",
            calories: 380,
            cookingTime: "12分",
            ingredients: ["米粉麺", "エビ", "卵", "豆腐", "もやし", "ニラ", "タマリンド", "パームシュガー", "魚醤", "ピーナッツ", "ライム"],
            nutritionInfo: NutritionInfo(protein: "18g", fat: "15g", carbs: "45g", sodium: "1100mg")
        ),
        Dish(
            name: "ガパオライス",
            description: "バジル炒めご飯、目玉焼きトッピング",
            detailedDescription: "タイのホーリーバジル（ガパオ）を使った香り高い炒めご飯です。豚ひき肉を唐辛子とニンニクで炒め、ガパオの葉を加えて仕上げます。上にのせた半熟の目玉焼きを崩して食べるのが本場スタイル。スパイシーで食欲をそそる一品です。",
            price: 1000,
            imageName: "ガパオライス",
            spicyLevel: 3,
            isVegetarian: false,
            allergens: ["卵", "魚醤"],
            category: "ご飯",
            calories: 520,
            cookingTime: "10分",
            ingredients: ["豚ひき肉", "ガパオ（ホーリーバジル）", "ジャスミンライス", "卵", "唐辛子", "ニンニク", "玉ねぎ", "魚醤", "オイスターソース", "砂糖"],
            nutritionInfo: NutritionInfo(protein: "28g", fat: "22g", carbs: "58g", sodium: "1350mg")
        ),
        Dish(
            name: "生春巻き",
            description: "新鮮な野菜とエビの生春巻き",
            detailedDescription: "透明なライスペーパーで包んだヘルシーな前菜です。新鮮なレタス、キュウリ、人参、香草と茹でエビを包み、甘酸っぱいスイートチリソースでお召し上がりください。さっぱりとした味わいで、食事の始まりにぴったりです。",
            price: 800,
            imageName: "生春巻き",
            spicyLevel: 0,
            isVegetarian: false,
            allergens: ["エビ"],
            category: "前菜",
            calories: 120,
            cookingTime: "8分",
            ingredients: ["エビ", "ライスペーパー", "レタス", "キュウリ", "人参", "パクチー", "ミント", "スイートチリソース"],
            nutritionInfo: NutritionInfo(protein: "8g", fat: "2g", carbs: "20g", sodium: "450mg")
        ),
        Dish(
            name: "ソムタム",
            description: "青パパイヤのサラダ、爽やかな酸味",
            detailedDescription: "タイ東北部イサーン地方の代表的なサラダです。千切りにした青パパイヤを、ライム汁、魚醤、パームシュガー、唐辛子で和えた爽やかな一品。トマト、いんげん、ピーナッツが加わり、酸味と辛味、甘味のバランスが絶妙です。",
            price: 900,
            imageName: "ソムタム",
            spicyLevel: 3,
            isVegetarian: true,
            allergens: ["ピーナッツ"],
            category: "サラダ",
            calories: 150,
            cookingTime: "10分",
            ingredients: ["青パパイヤ", "トマト", "いんげん", "ピーナッツ", "ライム汁", "パームシュガー", "唐辛子", "ニンニク"],
            nutritionInfo: NutritionInfo(protein: "4g", fat: "6g", carbs: "25g", sodium: "680mg")
        ),
        Dish(
            name: "カオマンガイ",
            description: "茹で鶏とジャスミンライス",
            detailedDescription: "シンガポールチキンライスのタイ版として親しまれている庶民料理です。鶏の出汁で炊いたジャスミンライスの上に、しっとりと茹でた鶏肉をのせ、生姜とニンニクの効いた特製ソースでお召し上がりください。シンプルながら奥深い味わいです。",
            price: 1300,
            imageName: "カオマンガイ",
            spicyLevel: 1,
            isVegetarian: false,
            allergens: ["大豆"],
            category: "ご飯",
            calories: 480,
            cookingTime: "45分",
            ingredients: ["鶏もも肉", "ジャスミンライス", "生姜", "ニンニク", "パクチー", "キュウリ", "大豆ソース", "オイスターソース", "ごま油"],
            nutritionInfo: NutritionInfo(protein: "35g", fat: "18g", carbs: "52g", sodium: "920mg")
        ),
        Dish(
            name: "ココナッツミルクアイス",
            description: "濃厚なココナッツの風味",
            detailedDescription: "新鮮なココナッツミルクを使用した手作りアイスクリームです。トロピカルな甘さと滑らかな舌触りが特徴で、タイの伝統的なデザートとして愛されています。パンダンリーフの香りがほのかに香り、食後のデザートに最適です。",
            price: 500,
            imageName: "ココナッツミルクアイス",
            spicyLevel: 0,
            isVegetarian: true,
            allergens: ["乳製品"],
            category: "デザート",
            calories: 220,
            cookingTime: "5分（冷凍時間除く）",
            ingredients: ["ココナッツミルク", "砂糖", "パンダンリーフ", "塩", "コーンスターチ"],
            nutritionInfo: NutritionInfo(protein: "3g", fat: "18g", carbs: "22g", sodium: "45mg")
        )
    ]
}

struct Reservation: Identifiable, Codable {
    let id = UUID()
    let customerName: String
    let phone: String
    let email: String
    let partySize: Int
    let date: Date
    let timeSlot: TimeSlot
    let specialRequests: String
    let status: ReservationStatus
    let createdAt: Date
    
    enum TimeSlot: String, CaseIterable, Codable {
        case lunch1130 = "11:30"
        case lunch1200 = "12:00"
        case lunch1230 = "12:30"
        case lunch1300 = "13:00"
        case lunch1330 = "13:30"
        case lunch1400 = "14:00"
        case dinner1730 = "17:30"
        case dinner1800 = "18:00"
        case dinner1830 = "18:30"
        case dinner1900 = "19:00"
        case dinner1930 = "19:30"
        case dinner2000 = "20:00"
        case dinner2030 = "20:30"
        
        var displayName: String {
            return self.rawValue
        }
        
        var isLunchTime: Bool {
            return ["11:30", "12:00", "12:30", "13:00", "13:30", "14:00"].contains(self.rawValue)
        }
    }
    
    enum ReservationStatus: String, Codable {
        case requested = "requested"
        case confirmed = "confirmed"
        case cancelled = "cancelled"
        case completed = "completed"
    }
}

struct OrderItem: Codable {
    let dish: Dish
    let quantity: Int
    let selectedOptions: [String: String]
}

struct CustomerInfo: Codable {
    let name: String
    let phone: String
    let email: String
    let address: String
}

struct Order: Identifiable, Codable {
    let id = UUID()
    let customerInfo: CustomerInfo
    let items: [OrderItem]
    let subtotal: Int
    let discount: Int
    let total: Int
    let status: OrderStatus
    let deliveryTime: DeliveryTime
    let deliveryInstructions: String
    let createdAt: Date
    
    enum DeliveryTime: String, CaseIterable, Codable {
        case asap = "asap"
        case time1 = "30分後"
        case time2 = "1時間後"
        case time3 = "1時間30分後"
        case time4 = "2時間後"
        
        var estimatedMinutes: Int {
            switch self {
            case .asap: return 25
            case .time1: return 30
            case .time2: return 60
            case .time3: return 90
            case .time4: return 120
            }
        }
    }
    
    enum OrderStatus: String, Codable {
        case pending = "pending"
        case preparing = "preparing"
        case ready = "ready"
        case delivering = "delivering"
        case delivered = "delivered"
        case cancelled = "cancelled"
    }
}

extension Coupon {
    static let sampleCoupons = [
        Coupon(
            title: "新規登録特典",
            description: "初回注文で使える500円割引クーポン",
            discountType: .fixedAmount,
            discountValue: 500,
            minimumAmount: 2000,
            expiryDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date(),
            isUsed: false,
            code: "WELCOME500"
        ),
        Coupon(
            title: "週末限定",
            description: "土日の注文で20%OFF！",
            discountType: .percentage,
            discountValue: 20,
            minimumAmount: 1500,
            expiryDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
            isUsed: false,
            code: "WEEKEND20"
        ),
        Coupon(
            title: "リピーター感謝",
            description: "3回目以降のご注文で300円割引",
            discountType: .fixedAmount,
            discountValue: 300,
            minimumAmount: 1000,
            expiryDate: Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date(),
            isUsed: false,
            code: "REPEAT300"
        ),
        Coupon(
            title: "大口注文特典",
            description: "5000円以上のご注文で送料無料",
            discountType: .freeShipping,
            discountValue: 0,
            minimumAmount: 5000,
            expiryDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date(),
            isUsed: false,
            code: "FREESHIP"
        ),
        Coupon(
            title: "期間限定セール",
            description: "全メニュー15%OFF（使用済み）",
            discountType: .percentage,
            discountValue: 15,
            minimumAmount: nil,
            expiryDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
            isUsed: true,
            code: "SALE15"
        )
    ]
}

// MARK: - Custom Components
struct SpicyIndicator: View {
    let level: Int
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { index in
                Image(systemName: "flame.fill")
                    .font(.caption2)
                    .foregroundColor(index < level ? DesignSystem.spicyColors[level] ?? .gray : Color.gray.opacity(0.3))
            }
            Text("辛さ\(level)")
                .font(.caption2)
                .foregroundColor(DesignSystem.textSecondary)
        }
    }
}

struct DishCard: View {
    let dish: Dish
    let size: CGSize
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.spacing.s) {
            // Image
            Image(dish.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
            .frame(width: size.width, height: size.height * 0.6)
            .clipped()
            .cornerRadius(DesignSystem.cornerRadius.card)
            
            VStack(alignment: .leading, spacing: DesignSystem.spacing.xs) {
                Text(dish.name)
                    .font(.headline)
                    .foregroundColor(DesignSystem.textPrimary)
                    .lineLimit(1)
                
                if dish.spicyLevel > 0 {
                    SpicyIndicator(level: dish.spicyLevel)
                }
                
                HStack {
                    Text("¥\(dish.price)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.primaryRed)
                    
                    Spacer()
                    
                    if dish.isVegetarian {
                        Image(systemName: "leaf.fill")
                            .font(.caption)
                            .foregroundColor(DesignSystem.accent)
                    }
                }
            }
            .padding(.horizontal, DesignSystem.spacing.s)
            .padding(.bottom, DesignSystem.spacing.s)
        }
        .background(Color.white)
        .cornerRadius(DesignSystem.cornerRadius.card)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

struct AsymmetricGrid: View {
    let dishes: [Dish]
    let isLoading: Bool
    @EnvironmentObject var cartManager: CartManager
    let columns = [
        GridItem(.flexible(), spacing: DesignSystem.spacing.m),
        GridItem(.flexible(), spacing: DesignSystem.spacing.m)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: DesignSystem.spacing.l) {
            ForEach(Array(dishes.enumerated()), id: \.element) { index, dish in
                let isLarge = index % 3 == 0
                let cardSize = CGSize(
                    width: isLarge ? 180 : 140,
                    height: isLarge ? 240 : 200
                )
                
                NavigationLink(destination: DishDetailView(dish: dish).environmentObject(cartManager)) {
                    DishCard(dish: dish, size: cardSize)
                        .offset(y: index % 2 == 0 ? 0 : 20)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, DesignSystem.spacing.l)
    }
}

struct HeroSection: View {
    @State private var currentImageIndex = 0
    let storeImages = ["店内イメージ１", "店内イメージ２", "店内イメージ３"]
    
    var body: some View {
        ZStack {
            // Background Image
            TabView(selection: $currentImageIndex) {
                ForEach(0..<storeImages.count, id: \.self) { index in
                    Image(storeImages[index])
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
                    withAnimation(.easeInOut(duration: 0.8)) {
                        currentImageIndex = (currentImageIndex + 1) % storeImages.count
                    }
                }
            }
            
            // Gradient Overlay
            LinearGradient(
                colors: [Color.black.opacity(0.6), Color.clear, Color.black.opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Content
            VStack(spacing: DesignSystem.spacing.xl) {
                Spacer()
                
                VStack(spacing: DesignSystem.spacing.m) {
                    Text("Tomyum Kitchen")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("本格タイ料理の温かい味わい")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
            }
            .padding(DesignSystem.spacing.xl)
        }
        .frame(height: 400)
    }
}

// MARK: - Main Views
struct HomeView: View {
    let dishes: [Dish]
    let isLoading: Bool
    
    var featuredDishes: [Dish] {
        Array(dishes.prefix(6))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ZStack {
                    HeroSection()
                    
                    // Navigation Links overlay
        VStack {
                        Spacer()
                        
                        HStack(spacing: DesignSystem.spacing.l) {
                            NavigationLink(destination: MenuView(dishes: dishes, isLoading: isLoading)) {
                                HStack {
                                    Image(systemName: "menucard.fill")
                                    Text("メニュー")
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, DesignSystem.spacing.xl)
                                .padding(.vertical, DesignSystem.spacing.m)
                                .background(DesignSystem.primaryRed)
                                .cornerRadius(DesignSystem.cornerRadius.button)
                            }
                            
                            NavigationLink(destination: ReservationView()) {
                                HStack {
                                    Image(systemName: "calendar")
                                    Text("予約")
                                }
                                .foregroundColor(DesignSystem.primaryRed)
                                .padding(.horizontal, DesignSystem.spacing.xl)
                                .padding(.vertical, DesignSystem.spacing.m)
                                .background(.white)
                                .cornerRadius(DesignSystem.cornerRadius.button)
                            }
                        }
                        .padding(.bottom, DesignSystem.spacing.xl)
                    }
                }
                .padding(.bottom, DesignSystem.spacing.xxl)
                
                VStack(alignment: .leading, spacing: DesignSystem.spacing.l) {
                    HStack {
                        Text("人気メニュー")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.textPrimary)
                        
                        Spacer()
                        
                        NavigationLink("すべて見る", destination: MenuView(dishes: self.dishes, isLoading: self.isLoading))
                            .font(.subheadline)
                            .foregroundColor(DesignSystem.primaryRed)
                    }
                    .padding(.horizontal, DesignSystem.spacing.l)
                    
                    AsymmetricGrid(dishes: featuredDishes, isLoading: isLoading)
                }
            }
            .padding(.bottom, 100) // タブバーとの余白を確保
        }
        .edgesIgnoringSafeArea(.top)
        .background(DesignSystem.background)
        .navigationBarHidden(true)
    }
}

struct MenuView: View {
    let dishes: [Dish]
    let isLoading: Bool
    @State private var selectedCategory = "すべて"
    let categories = ["すべて", "カレー", "麺", "ご飯", "前菜", "サラダ", "デザート"]
    
    var filteredDishes: [Dish] {
        if selectedCategory == "すべて" {
            return dishes
        }
        return dishes.filter { $0.category == selectedCategory }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Category Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.spacing.m) {
                    ForEach(categories, id: \.self) { category in
                        Button(action: {
                            withAnimation(.easeInOut) {
                                selectedCategory = category
                            }
                        }) {
                            Text(category)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(selectedCategory == category ? .white : DesignSystem.primaryRed)
                                .padding(.horizontal, DesignSystem.spacing.l)
                                .padding(.vertical, DesignSystem.spacing.s)
                                .background(
                                    selectedCategory == category ? DesignSystem.primaryRed : Color.clear
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: DesignSystem.cornerRadius.pill)
                                        .stroke(DesignSystem.primaryRed, lineWidth: 1)
                                )
                                .cornerRadius(DesignSystem.cornerRadius.pill)
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.spacing.l)
            }
            .padding(.vertical, DesignSystem.spacing.l)
            
            // Menu Grid
            ScrollView {
                AsymmetricGrid(dishes: filteredDishes, isLoading: isLoading)
                    .padding(.bottom, 120) // タブバーとの余白を確保
            }
        }
        .background(DesignSystem.background)
        .navigationTitle("メニュー")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct DishDetailView: View {
    let dish: Dish
    @State private var quantity = 1
    @State private var selectedSpicyLevel = 3
    @State private var includeCilantro = true
    @State private var riceSize = "普通"
    @State private var showingAddedToCart = false
    @EnvironmentObject var cartManager: CartManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Image
                Image(dish.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                .frame(height: 300)
                .clipped()
                
                // Content
                VStack(alignment: .leading, spacing: DesignSystem.spacing.l) {
                    // Title & Price
                    VStack(alignment: .leading, spacing: DesignSystem.spacing.s) {
                        Text(dish.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.textPrimary)
                        
                        HStack {
                            Text("¥\(dish.price)")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(DesignSystem.primaryRed)
                            
                            Spacer()
                            
                            if dish.spicyLevel > 0 {
                                SpicyIndicator(level: dish.spicyLevel)
                            }
                            
                            if dish.isVegetarian {
                                HStack(spacing: 4) {
                                    Image(systemName: "leaf.fill")
                                        .foregroundColor(DesignSystem.accent)
                                    Text("ベジタリアン")
                                        .font(.caption)
                                        .foregroundColor(DesignSystem.accent)
                                }
                            }
                        }
                    }
                    
                    // Description
                    Text(dish.detailedDescription)
                        .font(.body)
                        .foregroundColor(DesignSystem.textSecondary)
                        .lineSpacing(4)
                    
                    // Nutrition & Info Cards
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: DesignSystem.spacing.m) {
                        // Calories Card
                        VStack(spacing: DesignSystem.spacing.xs) {
                            Image(systemName: "flame.fill")
                                .font(.title2)
                                .foregroundColor(DesignSystem.gold)
                            
                            Text("\(dish.calories)")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(DesignSystem.textPrimary)
                            
                            Text("カロリー")
                                .font(.caption)
                                .foregroundColor(DesignSystem.textSecondary)
                        }
                        .padding(DesignSystem.spacing.m)
                        .background(Color.white)
                        .cornerRadius(DesignSystem.cornerRadius.card)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        
                        // Cooking Time Card
                        VStack(spacing: DesignSystem.spacing.xs) {
                            Image(systemName: "clock.fill")
                                .font(.title2)
                                .foregroundColor(DesignSystem.accent)
                            
                            Text(dish.cookingTime)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(DesignSystem.textPrimary)
                            
                            Text("調理時間")
                                .font(.caption)
                                .foregroundColor(DesignSystem.textSecondary)
                        }
                        .padding(DesignSystem.spacing.m)
                        .background(Color.white)
                        .cornerRadius(DesignSystem.cornerRadius.card)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                    
                    // Nutrition Information
                    VStack(alignment: .leading, spacing: DesignSystem.spacing.m) {
                        Text("栄養成分（1人前あたり）")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.textPrimary)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: DesignSystem.spacing.s) {
                            NutritionItem(label: "タンパク質", value: dish.nutritionInfo.protein, color: DesignSystem.primaryRed)
                            NutritionItem(label: "脂質", value: dish.nutritionInfo.fat, color: DesignSystem.gold)
                            NutritionItem(label: "炭水化物", value: dish.nutritionInfo.carbs, color: DesignSystem.accent)
                            NutritionItem(label: "塩分", value: dish.nutritionInfo.sodium, color: Color.purple)
                        }
                    }
                    .padding(DesignSystem.spacing.l)
                    .background(Color.white)
                    .cornerRadius(DesignSystem.cornerRadius.card)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    
                    // Ingredients
                    VStack(alignment: .leading, spacing: DesignSystem.spacing.m) {
                        Text("主な材料")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.textPrimary)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: DesignSystem.spacing.s) {
                            ForEach(dish.ingredients, id: \.self) { ingredient in
                                Text(ingredient)
                                    .font(.subheadline)
                                    .foregroundColor(DesignSystem.textPrimary)
                                    .padding(.horizontal, DesignSystem.spacing.s)
                                    .padding(.vertical, DesignSystem.spacing.xs)
                                    .background(DesignSystem.background)
                                    .cornerRadius(DesignSystem.cornerRadius.pill)
                            }
                        }
                    }
                    .padding(DesignSystem.spacing.l)
                    .background(Color.white)
                    .cornerRadius(DesignSystem.cornerRadius.card)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    
                    // Allergens
                    if !dish.allergens.isEmpty {
                        VStack(alignment: .leading, spacing: DesignSystem.spacing.s) {
                            Text("アレルゲン")
                                .font(.headline)
                                .foregroundColor(DesignSystem.textPrimary)
                            
                            HStack {
                                ForEach(dish.allergens, id: \.self) { allergen in
                                    Text(allergen)
                                        .font(.caption)
                                        .padding(.horizontal, DesignSystem.spacing.s)
                                        .padding(.vertical, DesignSystem.spacing.xs)
                                        .background(Color.red.opacity(0.1))
                                        .foregroundColor(.red)
                                        .cornerRadius(DesignSystem.cornerRadius.pill)
                                }
                                Spacer()
                            }
                        }
                    }
                    
                    // Customization Options
                    VStack(alignment: .leading, spacing: DesignSystem.spacing.l) {
                        Text("カスタマイズ")
                            .font(.headline)
                            .foregroundColor(DesignSystem.textPrimary)
                        
                        // Spicy Level
                        if dish.spicyLevel > 0 {
                            VStack(alignment: .leading, spacing: DesignSystem.spacing.s) {
                                Text("辛さレベル")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                HStack {
                                    ForEach(1...5, id: \.self) { level in
                                        Button(action: {
                                            selectedSpicyLevel = level
                                        }) {
                                            HStack(spacing: 4) {
                                                Image(systemName: "flame.fill")
                                                    .font(.caption)
                                                Text("\(level)")
                                                    .font(.caption)
                                            }
                                            .foregroundColor(selectedSpicyLevel == level ? .white : DesignSystem.primaryRed)
                                            .padding(.horizontal, DesignSystem.spacing.s)
                                            .padding(.vertical, DesignSystem.spacing.xs)
                                            .background(selectedSpicyLevel == level ? DesignSystem.primaryRed : Color.clear)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: DesignSystem.cornerRadius.button)
                                                    .stroke(DesignSystem.primaryRed, lineWidth: 1)
                                            )
                                            .cornerRadius(DesignSystem.cornerRadius.button)
                                        }
                                    }
                                    Spacer()
                                }
                            }
                        }
                        
                        // Cilantro
                        HStack {
                            Text("パクチー")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Toggle("", isOn: $includeCilantro)
                                .tint(DesignSystem.accent)
                        }
                        
                        // Rice Size (for rice dishes)
                        if dish.category == "ご飯" {
                            VStack(alignment: .leading, spacing: DesignSystem.spacing.s) {
                                Text("ご飯の量")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                HStack {
                                    ForEach(["少なめ", "普通", "大盛り"], id: \.self) { size in
                                        Button(action: {
                                            riceSize = size
                                        }) {
                                            Text(size)
                                                .font(.subheadline)
                                                .foregroundColor(riceSize == size ? .white : DesignSystem.primaryRed)
                                                .padding(.horizontal, DesignSystem.spacing.l)
                                                .padding(.vertical, DesignSystem.spacing.s)
                                                .background(riceSize == size ? DesignSystem.primaryRed : Color.clear)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: DesignSystem.cornerRadius.pill)
                                                        .stroke(DesignSystem.primaryRed, lineWidth: 1)
                                                )
                                                .cornerRadius(DesignSystem.cornerRadius.pill)
                                        }
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }
                    
                    // Quantity
                    HStack {
                        Text("数量")
                            .font(.headline)
                            .foregroundColor(DesignSystem.textPrimary)
                        
                        Spacer()
                        
                        HStack(spacing: DesignSystem.spacing.l) {
                            Button(action: {
                                if quantity > 1 {
                                    quantity -= 1
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(quantity > 1 ? DesignSystem.primaryRed : Color.gray.opacity(0.5))
                            }
                            .disabled(quantity <= 1)
                            
                            Text("\(quantity)")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .frame(minWidth: 30)
                            
                            Button(action: {
                                quantity += 1
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(DesignSystem.primaryRed)
                            }
                        }
                    }
                }
                .padding(DesignSystem.spacing.l)
                .padding(.bottom, 140) // CTAボタンとタブバーのスペース
            }
        }
        .background(DesignSystem.background)
        .navigationBarTitleDisplayMode(.inline)
        .overlay(
            // Fixed CTA Bar
        VStack {
                Spacer()
                
                Button(action: {
                    // カートに追加
                    cartManager.addToCart(dish: dish, quantity: quantity)
                    
                    withAnimation(.spring()) {
                        showingAddedToCart = true
                    }
                    
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            showingAddedToCart = false
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "cart.fill.badge.plus")
                        Text("カートに追加 - ¥\(dish.price * quantity)")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.spacing.l)
                    .background(DesignSystem.primaryRed)
                    .cornerRadius(DesignSystem.cornerRadius.button)
                }
                .padding(.horizontal, DesignSystem.spacing.l)
                .padding(.bottom, DesignSystem.spacing.l)
                .background(
                    LinearGradient(
                        colors: [Color.clear, DesignSystem.background.opacity(0.8), DesignSystem.background],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        )
        .overlay(
            // Success Toast
            VStack {
                if showingAddedToCart {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("カートに追加しました")
                            .fontWeight(.medium)
        }
        .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(DesignSystem.cornerRadius.card)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                Spacer()
            }
            .padding(.top, 50)
        )
    }
}

struct StoreInfoView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.spacing.xxl) {
                // Store Images
                TabView {
                    ForEach(["店内イメージ１", "店内イメージ２", "店内イメージ３"], id: \.self) { imageName in
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 250)
                            .clipped()
                            .cornerRadius(DesignSystem.cornerRadius.card)
                    }
                }
                .frame(height: 250)
                .tabViewStyle(PageTabViewStyle())
                .padding(.horizontal, DesignSystem.spacing.l)
                
                VStack(spacing: DesignSystem.spacing.xl) {
                    // Store Info
                    VStack(alignment: .leading, spacing: DesignSystem.spacing.l) {
                        Text("店舗情報")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.textPrimary)
                        
                        VStack(spacing: DesignSystem.spacing.l) {
                            InfoRow(icon: "mappin.and.ellipse", title: "住所", content: "東京都渋谷区〇〇 1-2-3")
                            InfoRow(icon: "phone.fill", title: "電話", content: "03-1234-5678")
                            InfoRow(icon: "clock.fill", title: "営業時間", content: "11:00 - 22:00 (L.O. 21:30)")
                            InfoRow(icon: "calendar", title: "定休日", content: "月曜日")
                        }
                    }
                    
                    // Action Buttons
                    VStack(spacing: DesignSystem.spacing.m) {
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "map.fill")
                                Text("地図で見る")
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DesignSystem.spacing.m)
                            .background(DesignSystem.primaryRed)
                            .cornerRadius(DesignSystem.cornerRadius.button)
                        }
                        
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "phone.fill")
                                Text("電話をかける")
                            }
                            .foregroundColor(DesignSystem.primaryRed)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DesignSystem.spacing.m)
                            .background(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.cornerRadius.button)
                                    .stroke(DesignSystem.primaryRed, lineWidth: 1)
                            )
                            .cornerRadius(DesignSystem.cornerRadius.button)
                        }
                    }
                    
                    // SNS Links
                    VStack(alignment: .leading, spacing: DesignSystem.spacing.l) {
                        Text("SNS")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.textPrimary)
                        
                        HStack(spacing: DesignSystem.spacing.l) {
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "camera.fill")
                                    Text("Instagram")
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, DesignSystem.spacing.l)
                                .padding(.vertical, DesignSystem.spacing.s)
                                .background(
                                    LinearGradient(
                                        colors: [Color.purple, Color.pink, Color.orange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(DesignSystem.cornerRadius.button)
                            }
                            
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "message.fill")
                                    Text("LINE")
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, DesignSystem.spacing.l)
                                .padding(.vertical, DesignSystem.spacing.s)
                                .background(Color(red: 0.02, green: 0.78, blue: 0.33)) // LINE Green
                                .cornerRadius(DesignSystem.cornerRadius.button)
                            }
                            
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.spacing.l)
            }
            .padding(.bottom, 120) // タブバーとの余白を確保
        }
        .background(DesignSystem.background)
        .navigationTitle("店舗情報")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct NutritionItem: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: DesignSystem.spacing.xs) {
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(DesignSystem.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, DesignSystem.spacing.s)
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.1))
        .cornerRadius(DesignSystem.cornerRadius.button)
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let content: String
    
    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.spacing.m) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(DesignSystem.primaryRed)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: DesignSystem.spacing.xs) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.textSecondary)
                
                Text(content)
                    .font(.body)
                    .foregroundColor(DesignSystem.textPrimary)
            }
            
            Spacer()
        }
        .padding(.vertical, DesignSystem.spacing.s)
    }
}

struct CouponCard: View {
    let coupon: Coupon
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.spacing.m) {
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.spacing.xs) {
                    Text(coupon.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(coupon.isAvailable ? DesignSystem.textPrimary : DesignSystem.textSecondary)
                    
                    Text(coupon.description)
                        .font(.subheadline)
                        .foregroundColor(DesignSystem.textSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: DesignSystem.spacing.xs) {
                    Text(coupon.discountText)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(coupon.isAvailable ? DesignSystem.primaryRed : .gray)
                    
                    if !coupon.isAvailable {
                        Text(coupon.isUsed ? "使用済み" : "期限切れ")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal, DesignSystem.spacing.s)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(DesignSystem.cornerRadius.pill)
                    }
                }
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.spacing.xs) {
                    Text("クーポンコード")
                        .font(.caption)
                        .foregroundColor(DesignSystem.textSecondary)
                    
                    Text(coupon.code)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.textPrimary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: DesignSystem.spacing.xs) {
                    Text("有効期限")
                        .font(.caption)
                        .foregroundColor(DesignSystem.textSecondary)
                    
                    Text(coupon.expiryDate, style: .date)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(coupon.isExpired ? .red : DesignSystem.textPrimary)
                }
            }
            
            if let minimumAmount = coupon.minimumAmount {
                Text("※ \(minimumAmount)円以上のご注文で利用可能")
                    .font(.caption)
                    .foregroundColor(DesignSystem.textSecondary)
            }
        }
        .padding(DesignSystem.spacing.l)
        .background(coupon.isAvailable ? Color.white : Color.gray.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.cornerRadius.card)
                .stroke(
                    coupon.isAvailable ? DesignSystem.primaryRed.opacity(0.3) : Color.gray.opacity(0.3),
                    lineWidth: 1
                )
        )
        .cornerRadius(DesignSystem.cornerRadius.card)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            if coupon.isAvailable {
                withAnimation {
                    isPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        isPressed = false
                    }
                }
            }
        }
    }
}

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    @State private var selectedCoupon: Coupon?
    @State private var showingCouponSelection = false
    
    var subtotal: Int {
        cartManager.subtotal
    }
    
    var discount: Int {
        guard let coupon = selectedCoupon else { return 0 }
        
        switch coupon.discountType {
        case .percentage:
            return subtotal * coupon.discountValue / 100
        case .fixedAmount:
            return min(coupon.discountValue, subtotal)
        case .freeShipping:
            return 300 // 送料
        }
    }
    
    var total: Int {
        subtotal - discount + (selectedCoupon?.discountType == .freeShipping ? 0 : 300)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if cartManager.cartItems.isEmpty {
                VStack(spacing: DesignSystem.spacing.xl) {
                    Spacer()
                    
                    Image(systemName: "cart")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("カートは空です")
                        .font(.title2)
                        .foregroundColor(DesignSystem.textSecondary)
                    
                    Text("メニューから商品を追加してください")
                        .font(.body)
                        .foregroundColor(DesignSystem.textSecondary)
                    
                    Spacer()
                }
            } else {
                ScrollView {
                    VStack(spacing: DesignSystem.spacing.l) {
                        // Cart Items
                        ForEach(Array(cartManager.cartItems.enumerated()), id: \.offset) { index, item in
                            CartItemRow(
                                dish: item.dish,
                                quantity: item.quantity,
                                onQuantityChange: { newQuantity in
                                    cartManager.updateQuantity(dish: item.dish, quantity: newQuantity)
                                }
                            )
                        }
                        
                        // Coupon Section
                        VStack(alignment: .leading, spacing: DesignSystem.spacing.m) {
                            Text("クーポン")
                                .font(.headline)
                                .foregroundColor(DesignSystem.textPrimary)
                            
                            Button(action: {
                                showingCouponSelection = true
                            }) {
                                HStack {
                                    if let coupon = selectedCoupon {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(coupon.title)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(DesignSystem.textPrimary)
                                            
                                            Text(coupon.discountText)
                                                .font(.caption)
                                                .foregroundColor(DesignSystem.primaryRed)
                                        }
                                    } else {
                                        Text("クーポンを選択")
                                            .font(.subheadline)
                                            .foregroundColor(DesignSystem.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding(DesignSystem.spacing.m)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: DesignSystem.cornerRadius.button)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .cornerRadius(DesignSystem.cornerRadius.button)
                            }
                        }
                        .padding(.horizontal, DesignSystem.spacing.l)
                        
                        // Order Summary
                        VStack(alignment: .leading, spacing: DesignSystem.spacing.m) {
                            Text("注文内容")
                                .font(.headline)
                                .foregroundColor(DesignSystem.textPrimary)
                            
                            VStack(spacing: DesignSystem.spacing.s) {
                                HStack {
                                    Text("小計")
                                    Spacer()
                                    Text("¥\(subtotal)")
                                }
                                
                                if discount > 0 {
                                    HStack {
                                        Text("割引")
                                        Spacer()
                                        Text("-¥\(discount)")
                                            .foregroundColor(DesignSystem.primaryRed)
                                    }
                                }
                                
                                HStack {
                                    Text("送料")
                                    Spacer()
                                    Text(selectedCoupon?.discountType == .freeShipping ? "無料" : "¥300")
                                        .foregroundColor(selectedCoupon?.discountType == .freeShipping ? DesignSystem.accent : DesignSystem.textPrimary)
                                }
                                
                                Divider()
                                
                                HStack {
                                    Text("合計")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    Spacer()
                                    Text("¥\(total)")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(DesignSystem.primaryRed)
                                }
                            }
                            .font(.subheadline)
                            .foregroundColor(DesignSystem.textPrimary)
                        }
                        .padding(DesignSystem.spacing.l)
                        .background(Color.white)
                        .cornerRadius(DesignSystem.cornerRadius.card)
                        .padding(.horizontal, DesignSystem.spacing.l)
                    }
                    .padding(.bottom, 140) // CTAボタンとタブバーのスペース
                }
                
                // Fixed CTA
                VStack {
                    Spacer()
                    
                    NavigationLink(destination: OrderConfirmationView(
                        cartItems: cartManager.cartItems,
                        selectedCoupon: selectedCoupon,
                        subtotal: subtotal,
                        discount: discount,
                        total: total
                    )) {
                        HStack {
                            Image(systemName: "creditcard.fill")
                            Text("注文する - ¥\(total)")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignSystem.spacing.l)
                        .background(DesignSystem.primaryRed)
                        .cornerRadius(DesignSystem.cornerRadius.button)
                    }
                    .padding(.horizontal, DesignSystem.spacing.l)
                    .padding(.bottom, DesignSystem.spacing.l)
                    .background(
                        LinearGradient(
                            colors: [Color.clear, DesignSystem.background.opacity(0.8), DesignSystem.background],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
        }
        .background(DesignSystem.background)
        .navigationTitle("カート")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingCouponSelection) {
            CouponSelectionView(selectedCoupon: $selectedCoupon)
        }
    }
}

struct CartItemRow: View {
    let dish: Dish
    let quantity: Int
    let onQuantityChange: (Int) -> Void
    
    var body: some View {
        HStack(spacing: DesignSystem.spacing.m) {
            Image(dish.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 60, height: 60)
                .clipped()
                .cornerRadius(DesignSystem.cornerRadius.button)
            
            VStack(alignment: .leading, spacing: DesignSystem.spacing.xs) {
                Text(dish.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.textPrimary)
                
                Text("¥\(dish.price)")
                    .font(.subheadline)
                    .foregroundColor(DesignSystem.primaryRed)
            }
            
            Spacer()
            
            HStack(spacing: DesignSystem.spacing.s) {
                Button(action: {
                    onQuantityChange(quantity - 1)
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                        .foregroundColor(quantity > 1 ? DesignSystem.primaryRed : Color.gray.opacity(0.5))
                }
                .disabled(quantity <= 1)
                
                Text("\(quantity)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(minWidth: 20)
                
                Button(action: {
                    onQuantityChange(quantity + 1)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(DesignSystem.primaryRed)
                }
            }
        }
        .padding(DesignSystem.spacing.m)
        .background(Color.white)
        .cornerRadius(DesignSystem.cornerRadius.card)
        .padding(.horizontal, DesignSystem.spacing.l)
    }
}

struct CouponSelectionView: View {
    @Binding var selectedCoupon: Coupon?
    @Environment(\.presentationMode) var presentationMode
    
    var availableCoupons: [Coupon] {
        Coupon.sampleCoupons.filter { $0.isAvailable }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(spacing: DesignSystem.spacing.l) {
                        ForEach(availableCoupons) { coupon in
                            Button(action: {
                                selectedCoupon = coupon
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                CouponCard(coupon: coupon)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DesignSystem.cornerRadius.card)
                                            .stroke(selectedCoupon?.id == coupon.id ? DesignSystem.primaryRed : Color.clear, lineWidth: 2)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, DesignSystem.spacing.l)
                    .padding(.vertical, DesignSystem.spacing.l)
                }
            }
            .background(DesignSystem.background)
            .navigationTitle("クーポンを選択")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("キャンセル") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("クリア") {
                    selectedCoupon = nil
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(selectedCoupon == nil)
            )
        }
    }
}

struct OrderConfirmationView: View {
    let cartItems: [(dish: Dish, quantity: Int)]
    let selectedCoupon: Coupon?
    let subtotal: Int
    let discount: Int
    let total: Int
    
    @StateObject private var firebaseService = FirebaseService()
    @State private var customerName = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var address = ""
    @State private var deliveryInstructions = ""
    @State private var selectedDeliveryTime = Order.DeliveryTime.asap
    @State private var showingOrderComplete = false
    @State private var isSubmitting = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.spacing.xl) {
                // Order Summary
                VStack(alignment: .leading, spacing: DesignSystem.spacing.l) {
                    Text("注文内容")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.textPrimary)
                    
                    ForEach(Array(cartItems.enumerated()), id: \.offset) { _, item in
                        HStack {
                            Text(item.dish.name)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("×\(item.quantity)")
                                .font(.subheadline)
                                .foregroundColor(DesignSystem.textSecondary)
                            
                            Text("¥\(item.dish.price * item.quantity)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(DesignSystem.primaryRed)
                        }
                    }
                    
                    Divider()
                    
                    VStack(spacing: DesignSystem.spacing.s) {
                        HStack {
                            Text("小計")
                            Spacer()
                            Text("¥\(subtotal)")
                        }
                        
                        if discount > 0 {
                            HStack {
                                Text("割引")
                                Spacer()
                                Text("-¥\(discount)")
                                    .foregroundColor(DesignSystem.primaryRed)
                            }
                        }
                        
                        HStack {
                            Text("送料")
                            Spacer()
                            Text(selectedCoupon?.discountType == .freeShipping ? "無料" : "¥300")
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("合計")
                                .font(.headline)
                                .fontWeight(.bold)
                            Spacer()
                            Text("¥\(total)")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(DesignSystem.primaryRed)
                        }
                    }
                    .font(.subheadline)
                }
                .padding(DesignSystem.spacing.l)
                .background(Color.white)
                .cornerRadius(DesignSystem.cornerRadius.card)
                
                // Customer Information
                VStack(alignment: .leading, spacing: DesignSystem.spacing.l) {
                    Text("お客様情報")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.textPrimary)
                    
                    VStack(spacing: DesignSystem.spacing.m) {
                        CustomTextField(title: "お名前", text: $customerName, placeholder: "山田太郎")
                        CustomTextField(title: "電話番号", text: $phoneNumber, placeholder: "090-1234-5678")
                        CustomTextField(title: "メールアドレス", text: $email, placeholder: "example@email.com")
                        CustomTextField(title: "配達先住所", text: $address, placeholder: "東京都渋谷区〇〇 1-2-3")
                        CustomTextField(title: "配達メモ", text: $deliveryInstructions, placeholder: "オートロック番号など（任意）")
                    }
                }
                .padding(DesignSystem.spacing.l)
                .background(Color.white)
                .cornerRadius(DesignSystem.cornerRadius.card)
                
                // Delivery Time
                VStack(alignment: .leading, spacing: DesignSystem.spacing.l) {
                    Text("配達時間")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.textPrimary)
                    
                    VStack(spacing: DesignSystem.spacing.s) {
                        ForEach(Order.DeliveryTime.allCases, id: \.self) { time in
                            Button(action: {
                                selectedDeliveryTime = time
                            }) {
                                HStack {
                                    Text(time.rawValue)
                                        .font(.subheadline)
                                        .foregroundColor(DesignSystem.textPrimary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: selectedDeliveryTime == time ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedDeliveryTime == time ? DesignSystem.primaryRed : .gray)
                                }
                                .padding(.vertical, DesignSystem.spacing.s)
                            }
                        }
                    }
                }
                .padding(DesignSystem.spacing.l)
                .background(Color.white)
                .cornerRadius(DesignSystem.cornerRadius.card)
            }
            .padding(.horizontal, DesignSystem.spacing.l)
            .padding(.bottom, 140) // CTAボタンとタブバーのスペース
        }
        .background(DesignSystem.background)
        .navigationTitle("注文確認")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(
            VStack {
                Spacer()
                
                Button(action: {
                    submitOrder()
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("注文を確定する")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.spacing.l)
                    .background(isFormValid ? DesignSystem.primaryRed : Color.gray)
                    .cornerRadius(DesignSystem.cornerRadius.button)
                }
                .disabled(!isFormValid)
                .padding(.horizontal, DesignSystem.spacing.l)
                .padding(.bottom, DesignSystem.spacing.l)
                .background(
                    LinearGradient(
                        colors: [Color.clear, DesignSystem.background.opacity(0.8), DesignSystem.background],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        )
        .sheet(isPresented: $showingOrderComplete) {
            OrderCompleteView()
        }
    }
    
    var isFormValid: Bool {
        !customerName.isEmpty && !phoneNumber.isEmpty && !email.isEmpty && !address.isEmpty
    }
    
    private func submitOrder() {
        guard isFormValid && !isSubmitting else { return }
        
        isSubmitting = true
        
        let customerInfo = CustomerInfo(
            name: customerName,
            phone: phoneNumber,
            email: email,
            address: address
        )
        
        let orderItems = cartItems.map { item in
            OrderItem(
                dish: item.dish,
                quantity: item.quantity,
                selectedOptions: [:] // カスタマイズオプションは将来実装
            )
        }
        
        let order = Order(
            customerInfo: customerInfo,
            items: orderItems,
            subtotal: subtotal,
            discount: discount,
            total: total,
            status: .pending,
            deliveryTime: selectedDeliveryTime,
            deliveryInstructions: deliveryInstructions,
            createdAt: Date()
        )
        
        Task {
            do {
                let orderId = try await firebaseService.createOrder(order)
                print("Order created with ID: \(orderId)")
                
                await MainActor.run {
                    showingOrderComplete = true
                    isSubmitting = false
                }
            } catch {
                print("Error creating order: \(error)")
                await MainActor.run {
                    isSubmitting = false
                    // エラーハンドリング（アラート表示など）
                }
            }
        }
    }
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.spacing.xs) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(DesignSystem.textPrimary)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct OrderCompleteView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: DesignSystem.spacing.xl) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            VStack(spacing: DesignSystem.spacing.m) {
                Text("ご注文ありがとうございます！")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.textPrimary)
                
                Text("注文番号: #TK\(Int.random(in: 1000...9999))")
                    .font(.headline)
                    .foregroundColor(DesignSystem.primaryRed)
                
                Text("配達予定時刻: \(Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date(), style: .time)")
                    .font(.subheadline)
                    .foregroundColor(DesignSystem.textSecondary)
            }
            
            VStack(spacing: DesignSystem.spacing.s) {
                Text("調理が開始されました")
                    .font(.body)
                    .foregroundColor(DesignSystem.textPrimary)
                
                Text("配達状況はアプリでご確認いただけます")
                    .font(.caption)
                    .foregroundColor(DesignSystem.textSecondary)
            }
            
            Spacer()
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("閉じる")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.spacing.l)
                    .background(DesignSystem.primaryRed)
                    .cornerRadius(DesignSystem.cornerRadius.button)
            }
            .padding(.horizontal, DesignSystem.spacing.l)
        }
        .padding(DesignSystem.spacing.xl)
        .background(DesignSystem.background)
    }
}

struct ReservationView: View {
    @StateObject private var firebaseService = FirebaseService()
    @State private var customerName = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var partySize = 2
    @State private var selectedDate = Date()
    @State private var selectedTimeSlot = Reservation.TimeSlot.dinner1800
    @State private var specialRequests = ""
    @State private var showingReservationComplete = false
    @State private var isSubmitting = false
    
    var availableTimeSlots: [Reservation.TimeSlot] {
        let calendar = Calendar.current
        let selectedDateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let today = calendar.dateComponents([.year, .month, .day], from: Date())
        
        // 今日の場合は現在時刻以降のスロットのみ表示
        if selectedDateComponents == today {
            let currentHour = calendar.component(.hour, from: Date())
            return Reservation.TimeSlot.allCases.filter { slot in
                let slotHour = Int(slot.rawValue.prefix(2)) ?? 0
                return slotHour > currentHour
            }
        } else {
            return Reservation.TimeSlot.allCases
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.spacing.xl) {
                // Header
                VStack(spacing: DesignSystem.spacing.m) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 40))
                        .foregroundColor(DesignSystem.primaryRed)
                    
                    Text("席予約")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.textPrimary)
                    
                    Text("本格タイ料理をゆっくりとお楽しみください")
                        .font(.subheadline)
                        .foregroundColor(DesignSystem.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, DesignSystem.spacing.l)
                
                // Customer Information
                VStack(alignment: .leading, spacing: DesignSystem.spacing.l) {
                    Text("お客様情報")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.textPrimary)
                    
                    VStack(spacing: DesignSystem.spacing.m) {
                        CustomTextField(title: "お名前", text: $customerName, placeholder: "山田太郎")
                        CustomTextField(title: "電話番号", text: $phoneNumber, placeholder: "090-1234-5678")
                        CustomTextField(title: "メールアドレス", text: $email, placeholder: "example@email.com")
                    }
                }
                .padding(DesignSystem.spacing.l)
                .background(Color.white)
                .cornerRadius(DesignSystem.cornerRadius.card)
                
                // Reservation Details
                VStack(alignment: .leading, spacing: DesignSystem.spacing.l) {
                    Text("予約詳細")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.textPrimary)
                    
                    VStack(spacing: DesignSystem.spacing.m) {
                        // Party Size
                        VStack(alignment: .leading, spacing: DesignSystem.spacing.xs) {
                            Text("人数")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(DesignSystem.textPrimary)
                            
                            HStack {
                                ForEach(1...8, id: \.self) { size in
                                    Button(action: {
                                        partySize = size
                                    }) {
                                        Text("\(size)名")
                                            .font(.subheadline)
                                            .foregroundColor(partySize == size ? .white : DesignSystem.primaryRed)
                                            .padding(.horizontal, DesignSystem.spacing.m)
                                            .padding(.vertical, DesignSystem.spacing.s)
                                            .background(partySize == size ? DesignSystem.primaryRed : Color.clear)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: DesignSystem.cornerRadius.button)
                                                    .stroke(DesignSystem.primaryRed, lineWidth: 1)
                                            )
                                            .cornerRadius(DesignSystem.cornerRadius.button)
                                    }
                                }
                                Spacer()
                            }
                        }
                        
                        // Date Selection
                        VStack(alignment: .leading, spacing: DesignSystem.spacing.xs) {
                            Text("日付")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(DesignSystem.textPrimary)
                            
                            DatePicker("", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .onChange(of: selectedDate) { _ in
                                    // 日付変更時に利用可能な時間スロットをチェック
                                    if !availableTimeSlots.contains(selectedTimeSlot) {
                                        selectedTimeSlot = availableTimeSlots.first ?? .dinner1800
                                    }
                                }
                        }
                        
                        // Time Selection
                        VStack(alignment: .leading, spacing: DesignSystem.spacing.xs) {
                            Text("時間")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(DesignSystem.textPrimary)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: DesignSystem.spacing.s) {
                                ForEach(availableTimeSlots, id: \.self) { slot in
                                    Button(action: {
                                        selectedTimeSlot = slot
                                    }) {
                                        VStack(spacing: 2) {
                                            Text(slot.displayName)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            
                                            Text(slot.isLunchTime ? "ランチ" : "ディナー")
                                                .font(.caption2)
                                        }
                                        .foregroundColor(selectedTimeSlot == slot ? .white : DesignSystem.primaryRed)
                                        .padding(.vertical, DesignSystem.spacing.s)
                                        .frame(maxWidth: .infinity)
                                        .background(selectedTimeSlot == slot ? DesignSystem.primaryRed : Color.clear)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: DesignSystem.cornerRadius.button)
                                                .stroke(DesignSystem.primaryRed, lineWidth: 1)
                                        )
                                        .cornerRadius(DesignSystem.cornerRadius.button)
                                    }
                                }
                            }
                        }
                        
                        // Special Requests
                        VStack(alignment: .leading, spacing: DesignSystem.spacing.xs) {
                            Text("ご要望（任意）")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(DesignSystem.textPrimary)
                            
                            TextField("アレルギーや席の希望など", text: $specialRequests, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(3, reservesSpace: true)
                        }
                    }
                }
                .padding(DesignSystem.spacing.l)
                .background(Color.white)
                .cornerRadius(DesignSystem.cornerRadius.card)
                
                // Important Notes
                VStack(alignment: .leading, spacing: DesignSystem.spacing.s) {
                    Text("ご予約について")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.textPrimary)
                    
                    VStack(alignment: .leading, spacing: DesignSystem.spacing.xs) {
                        Text("• 予約確定後、確認のお電話をさせていただく場合があります")
                        Text("• 15分以上の遅刻の場合、お席をお取りできない場合があります")
                        Text("• キャンセルは前日までにお願いいたします")
                    }
                    .font(.caption)
                    .foregroundColor(DesignSystem.textSecondary)
                }
                .padding(DesignSystem.spacing.l)
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(DesignSystem.cornerRadius.card)
            }
            .padding(.horizontal, DesignSystem.spacing.l)
            .padding(.bottom, 140) // CTAボタンとタブバーのスペース
        }
        .background(DesignSystem.background)
        .navigationTitle("予約")
        .navigationBarTitleDisplayMode(.large)
        .overlay(
            VStack {
                Spacer()
                
                Button(action: {
                    submitReservation()
                }) {
                    HStack {
                        Image(systemName: "calendar.badge.checkmark")
                        Text("予約を確定する")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.spacing.l)
                    .background(isReservationFormValid ? DesignSystem.primaryRed : Color.gray)
                    .cornerRadius(DesignSystem.cornerRadius.button)
                }
                .disabled(!isReservationFormValid)
                .padding(.horizontal, DesignSystem.spacing.l)
                .padding(.bottom, DesignSystem.spacing.l)
                .background(
                    LinearGradient(
                        colors: [Color.clear, DesignSystem.background.opacity(0.8), DesignSystem.background],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        )
        .sheet(isPresented: $showingReservationComplete) {
            ReservationCompleteView(
                customerName: customerName,
                partySize: partySize,
                date: selectedDate,
                timeSlot: selectedTimeSlot
            )
        }
    }
    
    var isReservationFormValid: Bool {
        !customerName.isEmpty && !phoneNumber.isEmpty && !email.isEmpty
    }
    
    private func submitReservation() {
        guard isReservationFormValid && !isSubmitting else { return }
        
        isSubmitting = true
        
        let reservation = Reservation(
            customerName: customerName,
            phone: phoneNumber,
            email: email,
            partySize: partySize,
            date: selectedDate,
            timeSlot: selectedTimeSlot,
            specialRequests: specialRequests,
            status: .requested,
            createdAt: Date()
        )
        
        Task {
            do {
                let reservationId = try await firebaseService.createReservation(reservation)
                print("Reservation created with ID: \(reservationId)")
                
                await MainActor.run {
                    showingReservationComplete = true
                    isSubmitting = false
                }
            } catch {
                print("Error creating reservation: \(error)")
                await MainActor.run {
                    isSubmitting = false
                    // エラーハンドリング（アラート表示など）
                }
            }
        }
    }
}

struct ReservationCompleteView: View {
    let customerName: String
    let partySize: Int
    let date: Date
    let timeSlot: Reservation.TimeSlot
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: DesignSystem.spacing.xl) {
            Spacer()
            
            Image(systemName: "calendar.badge.checkmark")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            VStack(spacing: DesignSystem.spacing.m) {
                Text("ご予約ありがとうございます！")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.textPrimary)
                
                Text("予約番号: #RS\(Int.random(in: 1000...9999))")
                    .font(.headline)
                    .foregroundColor(DesignSystem.primaryRed)
            }
            
            VStack(spacing: DesignSystem.spacing.l) {
                VStack(spacing: DesignSystem.spacing.s) {
                    Text("予約詳細")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.textPrimary)
                    
                    VStack(spacing: DesignSystem.spacing.xs) {
                        HStack {
                            Text("お名前:")
                            Spacer()
                            Text(customerName)
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text("人数:")
                            Spacer()
                            Text("\(partySize)名")
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text("日時:")
                            Spacer()
                            Text("\(date, style: .date) \(timeSlot.displayName)")
                                .fontWeight(.medium)
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(DesignSystem.textPrimary)
                }
                .padding(DesignSystem.spacing.l)
                .background(Color.white)
                .cornerRadius(DesignSystem.cornerRadius.card)
                
                Text("確認のお電話をさせていただく場合があります。\nご来店をお待ちしております！")
                    .font(.body)
                    .foregroundColor(DesignSystem.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("閉じる")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.spacing.l)
                    .background(DesignSystem.primaryRed)
                    .cornerRadius(DesignSystem.cornerRadius.button)
            }
            .padding(.horizontal, DesignSystem.spacing.l)
        }
        .padding(DesignSystem.spacing.xl)
        .background(DesignSystem.background)
    }
}

struct CouponView: View {
    @State private var selectedFilter = "利用可能"
    let filters = ["すべて", "利用可能", "使用済み", "期限切れ"]
    
    var filteredCoupons: [Coupon] {
        let coupons = Coupon.sampleCoupons
        
        switch selectedFilter {
        case "利用可能":
            return coupons.filter { $0.isAvailable }
        case "使用済み":
            return coupons.filter { $0.isUsed }
        case "期限切れ":
            return coupons.filter { $0.isExpired && !$0.isUsed }
        default:
            return coupons
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Filter Tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.spacing.m) {
                    ForEach(filters, id: \.self) { filter in
                        Button(action: {
                            withAnimation(.easeInOut) {
                                selectedFilter = filter
                            }
                        }) {
                            Text(filter)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(selectedFilter == filter ? .white : DesignSystem.primaryRed)
                                .padding(.horizontal, DesignSystem.spacing.l)
                                .padding(.vertical, DesignSystem.spacing.s)
                                .background(
                                    selectedFilter == filter ? DesignSystem.primaryRed : Color.clear
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: DesignSystem.cornerRadius.pill)
                                        .stroke(DesignSystem.primaryRed, lineWidth: 1)
                                )
                                .cornerRadius(DesignSystem.cornerRadius.pill)
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.spacing.l)
            }
            .padding(.vertical, DesignSystem.spacing.l)
            
            // Coupon List
            ScrollView {
                LazyVStack(spacing: DesignSystem.spacing.l) {
                    ForEach(filteredCoupons) { coupon in
                        CouponCard(coupon: coupon)
                    }
                }
                .padding(.horizontal, DesignSystem.spacing.l)
                .padding(.bottom, 120) // タブバーとの余白を確保
            }
        }
        .background(DesignSystem.background)
        .navigationTitle("クーポン")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ContentView: View {
    @StateObject private var cartManager = CartManager()
    @StateObject private var firebaseService = FirebaseService()
    @State private var dishes: [Dish] = []
    @State private var isLoading = true
    
    init() {
        // タブバーの背景設定
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor.white
        tabAppearance.shadowColor = UIColor.black.withAlphaComponent(0.1)
        
        // 選択時のアイテム色
        tabAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(DesignSystem.primaryRed)
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(DesignSystem.primaryRed)
        ]
        
        // 非選択時のアイテム色
        tabAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.gray
        ]
        
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        
        // ナビゲーションバーの背景設定
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor.white
        navAppearance.shadowColor = UIColor.black.withAlphaComponent(0.1)
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(DesignSystem.textPrimary)
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(DesignSystem.textPrimary)
        ]
        
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
    }
    
    var body: some View {
        TabView {
            NavigationView {
                HomeView(dishes: dishes, isLoading: isLoading)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .environmentObject(cartManager)
            .tabItem {
                Image(systemName: "house.fill")
                Text("ホーム")
            }
            
            NavigationView {
                MenuView(dishes: dishes, isLoading: isLoading)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .environmentObject(cartManager)
            .tabItem {
                Image(systemName: "menucard.fill")
                Text("メニュー")
            }
            
            NavigationView {
                CartView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .environmentObject(cartManager)
            .tabItem {
                Image(systemName: "cart.fill")
                Text("カート")
                if cartManager.totalItems > 0 {
                    Text("\(cartManager.totalItems)")
                }
            }
            
            NavigationView {
                CouponView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "ticket.fill")
                Text("クーポン")
            }
            
            NavigationView {
                StoreInfoView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "info.circle.fill")
                Text("店舗情報")
            }
        }
        .accentColor(DesignSystem.primaryRed)
        .preferredColorScheme(.light) // ダークモードを無効化
        .onAppear {
            loadFirebaseData()
        }
    }
    
    private func loadFirebaseData() {
        Task {
            do {
                let firebaseDishes = try await firebaseService.fetchDishes()
                await MainActor.run {
                    self.dishes = firebaseDishes.isEmpty ? Dish.sampleDishes : firebaseDishes
                    self.isLoading = false
                }
            } catch {
                print("Error loading Firebase data: \(error)")
                await MainActor.run {
                    self.dishes = Dish.sampleDishes
                    self.isLoading = false
                }
            }
        }
    }
}

