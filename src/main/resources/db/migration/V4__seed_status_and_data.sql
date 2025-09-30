-- V4: Inserção de status e dados iniciais

-- Status para cada grupo
INSERT INTO status (nome, status_grupo_id) VALUES ('Recebida', 1);
INSERT INTO status (nome, status_grupo_id) VALUES ('Registrada', 1);

INSERT INTO status (nome, status_grupo_id) VALUES ('Em Inspeção', 2);
INSERT INTO status (nome, status_grupo_id) VALUES ('Em Avaliação', 2);
INSERT INTO status (nome, status_grupo_id) VALUES ('Documentação Pendente', 2);

INSERT INTO status (nome, status_grupo_id) VALUES ('Pronta para Entrega', 3);
INSERT INTO status (nome, status_grupo_id) VALUES ('Entregue', 3);

INSERT INTO status (nome, status_grupo_id) VALUES ('Necessita Reparo', 4);
INSERT INTO status (nome, status_grupo_id) VALUES ('Em Reparo', 4);

INSERT INTO status (nome, status_grupo_id) VALUES ('Aguardando Cliente', 5);
INSERT INTO status (nome, status_grupo_id) VALUES ('Aguardando Documentos', 5);

-- Zonas iniciais
INSERT INTO zona (nome, letra) VALUES ('Zona A - Entrada', 'A');
INSERT INTO zona (nome, letra) VALUES ('Zona B - Processamento', 'B');
INSERT INTO zona (nome, letra) VALUES ('Zona C - Saída', 'C');
INSERT INTO zona (nome, letra) VALUES ('Zona D - Manutenção', 'D');

-- Pátios iniciais
INSERT INTO patio (nome) VALUES ('Pátio Principal');
INSERT INTO patio (nome) VALUES ('Pátio Secundário');
INSERT INTO patio (nome) VALUES ('Pátio de Manutenção');
INSERT INTO patio (nome) VALUES ('Pátio de Entrada');
