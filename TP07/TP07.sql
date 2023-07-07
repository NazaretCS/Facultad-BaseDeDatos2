|/*
	Ejercicio nro. 1:
	Para mejorar y automatizar el funcionamiento de la base de datos “Hospital” realice las siguientes tareas:
	
	a) Realice una función que permita modificar la fecha de ingreso o la fecha de baja de un
		empleado. Debe recibir como parámetros el dni del empleado, el nombre del campo a
		modificar (fecha_ingreso/fecha_baja) y el valor del nuevo campo. Recuerde controlar que el
		empleado a modificar exista, de lo contrario debe enviar un mensaje de error. Agregue más
		controles de ser necesario.
		
		CREATE OR REPLACE FUNCTION modificar_Fecha_empleado(IN p_dni_empleado character varying(20), 
													   IN p_campo_modificar character varying(100),
													   IN p_fecha DATE) RETURNS VOID AS $$
		DECLARE
		   v_id_empleado character varying(20);
		   v_query text; -- Variable para almacenar la consulta generada
		BEGIN

		   SELECT id_persona INTO v_id_empleado
		   FROM persona 
		   INNER JOIN empleado ON id_persona = id_empleado
		   WHERE dni LIKE p_dni_empleado;

		   IF v_id_empleado IS NULL THEN
			  RAISE EXCEPTION 'El dni % no existe en la base de datos', p_dni_empleado;
		   END IF;

		   IF p_campo_modificar != 'fecha_ingreso' AND p_campo_modificar != 'fecha_baja' THEN
			  RAISE EXCEPTION 'Error, el campo % no corresponde a lo necesario', p_campo_modificar;
		   END IF;

		   IF (p_fecha IS NULL) OR (p_fecha = '') THEN
				RAISE EXCEPTION 'No se puede setear la fecha a NULL';
		   END IF;
		
		
			   -- Construir la consulta dinámica
			   v_query := 'UPDATE empleado
						   SET ' || p_campo_modificar || ' = ' || quote_literal(p_fecha) || '
						   WHERE id_empleado = ' || v_id_empleado;
			/*
			   -- Mostrar la consulta generada
			   RAISE NOTICE 'Consulta generada: %', v_query;
			*/
			
		   -- Ejecutar la consulta dinámica
		   EXECUTE v_query;

		   RAISE NOTICE 'Carga exitosa';

		END;      
		$$ LANGUAGE plpgsql;

			select modificar_Fecha_empleado('18354930','fecha_ingreso', '');

			select * FROM persona 
			inner join empleado ON id_persona = id_empleado
			where dni like '18354930'
	
	
	
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
	
		CREATE OR REPLACE FUNCTION  modificar_precio_medicamento (  p_modificacion char(1),
																	p_nombre varchar(100),
																	p_tipo_modificacion char(1),
																	p_porcentaje numeric(4,2)
																	
		) RETURNS VOID AS $$
			DECLARE
				
				v_campo_modificacion varchar(100);
				v_id_campo_modificacion varchar(100);
				v_operacion char(1);
				v_id_campo INT;
				v_nombre varchar(100);
				v_query TEXT;
			BEGIN
				--Controles de las entradas
				IF p_modificacion NOT IN ('L', 'P', 'M') THEN
					RAISE EXCEPTION 'Seleccion del campo a modificar invalidada. Solo se permite modificar por Laboratorio (L), Proveedor (P) o por medicamento(M)';
				END IF;
				
				IF p_tipo_modificacion NOT IN ('A', 'D') THEN
					RAISE EXCEPTION 'Tipo de modificacion invalida. Solo se permiten las acciones de: Aumento (A) y Descuento (D)';
				END IF;
				
				IF p_porcentaje < 0.01 OR p_porcentaje > 0.99 THEN
       				RAISE EXCEPTION 'El porcentaje de cambio debe estar entre 0.01 y 0.99';
    			END IF;
				
				CASE p_modificacion
					WHEN 'L' THEN v_campo_modificacion:= 'laboratorio';
							      v_id_campo_modificacion := 'id_laboratorio';
								  v_nombre := 'laboratorio';
					WHEN 'M' THEN v_campo_modificacion := 'medicamento';
							      v_id_campo_modificacion := 'id_medicamento';
								  v_nombre := 'nombre';
					WHEN 'P' THEN v_campo_modificacion := 'proveedor';
							      v_id_campo_modificacion := 'id_proveedor';
								  v_nombre := 'proveedor';
				END CASE;
				
				IF p_tipo_modificacion = 'A' THEN
					v_operacion:= '+';
				ELSE 
					v_operacion:= '-';
				END IF;
				
				-- Obtener el ID del campo a modificar
    			EXECUTE format('SELECT %I FROM %I WHERE %L = %L', v_id_campo_modificacion, v_campo_modificacion, v_nombre, p_nombre)
        		INTO v_id_campo;
				
				IF v_id_campo IS NULL THEN
					RAISE EXCEPTION 'El % no existe en la base de datos', v_campo_modificacion;
				END IF;
				
				-- Construir la consulta dinámica para modificar el precio
				v_query := format('UPDATE medicamento
								  SET precio = precio %s (precio * %s) 
								  WHERE %I = %s', v_operacion, p_porcentaje::TEXT, v_id_campo_modificacion, v_id_campo::TEXT);
	
				-- Muestro la consulta
				RAISE NOTICE '%', v_query;
				-- Ejecutar la consulta dinámica
				EXECUTE v_query;

				RAISE NOTICE 'Precio modificado exitosamente. Nuevo precio: %', v_precio_nuevo;		   
			END;
			
		$$ LANGUAGE plpgsql;


		SELECT  modificar_precio_medicamento('M','ACETAM', 'A', 0.5);
		SELECT * FROM medicamento
		
		
	c)  Realice una función para el ABM (Alta-Baja-Modificación) de los cargos. Debe recibir dos
		parámetros, el primero será el nombre del cargo y el segundo, en el caso de agregar o borrar
		un registro, la palabra “insert” o “delete” respectivamente, o en caso de realizar una
		modificación, debe ser el nuevo nombre del cargo que debe reemplazar al existente (el del
		primer parámetro).

		
		
		CREATE OR REPLACE FUNCTION gestionar_cargo(p_nombre_cargo VARCHAR(100), 
												   p_operacion VARCHAR(10))
		RETURNS VOID AS $$
		BEGIN
			IF p_operacion = 'insert' THEN
				-- Verificar si el cargo ya existe
				IF EXISTS (SELECT 1 FROM cargo WHERE cargo = p_nombre_cargo) THEN
					RAISE EXCEPTION 'El cargo %, ya existe en la base de datos', p_nombre_cargo;
				END IF;

				-- Insertar el nuevo cargo
				INSERT INTO cargo VALUES (p_nombre_cargo);

				RAISE NOTICE 'El cargo "%", ha sido agregado exitosamente', p_nombre_cargo;

			ELSIF p_operacion = 'delete' THEN
				-- Verificar si el cargo existe
				IF NOT EXISTS (SELECT 1 FROM cargo WHERE nombre = p_nombre_cargo) THEN
					RAISE EXCEPTION 'El cargo %, no existe en la base de datos', p_nombre_cargo;
				END IF;

				-- Eliminar el cargo
				DELETE FROM cargo WHERE cargo = p_nombre_cargo;

				RAISE NOTICE 'El cargo %, ha sido eliminado exitosamente', p_nombre_cargo;

			ELSE
				-- Verificar si el cargo existe
				IF NOT EXISTS (SELECT 1 FROM cargo WHERE nombre = p_nombre_cargo) THEN
					RAISE EXCEPTION 'El cargo %, no existe en la base de datos', p_nombre_cargo;
				END IF;

				-- Actualizar el nombre del cargo
				UPDATE cargo SET cargo = p_operacion WHERE nombre = p_nombre_cargo;

				RAISE NOTICE 'El cargo "%", ha sido modificado exitosamente. Nuevo nombre: %', p_nombre_cargo, p_operacion;
			END IF;
		END;
		$$ LANGUAGE plpgsql;
		
		
		
		d) Realice UNA función que permite realizar alta en las tablas tipo_estudio, patología, clasificación
		y especialidad. Debe recibir dos parámetros, el primero el nombre de la tabla en la cual se
		quiere agregar la información y el segundo el valor del campo a agregar.

		CREATE OR REPLACE FUNCTION alta_en_tabla(IN nomb_tabla CHARACTER VARYING(14),
												 IN dato_agregar CHARACTER VARYING(60)) RETURNS void AS $$
		BEGIN
			IF nomb_tabla NOT IN ('tipo_estudio', 'patologia', 'clasificacion', 'especialidad') THEN
				RAISE EXCEPTION 'El nombre de la tabla % no es valido. La posibles tablas en las que 
				puede ingresar datos son: "tipo_estudio" / "patologia" / "clasificacion" / "especialidad"', nomb_tabla;
			END IF;

			IF nomb_tabla = 'tipo_estudio' THEN 
				INSERT INTO tipo_estudio(id_tipo, tipo_estudio) 
				VALUES ((SELECT max(id_tipo) + 1 FROM tipo_estudio), dato_agregar);
				RAISE NOTICE 'Se ingreso exitosamente el dato % en la tabla "%"',dato_agregar, nomb_tabla;
			ELSEIF nomb_tabla = 'patologia' THEN
				INSERT INTO patologia(id_patologia, nombre)
				VALUES ((SELECT max(id_patologia)+1 FROM patologia), dato_agregar);
				RAISE NOTICE 'Se ingreso exitosamente el dato % en la tabla "%"',dato_agregar, nomb_tabla;
			ELSEIF nomb_tabla = 'clasificacion' THEN
				INSERT INTO clasificacion(id_clasificacion, clasificacion)
				VALUES ((SELECT max(id_clasificacion)+1 FROM clasificacion), dato_agregar);
				RAISE NOTICE 'Se ingreso exitosamente el dato % en la tabla "%"',dato_agregar, nomb_tabla;
			ELSEIF nomb_tabla = 'especialidad' THEN
				INSERT INTO especialidad(id_especialidad, especialidad) 
				VALUES ((SELECT max(id_especialidad)+1 FROM especialidad), dato_agregar);
				RAISE NOTICE 'Se ingreso exitosamente el dato % en la tabla "%"',dato_agregar, nomb_tabla;
			END IF;
		END;
		$$ LANGUAGE plpgsql;

		SELECT * FROM clasificacion;
		SELECT alta_en_tabla('clasificacion', 'COSMETICOS2');

		-- Ejercicio 2
		
		Realice las siguientes funciones para agregar funcionalidad al sistema. Para realizar esta tarea se
		recomienda usar los “tipos de datos” creados en el ejercicio 2 del TP5 o crear un tipo nuevo de ser
		necesario.
		
		
		/*
		a) Escriba una función que reciba el nombre de una obra social y devuelva un listado de todos
		los pacientes que cuentan con la misma. El listado debe tener id, nombre y apellido del
		paciente, nombre y sigla de la obra social
		*/

		CREATE TYPE public.datospaciente AS
		(
			id_paciente integer,
			nombre character varying(100),
			apellido character varying(100),
			sigla character varying(15),
			nombobrasocial character varying(100)
		);

		ALTER TYPE public.datospaciente
			OWNER TO postgres;


		CREATE OR REPLACE FUNCTION pacientes_enOS(IN nombre_OS CHARACTER VARYING(150)) RETURNS SETOF datospaciente AS $$
		BEGIN 
		RETURN QUERY SELECT id_paciente, Pr.nombre , Pr.apellido , Os.sigla, Os.nombre AS nombobrasocial FROM obra_social Os 
					 INNER JOIN paciente Pc USING(id_obra_social) INNER JOIN persona Pr ON Pr.id_persona = Pc.id_paciente 
					 WHERE Os.nombre LIKE nombre_OS;
		END;
		$$ LANGUAGE plpgsql;

		SELECT pacientes_enOS('OBRA SOCIAL FERROVIARIA');

		/*
		b) Escriba una función que reciba el nombre de un proveedor y entregue un listado con el
		código, nombre, clasificación de los medicamentos, nombre del laboratorio que los
		produce, nombre del proveedor y el precio que se pagó por dichos medicamentos.
		*/

		CREATE TYPE public.datos_med_lab AS
		(
			id_medicamento integer,
			nombremed character varying(50),
			clasificacionmed character varying(75),
			nombrelab character varying(50),
			nombreproveedor character varying(50),
			precio numeric(10, 2)
		);

		ALTER TYPE public.datos_med_lab
			OWNER TO postgres;

		CREATE OR REPLACE FUNCTION medicamentos_por_proveedor(IN nomb_proveedor CHARACTER VARYING(150)) RETURNS SETOF datos_med_lab AS $$
		BEGIN

			IF NOT EXISTS(SELECT 1 FROM proveedor WHERE proveedor LIKE nomb_proveedor) THEN
				RAISE EXCEPTION 'El proveedor buscado (%) no se encontro en la base de datos. 
				Intente nuevamente con otros parametros.', nomb_proveedor;
			END IF;

			RETURN QUERY SELECT id_medicamento, Med.nombre AS nombremed, Cl.clasificacion AS clasificacionmed,
						 Lb.laboratorio AS nombrelab, Prv.proveedor AS nombreproveedor, Cm.precio_unitario AS precio
						 FROM medicamento Med INNER JOIN clasificacion Cl USING(id_clasificacion)
						 INNER JOIN laboratorio Lb USING(id_laboratorio) INNER JOIN compra Cm USING (id_medicamento)
						 INNER JOIN proveedor Prv USING(id_proveedor) WHERE Prv.proveedor LIKE nomb_proveedor;
		END;
		$$ LANGUAGE plpgsql;

		/*
		c) Escriba una función que reciba una fecha y devuelva el listado de todas las consultas
		realizadas en esa fecha, además, debe mostrar el nombre y apellido del paciente, nombre y
		apellido del médico, y el nombre del consultorio donde se realizaron las consultas.
		*/

		CREATE TYPE public.datosconsulta AS
		(
			nombrepaciente character varying(100),
			apellidopaciente character varying(100),
			nombremedico character varying(100),
			apellidomedico character varying(100),
			fechaconsulta date,
			consultorio character varying(50)
		);

		ALTER TYPE public.datosconsulta
			OWNER TO postgres;

		CREATE OR REPLACE FUNCTION consulta_por_fecha(IN fecha_consulta date) RETURNS SETOF datosconsulta AS $$
		BEGIN 
			IF NOT EXISTS(SELECT 1 FROM consulta WHERE fecha = fecha_consulta) THEN 
				RAISE EXCEPTION 'No se registro ninguna consulta para la fecha solicitada (%). Intente ingresando una fecha diferente.',fecha_consulta;
			END IF;

			RETURN QUERY 
			SELECT P_paciente.nombre AS nombrepaciente, P_paciente.apellido AS apellidopaciente, P_empleado.nombre AS nombremedico,
			P_empleado.apellido AS apellidomedico, Cn.fecha AS fechaconsulta, Con.nombre AS consultorio
			FROM consulta Cn
			INNER JOIN paciente Pc USING(id_paciente) 
			INNER JOIN empleado Em USING(id_empleado)
			INNER JOIN consultorio Con USING(id_consultorio)
			INNER JOIN persona P_paciente ON P_paciente.id_persona = Pc.id_paciente
			INNER JOIN persona P_empleado ON P_empleado.id_persona = Em.id_empleado
			WHERE Cn.fecha = fecha_consulta;
		END;
		$$ LANGUAGE plpgsql;


		SELECT P_paciente.nombre AS nombrepaciente, P_paciente.apellido AS apellidopaciente, P_empleado.nombre AS nombremedico,
			P_empleado.apellido AS apellidomedico, Cn.fecha AS fechaconsulta, Con.nombre AS consultorio
			FROM consulta Cn
			INNER JOIN paciente Pc USING(id_paciente) 
			INNER JOIN empleado Em USING(id_empleado)
			INNER JOIN consultorio Con USING(id_consultorio)
			INNER JOIN persona P_paciente ON P_paciente.id_persona = Pc.id_paciente
			INNER JOIN persona P_empleado ON P_empleado.id_persona = Em.id_empleado
			WHERE Cn.fecha = '2019-01-01';

		SELECT consulta_por_fecha('2019-01-01');

		/*
		d) Escriba una función que reciba el dni de un paciente y devuelva todas las internaciones que
		tuvo (aquellas en las que ya fue dado de alta). Se debe mostrar nombre y apellido del
		paciente, nombre y apellido del médico que ordenó la internación, fecha de alta y costo de
		las mismas
		*/

		CREATE TYPE public.datosinternacion AS
		(
			nombrepaciente character varying(100),
			apellidopaciente character varying(100),
			nombremedico character varying(100),
			apellidomedico character varying(100),
			costo numeric(10, 2),
			fecalta date
		);

		ALTER TYPE public.datosinternacion
			OWNER TO postgres;

		CREATE OR REPLACE FUNCTION consulta_internacion_dni(IN dni_paciente CHARACTER VARYING(10)) RETURNS SETOF datosinternacion AS $$
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM paciente INNER JOIN persona ON id_persona = id_paciente WHERE dni LIKE dni_paciente) THEN
				RAISE EXCEPTION 'No se encontro ningun paciente con dni "%" en la base de datos. Intente nuevamente.',dni_paciente;
			END IF;

			RETURN QUERY
			SELECT * FROM internacion Int 
			INNER JOIN paciente Pc USING(id_paciente)
			INNER JOIN empleado Em ON Int.ordena_internacion = Em.id_empleado
			INNER JOIN persona P_paciente ON P_paciente.id_persona = Pc.id_paciente
			INNER JOIN persona P_empleado ON P_empleado.id_persona = Em.id_empleado
			WHERE P_paciente.dni LIKE dni_paciente AND Int.fecha_alta NOT NULL;
		END;
		$$ LANGUAGE plpgsql;

		SELECT * FROM paciente INNER JOIN persona ON id_persona = id_paciente WHERE dni LIKE '18354930';

			


		*/