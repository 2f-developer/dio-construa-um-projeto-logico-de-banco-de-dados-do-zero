USE oficina;

INSERT INTO cliente (id, nome, documento, telefone, email) VALUES
  (1, 'Marcos Andrade', '52998224725', '11991234567', 'marcos.andrade@email.com'),
  (2, 'Juliana Freitas', '11144477735', '11982345678', 'juliana.f@email.com'),
  (3, 'Transportes Rápido Ltda', '45723174000110', '1140028922', 'frota@rapido.com.br'),
  (4, 'Renata Costa', '39053344705', '21976543210', NULL);

INSERT INTO veiculo (id, cliente_id, placa, marca, modelo, ano) VALUES
  (1, 1, 'FJK2B31', 'Volkswagen', 'Gol 1.6', 2018),
  (2, 2, 'QWE4512', 'Honda', 'Civic EXL', 2016),
  (3, 3, 'RTA1C22', 'Mercedes-Benz', 'Sprinter 415', 2021),
  (4, 3, 'RTA3D44', 'Fiat', 'Ducato Cargo', 2020),
  (5, 4, 'KLM8E90', 'Toyota', 'Corolla XEi', 2022);

INSERT INTO equipe (id, nome) VALUES (1, 'Motor e Câmbio'), (2, 'Suspensão e Freios'), (3, 'Elétrica e Revisão');

INSERT INTO mecanico (codigo, equipe_id, nome, endereco, especialidade) VALUES
  (101, 1, 'Paulo Henrique', 'Rua Tamoios, 45 - São Paulo/SP', 'Motor'),
  (102, 1, 'Sérgio Matos', 'Rua Guaianases, 310 - São Paulo/SP', 'Câmbio'),
  (201, 2, 'Fernanda Lopes', 'Av. Cupecê, 1200 - São Paulo/SP', 'Freios'),
  (202, 2, 'Diego Ramos', 'Rua Alvarenga, 88 - São Paulo/SP', 'Suspensão'),
  (301, 3, 'Carla Nunes', 'Rua Vergueiro, 2100 - São Paulo/SP', 'Elétrica'),
  (302, 3, 'Rafael Prado', 'Rua Domingos de Morais, 640 - São Paulo/SP', 'Revisão periódica');

INSERT INTO servico (id, descricao, valor_mao_obra) VALUES
  (1, 'Troca de óleo e filtro', 90.00),
  (2, 'Alinhamento e balanceamento', 120.00),
  (3, 'Troca de pastilhas de freio (eixo)', 150.00),
  (4, 'Revisão de 30.000 km', 380.00),
  (5, 'Diagnóstico de injeção eletrônica', 200.00),
  (6, 'Troca de embreagem', 650.00),
  (7, 'Troca de amortecedores (par)', 280.00);

INSERT INTO peca (id, descricao, valor) VALUES
  (1, 'Óleo 5W30 sintético (litro)', 52.00),
  (2, 'Filtro de óleo', 38.00),
  (3, 'Jogo de pastilhas dianteiras', 189.90),
  (4, 'Kit de embreagem', 1250.00),
  (5, 'Amortecedor dianteiro', 420.00),
  (6, 'Vela de ignição', 45.00);

-- Orçamentos (as OS nascem em avaliação; serviços e peças entram antes da autorização).
INSERT INTO ordem_servico (numero, veiculo_id, equipe_id, tipo, data_emissao, data_entrega) VALUES
  (1, 1, 3, 'revisao',  '2026-09-02', '2026-09-03'),
  (2, 2, 2, 'conserto', '2026-09-10', '2026-09-12'),
  (3, 3, 1, 'conserto', '2026-09-15', '2026-09-22'),
  (4, 5, 3, 'revisao',  '2026-10-01', '2026-10-01'),
  (5, 4, 2, 'conserto', '2026-10-06', '2026-10-09'),
  (6, 1, 1, 'conserto', '2026-10-20', '2026-10-24'),
  (7, 2, 3, 'conserto', '2026-11-03', '2026-11-05');

-- O valor unitário é preenchido pelo trigger a partir da tabela de referência.
INSERT INTO os_servico (os_numero, servico_id, quantidade, valor_unitario) VALUES
  (1, 4, 1, 0), (1, 1, 1, 0),
  (2, 3, 1, 0), (2, 2, 1, 0),
  (3, 6, 1, 0), (3, 5, 1, 0),
  (4, 4, 1, 0),
  (5, 7, 1, 0), (5, 3, 2, 0),
  (6, 5, 1, 0),
  (7, 5, 1, 0);

INSERT INTO os_peca (os_numero, peca_id, quantidade, valor_unitario) VALUES
  (1, 1, 4, 0), (1, 2, 1, 0), (1, 6, 4, 0),
  (2, 3, 1, 0),
  (3, 4, 1, 0),
  (4, 1, 4, 0), (4, 2, 1, 0),
  (5, 5, 2, 0), (5, 3, 2, 0);

-- Andamento: autorização do cliente e execução.
UPDATE ordem_servico SET status = 'concluida', autorizada_em = '2026-09-02 09:30', data_conclusao = '2026-09-03' WHERE numero = 1;
UPDATE ordem_servico SET status = 'concluida', autorizada_em = '2026-09-10 14:00', data_conclusao = '2026-09-13' WHERE numero = 2;
UPDATE ordem_servico SET status = 'concluida', autorizada_em = '2026-09-16 08:15', data_conclusao = '2026-09-21' WHERE numero = 3;
UPDATE ordem_servico SET status = 'concluida', autorizada_em = '2026-10-01 10:00', data_conclusao = '2026-10-01' WHERE numero = 4;
UPDATE ordem_servico SET status = 'em_execucao', autorizada_em = '2026-10-06 17:45' WHERE numero = 5;
UPDATE ordem_servico SET status = 'cancelada' WHERE numero = 6;
UPDATE ordem_servico SET status = 'aguardando_autorizacao' WHERE numero = 7;
