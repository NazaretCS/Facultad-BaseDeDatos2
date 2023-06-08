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
		   
		   
	
	
*/	