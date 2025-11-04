-- Script de criação do banco e carga inicial (MySQL 8)
-- Executar no MySQL do ACI antes de iniciar a aplicação (ou na primeira vez)

-- Ajuste o nome do schema conforme variáveis de ambiente (DB_NAME)
CREATE DATABASE IF NOT EXISTS `sprint4` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `sprint4`;

CREATE TABLE IF NOT EXISTS usuario (
  id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  usuario VARCHAR(50) NOT NULL UNIQUE,
  senha VARCHAR(255) NOT NULL,
  role VARCHAR(20) NOT NULL DEFAULT 'USER'
);

CREATE TABLE IF NOT EXISTS status_grupo (
  id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS status (
  id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  status_grupo_id BIGINT,
  CONSTRAINT fk_status_grupo FOREIGN KEY (status_grupo_id) REFERENCES status_grupo(id)
);

CREATE TABLE IF NOT EXISTS zona (
  id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  letra CHAR(1) NOT NULL
);

CREATE TABLE IF NOT EXISTS patio (
  id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS moto (
  id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  placa VARCHAR(10),
  chassi VARCHAR(50),
  qr_code VARCHAR(100),
  data_entrada TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  previsao_entrega TIMESTAMP NULL,
  fotos VARCHAR(500),
  observacoes VARCHAR(1000),
  zona_id BIGINT,
  patio_id BIGINT,
  status_id BIGINT,
  CONSTRAINT fk_moto_zona FOREIGN KEY (zona_id) REFERENCES zona(id),
  CONSTRAINT fk_moto_patio FOREIGN KEY (patio_id) REFERENCES patio(id),
  CONSTRAINT fk_moto_status FOREIGN KEY (status_id) REFERENCES status(id)
);

-- Índices
CREATE INDEX idx_moto_placa ON moto(placa);
CREATE INDEX idx_moto_chassi ON moto(chassi);
CREATE INDEX idx_moto_qr_code ON moto(qr_code);
CREATE INDEX idx_moto_data_entrada ON moto(data_entrada);

-- Seeds
INSERT INTO usuario (usuario, senha, role) VALUES 
  ('admin', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'ADMIN')
ON DUPLICATE KEY UPDATE role=VALUES(role);

INSERT INTO usuario (usuario, senha, role) VALUES 
  ('operador', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'OPERADOR')
ON DUPLICATE KEY UPDATE role=VALUES(role);

INSERT INTO usuario (usuario, senha, role) VALUES 
  ('user', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'USER')
ON DUPLICATE KEY UPDATE role=VALUES(role);

INSERT INTO status_grupo (nome) VALUES ('Entrada'), ('Processamento'), ('Saída'), ('Manutenção'), ('Aguardando')
ON DUPLICATE KEY UPDATE nome=VALUES(nome);

INSERT INTO status (nome, status_grupo_id) VALUES 
  ('Recebida', 1),
  ('Registrada', 1),
  ('Em Inspeção', 2),
  ('Em Avaliação', 2),
  ('Documentação Pendente', 2),
  ('Pronta para Entrega', 3),
  ('Entregue', 3),
  ('Necessita Reparo', 4),
  ('Em Reparo', 4),
  ('Aguardando Cliente', 5),
  ('Aguardando Documentos', 5)
ON DUPLICATE KEY UPDATE nome=VALUES(nome);

INSERT INTO zona (nome, letra) VALUES 
  ('Zona A - Entrada', 'A'),
  ('Zona B - Processamento', 'B'),
  ('Zona C - Saída', 'C'),
  ('Zona D - Manutenção', 'D')
ON DUPLICATE KEY UPDATE letra=VALUES(letra);

INSERT INTO patio (nome) VALUES 
  ('Pátio Principal'),
  ('Pátio Secundário'),
  ('Pátio de Manutenção'),
  ('Pátio de Entrada')
ON DUPLICATE KEY UPDATE nome=VALUES(nome);


