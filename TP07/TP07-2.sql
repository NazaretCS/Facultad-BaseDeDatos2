/*
	EJERCICIO 1:
		Para mejorar y automatizar el funcionamiento de la base de datos “Hospital” realice las siguientes tareas
		
		a) Realice una función que permita modificar la fecha de ingreso o la fecha de baja de un
		empleado. Debe recibir como parámetros el dni del empleado, el nombre del campo a
		modificar (fecha_ingreso/fecha_baja) y el valor del nuevo campo. Recuerde controlar que el
		empleado a modificar exista, de lo contrario debe enviar un mensaje de error. Agregue más
		controles de ser necesario
					
			CREATE OR REPLACE FUNCTION fn_modificar_fehca_empleado(text, text, date) RETURNS void AS $$
				DECLARE
					p_dni ALIAS FOR $1;
					p_campo ALIAS FOR $2;
					p_nueva_fecha ALIAS FOR $3;
					v_id_empleado int;
					v_fecha_actual DATE := CURRENT_DATE; --Tomo la fecha actual para realizar un control...
				BEGIN
					SELECT id_empleado INTO v_id_empleado 
					FROM empleado
					INNER JOIN persona ON id_persona = id_empleado
					WHERE dni = p_dni;

					IF v_id_empleado IS NULL THEN
						RAISE EXCEPTION 'La persona con DNI: % no se encuentra registrada en la base de datos...', p_dni;  
					END IF;

					IF p_campo = 'fecha_ingreso' THEN 
						UPDATE empleado
						SET fecha_ingreso = p_nueva_fecha 
						WHERE id_empleado = v_id_empleado;
					ELSEIF p_campo = 'fecha_baja' THEN
						IF p_nueva_fecha < v_fecha_actual THEN
							RAISE EXCEPTION 'La % no se puede actualizar a un valor menor que la fecha actual', p_nueva_fecha;
						END IF;					
						UPDATE empleado
						SET fecha_baja = p_nueva_fecha 
						WHERE id_empleado = v_id_empleado;					
					ELSE
						RAISE NOTICE 'El campo a modifcar ingresado: % no es valido...',p_campo;
						RAISE EXCEPTION 'El campo a modificar deve ser: fecha_ingreso o fecha_baja';
					END IF;

					RAISE NOTICE 'La % del empleado con DNI % se modifico exitosamente', p_campo, p_dni;
				END;
			$$ LANGUAGE plpgsql;

			SELECT fn_modificar_fehca_empleado ('18354930', 'fecha_ingreso', '14-07-2022');

			select * from empleado
			inner join persona ON id_persona = id_empleado
			WHERE dni = '18354930' "2022-07-13"
		

				CREATE OR REPLACE FUNCTION modifcar_fecha_empleado(p_dni CHARACTER VARYING, 
																p_campo CHARACTER VARYING, 
																p_fecha DATE)
				RETURNS VOID AS $$
				DECLARE
					v_id_empleado INT;

				BEGIN
					SELECT id_empleado INTO v_id_empleado FROM empleado
					INNER JOIN persona ON id_empleado = id_persona
					WHERE dni = p_dni;
					IF v_id_empleado IS NULL THEN
						RAISE EXCEPTION 'La persona con DNI: % no se encuentra registrada en la base de datos.', p_dni;
					END IF;

					IF p_campo NOT IN ('fecha_ingreso', 'fecha_baja') THEN
						RAISE EXCEPTION 'El nombre del campo debe ser fecha_ingreso o fecha_baja';
					END IF;
					
					IF (p_fecha IS NULL) THEN
						RAISE EXCEPTION 'No se puede setear la fecha a NULL';
					END IF;

					IF p_campo = 'fecha_ingreso' THEN
						UPDATE empleado 
						SET fecha_ingreso = p_fecha
						WHERE id_empleado = v_id_empleado;
					END IF;
					IF p_campo = 'fecha_baja' THEN
						UPDATE empleado 
						SET fecha_baja = p_fecha
						WHERE id_empleado = v_id_empleado;
					END IF;
					
					EXCEPTION
						WHEN OTHERS THEN
						RAISE EXCEPTION 'ERROR.  %', SQLERRM; 
						
					RAISE NOTICE 'Actualizacion exitosa';
				END;
				$$ LANGUAGE plpgsql;
				
				SELECT modifcar_fecha_empleado('18354930', 'fecha_ingreso', '02-11-2002')
				
				select * from empleado
				inner join persona on id_persona = id_empleado
				where id_persona = 1
				"1992-12-01"
		

		b) Realice una función para modificar el precio de un medicamento. La función debe recibir cuatro
		parámetros, el primero indica si los precios se modifican por laboratorio, por proveedor o un
		medicamento en particular (L/P/M), cualquier otra opción es inválida. El segundo argumento
		indica el nombre del laboratorio, proveedor o medicamento (sin importar la presentación), el
		tercero, si la modificación de los precios es un aumento o descuento (A/D) y el cuarto indicará
		el porcentaje de aumento o descuento a modificar, éste va de 0.01 a 0.99, cualquier otro valor
		es inválido. Realice todos los controles de existencia de los medicamentos, laboratorios y
		proveedores, además, debe controlar que cada uno de los datos pasados a la función cumplan
		con los requerimientos planteados, de lo contrario la función debe enviar un mensaje según el
		error cometido.


		CREATE OR REPLACE FUNCTION modificar_precio_medicamento(p_modificador CHARACTER VARYING,
                                                                p_nombre_modificador CHARACTER VARYING,
                                                                p_modificacion CHAR,
                                                                p_porcentaje REAL)
        AS $$
        DECLARE
            v_id_nombre_modificador INT;
            
        BEGIN
            IF p_modificador NOT IN ('L', 'P', 'M') THEN
                RAISE NOTICE 'Error en el campo indicador de la modificación. El campo indicador debe corresponder si o si a una de estas opciones:';
                RAISE EXCEPTION '"L" Para laboratorio.  "P" para proveedor.  "M" para un medicamento en particular.'
            END IF;

            IF p_modificacion NOT IN ('A', 'D') THEN
                RAISE EXCEPTION 'Error: Las acciones permitidas solo son: "A" para indicar un aumento, y "D" para indicar un descuento'
            END IF;

            IF p_porcentaje < 0 OR p_porcentaje >0.99 THEN
                RAISE EXCEPTION 'Porcentaje a trabajar mal ingresado';
            END IF;

            IF p_modificador = 'L' THEN
                SELECT id_laboratorio INTO v_id_nombre_modificador FROM laboratorio
                WHERE laboratorio = p_nombre_modificador;
                IF v_id_nombre_modificador IS NULL THEN
                    RAISE EXCEPTION 'El nombre del laboratorio espesificado no se encuentra registrado en la base de datos'
                END IF;

                IF p_modificacion = 'A' THEN
                    UPDATE medicamento 
                    SET precio = precio + (precio * p_porcentaje) / 100
                    WHERE id_laboratorio = v_id_nombre_modificador;
                    IF FOUND THEN
                        RAISE NOTICE 'Incremento de precios por laboratorio exitosa';
                    ELSE 
						RAISE NOTICE 'Las actualizaciones por laboratorio fallaron. %', SQLERRM;
					END IF; 
                ELSE IF p_modificacion = 'D' THEN       
                    UPDATE medicamento 
                    SET precio = precio - (precio * p_porcentaje) / 100
                    WHERE id_laboratorio = v_id_nombre_modificador;
                    IF FOUND THEN
                        RAISE NOTICE 'Descuento de precios por laboratorio exitosa';
                    ELSE 
						RAISE NOTICE 'Las actualizaciones por laboratorio fallaron. %', SQLERRM;
					END IF;      								
                END IF;
            END IF;

            -- Fijarse en la resolucion del tp...akjdhjkads

        END;
        $$ LANGUAGE plpgsql;


		c) Realice una función para el ABM (Alta-Baja-Modificación) de los cargos. Debe recibir dos
		parámetros, el primero será el nombre del cargo y el segundo, en el caso de agregar o borrar
		un registro, la palabra “insert” o “delete” respectivamente, o en caso de realizar una
		modificación, debe ser el nuevo nombre del cargo que debe reemplazar al existente (el del
		primer parámetro).


			CREATE OR REPLACE FUNCTION fn_abm_cargos(p_nombre_cargo CHARACTER VARYING,
													p_accion CHARACTER VARYING)
			RETURNS VOID AS $$
			DECLARE
				v_id_cargo INT;
				v_id_empleado INT;
			BEGIN 
				SELECT id_cargo INTO v_id_cargo FROM cargo
				WHERE cargo = p_nombre_cargo;

				IF p_accion = 'insert' THEN
					IF v_id_cargo IS NOT NULL THEN
						RAISE EXCEPTION 'El cargo ya se encuentra en la base de datos';
					END IF;
					INSERT INTO cargo (id_cargo, cargo)
					VALUES ((SELECT MAX(id_cargo) FROM cargo)+1, p_nombre_cargo);
					IF FOUND THEN
						RAISE NOTICE 'El cargo de añadio correctamente';
					END IF;
				END IF;

				IF p_accion = 'delete' THEN
					IF v_id_cargo IS NULL THEN
						RAISE EXCEPTION 'El cargo no existe en la base de datos';
					END IF;
					SELECT id_empleado INTO v_id_empleado FROM empleado
					INNER JOIN compra USING(id_empleado)
					INNER JOIN cargo USING(id_cargo)
					WHERE id_cargo = v_id_cargo;
					
					DELETE FROM compra
					WHERE id_empleado = v_id_empleado;
					
					DELETE FROM empleado
					WHERE id_cargo = v_id_cargo;

					DELETE FROM cargo
					WHERE id_cargo = v_id_cargo;
					IF FOUND THEN
						RAISE NOTICE 'El cargo se elimino exitosamente';
					END IF;
				END IF;

				IF p_accion NOT IN ('insert', 'delete') THEN
					IF v_id_cargo IS NULL THEN
						RAISE EXCEPTION 'El cargo no existe en la base de datos';
					END IF;
					UPDATE cargo 
					SET cargo = p_accion
					WHERE id_cargo = v_id_cargo;
					IF FOUND THEN
						RAISE NOTICE 'El cargo se modifico exitosamente';
					END IF;
				END IF;

			
			END;
			$$ LANGUAGE plpgsql;
			
			SELECT fn_abm_cargos('GERENTE', 'insert')
			
			select * from cargo
			where cargo = 'GERENTE'

		
		d) Realice UNA función que permite realizar alta en las tablas tipo_estudio, patología, clasificación
		y especialidad. Debe recibir dos parámetros, el primero el nombre de la tabla en la cual se
		quiere agregar la información y el segundo el valor del campo a agregar.

			CREATE OR REPLACE FUNCTION fn_alta_tipoEstudio_patología_clasificación_especialidad(p_nombre_tabla CHARACTER VARYING,
																								p_valor CHARACTER VARYING)
			RETURNS VOID AS $$
			DECLARE
				v_query1 text;
				v_id INT;
				v_campo_clave TEXT;
			BEGIN
				CASE p_nombre_tabla 
					WHEN 'tipo_estudio' THEN 
						SELECT id_tipo INTO v_id FROM tipo_estudio
						WHERE tipo_estudio = p_valor;
						v_campo_clave:= 'id_tipo';
					WHEN 'patologia' THEN
						SELECT id_patologia INTO v_id FROM patologia 
						WHERE nombre = p_valor;
						v_campo_clave:= 'id_patologia';
					WHEN 'clasificacion' THEN
						SELECT id_clasificacion INTO v_id FROM clasificacion
						WHERE clasificacion = p_valor;
						v_campo_clave:= 'id_clasificacion';
					WHEN 'especialidad' THEN
						SELECT id_especialidad INTO v_id FROM especialidad
						WHERE especialidad = p_valor;
						v_campo_clave:= 'id_especialidad';
				END CASE;

				IF v_id IS NOT NULL THEN
					RAISE EXCEPTION 'Ya existe el valor: % en la tabla %', p_valor, p_nombre_tabla;
				END IF;

				v_query1 := 'INSERT INTO '||p_nombre_tabla||' VALUES ((SELECT MAX('||v_campo_clave||')+ 1), '||p_valor||')';
				RAISE NOTICE '%', v_query1;

				EXECUTE v_query1;
			END;
			$$ LANGUAGE plpgsql;
			
			SELECT fn_alta_tipoEstudio_patología_clasificación_especialidad('tipo_estudio', 'NEUROLOGIAa')
			
			select * from tipo_estudio


			NOTICE:  INSERT INTO tipo_estudio VALUES ((SELECT MAX(id_tipo)+ 1), NEUROLOGIAa)

			ERROR:  no existe la columna «id_tipo»
			LINE 1: INSERT INTO tipo_estudio VALUES ((SELECT MAX(id_tipo)+ 1), N...
																^
			HINT:  Hay una columna llamada «id_tipo» en la tabla «tipo_estudio», pero no puede ser referenciada desde esta parte de la consulta.
			QUERY:  INSERT INTO tipo_estudio VALUES ((SELECT MAX(id_tipo)+ 1), NEUROLOGIAa)
			CONTEXT:  función PL/pgSQL "fn_alta_tipoestudio_patología_clasificación_especialidad"(character varying,character varying) en la línea 33 en EXECUTE 

			SQL state: 42703	


						Que onda con eso jasdjhajsd desbloquee un error.(?
						FUE UN SELECT SIN FROM jashdjahsd q gil

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


	Ejercicio nro. 2:
		Realice las siguientes funciones para agregar funcionalidad al sistema. Para realizar esta tarea se
		recomienda usar los “tipos de datos” creados en el ejercicio 2 del TP5 o crear un tipo nuevo de ser
		necesario.

			EJEMPLO:
				CREATE FUNCTION fn_lista_med() RETURNS SETOF medicamento AS $$
				BEGIN
					RETURN QUERY SELECT * FROM medicamento;
				END;
				$$ LANGUAGE 'plpgsql';

				SELECT fn_lista_med();

		a) Escriba una función que reciba el nombre de una obra social y devuelva un listado de todos
		los pacientes que cuentan con la misma. El listado debe tener id, nombre y apellido del
		paciente, nombre y sigla de la obra social.


			CREATE TYPE public.obra_social_paciente AS
			(
				id_paciente integer,
				nombre_paciente character varying(100),
				apellido_paciente character varying(100),
				sigla_obra_social character varying(15),
				nombre_obra_social character varying(100)
			);

			ALTER TYPE public.obra_social_paciente
				OWNER TO postgres;

			ALTER TYPE public.obra_social_paciente
				ALTER ATTRIBUTE sigla_obra_social SET DATA TYPE character varying(15);	


			CREATE OR REPLACE FUNCTION fn_listarXobraSocial(p_obra_social CHARACTER VARYING)
			RETURNS SETOF obra_social_paciente AS $$
			BEGIN
				RETURN QUERY 
							SELECT id_paciente, pe.nombre, pe.apellido, sigla, os.nombre FROM paciente 
							INNER JOIN persona pe ON id_persona = id_paciente
							INNER JOIN obra_social os USING(id_obra_social)
							WHERE os.nombre = p_obra_social;
			END;
			$$ LANGUAGE plpgsql;
			SELECT * from obra_social
			SELECT fn_listarXobraSocial('OBRA SOCIAL PORTUARIOS ARGENTINOS DE MAR DEL PLATA')
		

		b) Escriba una función que reciba el nombre de un proveedor y entregue un listado con el
		código, nombre, clasificación de los medicamentos, nombre del laboratorio que los
		produce, nombre del proveedor y el precio que se pagó por dichos medicamentos.


			CREATE TYPE public.medicamentos_x_proveedor AS
			(
				id_medicamento integer,
				nombre_medicamento character varying(100),
				clasificacion_medicamento character varying(100),
				nombre_laboratorio character varying(100),
				nombre_proveedor character varying(100),
				precio_medicamento numeric(8, 2)
			);

			ALTER TYPE public.medicamentos_x_proveedor
				OWNER TO postgres;
			
			ALTER TYPE public.medicamentos_x_proveedor
					ALTER ATTRIBUTE nombre_medicamento SET DATA TYPE character varying(50);
			ALTER TYPE public.medicamentos_x_proveedor
					ALTER ATTRIBUTE clasificacion_medicamento SET DATA TYPE character varying(75);
			ALTER TYPE public.medicamentos_x_proveedor
					ALTER ATTRIBUTE nombre_laboratorio SET DATA TYPE character varying(50);
			ALTER TYPE public.medicamentos_x_proveedor
					ALTER ATTRIBUTE nombre_proveedor SET DATA TYPE character varying(50);

			CREATE OR REPLACE FUNCTION fn_listar_medicamentosXproveedor(p_proveedor CHARACTER VARYING)
			RETURNS SETOF medicamentos_x_proveedor AS $$
			BEGIN
				RETURN QUERY
							SELECT id_medicamento, nombre, clasificacion, laboratorio, proveedor, precio FROM medicamento
							INNER JOIN clasificacion USING(id_clasificacion)
							INNER JOIN laboratorio USING(id_laboratorio)
							INNER JOIN compra USING(id_medicamento)
							INNER JOIN proveedor USING(id_proveedor)
							WHERE proveedor = p_proveedor;
			END;
			$$ LANGUAGE plpgsql;
			
			select * from proveedor
			
			select fn_listar_medicamentosXproveedor('QUIMICA SUIZA S.A.')



		c) Escriba una función que reciba una fecha y devuelva el listado de todas las consultas
        realizadas en esa fecha, además, debe mostrar el nombre y apellido del paciente, nombre y
        apellido del médico, y el nombre del consultorio donde se realizaron las consultas.
		
		
			CREATE TYPE public."consultasXfecha" AS
			(
				fecha_consulta date,
				nombre_paciente character varying(100),
				apellido_paciente character varying(100),
				nombre_medico character varying(100),
				apellido_medico character varying(100),
				consultorio_nombre character varying(50)
			);

			ALTER TYPE public."consultasXfecha"
				OWNER TO postgres;
			ALTER TYPE public."consultasXfecha"
			RENAME TO consultas_x_fecha;
			
			CREATE OR REPLACE FUNCTION fn_listarXfecha(p_fecha DATE)
			RETURNS SETOF consultas_x_fecha AS $$
				BEGIN
					RETURN QUERY    
								SELECT fecha, pe.nombre, pe.apellido, pers.nombre, pers.apellido, co.nombre FROM consulta
								INNER JOIN paciente pa USING(id_paciente)
								INNER JOIN persona pe ON pe.id_persona = id_paciente
								
								INNER JOIN empleado me USING(id_empleado)
								INNER JOIN persona pers ON pers.id_persona = id_empleado
								INNER JOIN consultorio co USING(id_consultorio)
								WHERE fecha = p_fecha;
				END;
			$$ LANGUAGE plpgsql;
			
			SELECT * from consulta
			select fn_listarXfecha('2019-01-01')


		d) Escriba una función que reciba el dni de un paciente y devuelva todas las internaciones que
		tuvo (aquellas en las que ya fue dado de alta). Se debe mostrar nombre y apellido del
		paciente, nombre y apellido del médico que ordenó la internación, fecha de alta y costo de
		las mismas.

			CREATE TYPE public.internaciones_x_paciente AS
			(
				nombre_paciente character varying(100),
				apellido_paciente character varying(100),
				nombre_empleado character varying(100),
				apellido_empleado character varying(100),
				fecha_alta date,
				costo_internacion numeric(10, 2)
			);

			ALTER TYPE public.internaciones_x_paciente
				OWNER TO postgres;
				
		 	CREATE OR REPLACE FUNCTION fn_internacionesXpaciente(p_dni CHARACTER VARYING)
            RETURNS SETOF internaciones_x_paciente AS $$    
                BEGIN
                    RETURN QUERY
                                SELECT pe.nombre, pe.apellido, pers.nombre, pers.apellido, fecha_alta, costo FROM internacion
                                INNER JOIN paciente USING(id_paciente)
                                INNER JOIN persona pe ON pe.id_persona = id_paciente
                                INNER JOIN empleado ON ordena_internacion = id_empleado
                                INNER JOIN persona pers ON pers.id_persona = id_empleado
                                WHERE pe.dni = p_dni AND fecha_alta IS NOT NULL;
                END;
            $$ LANGUAGE plpgsql;
			SELECT fn_internacionesXpaciente('45705891')
			
			
			select * from internacion 
		 	INNER JOIN paciente USING(id_paciente)
            INNER JOIN persona pe ON id_persona = id_paciente
			dni = "45705891"


		e) Escriba una función que reciba el nombre de un laboratorio y devuelva el código, nombre y
        stock de todos los medicamentos de dicho laboratorio, además, debe mostrar la
        clasificación de los mismos.
		
		
		    CREATE TYPE public.medicamento_x_laboratorio AS
			(
				id_medicamento integer,
				nombre_medicamento character varying(50),
				stock_medicamento integer,
				clasificacion_medicamento character varying(75)
			);

			ALTER TYPE public.medicamento_x_laboratorio
				OWNER TO postgres;
            

           CREATE TYPE public.medicamento_x_laboratorio AS
			(
				id_medicamento integer,
				nombre_medicamento character varying(50),
				stock_medicamento integer,
				clasificacion_medicamento character varying(75)
			);

			ALTER TYPE public.medicamento_x_laboratorio
				OWNER TO postgres;
		
			CREATE OR REPLACE FUNCTION fn_listar_medicamentosXlaboratorio(p_laboratorio CHARACTER VARYING)
            RETURNS SETOF medicamento_x_laboratorio AS $$
                DECLARE
                    v_id_laboratorio INT;
                BEGIN
                    SELECT id_laboratorio INTO v_id_laboratorio FROM laboratorio
                    WHERE laboratorio = p_laboratorio;
                    IF v_id_laboratorio IS NULL THEN
                        RAISE EXCEPTION 'El laboratorio espesificado no se encuentra registrado en la base de deatos';
                    END IF;
                    RETURN QUERY    
                                SELECT id_medicamento, nombre, stock, clasificacion FROM medicamento
                                INNER JOIN clasificacion USING(id_clasificacion)
                                INNER JOIN laboratorio USING(id_laboratorio)
                                WHERE laboratorio = p_laboratorio;
                END;
            $$ LANGUAGE plpgsql;
			
			select * from laboratorio
			
			select fn_listar_medicamentosXlaboratorio('CARRION LABORATORIOS')

		f) Escriba una función que reciba el dni de un paciente y muestre su nombre y apellido, y el
		número, fecha y monto de todas las facturas que se le emitieron.		
		
			CREATE TYPE public.paciente_x_facturas AS
			(
				nombre_paciente character varying(100),
				apellido_paciente character varying(100),
				id_factura integer,
				fecha_factura date,
				monto_factura numeric(10, 2)
			);

			ALTER TYPE public.paciente_x_facturas
				OWNER TO postgres;
			ALTER TYPE public.paciente_x_facturas
        		ALTER ATTRIBUTE id_factura SET DATA TYPE bigint;

			CREATE OR REPLACE FUNCTION fn_Listar_paciente_x_facturas(p_dni CHARACTER VARYING)
            RETURNS SETOF paciente_x_facturas AS $$
                BEGIN
                    RETURN QUERY
                                SELECT nombre, apellido, id_factura, fecha, monto FROM paciente 
                                INNER JOIN persona ON id_persona = id_paciente
                                INNER JOIN factura USING(id_paciente)
                                WHERE dni = p_dni;
                END;
            $$ LANGUAGE plpgsql;
		
			SELECT fn_Listar_paciente_x_facturas('68858698')
			select * from paciente 
			INNER JOIN persona ON id_persona = id_paciente

		
		g) Escriba una función que reciba el dni de un empleado y muestre su nombre y apellido,
		nombre y marca de los equipos y la fecha de ingreso y estado de los mismos (equipos que
		reparó dicho empleado).	
		
			CREATE TYPE public.mantenimientos_x_empleado AS
			(
				nombre_empleado character varying(100),
				apellido_empleado character varying(100),
				nombre_equipo character varying(100),
				fecha_ingreso_mantenimiento date,
				estado_mantenimiento character varying(25)
			);

			ALTER TYPE public.mantenimientos_x_empleado
				OWNER TO postgres;
				
			CREATE OR REPLACE FUNCTION fn_lista_mantenimientos_x_empleado(p_dni character varying)
            RETURNS SETOF mantenimientos_x_empleado AS $$
                DECLARE
                    v_id_empleado INT;
                BEGIN
                    SELECT id_empleado INTO v_id_empleado FROM empleado 
                    INNER JOIN persona ON id_persona = id_empleado
                    WHERE dni = p_dni;
                    IF v_id_empleado IS NULL THEN
                        RAISE EXCEPTION 'El DNI ingresado no corresponde a ninguna persona registrada en la base de datos';
                    END IF;
                    RETURN QUERY
                                SELECT pe.nombre, pe.apellido, e.nombre, eq.fecha_ingreso, estado FROM empleado
                                INNER JOIN persona pe ON id_empleado = id_persona
                                INNER JOIN mantenimiento_equipo eq USING(id_empleado)
                                INNER JOIN equipo e USING(id_equipo)
                                WHERE pe.dni = p_dni; 
                    EXCEPTION
                        WHEN OTHERS THEN
                        RAISE EXCEPTION 'ERROR  %',SQLERRM;
                END;
            $$ LANGUAGE plpgsql;
			
			SELECT fn_lista_mantenimientos_x_empleado('68858698');
			
			SELECT pe.nombre, pe.apellido, e.nombre, eq.fecha_ingreso, estado FROM empleado
			INNER JOIN persona pe ON id_empleado = id_persona
			INNER JOIN mantenimiento_equipo eq USING(id_empleado)
			INNER JOIN equipo e USING(id_equipo)
			WHERE pe.dni = '68858698'; 

			
		
		h) Escriba una función que muestre el listado de las facturas indicando el número, fecha y
		monto de las mismas, nombre y apellido del paciente, y una columna donde se indique un
		mensaje en base al saldo pendiente. Si el saldo es menor que 500.000 en la columna se debe
		mostrar “El cobro puede esperar”, si es mayor que 500.000 mostrar “Cobrar prioridad” y si
		es mayor a 1.000.000 mostrar “Cobrar urgente”.

			CREATE TYPE public.listado_facturas AS
			(
				numero_factura INTEGER,
				fecha_factura DATE,
				monto_factura NUMERIC(9, 2),
				nombre_paciente VARCHAR(100),
				apellido_paciente VARCHAR(100),
				mensaje_saldo_pendiente VARCHAR(100)
			);

			ALTER TYPE public.listado_facturas
			OWNER TO postgres;

			ALTER TYPE public.listado_facturas
					ALTER ATTRIBUTE numero_factura SET DATA TYPE bigint;
			ALTER TYPE public.listado_facturas
					ALTER ATTRIBUTE monto_factura SET DATA TYPE numeric(10, 2);
			ALTER TYPE public.listado_facturas
					ALTER ATTRIBUTE mensaje_saldo_pendiente SET DATA TYPE text;

			CREATE OR REPLACE FUNCTION fn_listado_facturas()
				RETURNS SETOF listado_facturas AS $$
				DECLARE
					resultado listado_facturas;
				BEGIN
					RETURN QUERY
					SELECT f.id_factura, f.fecha, f.monto, p.nombre, p.apellido,
						CASE
							WHEN f.saldo < 500000 THEN 'El cobro puede esperar'
							WHEN f.saldo >= 500000 AND f.saldo < 1000000 THEN 'Cobrar prioridad'
							ELSE 'Cobrar urgente'
						END
					FROM factura f
					INNER JOIN paciente USING(id_paciente)
					INNER JOIN persona p ON id_persona = id_paciente;
					
					RETURN;
				END;
			$$ LANGUAGE plpgsql;

			SELECT fn_listado_facturas()
		

		i) Escriba UNA función que liste todos los registros de alguna de las siguientes tablas: cargo,
        clasificaciones, especialidad, patología y tipo_estudio. No use estructuras de control para
        decidir que tabla mostrar, solo debe averiguar si el parámetro pasado a la función coincide
        con el nombre de alguna de las tablas requeridas.

			CREATE OR REPLACE FUNCTION fn_listar_registros(p_tabla VARCHAR)
				RETURNS TABLE (
					columna1 Smallint,
					columna2 VARCHAR
				) AS $$
				DECLARE
					resultado RECORD;
				BEGIN

					IF p_tabla NOT IN ('cargo', 'clasificacion', 'especialidad', 'patologia', 'tipo_estudio') THEN
						RAISE EXCEPTION 'La tabla ingresada: % no se encuentra en la base de datos', p_tabla;
					END IF;
					
					RETURN QUERY 
								EXECUTE 'SELECT * FROM ' || p_tabla;
				END;
				$$ LANGUAGE plpgsql;
				SELECT fn_listar_registros('especialidad')

				-- Funciona solamente con algunos ya que no todos los campos id estan definidos con el mismo tipo de datos.
*/	