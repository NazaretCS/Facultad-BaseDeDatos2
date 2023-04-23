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
	
	
	
	
	
	INSERT INTO articulo (id_articulo, id_autor, id_editorial, id_genero, titulo, duracion_paginas, anio,
	precio, id_origen, id_proveedor)	
	VALUES ((SELECT MAX(a.id_articulo) FROM articulo a)+1,(SELECT a.id_autor FROM autor a WHERE
	autor = 'Paul Beynon-Davies'),(SELECT e.id_editorial FROM editorial e WHERE editorial = 'Editorial
	Reventé'),(SELECT g.id_genero FROM genero g WHERE genero = 'Informatica'),'Sistemas de Bases
	de Datos',686,2010,24.954,(SELECT o.id_origen FROM origen o WHERE origen = 'U.K'),10);}
	
	INSERT INTO autor (id_autor,autor,tipo)
	VALUES ((SELECT MAX(a.id_autor) FROM autor a)+1,'Dolores Cuadra','autor');
	
	
	Ejercicio nro. 4:
	Agregue en la tabla factura, la facturación realizada al paciente HERRERA, ALEJANDRA por todos los servicios prestados
	en el mes de abril de 2023.
	
	
	BEGIN;
		
		INSERT INTO factura (id_factura, id_paciente, fecha, hora, monto, pagada, saldo)
		VALUES ( (SELECT MAX(id_paciente) FROM paciente)+1, ( SELECT id_persona FROM persona 
															 WHERE nombre = 'ALEJANDRA' AND apellido LIKE '%HERRERA%'), 
			    '2023-04-06', '16:44:00', 169699.41, 'S', 0.00 )
	
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
								   2) Que hago con el dato hora que no esta en la factura.
								   3) Seria lo mismo sacar el id_paciente de estas dos formas:
								   		SELECT id_persona FROM persona 
										WHERE nombre = 'ALEJANDRA' AND apellido = 'HERRERA'
										
										SELECT id_paciente FROM paciente
										INNER JOIN persona ON id_persona = id_paciente
										WHERE nombre = 'ALEJANDRA' AND apellido = 'HERRERA'
										
									  (ambas consultas dan el mismo id)
*/
	
	
	