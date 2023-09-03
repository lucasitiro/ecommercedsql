-- criar tabela cliente

CREATE TABLE clients (
    idClient serial PRIMARY KEY,
    Fname varchar(10),
	Minit varchar(10),
	Lname varchar(20),
	CPF char(11) not null,
	Address varchar(30),
	constraint unique_cpf_client unique(CPF)
	
);



-- criar tabela produto
CREATE TYPE category AS ENUM('Brinquedos','Roupas','Acessórios','Jogos','Livros');
CREATE TABLE product (
    idProduct serial PRIMARY KEY,
    Pname varchar(10) not null,
	classification_kids bool,
	current_category category not null,
	avaliacao float default 0,
	size_ varchar(10)
	
);

-- criar conexão com as tabelas necessárias

CREATE TYPE typePayment AS ENUM ('Cartão','Boleto','PIX');
create table payment (
	idClient int,
	idPayment int,
	current_typePayment typePayment not null,
	limitAvaible float,
	primary key(idClient, idPayment) 
	
	
);

-- criar tabela pedido
CREATE TYPE orderStatus AS ENUM ('Confirmado', 'Cancelado', 'Em andamento');

CREATE TABLE orders (
	idOrder serial PRIMARY KEY,
	idOrderClient int,
	current_orderStatus orderStatus not null,
	orderDescription varchar(255),
	sendValue float default 0,
	paymentCash bool default false, 
	constraint fk_ordes_client foreign key (idOrderClient) references clients(idClient)
		
);

-- criar tabela estoque

CREATE TABLE productStorage (
	idProdStorage serial PRIMARY KEY,
	storageLocation varchar(255),
	quantity int default 0,
	orderDescription varchar(255),
	sendValue float default 0
);

-- criar tabela fornecedor

CREATE TABLE supplier (
	idSupplier serial PRIMARY KEY,
	socialName varchar(255) not null,
	CNPJ char(15) not null,
	contact char(11) not null,
	constraint unique_supplier unique(CNPJ)
);

-- criar tabela vendedor

CREATE TABLE seller (
	idSeller serial PRIMARY KEY,
	socialName varchar(255) not null,
	AbstName varchar(255),
	CNPJ char(15),
	CPF char(11),
	locations varchar(255),
	contact char(11) not null,
	constraint unique_CNPJ_seller unique(CNPJ),
	constraint unique_cpf_seller unique(CPF)
);

CREATE TABLE productSeller (
	idPseller int,
	idPproduct int,
	prodQuantity int default 1,
	PRIMARY KEY(idPseller, idPproduct),
	constraint fk_product_seller foreign key (idPseller) references seller(idSeller),
	constraint fk_product_product foreign key (idPproduct) references product(idProduct)
);

CREATE TYPE poStatus AS ENUM ('Sem estoque','Disponível');
CREATE TABLE productOrder (
	idPOproduct int,
	idPOrder int,
	poQuantity int default 1,
	current_poStatus poStatus not null,
	PRIMARY KEY(idPOproduct, idPOrder),
	constraint fk_productorder_seller foreign key (idPOproduct) references product(idProduct),
	constraint fk_productorder_product foreign key (idPOrder) references orders(idOrder)
);

CREATE TABLE statuslocation(
	idLproduct int,
	idLstorage int,
	locations varchar(255),
	PRIMARY KEY(idLproduct, idLstorage),
	constraint fk_storage_location_product foreign key (idLproduct) references product(idProduct),
	constraint fk_storage_location_storage foreign key (idLstorage) references productStorage(idProdStorage)
);

CREATE TABLE productSupplier(
	idPsSupplier int,
	idPsProduct int,
	quantity int not null,
	PRIMARY KEY(idPsSupplier,idPsProduct ),
	constraint fk_storage_supplier_supplier foreign key (idPsSupplier) references supplier(idSupplier),
	constraint fk_product_supplier_product foreign key (idPsProduct) references product(idProduct)
);

SELECT * from clients;

INSERT INTO clients VALUES (0,'Nelson','Rodrigo','Silva','48513426744','rua silav');

INSERT INTO clients (Fname, Minit, Lname, CPF, Address)
VALUES ('John', 'A', 'Doe', '12345678901', '123 Main St');

INSERT INTO product (Pname, classification_kids, current_category, avaliacao, size_)
VALUES ('Carrinho', true, 'Brinquedos', 4.5, 'Small')
RETURNING idProduct;

INSERT INTO payment (idClient, idPayment, current_typePayment, limitAvaible)
VALUES (1, 1, 'Cartão', 1000.00);

INSERT INTO orders (idOrderClient, current_orderStatus, orderDescription, sendValue, paymentCash)
VALUES (1, 'Confirmado', 'pedido brinquedo', 50.00, false);

INSERT INTO productStorage (storageLocation, quantity, orderDescription, sendValue)
VALUES ('Casa A', 100, 'Em estoque', 0);

INSERT INTO supplier (socialName, CNPJ, contact)
VALUES ('Toy Supplier Inc', '12345678901234', '5555555555');

INSERT INTO seller (socialName, AbstName, CNPJ, CPF, locations, contact)
VALUES ('Toy Shop ABC', 'ABC Toys', '98763432109876', '12345678901', '123 Main St', '5555555551');

INSERT INTO productSeller (idPseller, idPproduct, prodQuantity)
VALUES (1, 1, 50);

INSERT INTO productOrder (idPOproduct, idPOrder, poQuantity, current_poStatus)
VALUES (1, 1, 10, 'Disponível');

INSERT INTO statuslocation (idLproduct, idLstorage, locations)
VALUES (1, 1, 'Shelf A');

INSERT INTO productSupplier (idPsSupplier, idPsProduct, quantity)
VALUES (1, 1, 100);

-- Alterar o tipo ENUM para aceitar mais de um modelo de pagamento
CREATE TYPE paymentMethods AS ENUM ('Cartão', 'Boleto', 'PIX', 'Outro');
-- Alterar a tabela payment para usar o novo ENUM paymentMethods
ALTER TABLE payment
ADD COLUMN typePaymentNew paymentMethods;
UPDATE payment
SET typePaymentNew = 'Cartão'
WHERE current_typePayment = 'Cartão';

UPDATE payment
SET typePaymentNew = 'Boleto'
WHERE current_typePayment = 'Boleto';

UPDATE payment
SET typePaymentNew = 'PIX'
WHERE current_typePayment = 'PIX';

-- Para valores que não correspondem a 'Cartão', 'Boleto' ou 'PIX', você pode definir como 'Outro'
UPDATE payment
SET typePaymentNew = 'Outro'
WHERE current_typePayment NOT IN ('Cartão', 'Boleto', 'PIX');

-- Removendo a coluna typePayment antiga
ALTER TABLE payment
DROP COLUMN current_typePayment;

-- Renomeando a coluna typePaymentNew para typePayment
ALTER TABLE payment
RENAME COLUMN typePaymentNew TO typePayment;

-- Adicionando uma coluna isPJ à tabela clients
ALTER TABLE clients
ADD COLUMN isPJ boolean;

INSERT INTO clients (Fname, Minit, Lname, CPF, Address, isPJ)
VALUES ('Natal', '', 'RT', '12345648901', 'rua Andersin', true);

-- Adicione colunas de rastreamento e status à tabela statusLocation
DELETE from statuslocation WHERE idLproduct = 1
ALTER TABLE statuslocation 
ADD COLUMN trackingCode varchar(50) not null,
ADD COLUMN deliveryStatus varchar(20) not null;
INSERT INTO statusLocation (idLproduct, idLstorage, locations, trackingCode, deliveryStatus)
VALUES (1, 1, 'Monte Resort','1231231312', 'Em Trânsito');

-- ordenação de clientes
SELECT *
FROM clients
WHERE CPF IS NOT NULL
ORDER BY Lname, Fname;

-- contagem de pedidos por cliente
SELECT C.idClient, C.Fname, C.Lname, COUNT(O.idOrder) AS num_orders
FROM clients AS C
LEFT JOIN orders AS O ON C.idClient = O.idOrderClient
GROUP BY C.idClient, C.Fname, C.Lname
HAVING COUNT(O.idOrder) > 5
ORDER BY num_orders DESC;

-- lista de produtos vendidos por vendedor
SELECT S.idSeller, S.socialName AS seller_name, P.Pname AS product_name
FROM seller AS S
INNER JOIN productSeller AS PS ON S.idSeller = PS.idPseller
INNER JOIN product AS P ON PS.idPproduct = P.idProduct
WHERE S.idSeller = 1;



















