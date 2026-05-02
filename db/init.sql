SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

ALTER DATABASE labdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

DROP TABLE IF EXISTS items;

CREATE TABLE items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

INSERT INTO items (name) VALUES
('Пример 1'),
('Пример 2');
