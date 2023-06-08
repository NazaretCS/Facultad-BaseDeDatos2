/*

   Modelo Entidad Relacion: 
   
   *Los campos entre corchetes en realidad son campos compuestos en el entidad relacion.
   *los campos que tienen corches al final de su nombre son arreglos (campos multivaluados en E-R)

    Cunado estoy pasando del entidad realcion al relacional para implemntar con el modelo objeto relacional y quiero generar la herencia se representa de la misma manera que en el entidad relacion con la diferencia de que ya no se puede optar por cualquiera de las 3 formas de representar... sino que si o si va la primera (en la que se crea la tabla para el objeto padre, y otras tablas para los objetos hijos con sus atributos espesificos...)

        domicilio  =  calle, numero, ciudad, provincia

        Persona(id_persona, nombre dni, {domicilio}, provincia, e-mail[], telefono[])
                   PK

        empleado(id_empleado, cargo, legajo, sueldo, sector)
                    PK-FK

        cliente(id_cliente, cta_cte)
                  PK-FK

        pedido(id_pedido, fecha, total, id_empleado, id_cliente)
                    PK                       FK          FK

        producto(id_producto, nombre, descripcion, precio, categoria, proveedor[])
                      PK

        tiene(idproducto, id_pedido, cantidad, precio)
                        P K






	CREACION DEl tipo de dato DOMICILIO.
	
		CREATE TYPE public.domicilio AS
		(
			calle character varying(120),
			numero character varying(7),
			ciudad character varying(120),
			provincia character varying(120)
		);
	
	
	
	Creacion de la tabla persona
	
	
	CREATE TABLE public.persona
	(
		id_persona integer NOT NULL,
		nombre character varying(300) NOT NULL,
		dni integer NOT NULL,
		domicilio domicilio NOT NULL,
		"e-mail" character varying(80)[],
		telefono character varying(18)[],
		CONSTRAINT id_persona PRIMARY KEY (id_persona)
	)
	WITH (
		OIDS = FALSE
	);

	ALTER TABLE public.persona
		OWNER to postgres;
	
	
	
	Creacion del tipo de dato enumerado Cargo
	
		CREATE TYPE public.cargo AS ENUM
		('Administrativo', 'Cajero', 'Vendedor', 'Gerente');
	
	
	Creacion del tipo de dato enumerado Sector
	
		CREATE TYPE public.sector AS ENUM
		('Ventas ', 'Compras', 'Gerencia', 'Deposito');
	
	
	
	Creacion del tipo de dato enumerado producto
	
		CREATE TYPE public.categoria AS ENUM
    	('Bebidas', 'Carnes', 'Lácteos', 'Cereales');



	
	
	Creacion de la tabla empleado:
	
		CREATE TABLE public.empleado
		(
			cargo cargo NOT NULL,
			sector sector NOT NULL,
			legajo character varying(80),
			sueldo numeric(9, 2)
		)
			INHERITS (public.persona)
		WITH (
			OIDS = FALSE
		);
		
		Alteracion de la tabla empleado...
		
		ALTER TABLE public.empleado
  		  ADD PRIMARY KEY (id_persona);
	
	
	
	Creacion de la tabla cliente:
		
		CREATE TABLE public.cliente
		(
			cta_cte character varying(150) NOT NULL
		)
			INHERITS (public.persona)
		WITH (
			OIDS = FALSE
		);
	
	
	Alteracion de la tabla cliente
		ALTER TABLE public.cliente
   		 ADD PRIMARY KEY (id_persona);
		 
		 
	
	Creacion de la tabla Pedido
		
		CREATE TABLE public.pedido
		(
			id_pedido integer NOT NULL,
			fecha date NOT NULL,
			total numeric(9, 2) NOT NULL,
			id_empleado integer NOT NULL,
			id_cliente integer NOT NULL,
			PRIMARY KEY (id_pedido),
			CONSTRAINT id_empleado FOREIGN KEY (id_empleado)
				REFERENCES public.empleado (id_persona) MATCH SIMPLE
				ON UPDATE CASCADE
				ON DELETE CASCADE
				NOT VALID,
			CONSTRAINT id_cliente FOREIGN KEY (id_cliente)
				REFERENCES public.cliente (id_persona) MATCH SIMPLE
				ON UPDATE CASCADE
				ON DELETE CASCADE
				NOT VALID
		)
		WITH (
			OIDS = FALSE
		);

	
	
	Creacion de la tabla producto:
		
		CREATE TABLE public.producto
		(
			id_producto integer NOT NULL,
			nombre character varying(150) NOT NULL,
			descripcion character varying(400),
			precio numeric(9, 2) NOT NULL,
			categoria character varying(150),
			proveedor character varying(150)[],
			PRIMARY KEY (id_producto)
		)
		WITH (
			OIDS = FALSE
		);

		
	Creacion de la tabla tienen:
	
		CREATE TABLE public.tienen
		(
			id_producto integer NOT NULL,
			id_pedido integer NOT NULL,
			cantidad smallint NOT NULL,
			precio numeric(9, 2) NOT NULL,
			PRIMARY KEY (id_producto, id_pedido),
			CONSTRAINT id_producto FOREIGN KEY (id_producto)
				REFERENCES public.producto (id_producto) MATCH SIMPLE
				ON UPDATE CASCADE
				ON DELETE CASCADE
				NOT VALID,
			CONSTRAINT id_pedido FOREIGN KEY (id_pedido)
				REFERENCES public.pedido (id_pedido) MATCH SIMPLE
				ON UPDATE CASCADE
				ON DELETE CASCADE
				NOT VALID
		)
		WITH (
			OIDS = FALSE
		);
		
		
		proveedor character varying(150)[]   cuadno uno dice eso se refiere a que por cada descripcio estan permitidas hasta 150 caracteres.??
		
		
		
		
	EJERCICIO 1.
	
		b) Inserte los siguientes registros en cada una de las tablas. Utilice transacciones por cada tabla
		
		INCERCIONES EN LA TABLA EMPLEADOS
		
			BEGIN;
				INSERT INTO empleado (id_persona, nombre, dni, domicilio, email, telefono, cargo, sector, legajo, sueldo)
				VALUES (1, 'VILCARROMERO, ERICK', 17130935, ROW('AV SANTA ROSA', 1177, 'S.M.TUC', 'TUCUMAN'), ARRAY['vil@gmail.com', 'vilco@live.com'],
				ARRAY['4319842', '42455540', '4444444', '381555414'], cajero, 'Ventas', 1232, 150000);

				INSERT INTO empleado (id_persona, nombre, dni, domicilio, email, telefono, cargo, sector, legajo, sueldo)
				VALUES (SELECT MAX(id_persona) FROM persona)+1, 'MUNIZ, SILVIA', 27418519, ROW('AV. AREQUIPA', 2288, 'SALTA', 'SALTA'), ARRAY['muniz@gmail.com', 'silvi@gmail.com'],
				ARRAY['4404170', '4211111', '4222222', '38154848'], gerente, 'Gerencia', 1002, 192000);

			COMMIT;
		
		
		INCERCIONES EN LA TABLA CLIENTE
			
			BEGIN;
			
				INSERT INTO cliente (id_persona, nombre, dni, domicilio, email, telefono, cta_cte)
				VALUES ((SELECT MAX(id_persona) FROM persona)+1, 'JARUFE, ERNESTO', 31569934, ROW('LAS BEGONIAS', 451, 'LA PLATA', 'BS. AS'),
						ARRAY['jarus@gmail.com'], array['4999999', '4525252'], 1515);
				
				ROLLBACK TO primeraIncert;
				
				INSERT INTO cliente (id_persona, nombre, dni, domicilio, email, telefono, cta_cte)
				VALUES ((SELECT MAX(id_persona) FROM persona)+1, 'HUAPAYA, CLAUDIA', 23185175, ROW('COLOMBIA ', 395, 'SALTA', 'SALTA'),
						ARRAY['huap@gmail.com', 'laud@gmail.com'], array['4828283', '4979797'], 1254);
						
				INSERT INTO cliente (id_persona, nombre, dni, domicilio, email, telefono, cta_cte)
				VALUES ((SELECT MAX(id_persona) FROM persona)+1, 'VASQUEZ, JUAN', 44125608, ROW('AV PASEO DE LA REPUBLICA ', 3755, 'SALTA', 'SALTA'),
						ARRAY['vazquez@gmail.com', 'juan@gmail.com'], array['4044444', '4555555', '4666666'], NULL);
						
				INSERT INTO cliente (id_persona, nombre, dni, domicilio, email, telefono, cta_cte)
				VALUES ((SELECT MAX(id_persona) FROM persona)+1, 'RAMES, MAYRA', 12113059, ROW('J.P FERNANDINI ', 1140, 'LA PLATA', 'BS. AS'),
						ARRAY['rames@gmail.com'], array['4333333', '4181818'], 3321);
				
				INSERT INTO cliente (id_persona, nombre, dni, domicilio, email, telefono, cta_cte)
				VALUES ((SELECT MAX(id_persona) FROM persona)+1, 'ABON, ALFREDO ', 29085527, ROW('AV BOLIVIA', 1157, 'S.M.TUC', 'TUCUMAN'),
						ARRAY['abon@gmail.com', 'abon@live.com'], array['4123456', '4234567', '4345678'], NULL);
			
			COMMIT;
			
			
		INCERCIONES EN LA TABLA PRODUCTOS
			
			BEGIN;

				INSERT INTO producto (id_producto, nombre, descripcion, precio, categoria, proveedor)
				VALUES (1, 'Coca cola', 'Botella 1.5 litros', 480.00, 'Bebidas', ARRAY['DistriTuc', 'coca cola s.a.']);

				INSERT INTO producto (id_producto, nombre, descripcion, precio, categoria, proveedor)
				VALUES ((SELECT MAX(id_producto) FROM producto)+1, 'Yogurisimo', 'Yogurt gusto frutilla 1 lt', 575, 'Lácteos', ARRAY['Lacteos s.a.', 'la serenisima']);
				
				INSERT INTO producto (id_producto, nombre, descripcion, precio, categoria, proveedor)
				VALUES ((SELECT MAX(id_producto) FROM producto)+1, 'Hamburguesas', 'Pack x 4 ', 620, 'Barnes', ARRAY['Paty s.a.', 'distriBurguer']);
			
				INSERT INTO producto (id_producto, nombre, descripcion, precio, categoria, proveedor)
				VALUES ((SELECT MAX(id_producto) FROM producto)+1, 'Pepsi cola', 'Botella 2.25 litros', 520.00, 'Bebidas', ARRAY['DistriTuc', 'Pepsico']);
				
				INSERT INTO producto (id_producto, nombre, descripcion, precio, categoria, proveedor)
				VALUES ((SELECT MAX(id_producto) FROM producto)+1, 'Yogurisimo cereal', 'Yogurt gusto frutilla 159gr ', 250.50, 'Cereales', ARRAY['Lacteos s.a.', 'la serenisima']);
			
			/*ROLLBACK;*/
			COMMIT;
			
			
			
			
			begin;
			
				CREATE TABLE tienenPrecioMenor (
				CHECK (precio >= 50000)
					CONSTRAINT 'pk1' PRIMARY KEY (id_producto, id_pedido)
				) INHERITS (tienen);

			rollback;
			
			Al momento de crear las particiones en la tabla tienen, en que conviene centrarse mas: en la cantidad o en el precio.? 
			o deveria calcular el total y de acuerdo a el particionar.?
			
			se lo puede hacer mediante interfaz grafica.?
			
			como hago si mi pk en tienen esta formada por dos campos.? 
			en el ejemplo de la teoria solo esta formada por uno...
			
			como defino la pk de la nueva tabla en si...
			solo se puede particionar por un campo o se puede llegar a hacer una particion por varios campos.??
			
			Como se realiza el analisis para la eleccion del campo a travez del cual se creara la particion.?
			en el caso del ejemplo de la teoria: cada año se deveria crear una tabla nueva.?
			
								&&&&&&&&&&&&&&&&&&&&&&&&&&&&
								%%                        %%
								%%          #####         %%
								%%       ###     ###      %%      
								%%            ###         %%
								%%           ##           %%
								%%                        %%
								%%           #            %%
								%%                        %%
								%%%%%%%%%%%%%%%%%%%%%%%%%%%%
								
		EJERCICIO 1
		c) Suponiendo que las tablas “pedido” y “tiene”, tienen muchos registros, usando herencia proponga e implemente particiones en ambas tablas.

		CREACION DE LAS PARTICONES EN LA TABLA PEDIDOS
			
			
			BEGIN;
			
				CREATE TABLE pedidos2020 (
				CHECK (fecha >= '2020-01-01' AND fecha < '2020-12-31'),
				CONSTRAINT "pk1" PRIMARY KEY (id_pedido)
				) INHERITS (pedido);

				CREATE TABLE factura2021 (
				CHECK (fecha >= '2021-01-01' AND fecha < '2021-12-31'),
				CONSTRAINT "pk2" PRIMARY KEY (id_pedido)
				) INHERITS (pedido);
				
				
				CREATE TABLE pedidos2022 (
				CHECK (fecha >= '2022-01-01' AND fecha < '2022-12-31'),
				CONSTRAINT "pk3" PRIMARY KEY (id_pedido)
				) INHERITS (pedido);

				CREATE TABLE pedidos2023 (
				CHECK (fecha >= '2023-01-01' AND fecha < '2023-12-31'),
				CONSTRAINT "pk4" PRIMARY KEY (id_pedido)
				) INHERITS (pedido);
				
			/*rollback;*/
			COMMIT;
		
		ALTER TABLE public.factura2021
    		RENAME TO pedidos2021;
		
		/*jeje eso me pasa por copiar y pegar*/
		
		
		
		
		INCERCION DE LOS DATOS EN LAS PARTICIONES DE LA TABLA PEDIDOS
			
			BEGIN;
				INSERT INTO pedidos2021
				VALUES (1, '2021-03-25', 3136.25, 1, 4)

				INSERT INTO pedidos2022
				VALUES (18200, '2022-08-16', 5652.21, 1, 4)

				INSERT INTO pedidos2023
				VALUES (35300 , '2023-03-15', 12087.47, 1, 4)

			/*rollback;*/
			COMMIT;
			
			
			
			
			
			
	Ejercicio 2: En la base de datos HOSPITAL, cree los tipos de datos que cumplan con los siguientes
	requerimientos:
	
	a) Id, nombre y apellido del paciente, sigla y nombre de la obra social de los pacientes.
	
		CREATE TYPE public."ObraSocialPaciente" AS
		(
			id_paciente integer,
			nombre_paciente character varying(100),
			apellido_paciente character varying(100),
			sigla_obra_social character varying(12),
			nombre_obra_social character varying(100)
		);

	
	b) Id, nombre, apellido, fecha de ingreso, cargo y especialidad de los empleados.
		
		CREATE TYPE public."CargoEspecialidadEmpleados" AS
		(
			id_empleado integer,
			"nombreEmpleado" character varying(100),
			"apellidoEmpleado" character varying(100),
			"fechaIngreso" date,
			id_cargo integer,
			id_especialidad integer
		);


	c) Código, nombre, stock y clasificación de los medicamentos, además, el nombre del laboratorio
	que los produce.
	*/
		
		CREATE TYPE public.StockMedicamentos AS
(
	id_medicamento integer,
	nombreMedicamento character varying(50),
	stockMedicamento integer,
	id_lavoratorio integer
);

ALTER TYPE public.StockMedicamentos
    OWNER TO postgres;
	


