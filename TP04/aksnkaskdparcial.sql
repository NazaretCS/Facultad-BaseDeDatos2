/*
	EJERCICIO N° 1: Tipos de datos e índices
		a) Indique el tipo de dato adecuado cada uno de los campos de las tablas Comentarios e Tipos_autores
		
			Tabla Comentarios:
				id_comentario: Integer
				id_noticias (fk): Integer
				id_autor (fk): integer
				id_usuario (fk): integer
				comentario: characterVarying(200)
				puntaje: numeric(10,2)
				fecha: date
				baja: bool
				
			Tipos_autores:
				id_tipo_autor: smallint
				tipo: characterVarying(100)
				sueldo:	numeric(9,2)
				
								
								Tipo Numeric: (mantiza, precicion)
								Consultar si no podria ir Money
				Van saliendo de circulacion el tupo de dato money, esta quedadno deprecado, por eso es mejor 
								ponerlo como numeric
								
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
	
		b) ¿Qué índice/s propone para la tabla Noticias? ¿Por qué?
			
			 	Indices por fecha y por titulo
				De los campos de la tabla noticia creo son los que mas resaltan y los que menos repeticiones tendran entre si. Me es 
				conveniente.
				
		c) ¿Cuál de los siguientes índices considera es más efectivo para la tabla Comentarios, (puntaje, fecha) o (fecha, puntaje)?
		   Justifique su respuesta.
				
				 (fecha, puntaje)
				 de esta manera concidero que sera mas efectivo dado que a lo largo de un dia, por ejemplo, se pueden crear muchos puntajes.
				 osea seria menos efectivo.
				 
				 
				 
				 
	EJERCICIO N° 2: Permisos
	
		Trabaje con la base de datos de Hospital. Realice las siguientes consultas e indique qué permisos y sobre qué tablas debe tener el 
		usuario User1 para poder llevar a cabo las siguientes tareas:
		
		a) Muestre el nombre, apellido y cargo de los empleados que repararon las camas de las habitaciones TRIPLES del piso 5 en menos de 
		   50 días.



		   SELECT * FROM empleado
		   INNER JOIN persona ON id_persona = id_empleado
		   INNER JOIN mantenimiento_cama USING(id_empleado)
		   INNER JOIN cama USING(id_cama)
		   INNER JOIN habitacion USING(id_habitacion)
		   WHERE tipo LIKE '%DOBLES PRIVADA%'
		   
		   
		   
		   select * from cama
		   select * from habitacion 
		   
	
	
	












Especialidad: ANATOMOPATOLOGÍA

Cargo: MEDICO ANATOMOPATOLOGO

Fecha de ingreso: 04-05-2023

Sueldo: 350000.00

Fecha de baja:  --


	BEGIN;
		INSERT INTO persona (id_persona, nombre, apellido, dni, fecha_nacimiento, domicilio, telefono)
		VALUES ((SELECT MAX(id_persona) FROM persona) +1, 'BRUCE', 'BANNER', '12122211', '1962-05-01', 'MARVEL STUDIOS', '99999999');
		SAVEPOINT insercionPersona;
		INSERT INTO empleado (id_empleado, id_especialidad, id_cargo, fecha_ingreso, sueldo, fecha_baja)
		VALUES ((SELECT MAX(id_persona) FROM persona), (SELECT id_especialidad FROM especialidad WHERE especialidad LIKE '%ANATOMOPATOLOGÍA%'),
		        (SELECT id_cargo FROM cargo WHERE cargo LIKE '%MEDICO ANATOMOPATOLOGO%'), '2023-05-04', '350000.00', NULL);
		/*ROLLBACK TO insercionPersona;*/
	/*ROLLBACK;*/
	COMMIT;
	*/
	
	BEGIN;
		DELETE FROM cama WHERE id_habitacion = 90;
		SAVEPOINT EliminacionDeCama;
		DELETE FROM habitacion WHERE id_habitacion = 90;
	ROLLBACK;