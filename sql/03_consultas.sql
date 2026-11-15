USE oficina;

-- 1. Quais clientes estão cadastrados e como falar com eles? (SELECT simples, ORDER BY)
SELECT nome, telefone, email
FROM cliente
ORDER BY nome;

-- 2. Quais veículos têm mais de 5 anos de uso? (WHERE + atributo derivado)
SELECT placa, marca, modelo, ano, YEAR(CURDATE()) - ano AS idade_anos
FROM veiculo
WHERE YEAR(CURDATE()) - ano > 5
ORDER BY idade_anos DESC;

-- 3. Quanto custou cada OS, separando mão de obra e peças? (junção + derivados)
SELECT v.placa, os.numero, os.tipo, os.status, os.valor_servicos, os.valor_pecas, os.valor_total
FROM vw_ordem_servico os
JOIN veiculo v ON v.id = os.veiculo_id
ORDER BY os.valor_total DESC;

-- 4. Quais OS concluídas atrasaram, e em quantos dias? (WHERE + derivado + ORDER BY)
SELECT numero, data_entrega, data_conclusao, DATEDIFF(data_conclusao, data_entrega) AS dias_de_atraso
FROM ordem_servico
WHERE status = 'concluida' AND data_conclusao > data_entrega
ORDER BY dias_de_atraso DESC;

-- 5. Quais clientes já gastaram mais de R$ 1.000 em OS concluídas? (junções + GROUP BY + HAVING)
SELECT c.nome, COUNT(*) AS ordens, SUM(os.valor_total) AS total_gasto
FROM cliente c
JOIN veiculo v ON v.cliente_id = c.id
JOIN vw_ordem_servico os ON os.veiculo_id = v.id
WHERE os.status = 'concluida'
GROUP BY c.id, c.nome
HAVING SUM(os.valor_total) > 1000
ORDER BY total_gasto DESC;

-- 6. Faturamento e ticket médio por equipe, só para quem tem mais de uma OS concluída. (HAVING)
SELECT e.nome AS equipe,
       COUNT(*) AS ordens_concluidas,
       SUM(os.valor_total) AS faturamento,
       ROUND(AVG(os.valor_total), 2) AS ticket_medio
FROM equipe e
JOIN vw_ordem_servico os ON os.equipe_id = e.id
WHERE os.status = 'concluida'
GROUP BY e.id, e.nome
HAVING COUNT(*) > 1
ORDER BY faturamento DESC;

-- 7. Quais serviços mais aparecem nas OS, e quanto renderam? (junção + GROUP BY + ORDER BY)
SELECT s.descricao, SUM(x.quantidade) AS vezes, SUM(x.quantidade * x.valor_unitario) AS receita
FROM os_servico x
JOIN servico s ON s.id = x.servico_id
JOIN ordem_servico os ON os.numero = x.os_numero
WHERE os.status <> 'cancelada'
GROUP BY s.id, s.descricao
ORDER BY vezes DESC, receita DESC;

-- 8. Quem são os mecânicos responsáveis pelas OS em aberto? (várias junções)
SELECT os.numero, v.placa, os.status, e.nome AS equipe, m.nome AS mecanico, m.especialidade
FROM ordem_servico os
JOIN veiculo v ON v.id = os.veiculo_id
JOIN equipe e ON e.id = os.equipe_id
JOIN mecanico m ON m.equipe_id = e.id
WHERE os.status IN ('em_avaliacao', 'aguardando_autorizacao', 'autorizada', 'em_execucao')
ORDER BY os.numero, m.nome;

-- 9. Qual peça representa a maior fatia do valor de cada OS que usou peças? (subconsulta correlacionada)
SELECT p1.os_numero, pc.descricao, p1.quantidade * p1.valor_unitario AS valor
FROM os_peca p1
JOIN peca pc ON pc.id = p1.peca_id
WHERE p1.quantidade * p1.valor_unitario = (
  SELECT MAX(p2.quantidade * p2.valor_unitario) FROM os_peca p2 WHERE p2.os_numero = p1.os_numero
)
ORDER BY p1.os_numero;

-- 10. Quais clientes têm mais de um veículo? (GROUP BY + HAVING)
SELECT c.nome, COUNT(v.id) AS veiculos, GROUP_CONCAT(v.placa ORDER BY v.placa SEPARATOR ', ') AS placas
FROM cliente c
JOIN veiculo v ON v.cliente_id = c.id
GROUP BY c.id, c.nome
HAVING COUNT(v.id) > 1;
