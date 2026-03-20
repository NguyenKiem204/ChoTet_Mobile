-- Tạo bảng users
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tạo bảng shopping_lists (Danh sách mua sắm)
CREATE TABLE IF NOT EXISTS shopping_lists (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    budget DECIMAL(15, 2) DEFAULT 0,
    total_estimated DECIMAL(15, 2) DEFAULT 0,
    total_actual DECIMAL(15, 2) DEFAULT 0,
    scheduled_date DATE,
    image_url VARCHAR(500),
    status VARCHAR(20) DEFAULT 'PLANNED', -- PLANNED, IN_PROGRESS, COMPLETED
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tạo bảng shopping_items (Món đồ trong danh sách)
CREATE TABLE IF NOT EXISTS shopping_items (
    id SERIAL PRIMARY KEY,
    list_id INT NOT NULL REFERENCES shopping_lists(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    quantity DECIMAL(10, 2) DEFAULT 1,
    image_url VARCHAR(500),
    unit VARCHAR(50), -- kg, bó, hộp, v.v.
    estimated_price DECIMAL(15, 2) DEFAULT 0,
    actual_price DECIMAL(15, 2) DEFAULT 0,
    is_purchased BOOLEAN DEFAULT FALSE,
    is_extra BOOLEAN DEFAULT FALSE, -- Bật True nếu món này AI quét thấy nhưng không có trong danh sách ban đầu
    category VARCHAR(100),
    scheduled_date DATE,
    note TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tạo bảng price_book (Sổ tay khảo giá)
CREATE TABLE IF NOT EXISTS price_book (
    id SERIAL PRIMARY KEY,
    item_name VARCHAR(255) NOT NULL,
    store_name VARCHAR(255), -- Nơi mua: VD "Coopmart", "Chợ Đồng Xuân"
    unit VARCHAR(50),
    price DECIMAL(15, 2) NOT NULL,
    image_url VARCHAR(500),
    source_list_id INT REFERENCES shopping_lists(id) ON DELETE SET NULL, -- Lưu vết nguồn giá từ danh sách nào (nếu có)
    observed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================================================
-- SAMPLE DATA
-- =========================================================

-- Insert sample users
INSERT INTO users (username, email, image_url) VALUES 
('nguyenvana', 'nguyenvana@example.com', 'https://ui-avatars.com/api/?name=Nguyen+Van+A'),
('thib', 'thib@example.com', 'https://ui-avatars.com/api/?name=Thi+B');

-- Insert sample shopping lists
INSERT INTO shopping_lists (user_id, name, budget, total_estimated, total_actual, scheduled_date, status) VALUES 
(1, 'Đi chợ Tết - Ngày 28', 2000000, 1850000, 0, '2026-02-14', 'PLANNED'),
(1, 'Siêu thị cuối tuần', 1000000, 850000, 920000, '2026-03-01', 'COMPLETED');

-- Insert sample items for 'Đi chợ Tết - Ngày 28' (Chưa đi chợ)
INSERT INTO shopping_items (list_id, name, quantity, unit, estimated_price, is_purchased, is_extra, image_url, category, scheduled_date) VALUES 
(1, 'Thịt lợn ba chỉ', 1.5, 'kg', 180000, FALSE, FALSE, 'https://picsum.photos/seed/thitlon/200/200', 'Thịt tươi', '2026-02-14'),
(1, 'Gà ta', 2, 'con', 300000, FALSE, FALSE, 'https://picsum.photos/seed/gata/200/200', 'Thịt tươi', '2026-02-14'),
(1, 'Bánh chưng', 4, 'cái', 200000, FALSE, FALSE, 'https://picsum.photos/seed/banhchung/200/200', 'Thực phẩm', '2026-02-14'),
(1, 'Nước ngọt', 1, 'thùng', 150000, FALSE, FALSE, 'https://picsum.photos/seed/nuocngot/200/200', 'Đồ uống', '2026-02-14');

-- Insert sample items for 'Siêu thị cuối tuần' (Đã đi, và có dùng AI quét bill)
-- Món ban đầu có trong danh sách và đã mua
INSERT INTO shopping_items (list_id, name, quantity, unit, estimated_price, actual_price, is_purchased, is_extra, image_url, category, scheduled_date) VALUES 
(2, 'Gạo ST25', 5, 'kg', 150000, 160000, TRUE, FALSE, 'https://picsum.photos/seed/gao/200/200', 'Đồ khô', '2026-03-01'),
(2, 'Dầu ăn', 2, 'chai', 120000, 120000, TRUE, FALSE, 'https://picsum.photos/seed/dauan/200/200', 'Gia vị', '2026-03-01'),
(2, 'Trứng gà', 3, 'vỉ', 90000, 85000, TRUE, FALSE, 'https://picsum.photos/seed/trung/200/200', 'Thực phẩm', '2026-03-01');

-- Món phát sinh (AI nhận diện từ hóa đơn nhưng không có trong danh sách)
INSERT INTO shopping_items (list_id, name, quantity, unit, estimated_price, actual_price, is_purchased, is_extra, image_url, category, scheduled_date) VALUES 
(2, 'Snack khoai tây', 2, 'gói', 0, 40000, TRUE, TRUE, 'https://picsum.photos/seed/snack/200/200', 'Bánh kẹo', '2026-03-01'),
(2, 'Sữa tươi', 1, 'lốc', 0, 35000, TRUE, TRUE, 'https://picsum.photos/seed/sua/200/200', 'Đồ uống', '2026-03-01');

-- Insert sample Data to Price Book (Sổ tay khảo giá) được trích xuất đồng thời từ bill
INSERT INTO price_book (item_name, store_name, unit, price, image_url, source_list_id, observed_at) VALUES 
('Gạo ST25', 'Vinmart', 'kg', 32000, 'https://picsum.photos/seed/gao/200/200', 2, '2026-03-01 10:00:00'),
('Dầu ăn', 'Vinmart', 'chai', 60000, 'https://picsum.photos/seed/dauan/200/200', 2, '2026-03-01 10:00:00'),
('Trứng gà', 'Vinmart', 'vỉ', 28333, 'https://picsum.photos/seed/trung/200/200', 2, '2026-03-01 10:00:00'),
('Snack khoai tây', 'Vinmart', 'gói', 20000, 'https://picsum.photos/seed/snack/200/200', 2, '2026-03-01 10:00:00'),
('Sữa tươi', 'Vinmart', 'lốc', 35000, 'https://picsum.photos/seed/sua/200/200', 2, '2026-03-01 10:00:00');
