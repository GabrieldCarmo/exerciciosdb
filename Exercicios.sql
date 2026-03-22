CREATE DATABASE	IF NOT EXISTS empresa
CHARACTER SET utf8mb4
COLLATE utf8mb4_general_ci;

USE empresa;

CREATE TABLE cliente(
	id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(254) UNIQUE NOT NULL,
    stats BOOLEAN DEFAULT TRUE,
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP
)ENGINE=InnoDB;

SHOW TABLES;

DESCRIBE cliente;

SHOW INDEX FROM cliente;

CREATE TABLE categoria(
	id_categoria INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(50) UNIQUE NOT NULL
)ENGINE=InnoDB;

CREATE TABLE produto(
	id_produto INT PRIMARY KEY AUTO_INCREMENT,
    nome varchar(100) NOT NULL,
	preco DECIMAL(10,2) NOT NULL CHECK (preco > 0),
    qtd_estoque INT NOT NULL DEFAULT 0,
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    id_categoria int NOT NULL,
    
    CONSTRAINT fk_produto_categoria
		FOREIGN KEY (id_categoria)
		REFERENCES categoria(id_categoria)
		ON DELETE RESTRICT
)ENGINE=InnoDB;

-- PERGUNTAS TÉCNICAS

/*1 - DECIMAL(10,2) Pois aceita valores exatos até 10 milhoes e com duas casas decimais (centavos). 
Mas esse valor pode ser modelado para casos especificos para ocupar menos espaço. */

/*2 - Porque tem uma precisao aproximada, podendo ter erros de arredondamentos. Sendo assim péssimo
para dinheiro e valores monetários. */

/*3 - O impacto gerado pelo uso de float como tipo de dado no sistema financeiro é considerado grave,
podendo resultar em consequencias financeiras e tecnicas severas, como erros de arredondamento, discrepancia
em relatórios e rombos financeiros graças a isso. */

/*4 - Teriamos problemas na hora de fazer um insert ocultando o valor do estoque, e daria um erro como:
Field 'qtd_estoque' doesn't have a default value
E em todo insert seriamos obrigados a inserir um valor para o estoque de determinado produto.*/

/*5 - Não é obrigatório, mas é recomendado. O MySQL usa o engine padrão do servidor(InnoDb normalmente)
Definimos para termos uma garantia de comportamento, como no caso do InnoDB:
-Transaçoes na tabela
-FK
-Integridade
*/

/*6 Justificativas

-id: Int é o suficiente para o grande volume.
-nome: varchar(50) permite armazenar o nome de diversas categorias com o tamanho adequado.
*/

/*7 - Para garantir que o nome da categoria não se repita.*/

/*8 - Poderia ter redundancia de nomes no sistema, duas categorias calçados por exemplo.*/

/*9 - A tabela não tem integridade e nem se relacionaria com o restante do sistema.*/

/*10 - Utilizamos ON DELETE RESTRICT pois ele garante que nenhuma categoria seja apagada se ainda houver registros de categorias na tabela.*/

/*11 - ON DELETE CASCADE deve ser utilizado quando os registros dependentes não fazem sentido sem o registro principal. Ou seja exluir o registro pai, também apaga os registros filhos.*/

/*12 - ON DELETE RESTRICT deve ser utilizado quando não se deseja permitir a exclusão de um registro que possua dependências*/

/*13 - Permitir SET NULL faz com que, ao excluir o registro pai, a chave estrangeira nos registros filhos seja definida como NULL.*/

/*14 - A regra no banco de dados garante a integridade das informações de forma centralizada e independente da aplicação,
evitando inconsistências mesmo em casos de falha ou múltiplos acessos. Já a regra na aplicação depende da implementação do sistema, podendo ser ignorada ou falhar,
o que compromete a confiabilidade dos dados.
*/

CREATE TABLE pedido(
	id_pedido INT PRIMARY KEY AUTO_INCREMENT,
    data_pedido DATETIME DEFAULT CURRENT_TIMESTAMP,
    valor_pedido DECIMAL(10,2) NOT NULL CHECK (valor_pedido > 0),
    id_cliente INT NOT NULL,
	CONSTRAINT fk_pedido_cliente
		FOREIGN KEY (id_cliente)
		REFERENCES cliente(id_cliente)
		ON DELETE CASCADE
        ON UPDATE CASCADE
)ENGINE=InnoDB;

CREATE TABLE pedido_item (
	id_pedido INT NOT NULL,
    id_produto INT NOT NULL,
    qtd INT NOT NULL CHECK (qtd > 0),
    preco_un DECIMAL(10,2) NOT NULL,
    
    PRIMARY KEY (id_pedido, id_produto),
    
    CONSTRAINT fk_item_pedido_pedido
		FOREIGN KEY (id_pedido)
        REFERENCES pedido(id_pedido)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
        
	CONSTRAINT fk_item_pedido_produto
		FOREIGN KEY (id_produto)
        REFERENCES produto(id_produto)
        ON DELETE RESTRICT
)ENGINE=InnoDB;

INSERT INTO cliente (nome, email)
VALUES 
('Gabriel', 'gabrieldcarmo1@gmail.com'),
('Anna', 'annabxs1@gmail.com'),
('Enildo', 'enildocandido@gmail.com');
DELIMITER $$

INSERT INTO pedido (valor_pedido, id_cliente)
VALUES 
(200.00, 1),
(199.00, 2),
(198.00, 3);

INSERT INTO pedido (valor_pedido, id_cliente)
VALUES (302.00, 999);

/*
CALL inserir_pedido(302, 999)	Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails (`empresa`.`pedido`, CONSTRAINT `fk_pedido_cliente` FOREIGN KEY (`id_cliente`) 
REFERENCES `cliente` (`id_cliente`) ON DELETE CASCADE ON UPDATE CASCADE)	0.016 sec

O erro ocorre porque foi tentado inserir um pedido com um identificador de cliente inexistente.
*/

DELETE FROM cliente WHERE id_cliente = 1;

SELECT * FROM pedido WHERE id_cliente = 1;

/*Os pedidos do cliente foram apagados graças ao metodo ON DELETE CASCADE.*/

ALTER TABLE pedido
ADD desconto DECIMAL(5,2);

ALTER TABLE pedido
ADD CONSTRAINT chk_desconto
CHECK (desconto >= 0 AND desconto <= 100);

INSERT INTO pedido (valor_pedido, id_cliente, desconto)
VALUES (150.00, 2, 10);

SELECT * FROM pedido where id_cliente = 2;

/* Foi utilizado ON DELETE CASCADE na tabela pedido_item em relação ao pedido, pois os itens não possuem sentido sem o pedido ao qual pertencem. 
Dessa forma, ao excluir um pedido, todos os seus itens são automaticamente removidos*/

/* A regra ON DELETE RESTRICT é mais segura para a tabela produto, pois impede a exclusão de produtos que ainda estão associados a pedidos. Isso evita a perda de informações importantes e garante a consistência histórica das vendas */
















