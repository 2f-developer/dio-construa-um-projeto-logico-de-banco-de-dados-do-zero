-- Verificações das regras do modelo. Qualquer falha interrompe com erro.
USE oficina;

DELIMITER $$

CREATE PROCEDURE espera_erro(IN descricao VARCHAR(200), IN comando TEXT)
BEGIN
  DECLARE falhou BOOLEAN DEFAULT FALSE;
  BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET falhou = TRUE;
    SET @comando = comando;
    PREPARE stmt FROM @comando;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
  END;
  IF NOT falhou THEN
    SET @msg = CONCAT('FALHOU (deveria ser recusado): ', descricao);
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
  END IF;
  SELECT CONCAT('ok  ', descricao) AS resultado;
END$$

CREATE PROCEDURE espera_igual(IN descricao VARCHAR(200), IN obtido VARCHAR(100), IN esperado VARCHAR(100))
BEGIN
  IF NOT (obtido <=> esperado) THEN
    SET @msg = CONCAT('FALHOU: ', descricao, ' (obtido ', COALESCE(obtido, 'NULL'), ', esperado ', COALESCE(esperado, 'NULL'), ')');
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
  END IF;
  SELECT CONCAT('ok  ', descricao) AS resultado;
END$$

DELIMITER ;

-- Valores vindos da tabela de referência
CALL espera_igual('serviço da OS usa o valor da tabela de mão de obra',
  (SELECT valor_unitario FROM os_servico WHERE os_numero = 3 AND servico_id = 6), '650.00');
CALL espera_igual('valor total da OS 1 = mão de obra + peças',
  (SELECT valor_total FROM vw_ordem_servico WHERE numero = 1), '896.00');
CALL espera_igual('OS com serviço e peça não duplica valores (sem produto cartesiano)',
  (SELECT valor_total FROM vw_ordem_servico WHERE numero = 5), '1799.80');
UPDATE servico SET valor_mao_obra = 999 WHERE id = 6;
CALL espera_igual('reajuste na tabela não muda OS já orçada',
  (SELECT valor_servicos FROM vw_ordem_servico WHERE numero = 3), '850.00');
UPDATE servico SET valor_mao_obra = 650 WHERE id = 6;

-- Autorização e equipe
CALL espera_erro('OS não vai para execução sem autorização do cliente',
  "UPDATE ordem_servico SET status = 'em_execucao' WHERE numero = 7");
CALL espera_erro('OS não é concluída sem data de conclusão',
  "UPDATE ordem_servico SET status = 'concluida', autorizada_em = NOW() WHERE numero = 7");
CALL espera_erro('equipe não muda depois da autorização',
  "UPDATE ordem_servico SET equipe_id = 1 WHERE numero = 5");
CALL espera_erro('orçamento autorizado não recebe serviço novo',
  "INSERT INTO os_servico (os_numero, servico_id, valor_unitario) VALUES (5, 1, 0)");
CALL espera_erro('orçamento autorizado não recebe peça nova',
  "INSERT INTO os_peca (os_numero, peca_id, valor_unitario) VALUES (5, 1, 0)");
UPDATE ordem_servico SET equipe_id = 2 WHERE numero = 7;
CALL espera_igual('antes da autorização, a equipe pode ser trocada',
  (SELECT equipe_id FROM ordem_servico WHERE numero = 7), '2');

-- Integridade dos cadastros
CALL espera_erro('placa fora do padrão é recusada',
  "INSERT INTO veiculo (cliente_id, placa, marca, modelo, ano) VALUES (1, 'AB-1234', 'X', 'Y', 2020)");
CALL espera_erro('placa repetida é recusada',
  "INSERT INTO veiculo (cliente_id, placa, marca, modelo, ano) VALUES (2, 'FJK2B31', 'X', 'Y', 2020)");
CALL espera_erro('entrega prometida antes da emissão é recusada',
  "INSERT INTO ordem_servico (veiculo_id, equipe_id, tipo, data_emissao, data_entrega) VALUES (1, 1, 'revisao', '2026-11-10', '2026-11-01')");
CALL espera_erro('mecânico sem equipe é recusado',
  "INSERT INTO mecanico (equipe_id, nome, endereco, especialidade) VALUES (99, 'X', 'Y', 'Z')");

-- Respostas das consultas
CALL espera_igual('clientes com mais de R$ 1.000 em OS concluídas',
  (SELECT COUNT(*) FROM (
     SELECT c.id FROM cliente c JOIN veiculo v ON v.cliente_id = c.id
     JOIN vw_ordem_servico os ON os.veiculo_id = v.id
     WHERE os.status = 'concluida' GROUP BY c.id HAVING SUM(os.valor_total) > 1000) t), '1');

DROP PROCEDURE espera_erro;
DROP PROCEDURE espera_igual;
SELECT 'todas as verificações passaram' AS resultado;
