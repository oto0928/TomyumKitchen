// Tomyum Kitchen 管理者ダッシュボード用JavaScript

class AdminDashboard {
    constructor() {
        this.db = null;
        this.isInitialized = false;
        this.refreshInterval = null;
        this.init();
    }

    async init() {
        try {
            // Firebase初期化
            await this.initializeFirebase();
            this.isInitialized = true;
            
            // 初期データ読み込み
            await this.loadAllData();
            
            // 自動更新設定
            this.startAutoRefresh();
            
            console.log('管理者ダッシュボードが初期化されました');
        } catch (error) {
            console.error('初期化エラー:', error);
            this.showError('ダッシュボードの初期化に失敗しました');
        }
    }

    async initializeFirebase() {
        // Firebase設定（実際の設定に置き換えてください）
        const firebaseConfig = {
            apiKey: "AIzaSyCnxcVvjWVJB9lTR1ZI7QnhtVr6sGqM2jI",
            authDomain: "tomyumkitchen-61a11.firebaseapp.com",
            projectId: "tomyumkitchen-61a11",
            storageBucket: "tomyumkitchen-61a11.firebasestorage.app",
            messagingSenderId: "329516809259",
            appId: "1:329516809259:web:admin-dashboard"
        };

        // Firebase SDKの動的インポート
        const { initializeApp } = await import('https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js');
        const { getFirestore, collection, getDocs, query, orderBy, limit, where, onSnapshot } = await import('https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore.js');

        const app = initializeApp(firebaseConfig);
        this.db = getFirestore(app);
        
        // グローバルにFirestore関数を設定
        window.firestoreFunctions = {
            getFirestore: () => this.db,
            collection,
            getDocs,
            query,
            orderBy,
            limit,
            where,
            onSnapshot
        };
    }

    async loadAllData() {
        await Promise.all([
            this.loadReservations(),
            this.loadOrders(),
            this.updateStats()
        ]);
    }

    async loadReservations() {
        try {
            const { collection, getDocs, query, orderBy, limit } = window.firestoreFunctions;
            const reservationsRef = collection(this.db, 'reservations');
            const q = query(reservationsRef, orderBy('createdAt', 'desc'), limit(10));
            const snapshot = await getDocs(q);
            
            this.displayReservations(snapshot);
        } catch (error) {
            console.error('予約データの読み込みエラー:', error);
            this.showError('予約データの読み込みに失敗しました');
        }
    }

    async loadOrders() {
        try {
            const { collection, getDocs, query, orderBy, limit } = window.firestoreFunctions;
            const ordersRef = collection(this.db, 'orders');
            const q = query(ordersRef, orderBy('createdAt', 'desc'), limit(10));
            const snapshot = await getDocs(q);
            
            this.displayOrders(snapshot);
        } catch (error) {
            console.error('注文データの読み込みエラー:', error);
            this.showError('注文データの読み込みに失敗しました');
        }
    }

    displayReservations(snapshot) {
        const reservationsList = document.getElementById('reservationsList');
        
        if (snapshot.empty) {
            reservationsList.innerHTML = '<div class="no-data">予約データがありません</div>';
            return;
        }

        let html = '';
        snapshot.forEach(doc => {
            const data = doc.data();
            const date = new Date(data.date.seconds * 1000);
            const createdAt = new Date(data.createdAt.seconds * 1000);
            
            html += `
                <div class="reservation-item">
                    <div class="item-header">
                        <span class="customer-name">${this.escapeHtml(data.customerName)}</span>
                        <span class="status ${data.status}">${this.getReservationStatusText(data.status)}</span>
                    </div>
                    <div class="item-details">
                        <div><i class="fas fa-phone"></i> ${this.escapeHtml(data.phone)}</div>
                        <div><i class="fas fa-envelope"></i> ${this.escapeHtml(data.email)}</div>
                        <div><i class="fas fa-users"></i> ${data.partySize}名</div>
                        <div><i class="fas fa-calendar"></i> ${date.toLocaleDateString('ja-JP')}</div>
                        <div><i class="fas fa-clock"></i> ${this.getTimeSlotText(data.timeSlot)}</div>
                        ${data.specialRequests ? `<div><i class="fas fa-comment"></i> ${this.escapeHtml(data.specialRequests)}</div>` : ''}
                        <div><i class="fas fa-clock"></i> 予約日時: ${createdAt.toLocaleString('ja-JP')}</div>
                    </div>
                </div>
            `;
        });
        
        reservationsList.innerHTML = html;
    }

    displayOrders(snapshot) {
        const ordersList = document.getElementById('ordersList');
        
        if (snapshot.empty) {
            ordersList.innerHTML = '<div class="no-data">注文データがありません</div>';
            return;
        }

        let html = '';
        snapshot.forEach(doc => {
            const data = doc.data();
            const createdAt = new Date(data.createdAt.seconds * 1000);
            
            html += `
                <div class="order-item">
                    <div class="item-header">
                        <span class="customer-name">${this.escapeHtml(data.customerInfo.name)}</span>
                        <span class="status ${data.status}">${this.getOrderStatusText(data.status)}</span>
                    </div>
                    <div class="item-details">
                        <div><i class="fas fa-phone"></i> ${this.escapeHtml(data.customerInfo.phone)}</div>
                        <div><i class="fas fa-envelope"></i> ${this.escapeHtml(data.customerInfo.email)}</div>
                        <div><i class="fas fa-map-marker-alt"></i> ${this.escapeHtml(data.customerInfo.address)}</div>
                        <div><i class="fas fa-shopping-basket"></i> ${data.items.length}品目</div>
                        <div><i class="fas fa-yen-sign"></i> ¥${data.total.toLocaleString()}</div>
                        <div><i class="fas fa-truck"></i> ${this.getDeliveryTimeText(data.deliveryTime)}</div>
                        ${data.deliveryInstructions ? `<div><i class="fas fa-comment"></i> ${this.escapeHtml(data.deliveryInstructions)}</div>` : ''}
                        <div><i class="fas fa-clock"></i> 注文日時: ${createdAt.toLocaleString('ja-JP')}</div>
                    </div>
                </div>
            `;
        });
        
        ordersList.innerHTML = html;
    }

    async updateStats() {
        try {
            const { collection, getDocs, query, where } = window.firestoreFunctions;
            
            // 今日の日付範囲
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            const tomorrow = new Date(today);
            tomorrow.setDate(tomorrow.getDate() + 1);

            // 今月の日付範囲
            const monthStart = new Date(today.getFullYear(), today.getMonth(), 1);
            const monthEnd = new Date(today.getFullYear(), today.getMonth() + 1, 1);

            // 今日の予約数
            const reservationsRef = collection(this.db, 'reservations');
            const todayReservationsQuery = query(
                reservationsRef,
                where('date', '>=', today),
                where('date', '<', tomorrow)
            );
            const todayReservationsSnapshot = await getDocs(todayReservationsQuery);
            document.getElementById('todayReservations').textContent = todayReservationsSnapshot.size;

            // 今日の注文数
            const ordersRef = collection(this.db, 'orders');
            const todayOrdersQuery = query(
                ordersRef,
                where('createdAt', '>=', today),
                where('createdAt', '<', tomorrow)
            );
            const todayOrdersSnapshot = await getDocs(todayOrdersQuery);
            document.getElementById('todayOrders').textContent = todayOrdersSnapshot.size;

            // 今月の売上
            const monthlyOrdersQuery = query(
                ordersRef,
                where('createdAt', '>=', monthStart),
                where('createdAt', '<', monthEnd)
            );
            const monthlyOrdersSnapshot = await getDocs(monthlyOrdersQuery);
            
            let monthlyRevenue = 0;
            monthlyOrdersSnapshot.forEach(doc => {
                monthlyRevenue += doc.data().total;
            });
            document.getElementById('monthlyRevenue').textContent = '¥' + monthlyRevenue.toLocaleString();

            // アクティブ予約数
            const activeReservationsQuery = query(
                reservationsRef,
                where('status', 'in', ['requested', 'confirmed'])
            );
            const activeReservationsSnapshot = await getDocs(activeReservationsQuery);
            document.getElementById('activeReservations').textContent = activeReservationsSnapshot.size;

        } catch (error) {
            console.error('統計データの更新エラー:', error);
        }
    }

    getReservationStatusText(status) {
        const statusMap = {
            'requested': '予約申請中',
            'confirmed': '予約確定',
            'cancelled': 'キャンセル',
            'completed': '完了'
        };
        return statusMap[status] || status;
    }

    getOrderStatusText(status) {
        const statusMap = {
            'pending': '注文受付中',
            'preparing': '調理中',
            'ready': '準備完了',
            'delivering': '配送中',
            'delivered': '配送完了',
            'cancelled': 'キャンセル'
        };
        return statusMap[status] || status;
    }

    getTimeSlotText(timeSlot) {
        const timeSlotMap = {
            '11:00': '11:00-12:00',
            '12:00': '12:00-13:00',
            '13:00': '13:00-14:00',
            '17:00': '17:00-18:00',
            '18:00': '18:00-19:00',
            '19:00': '19:00-20:00',
            '20:00': '20:00-21:00'
        };
        return timeSlotMap[timeSlot] || timeSlot;
    }

    getDeliveryTimeText(deliveryTime) {
        const deliveryTimeMap = {
            'asap': 'できるだけ早く',
            '30min': '30分後',
            '1hour': '1時間後',
            '2hours': '2時間後'
        };
        return deliveryTimeMap[deliveryTime] || deliveryTime;
    }

    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    showError(message) {
        const errorDiv = document.createElement('div');
        errorDiv.className = 'no-data';
        errorDiv.style.color = '#dc2626';
        errorDiv.textContent = message;
        
        // エラーを表示する適切な場所に挿入
        const container = document.querySelector('.container');
        if (container) {
            container.insertBefore(errorDiv, container.firstChild);
            
            // 5秒後にエラーメッセージを削除
            setTimeout(() => {
                if (errorDiv.parentNode) {
                    errorDiv.parentNode.removeChild(errorDiv);
                }
            }, 5000);
        }
    }

    startAutoRefresh() {
        // 30秒ごとに自動更新
        this.refreshInterval = setInterval(() => {
            if (this.isInitialized) {
                this.loadAllData();
            }
        }, 30000);
    }

    stopAutoRefresh() {
        if (this.refreshInterval) {
            clearInterval(this.refreshInterval);
            this.refreshInterval = null;
        }
    }

    // 手動更新メソッド
    async refresh() {
        if (this.isInitialized) {
            await this.loadAllData();
        }
    }
}

// グローバル関数として定義（HTMLから呼び出し用）
let dashboard;

// ページ読み込み時の初期化
document.addEventListener('DOMContentLoaded', function() {
    dashboard = new AdminDashboard();
});

// グローバル関数として公開
window.loadReservations = () => dashboard?.loadReservations();
window.loadOrders = () => dashboard?.loadOrders();
window.refreshAll = () => dashboard?.refresh();
