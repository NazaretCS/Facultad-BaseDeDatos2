/*

	Ejercicio nro. 1:
	Agregue un nuevo registro en la tabla consulta.
	
		BEGIN;

			INSERT INTO persona (id_persona, nombre, apellido, dni, fecha_nacimiento, domicilio, telefono)
			VALUES ( (SELECT MAX(id_persona) FROM persona) +1, 'ALEJANDRA', 'HERRERA', '7366992', '1992-06-20', 'SAN JUAN 258', '54-381-326-1780');

			/* SAVEPOINT InserPersona; */

			INSERT INTO paciente (id_paciente, id_obra_social)
			VALUES ( (SELECT MAX(id_persona) FROM persona), 137 );

			/*rollback to InserPersona;*/

			INSERT INTO consulta (id_paciente, id_empleado, fecha, id_consultorio, hora, resultado)
			VALUES ( (SELECT MAX(id_paciente) FROM paciente), 253, '2023-03-23', 5, '14:14:00', 'SE DIAGNOSTICA DERMATITIS');

		COMMIT; 
	
	
	
	Ejercicio nro. 2:
	Modifique el precio de todos los medicamentos cuya clasificación sea “ANALGESICO” (de cualquier tipo), siguiendo los
	criterios según el laboratorio.
	
		BEGIN;

			UPDATE medicamento
			SET precio = (precio + (( precio * 2 )/ 100))
			WHERE 	 id_medicamento IN (
										 SELECT id_medicamento FROM medicamento
										 INNER JOIN clasificacion USING(id_clasificacion)
										 INNER JOIN laboratorio USING(id_laboratorio)
										 WHERE clasificacion LIKE '%ANALGESICO%' AND laboratorio LIKE '%ABBOTT LABORATORIOS%'
										);

			/*ROLLBACK;*/

			UPDATE medicamento
			SET precio = precio - (( precio * 3.5 )/ 100)
			WHERE id_medicamento IN (
									  SELECT id_medicamento FROM medicamento
									  INNER JOIN clasificacion USING(id_clasificacion)
									  INNER JOIN laboratorio USING(id_laboratorio)
									  WHERE clasificacion LIKE '%ANALGESICO%' AND laboratorio LIKE '%BAYER QUIMICAS UNIDAS S.A.%'
									);


			SAVEPOINT medicamento1;


			UPDATE medicamento
			SET precio = precio + (( precio * 8 )/ 100)
			WHERE id_medicamento IN (
									  SELECT id_medicamento FROM medicamento
									  INNER JOIN clasificacion USING(id_clasificacion)
									  INNER JOIN laboratorio USING(id_laboratorio)
									  WHERE clasificacion LIKE '%ANALGESICO%' AND laboratorio LIKE '%COFANA (CONSORCIO FARMACEUTICO NACIONAL)%'
									);

			UPDATE medicamento
			SET precio = precio - (( precio * 4 )/ 100)
			WHERE id_medicamento IN (
									  SELECT id_medicamento FROM medicamento
									  INNER JOIN clasificacion USING(id_clasificacion)
									  INNER JOIN laboratorio USING(id_laboratorio)
									  WHERE clasificacion LIKE '%ANALGESICO%' AND laboratorio LIKE '%FARPASA FARMACEUTICA DEL PACIFICO%'
									);

			SAVEPOINT medicamento2;

			UPDATE medicamento
			SET precio = precio - (( precio * 10.2 )/ 100)
			WHERE id_medicamento IN (
									  SELECT id_medicamento FROM medicamento
									  INNER JOIN clasificacion USING(id_clasificacion)
									  INNER JOIN laboratorio USING(id_laboratorio)
									  WHERE clasificacion LIKE '%ANALGESICO%' AND laboratorio LIKE '%RHONE POULENC ONCOLOGICOS%'
									);

			/*ROLLBACK TO medicamento2;*/

			UPDATE medicamento
			SET precio = precio + (( precio * 5.5 )/ 100)
			WHERE id_medicamento IN (
									  SELECT id_medicamento FROM medicamento
									  INNER JOIN clasificacion USING(id_clasificacion)
									  INNER JOIN laboratorio USING(id_laboratorio)
									  WHERE clasificacion LIKE '%ANALGESICO%' AND laboratorio LIKE '%ROEMMERS%'
									);

			SAVEPOINT medicamento3;

			UPDATE medicamento
			SET precio = precio + (( precio * 7 )/ 100)
			WHERE id_medicamento NOT IN (
									  SELECT id_medicamento FROM medicamento
									  INNER JOIN clasificacion USING(id_clasificacion)
									  INNER JOIN laboratorio USING(id_laboratorio)
									  WHERE clasificacion LIKE '%ANALGESICO%' AND laboratorio IN ('ABBOTT LABORATORIOS', 'BAYER QUIMICAS UNIDAS S.A.', 'COFANA (CONSORCIO FARMACEUTICO NACIONAL)',
																								  'FARPASA FARMACEUTICA DEL PACIFICO', 'RHONE POULENC ONCOLOGICOS', 'ROEMMERS')
									);

		COMMIT;
	
	
	
	Ejercicio nro. 3:
	Agregue los registros en las tablas.
		
		BEGIN;
		
			INSERT INTO estudio_realizado (id_paciente, id_estudio, fecha, resultado, observacion, id_equipo, id_empleado, precio)
			VALUES (175363, 24, '2023-04-01', 'NORMAL', 'NO SE OBSERVAN IRREGULARIDADES', 15, 522, 3526.00);

			/*ROLLBACK;*/
			SAVEPOINT primera;

			INSERT INTO tratamiento (id_paciente, id_medicamento, fecha_indicacion, prescribe, nombre, descripcion, dosis,  costo)
			VALUES (175363, 1532, '2023-04-03', 253, 'AFRIN ADULTOS SOL', 'FRASCO X 15 CC', 1, 1821.79);

			/*ROLLBACK TO primera;*/

			INSERT INTO tratamiento (id_paciente, id_medicamento, fecha_indicacion, prescribe, nombre, descripcion, dosis, costo)
			VALUES (175363, 1560, '2023-04-03', 253, 'NAFAZOL', 'FRASCO X 15 ML', 2, 1850.96);

			INSERT INTO tratamiento (id_paciente, id_medicamento, fecha_indicacion, prescribe, nombre, descripcion, dosis, costo)
			VALUES (175363, 1522, '2023-04-03',  253, 'VIBROCIL GOTAS NASALES', 'FRASCO X 15 CC', 2, 2500.66);

			SAVEPOINT segundas;

			INSERT INTO internacion (id_paciente, id_cama, fecha_inicio, ordena_internacion, fecha_alta, hora, costo)
			VALUES (175363, 157, '2023-04-03',  253, '2023-06-04',  '11:30:00', '160000.00')

			/*ROLLBACK TO segundas;*/

		COMMIT;
	
	
	
	
	
	Ejercicio nro. 4:
	Agregue en la tabla factura, la facturación realizada al paciente HERRERA, ALEJANDRA por todos los servicios prestados
	en el mes de abril de 2023.
	
	
	BEGIN;
		
		SELECT * FROM persona 
		INNER JOIN paciente ON id_paciente = id_persona
		INNER JOIN factura USING (id_paciente)
		WHERE nombre = 'ALEJANDRA' AND apellido LIKE '%HERRERA%'
		
		INSERT INTO factura (id_factura, id_paciente, fecha, hora, monto, pagada, saldo)
		VALUES ( (SELECT MAX(id_factura) FROM factura)+1, ( SELECT id_persona FROM persona 
															 WHERE nombre = 'ALEJANDRA' AND apellido LIKE '%HERRERA%'), 
			    '2023-04-06', '16:44:00', 169699.41, 'N', 169699 )
	
	COMMIT;
	/*ROLLBACK;*/
	
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
									
						Consultar: 
								   1) Devo hacer una sola incersion por toda la factura o una por cada apartado de los detalles
								   	1 Sola incersion.
									
								   2) Que hago con el dato hora que no esta en la factura.
								   	Se le pone cualquiera.
									
								   3) Seria lo mismo sacar el id_paciente de estas dos formas:
								   		SELECT id_persona FROM persona 
										WHERE nombre = 'ALEJANDRA' AND apellido = 'HERRERA'
										
										SELECT id_paciente FROM paciente
										INNER JOIN persona ON id_persona = id_paciente
										WHERE nombre = 'ALEJANDRA' AND apellido = 'HERRERA'
										
									  (ambas consultas dan el mismo id)
									  
									  Datos ramdom: El monto es lo que le estas cobrando, si recien se la esta creando a la consulta
									  				no hay chance de que este pagada. 


	Ejercicio nro. 6:	
	Ingresan a mantenimiento las siguientes camas y equipos.
	
		Camas: 53, 111, 163		   El estado de los mismos debe ser EN REPARACION, modifique y 
		Equipos: 12, 30             agregue los registros correspondientes con la fecha de hoy.
	
	

	
	BEGIN;
	
		INSERTT INTO mantenimiento_cama (id_cama, fecha_ingreso, observacion, estado, fecha_egreso, demora, id_empleado)
		VALUES ( 53, '2023-04-23', 'sin novedad', 'En reparacion', '', 0, 801 );
		
		INSERT INTO mantenimiento_cama (id_cama, fecha_ingreso, observacion, estado, fecha_egreso, demora, id_empleado)
		VALUES ( 111, '2023-04-23', 'sin novedad', 'En reparacion', '', 0, 143 );
		
		INSERT INTO mantenimiento_cama (id_cama, fecha_ingreso, observacion, estado, fecha_egreso, demora, id_empleado)
		VALUES ( 163, '2023-04-23', 'sin novedad', 'En reparacion', '', 0, 143 );
		
		INSERT INTO mantenimiento_equipo (id_equipo, fecha_ingreso, observacion, estado, fecha_egreso, demora, id_empleado)
		VALUES ( 12, '2023-04-23', 'sin novedad', 'En reparacion', '', 0, 801 )
		
		INSERT INTO mantenimiento_equipo (id_equipo, fecha_ingreso, observacion, estado, fecha_egreso, demora, id_empleado)
		VALUES ( 30, '2023-04-23', 'sin novedad', 'En reparacion', '', 0, 801 )
		
		
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
									
							Puedo poner cualquier cosa en los datos q no estan espesificados.?
							(Todavia no esta ejecutado el punto)
							
							En el relacional, las fk que se muestran abajo es porque pueden llegar a ser nulas.
							Los datos que no estan fijarse si pueden ser nulos. Ya era digamos jajaja la agrege pagada 
		
		
	Ejercicio nro. 7:
	Realice una transacción que agregue los espesificados registros en la tabla compras.
		
		BEGIN;
			
			INSERT INTO compra (id_medicamento, id_proveedor, fecha, id_empleado, precio_unitario, cantidad)
			VALUES (
					(SELECT id_medicamento FROM medicamento
					 WHERE nombre = 'BILICANTA'),					
					(SELECT id_proveedor FROM proveedor
					 WHERE proveedor = 'MEDIFARMA'),
					'2023-04-19', 801, 
					(((SELECT precio FROM medicamento
					 WHERE nombre = 'BILICANTA') * 70) / 100),
					240
				   );
			
			INSERT INTO compra (id_medicamento, id_proveedor, fecha, id_empleado, precio_unitario, cantidad)
			VALUES (
					(SELECT id_medicamento FROM medicamento
					 WHERE nombre = 'IRRITREN 200 MG'),					
					(SELECT id_proveedor FROM proveedor
					 WHERE proveedor = 'DIFESA'),
					'2023-04-19', 801, 
					(((SELECT precio FROM medicamento
					 WHERE nombre = 'IRRITREN 200 MG') * 70) / 100),
					90
				   );
			
			INSERT INTO compra (id_medicamento, id_proveedor, fecha, id_empleado, precio_unitario, cantidad)
			VALUES (
					(SELECT id_medicamento FROM medicamento
					 WHERE nombre = 'PEDIAFEN JARABE'),					
					(SELECT id_proveedor FROM proveedor
					 WHERE proveedor = 'REYES DROGUERIA'),
					'2023-04-19', 801, 
					(((SELECT precio FROM medicamento
					 WHERE nombre = 'PEDIAFEN JARABE') * 70) / 100),
					150
				   );
				   
		/*ROLLBACK;*/
		COMMIT;
	
	
	
	Ejercicio nro. 8:
	a) Escriba una transacción para eliminar al paciente 175363.
		
		BEGIN;
			
			DELETE FROM paciente
			WHERE id_paciente = 175363
			
			/*
				ERROR:  update o delete en «paciente» viola la llave foránea «Refpaciente101» en la tabla «estudio_realizado»
				DETAIL:  La llave (id_paciente)=(175363) todavía es referida desde la tabla «estudio_realizado».
				SQL state: 23503
				
				Para solucionar el error deveria borrar tabla por tabala al paciente para asi eliminar las relaciones creadas.
				
				
			*/

		ROLLBACK;
	
	
	
	b) Escriba una transacción para eliminar al medicamento "SALBUTOL GOTAS".
	
		BEGIN;
			
			DELETE FROM medicamento
			WHERE nombre = 'SALBUTOL GOTAS';
			
			/*
				ERROR:  update o delete en «medicamento» viola la llave foránea «Refmedicamento11» en la tabla «compra»
				DETAIL:  La llave (id_medicamento)=(867) todavía es referida desde la tabla «compra».
				SQL state: 23503
			*/
		ROLLBACK;
		
		
		
		Ejercicio nro. 5:
		
			CREATE ROLE "Nazaret2" WITH
			LOGIN
			SUPERUSER
			CREATEDB
			CREATEROLE
			INHERIT
			NOREPLICATION
			CONNECTION LIMIT -1
			PASSWORD 'xxxxxx'; /* nazaret */
			
			
			PERSONA 1
			
		a) Trabaje de a 2 en el servidor (en caso de tener problemas trabaje en la BD local con 2 query tool conectadas cada una con un 
		   usuario distinto) y realicen:
		   
		   Persona 1 muestre todos los campos de la patología 1. Que datos se ven?
		   	
				SELECT * FROM patologia
				WHERE id_patologia = 1
			
				Se ven el dato de la PK y el nombre de la patologia (los campos de la tabla digamos)
			
			
			Persona 1 vuelva a mostrar los campos de la patología 1. Que datos se ven?
			
				SELECT * FROM patologia
				WHERE id_patologia = 1
				
				Se siguen viendo los mismos campos, por mas que se halla iniciado la transaccion.
				
			Persona 1 vuelva a mostrar los campos de la patología 1. Que datos se ven?
				
				SELECT * FROM patologia
				WHERE id_patologia = 1
				
				Se ven los mismos campos, pero ahora luego de realizarse el commit se actualizo el nombre de la patologia, y 
				ahora muestra mi nombre
			
			Responda que nivel de aislamiento tuvo la transacción
				
				El nivel de aislamiento que tuvo la transaccion es el que tiene postgresql por defecto:
				El nivel de aislamiento por defecto de una transacción en el SQL estándar es SERIALIZABLE. En PostgreSQL el 
				valor por defecto es READ COMMITTED, además trata a READ UNCOMMITTED cómo READ COMMITTED. 
			
*/		
		
			
	
	