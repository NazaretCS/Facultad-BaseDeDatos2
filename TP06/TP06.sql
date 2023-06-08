/* EJEMPLO DEL PROFE EN CLASE

	CREATE OR REPLACE PROCEDURE internacion_alta(IN p_dni_paciente character varying(8),
												 IN p_id_cama smallint,
												 IN p_fecha_inicio date,
												 IN p_dni_medico character varying(8),
												 IN p_fecha_alta date,
												 IN p_hora time without time zone,
												 IN p_costo numeric(10,2))
	AS $$
	DECLARE
		v_existe_paciente boolean;
	BEGIN
		SELECT EXISTS(SELECT * FROM persona pe 
					  INNER JOIN paciente pa ON pe.id_persona = pa.id_paciente
					  WHERE dni = p_dni_paciente) INTO v_existe_paciente;

		IF NOT v_existe_paciente THEN
			RAISE EXCEPTION 'NO existe el paciente';
		END IF;

		INSERT INTO internacion VALUES(subconsulta, p_id_cama, p_fecha_inicio,
									subconsulta, p_fecha_alta, p_hora, p_costo);
		RAISE NOTICE 'Se insertó bien';
		EXCEPTION
			WHEN OTHERS THEN
			RAISE EXCEPTION 'No se pudo hacer el insert %', SQLERRM;
	END;
	$$ LANGUAGE plpgsql;



EJERCICIO 1

	a) Escriba un procedimiento almacenado (SP) para agregar registros a la tabla persona. Reciba
	todos los parámetros necesarios excepto el id (max + 1) que se deberá obtener dentro del SP.
	Muestre un mensaje de error si no se pudo realizar. Nombre sugerido: persona_alta

		CREATE OR REPLACE PROCEDURE persona_alta( IN p_nombre character varying(100),
												  IN p_apellido character varying(100),
												  IN p_dni character varying(8),
												  IN p_fecha_nacimiento date,
												  IN p_domicilio character varying(100),
												  IN p_telefono character varying(15))
		AS $$
		DECLARE
		  v_id_persona INT;
		BEGIN
		  /* Verificar si ya existe el paciente */
		  SELECT id_persona INTO v_id_persona
		  FROM persona
		  WHERE dni = p_dni;

		  IF v_id_persona IS NOT NULL THEN
			RAISE EXCEPTION 'La persona con DNI: % ya existe en la tabla persona.', p_dni;
		  END IF;
	
		  -- Insertar nuevo registro en la tabla persona
		  INSERT INTO persona (id_persona, nombre, apellido, dni, fecha_nacimiento, domicilio, telefono)
		  VALUES ((SELECT MAX(id_persona) FROM persona)+1, p_nombre, p_apellido, p_dni, p_fecha_nacimiento,
		  		   p_domicilio, p_telefono)
		  RETURNING id_persona INTO v_id_persona;
		  
		  -- Verificar si se insertaron correctamente los registros
		  IF v_id_persona IS NOT NULL THEN
			RAISE NOTICE 'Registros insertados correctamente. ID Persona: %', v_id_persona;
		  ELSE
			RAISE EXCEPTION 'No se pudo insertar el registro.';
		  END IF;
		END;
		$$ LANGUAGE plpgsql;

		CALL persona_alta('Nazaret', 'Campos', '43709133', '1990-01-01', '123 Main St', '');



	b) Escriba un SP para agregar registros en la tabla empleado, pase todos los campos por
	parámetro, respecto a los campos que son FK pase el DNI de la persona, el nombre de la
	especialidad y el nombre del cargo. Verifique que dichos datos existan para poder hacer el alta.
	Nombre sugerido: empleado_alta.
	
		CREATE OR REPLACE PROCEDURE empleado_alta (IN p_dni character varying(8),
												   IN p_nombreEspecialidad character varying(100),
												   IN p_nombreCargo character varying(100),
												   IN p_fecha_ingreso date,
												   IN p_sueldo numeric(9,2),
												   IN p_fecha_baja date
													)
		AS $$
			DECLARE 
			v_id_persona INT;
			v_id_especialidad INT;
			v_id_cargo INT;
			v_id_empleado INT;

			BEGIN
			/*verifico si la persona ya se encuentra en la bd*/
			SELECT id_persona INTO v_id_persona
			FROM persona 
			WHERE dni = p_dni;

			IF v_id_persona IS NULL THEN 
				RAISE NOTICE 'La persona con DNI: % no existe.', p_dni;
			END IF;

			/*verifico que la especialidad exista*/
			SELECT id_especialidad INTO v_id_especialidad
			FROM especialidad
			WHERE especialidad = p_nombreEspecialidad;

			IF v_id_especialidad IS NULL THEN
				RAISE NOTICE 'La especialidad % no coincide con las almacenadas.', p_nombreEspecialidad;
			END IF;

			/*Verifico la existencia del cargo*/
			SELECT id_cargo INTO v_id_cargo
			FROM cargo
			WHERE cargo = p_nombreCargo;

			IF v_id_cargo IS NULL THEN
				RAISE NOTICE 'El cargo % no coincide con los almacenados', p_nombreCargo;
			END IF;

			INSERT INTO empleado (id_empleado, id_especialidad, id_cargo, fecha_ingreso, sueldo, fecha_baja)
			VALUES (v_id_persona, v_id_especialidad, v_id_cargo, p_fecha_ingreso, p_sueldo, p_fecha_baja)
			RETURNING id_empleado INTO v_id_empleado;

			RAISE NOTICE 'Registro insertado correctamente en la tabla empleado. ID Empleado: %', v_id_empleado;
		END;
		$$ LANGUAGE plpgsql; 

		CALL empleado_alta('43709133', 'CLINICA', 'GERENTE', '2023-06-01', 2000.00, '2023-06-30');

	
	
	c) Realice un SP que permita modificar el saldo de una factura. Debe recibir como parámetro el
	id de la factura y el monto que se pagó que deberá ser descontado del saldo. Verifique que el
	número de factura exista (de momento no es necesario ningún otro control). Nombre suerido:
	factura_modifica_saldo.
	
		CREATE OR REPLACE PROCEDURE factura_modifica_saldo(IN p_id_factura integer,
													   IN p_monto numeric(10,2)
														) 
		AS $$
			DECLARE
				v_id_factura INT;
			BEGIN
				-- Verifico si la factura verdaderamente existe:
				SELECT id_factura INTO v_id_factura 
				FROM factura
				WHERE id_factura = p_id_factura;

				IF v_id_factura IS NULL THEN 
					RAISE NOTICE 'No existe la factura con id %', p_id_factura;
				END IF;

				UPDATE factura 
				SET saldo = saldo - p_monto
				WHERE id_factura = p_id_factura;

				RAISE NOTICE 'Saldo de la factura id % modificado correctamente.', p_id_factura;
			END;
		$$ LANGUAGE plpgsql; 

		SELECT * from factura
		where id_factura =939590

		CALL factura_modifica_saldo(939590, 32.00);

		SELECT * from factura
		where id_factura =939590
	
	
		d) Escriba un SP para modificar el precio de la tabla medicamento. La función debe recibir por
	parámetro, el nombre de un laboratorio y el porcentaje de aumento. Verifique que el
	laboratorio exista y modifique todos los medicamentos de ese laboratorio. Nombre sugerido:
	medicamento_modifica_por_laboratorio.
	
	
		CREATE OR REPLACE PROCEDURE medicamento_modifica_por_laboratorio (IN p_laboratorio_nombre character varying(50),
																		  IN p_porcentaje_aumento INTEGER)
		AS $$
			DECLARE
			v_id_laboratorio INT;
			
			BEGIN
				-- verfico la existencia del laboratorio...
				SELECT id_laboratorio INTO v_id_laboratorio 
				FROM laboratorio
				WHERE laboratorio = p_laboratorio_nombre;
				
				IF v_id_laboratorio IS NULL THEN
					RAISE NOTICE 'El laboratorio % no se encuentra almacenado', p_laboratorio_nombre;
					RETURN;
				END IF;
				
				UPDATE medicamento
				SET precio = precio + ((precio *p_porcentaje_aumento)/100)
				WHERE id_laboratorio = v_id_laboratorio;
				
				RAISE NOTICE 'Se han modificado los precios de los medicamentos del laboratorio "%"".', p_laboratorio_nombre;
			END;
		$$ LANGUAGE plpgsql
		
		CALL medicamento_modifica_por_laboratorio('ERREwwPE', 10);
		CALL medicamento_modifica_por_laboratorio('ERREPE', 10);
		
		Select * from medicamento
		where id_laboratorio IN (select id_laboratorio 
								 from laboratorio 
								 where laboratorio = 'ERREPE') AND id_medicamento IN (1311, 1363,1805);
								 --precios viejos: 1397, 732,744
								 -- precios nuevos: 1537, 805, 818
								 
		
		
		
	e) Realice un SP para eliminar un medicamento según su nombre. Recuerde que puede estar
	referenciado en otras tablas por lo que deberá hacer los delete necesarios para poder eliminar
	el medicamento. Nombre sugerido: medicamento_elimina


			CREATE OR REPLACE PROCEDURE medicamento_elimina(IN p_nombre_medicamento character varying (50))
			AS $$
				DECLARE
					v_id_medicamento INT;
				BEGIN

					SELECT id_medicamento INTO v_id_medicamento
					FROM medicamento
					WHERE nombre = p_nombre_medicamento;

					IF v_id_medicamento IS NULL THEN
						RAISE NOTICE 'No se encontro ningun medicamnto de nombre %', p_nombre_medicamento;
						RETURN;
					END IF;

					--elimino las referencias de las tablas compra y tratamiento
					DELETE FROM compra WHERE id_medicamento = v_id_medicamento;
					DELETE FROM tratamiento WHERE id_medicamento = v_id_medicamento;

					--elimino el medicamento
					DELETE FROM medicamento WHERE id_medicamento = v_id_medicamento;
					RAISE NOTICE 'Se ha eliminado el medicamento "%"', p_nombre_medicamento;
				END;
			$$ LANGUAGE plpgsql;

			CALL medicamento_elimina('ACETAM GOTAS');

			select * from medicamento
			where nombre = 'ACETAM GOTAS'


EJERCICIO 2
	Realice los siguientes procedimientos almacenados para que muestren la información solicitada.
	
	a) Un SP que muestre el nombre y apellido de un paciente según un DNI ingresado. 
	Nombre sugerido: paciente_obtener.
	
	
		CREATE OR REPLACE PROCEDURE paciente_obtener (IN p_dni character varying(8))
		AS $$
			DECLARE
				v_id_paciente INT;
				v_nombre character varying(100);
				v_apellido character varying(100);

			BEGIN
				SELECT id_paciente INTO v_id_paciente
				FROM paciente
				INNER JOIN persona ON id_persona = id_paciente
				WHERE dni = p_dni;

				IF v_id_paciente IS NULL THEN
					RAISE NOTICE 'No existe un paciente con DNI: %', p_dni;
					RETURN;
				END IF;

				SELECT nombre, apellido INTO v_nombre, v_apellido
				FROM persona
				INNER JOIN paciente ON id_persona = id_paciente
				WHERE id_paciente = v_id_paciente;

				RAISE NOTICE 'Nombre del paciente: % %', v_nombre, v_apellido;
			END;
		$$ LANGUAGE plpgsql;

		CALL paciente_obtener('43709133')
		CALL paciente_obtener('29995711')

		select * from paciente
		INNER JOIN persona ON id_persona = id_paciente
		where dni = '29995711'
		
		
		
	b) Un SP que muestre el precio y stock de un medicamente. Debe recibir como parámetro el
	nombre del medicamento. Nombre sugerido: medicamento_precio_stock.
	
		CREATE OR REPLACE PROCEDURE medicamento_precio_stock(IN p_nombre_medicamento character varying(100))
		AS $$
			DECLARE
				v_precio numeric(10, 2);
				v_stock integer;
			BEGIN
				SELECT precio, stock INTO v_precio, v_stock
				FROM medicamento
				WHERE nombre = p_nombre_medicamento;

				IF v_precio IS NULL OR v_stock IS NULL THEN
					RAISE NOTICE 'El medicamento con nombre: % no se encuentra almacenado', p_nombre_medicamento;
					RETURN;
				END IF;

				RAISE NOTICE 'Precio del medicamento %: %, Stock: %', p_nombre_medicamento, v_precio, v_stock;
			END;
		$$ LANGUAGE plpgsql;

		CALL medicamento_precio_stock('DORIssXINA')
		CALL medicamento_precio_stock('DORIXINA')
		select * from medicamento
		where nombre = 'DORIXINA'	
		
		
		
	c) Escriba un SP que muestre el total adeudado (campo saldo de las facturas) por un paciente,
	según un número de DNI ingresado. Nombre sugerido: paciente_deuda
	
		CREATE OR REPLACE PROCEDURE paciente_deuda(IN p_dni character varying(8))
		AS $$
			DECLARE
				v_total_deuda numeric(10, 2);
				v_id_paciente INT;

			BEGIN

				SELECT id_paciente INTO v_id_paciente
				FROM paciente 
				INNER JOIN persona ON id_persona = id_paciente
				WHERE dni = p_dni;

				IF v_id_paciente IS NULL THEN
					RAISE NOTICE 'No existe el paciente con DNI: %', p_dni;
					RETURN;
				END IF;

				-- uso coalesce para cubrir el caso en que la consulta devuleva NULL
				SELECT COALESCE(SUM(saldo), 0) INTO v_total_deuda
				FROM factura
				INNER JOIN paciente USING(id_paciente)
				INNER JOIN persona ON id_persona = id_paciente
				WHERE dni = p_dni;

				RAISE NOTICE 'Total adeudado por el paciente con DNI %: %', p_dni, v_total_deuda;
			END;
		$$ LANGUAGE plpgsql;

		CALL paciente_deuda('68858698');
		select * from paciente
		INNER JOIN persona ON id_persona = id_paciente
		inner join factura using(id_paciente)
		where dni = '68858698' 
		/* saldos : 35403.00 + 344.00 + 3306.00 + 408726.00 + 7395.00 = 455.174 */
		
		
		
	d) Realice un SP que muestre la cantidad de veces que una cama estuvo en mantenimiento, se
	debe mandar como parámetro el id de la cama. Nombre sugerido: cama_cantidad_mantenimiento.
	
		CREATE OR REPLACE PROCEDURE cama_cantidad_mantenimiento(IN p_id_cama INTEGER)
		AS $$
			DECLARE
				v_id_cama INT;
				v_cantidad_mantenimiento INTEGER;

			BEGIN
				SELECT id_cama INTO v_id_cama
				FROM mantenimiento_cama
				WHERE id_cama = p_id_cama;

				IF v_id_cama IS NULL THEN 
					RAISE NOTICE 'No existe la cama de ID: %', p_id_cama;
					RETURN;
				END IF;

				SELECT COUNT(id_cama) INTO v_cantidad_mantenimiento
				FROM mantenimiento_cama
				WHERE id_cama = p_id_cama;

				RAISE NOTICE 'La cama con ID: % estuvo en mantenimiento % veces.', p_id_cama, v_cantidad_mantenimiento;
			END;
		$$ LANGUAGE plpgsql;

		CALL cama_cantidad_mantenimiento(122222); --No existe
		CALL cama_cantidad_mantenimiento(1);	
		SELECT COUNT(id_cama) from mantenimiento_cama
		where id_cama = 1 -- 24 veces
		


EJERCICIO 3:
	Realice los siguientes procedimientos almacenados utilizando cursores.
	
		a) Realice un SP donde se listen todas las obras sociales con toda su información. Nombre
		sugerido: obra_social_listado

			CREATE OR REPLACE PROCEDURE obra_social_listado()
			AS $$
				DECLARE
					cursor_obras_sociales CURSOR FOR
										  SELECT *
										  FROM obra_social;
					v_id_obrea_social smallint;
					v_sigla character varying(15);
					v_nombre character varying(100);
					v_direccion character varying(100);
					v_localidad character varying(75);
					v_provincia character varying(100);
					v_telefono character varying(15);

				BEGIN
					OPEN cursor_obras_sociales;
					LOOP
						FETCH cursor_obras_sociales INTO v_id_obrea_social, v_sigla, v_nombre, v_direccion, v_localidad,
														 v_provincia, v_telefono;
						EXIT WHEN NOT FOUND;

						RAISE NOTICE '··· ID obra social: %, Sigla: %, Nombre: %, Dirección: %, Localidad: %, Provincia: %, Telefono: % ',
									  v_id_obrea_social, v_sigla, v_nombre, v_direccion, v_localidad, v_provincia, v_telefono;
					END LOOP;
					CLOSE cursor_obras_sociales;
				END;
			$$ LANGUAGE plpgsql;

			CALL obra_social_listado();
	
	
	
	b) Realice un SP donde se listen todas las camas cuyo estado sea “OK”. Nombre sugerido:
	cama_listado_ok
	
		CREATE OR REPLACE PROCEDURE cama_listado_ok()
		AS $$
			DECLARE
				cursor_camas CURSOR FOR 
							 SELECT * FROM cama
							 WHERE estado = 'OK'
							 ORDER BY tipo;
				v_id_cama smallint;
				v_tipo character varying(25);
				v_estado character varying(25);
				v_hay_registros boolean := false;

			BEGIN
				OPEN cursor_camas;
				LOOP
					FETCH cursor_camas INTO v_id_cama, v_tipo, v_estado;
					EXIT WHEN NOT FOUND;

					RAISE NOTICE 'ID cama: %, Tipo: %, Estado: %', v_id_cama, v_tipo, v_estado;
				END LOOP;	
				CLOSE cursor_camas;
			END;
		$$ LANGUAGE plpgsql;

		CALL cama_listado_ok()
		SELECT * FROM cama
		
		
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
								
						Consultar que pasaria o que se deveria hacer si la tabla esta vacia, y
						como se tomaria ese caso...
		
		
		
		
	c) Realice un SP que liste todos los medicamentos cuyo stock sea menor que 50. Nombre
	sugerido: medicamentos_poco_stock.

		CREATE OR REPLACE PROCEDURE medicamentos_poco_stock()
		AS $$
			DECLARE
				cursor_medicamentos_ps CURSOR FOR
												 SELECT * FROM medicamento
												 WHERE stock < 50
												 ORDER BY stock ASC;
				v_id_medicamento integer;
				v_id_clasificacion smallint;
				v_id_laboratorio smallint;
				v_nombre character varying(50);
				v_presentacion character varying(50);
				v_precio numeric(8,2);
				v_stock integer;
			BEGIN
				OPEN cursor_medicamentos_ps;
				LOOP
					FETCH cursor_medicamentos_ps INTO v_id_medicamento, v_id_clasificacion, v_id_laboratorio, v_nombre,
													  v_presentacion, v_precio, v_stock;
					EXIT WHEN NOT FOUND;

					RAISE NOTICE 'ID medicamento: %, Clasificacion: %, ID laboratorio: %, Nombre: % Presentación: %, Precio: %, Stock: %',
								 v_id_medicamento, v_id_clasificacion, v_id_laboratorio, v_nombre, v_presentacion, v_precio, v_stock;
				END LOOP;
				CLOSE cursor_medicamentos_ps;
			END;
		$$ LANGUAGE plpgsql;
		
		
	d) Escriba un SP que muestre todas las consultas realizadas en determinada fecha (no haga
	JOINS). Debe recibir por parámetro la fecha. Nombre sugerido: consulta_listado_por_fecha.

	
		CREATE OR REPLACE PROCEDURE obtener_nombre_apellido(IN p_id_persona INTEGER, out v_nombre_completo character varying(200))
		AS $$
			DECLARE
				v_nombre character varying(100);
				v_apellido character varying(100);

			BEGIN
				SELECT nombre, apellido INTO v_nombre, v_apellido
				FROM persona
				WHERE id_persona = p_id_persona;

				IF v_nombre IS NULL THEN
					RAISE NOTICE 'No se encontró ninguna persona con el ID: %', p_id_persona;
					RETURN;
				END IF;
				v_nombre_completo := v_apellido || ' ' || v_nombre;
			END;
		$$ LANGUAGE plpgsql;

		CALL obtener_nombre_apellido(1) -- "ARELI VERONICA" 

		/*DROP PROCEDURE obtener_nombre_apellido(integer)*/

		CREATE OR REPLACE PROCEDURE consulta_listado_por_fecha(IN p_fecha date)
		AS $$
			DECLARE
				cursor_fecha CURSOR FOR 
					SELECT * FROM consulta
					WHERE fecha = p_fecha;
				v_existe_consulta boolean;
				v_id_paciente integer;
				v_id_empleado integer;
				v_fecha date;
				v_id_consultorio smallint;
				v_hora time;
				v_resultado character varying(100);
				v_nombre_paciente character varying(200);
				v_nombre_empleado character varying(200);
			BEGIN
				SELECT EXISTS(SELECT * FROM consulta 
					WHERE fecha = p_fecha)
				INTO v_existe_consulta;

				IF NOT v_existe_consulta THEN
					RAISE EXCEPTION 'No existen consultas realizadas en la fecha %', p_fecha;
					RETURN;
				END IF;

				OPEN cursor_fecha;
				LOOP
					FETCH cursor_fecha INTO v_id_paciente, v_id_empleado, v_fecha, v_id_consultorio, v_hora, v_resultado;
					EXIT WHEN NOT FOUND;	

					CALL obtener_nombre_apellido(v_id_paciente, v_nombre_paciente);
					CALL obtener_nombre_apellido(v_id_empleado, v_nombre_empleado);
					RAISE NOTICE 'Nombre del paciente: %, Nombre del empleado que lo atendio: %, Fecha: %, Consultorio: %, Hora: %, Resultado: %',
								  v_nombre_paciente,v_nombre_empleado, v_fecha, v_id_consultorio, v_hora, v_resultado;
				END LOOP;
				CLOSE cursor_fecha;
			END;
		$$ LANGUAGE plpgsql;

		CALL consulta_listado_por_fecha('2019-01-01')
		select * from consulta
		
		
		
		
		
	e) Realice un SP que muestre el nombre y apellido de un paciente, la fecha y nombre de los
	estudios que se realizó. Debe recibir como parámetro el DNI del paciente. Nombre sugerido:
	estudio_por_paciente

		CREATE OR REPLACE PROCEDURE estudio_por_paciente(IN p_dni character varying (100))
		AS $$
			DECLARE
				v_id_paciente character varying (100);
				v_fecha_estudio date;
				v_nombre_estudio character varying (100);
				cursor_estudios CURSOR FOR
										   SELECT fecha, es.nombre
										   FROM estudio es
										   INNER JOIN estudio_realizado USING(id_estudio)
										   INNER JOIN paciente USING(id_paciente)
										   INNER JOIN persona pe ON id_paciente = id_persona
										   WHERE pe.dni = p_dni
										   ORDER BY fecha ASC;
			BEGIN
				SELECT id_paciente INTO v_id_paciente
				FROM estudio_realizado 
				INNER JOIN persona ON id_paciente = id_persona
				WHERE dni = p_dni;

				IF v_id_paciente IS NULL THEN
					RAISE NOTICE 'No existen estudios para el DNI %', p_dni;
				END IF;

				CALL paciente_obtener(p_dni);
				OPEN cursor_estudios;
				LOOP	
					FETCH cursor_estudios INTO v_fecha_estudio, v_nombre_estudio;
					EXIT WHEN NOT FOUND;

					RAISE NOTICE 'Fecha: %, Nombre Estudio: %', v_fecha_estudio, v_nombre_estudio;
				END LOOP;
				CLOSE cursor_estudios;

			END;		
		$$ LANGUAGE plpgsql;

		CALL estudio_por_paciente('58362446')
		SELECT * from paciente
		INNER JOIN estudio_realizado USING(id_paciente)
		INNER JOIN persona ON id_paciente = id_persona
		where dni = '58362446' -- 5 estudios
		
		
	
	
	f) Realice un SP que muestre el nombre, apellido y teléfono de los empleados que trabajan en
	un determinado turno. Debe recibir por parámetro el nombre del turno. Nombre sugerido:
	empleado_por_turno.
	
	
		CREATE OR REPLACE PROCEDURE empleado_por_turno(IN p_turno character varying(25))
		AS $$
			DECLARE 
				cursor_turno CURSOR FOR 
										SELECT nombre, apellido, telefono 
										FROM empleado
										INNER JOIN persona ON id_empleado = id_persona
										INNER JOIN trabajan USING(id_empleado)
										INNER JOIN turno USING(id_turno)
										WHERE turno = p_turno;
				v_nombre character varying(100);
				v_apellido character varying(100);
				v_telefono character varying(25);
				v_id_turno smallint;
			BEGIN

				SELECT id_turno INTO v_id_turno
				FROM turno
				WHERE turno = p_turno;

				IF v_id_turno IS NULL THEN
					RAISE NOTICE 'El turno ingresado: % no se encuentra almacenado', p_turno;
					RETURN;
				END IF;

				RAISE NOTICE 'TURNO:   %', p_turno;
				OPEN cursor_turno;
				LOOP
					FETCH cursor_turno INTO v_nombre, v_apellido, v_telefono;
					EXIT WHEN NOT FOUND;

					RAISE NOTICE 'Nombre del empleado: %, %. Teléfono: %', v_nombre, v_apellido, v_telefono;
				END LOOP;
				CLOSE cursor_turno;


			END;

		$$ LANGUAGE plpgsql;

		CALL empleado_por_turno('full'); -- 48 filas devueltas
		SELECT nombre, apellido, telefono 
		FROM empleado
		INNER JOIN persona ON id_empleado = id_persona
		INNER JOIN trabajan USING(id_empleado)
		INNER JOIN turno USING(id_turno)
		WHERE turno = 'full'; -- 48 filas devueltas
*/


		