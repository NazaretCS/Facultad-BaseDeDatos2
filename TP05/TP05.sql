/*

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
		
		
		
		


		
	
*/
