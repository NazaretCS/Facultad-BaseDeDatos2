/*Ejercicio 1: Funciones*/
/*
a) Escriba una función que reciba como parámetros el nombre y apellido de un paciente, id_cama y una fecha. 
Si existe un registro con el paciente y la cama ingresada, y no hay datos de la fecha_alta, deberá modificar la 
fecha de alta con el valor ingresado. Por el contrario, si fecha_alta tiene dato almacenado, deberá realizar un 
nuevo ingreso usando la fecha (recibida como parámetro) como fecha_inicio. 
Realice todos los controles, y tenga en cuenta que hay camas que están fuera de servicio.
*/

SELECT * FROM cama WHERE id_cama = 108;
SELECT * FROM internacion;
SELECT * FROM empleado;

CREATE OR REPLACE FUNCTION modifica_ingresa_internacion(IN nombre_pac CHARACTER VARYING(100),
													    IN apellido_pac CHARACTER VARYING(100),
													    IN in_id_cama INTEGER,
													    IN in_fecha DATE) RETURNS void AS $$
DECLARE
	fecha_control DATE;
	id_paciente_busca INTEGER;
	id_cama_busca INTEGER;
	dato RECORD;
BEGIN
	SELECT id_paciente INTO id_paciente_busca FROM persona INNER JOIN paciente ON id_persona = id_paciente 
	WHERE nombre LIKE nombre_pac AND apellido LIKE apellido_pac;
	
	SELECT id_cama INTO id_cama_busca FROM cama WHERE id_cama = in_id_cama AND estado LIKE 'OK';
	
	SELECT fecha_alta INTO fecha_control FROM internacion WHERE id_paciente = id_paciente_busca AND id_cama = id_cama_busca;
	
	IF id_paciente_busca IS NULL THEN
		RAISE EXCEPTION 'EL paciente buscado (%, %) no se encontro en la base de datos. Corrobore los datos e intente nuevamente.', nombre_pac, apellido_pac;
	ELSEIF id_cama_busca IS NULL THEN
		RAISE EXCEPTION 'La cama que esta solicitando (%) puede que no este habilitada actualmente. Intente ingresando otra diferente.', in_id_cama;
	ELSEIF NOT EXISTS(SELECT 1 FROM internacion WHERE id_paciente = id_paciente_busca AND id_cama = id_cama_busca) THEN
--		RAISE EXCEPTION 'La internacion no se encontro con los parametros de busqueda ingresados (Nombre y apellido paciente: % -- Nº Cama: %). Vuelva a intentarlo mas tarde.',nombre_pac,apellido_pac,in_id_cama;
		INSERT INTO internacion (id_paciente, id_cama, fecha_inicio, ordena_internacion, fecha_alta, hora, costo) 
		VALUES (id_paciente_busca, id_cama_busca, in_fecha, (SELECT min(id_empleado) FROM empleado), NULL, CURRENT_TIME,99999999.99);
		RAISE NOTICE 'Se ingreso el paciente % % en la cama %, como una nueva internacion.', nombre_pac, apellido_pac, in_id_cama;
 	ELSEIF EXISTS(SELECT 1 FROM internacion WHERE id_paciente = id_paciente_busca AND id_cama = id_cama_busca) AND fecha_control IS NOT NULL THEN
		UPDATE internacion SET fecha_alta = NULL, fecha_inicio = in_fecha
		WHERE (id_paciente, id_cama) = (SELECT id_paciente, id_cama FROM internacion
									    WHERE id_paciente = id_paciente_busca 
										AND id_cama = id_cama_busca);
		RAISE NOTICE 'Se ingreso el paciente % % en la cama %, (se modifico una internacion anterior).', nombre_pac, apellido_pac, in_id_cama;
	ELSEIF EXISTS(SELECT 1 FROM internacion WHERE id_paciente = id_paciente_busca AND id_cama = id_cama_busca) AND fecha_control IS NULL THEN
		UPDATE internacion SET fecha_alta = in_fecha
		WHERE (id_paciente, id_cama) = (SELECT id_paciente, id_cama FROM internacion
									    WHERE id_paciente = id_paciente_busca 
										AND id_cama = id_cama_busca);
		RAISE NOTICE 'Se dio de alta a el paciente % %.', nombre_pac, apellido_pac;
	END IF;
END;
$$ LANGUAGE plpgsql;

COMMIT;
ROLLBACK;

SELECT * FROM persona INNER JOIN paciente ON id_persona = id_paciente
INNER JOIN internacion USING(id_paciente) WHERE nombre LIKE 'CAMILA' AND apellido LIKE 'PONCE DE LEON PINHEIRO';

SELECT * FROM modifica_ingresa_internacion('CAMILA', 'PONCE DE LEON PINHEIRO', 108, '2023-12-05');

/*
b)Escriba una función para listar los registros de las tablas clasificaciones o laboratorio. 
La función recibirá el nombre de la tabla y el nombre de la clasificación o laboratorio, según corresponda. 
La función deberá mostrar un listado de todos los medicamentos que pertenecen a dicha clasificación o laboratorio. 
El listado debe tener el id, nombre, presentación y precio del medicamento, además de id y nombre 
del laboratorio o clasificación, según corresponda. 
*/

CREATE OR REPLACE FUNCTION listar_medicamentos(IN nombre_tabla CHARACTER VARYING(100),
											   IN clasificacion_laboratorio CHARACTER VARYING(100)
											  ) RETURNS TABLE (
												  id_medicamento INTEGER,
												  nombre_medicamento CHARACTER VARYING(50),
												  presentacion CHARACTER VARYING(50),
												  precio NUMERIC(8,2),
												  id_lab_clas SMALLINT,
												  nombre_lab_clas CHARACTER VARYING(100)
											  )AS $$
BEGIN
	IF nombre_tabla NOT IN ('clasificacion', 'laboratorio') THEN
		RAISE EXCEPTION 'El nombre de tabla solicitado (%) no se encontro como opcion valida. Puede seleccionar entre alguna de las siguientes tablas: clasificacion / laboratorio', nombre_tabla;
	ELSEIF nombre_tabla = 'clasificacion' THEN
		IF NOT EXISTS (SELECT 1 FROM clasificacion WHERE clasificacion LIKE clasificacion_laboratorio) THEN
			RAISE EXCEPTION 'El parametro de clasifiacion: %, solicitado no se encontro en la base de datos. Revise detenidamente la informacion e intente nuevamente.', clasificacion_laboratorio;
		ELSE
			RETURN QUERY SELECT Med.id_medicamento, Med.nombre, Med.presentacion, Med.precio, 
						 Cl.id_clasificacion, Cl.clasificacion
						 FROM medicamento Med INNER JOIN clasificacion Cl USING(id_clasificacion) 
						 WHERE Cl.clasificacion LIKE clasificacion_laboratorio;
		END IF;
	ELSEIF nombre_tabla = 'laboratorio' THEN
		IF NOT EXISTS (SELECT 1 FROM laboratorio WHERE laboratorio LIKE clasificacion_laboratorio) THEN
			RAISE EXCEPTION 'El parametro de laboratorio: %, solicitado no se encontro en la base de datos. Revise detenidamente la informacion e intente nuevamente.', clasificacion_laboratorio;
		ELSE
			RETURN QUERY SELECT Med.id_medicamento, Med.nombre, Med.presentacion, Med.precio,
						 L.id_laboratorio, L.laboratorio
						 FROM medicamento Med INNER JOIN laboratorio L USING(id_laboratorio) 
						 WHERE L.laboratorio LIKE clasificacion_laboratorio;
		END IF;
	END IF;
END;
$$ LANGUAGE plpgsql;

COMMIT;
ROLLBACK;

SELECT * FROM medicamento INNER JOIN clasificacion USING(id_clasificacion) WHERE clasificacion LIKE 'ANTIASTENICO';
SELECT * FROM medicamento INNER JOIN laboratorio USING(id_laboratorio) WHERE laboratorio LIKE 'LARPE S.A. LABORATORIOS';
SELECT * FROM listar_medicamentos('laboratorio', 'LARPE S.A. LABORATORIOS');


--=======================================================================================

CREATE FUNCTION obtener_datos_empleado(
									   empleado_id INTEGER
									  )RETURNS TABLE 
									  ( 
										  nombre VARCHAR(100), 
										  apellido VARCHAR(100),
										  cargo VARCHAR(50), 
										  especialidad VARCHAR(50)
									  ) AS $$
BEGIN
 -- Declarar las variables para almacenar los datos del empleado
 DECLARE
 v_nombre VARCHAR(100);
 v_apellido VARCHAR(100);
 v_cargo VARCHAR(50);
 v_especialidad VARCHAR(50);
-- Obtener los datos del empleado
BEGIN
SELECT p.nombre, p.apellido, c.cargo, e.especialidad
 INTO v_nombre, v_apellido, v_cargo, v_especialidad
 FROM empleado emp
 JOIN persona p ON emp.id_empleado = p.id_persona
 JOIN cargo c ON emp.id_cargo = c.id_cargo
 JOIN especialidad e ON emp.id_especialidad = e.id_especialidad
 WHERE emp.id_empleado = empleado_id;
-- Verificar si el empleado existe
 IF NOT FOUND THEN
 -- Lanzar una excepción personalizada si el empleado no existe
 RAISE EXCEPTION 'El empleado con ID % no existe.', empleado_id;
 END IF;
 
 -- Retornar los datos del empleado
 RETURN QUERY SELECT v_nombre, v_apellido, v_cargo, 
v_especialidad;
 END;
END;
$$ LANGUAGE plpgsql;
SELECT * FROM obtener_datos_empleado(109)

--=======================================================================================



/*
c)Escriba una función que reciba como parámetros el nombre y presentación de un medicamento
y un porcentaje de modificación de precio. Si el porcentaje ingresado es positivo,
debe aumentar el precio, por lo contrario, si el valor es negativo debe realizar un descuento. 
En caso de ser 0, se debe modificar el precio, en un 15%, de todos los medicamentos que sean 
producidos por el mismo laboratorio que el medicamento ingresado como parámetro.  
La función debe devolver un listado con el id, nombre presentación, precio y nombre del 
laboratorio que lo produce.
*/
CREATE OR REPLACE FUNCTION modifica_precio(IN nombre_medicamento CHARACTER VARYING(50),
										   IN in_presentacion CHARACTER VARYING(50),
										   IN in_porcentaje NUMERIC(3,2)
										  ) RETURNS TABLE (
										  	id_medicamento INTEGER,
											nomb_medicamento CHARACTER VARYING(50),
											presentacion CHARACTER VARYING(50),
											precio NUMERIC(8,2),
											nombre_laboratorio CHARACTER VARYING(100)
										  ) AS $$
DECLARE 
	medicamento_buscado CHARACTER VARYING(50);
	busca_id_laboratorio INTEGER;
BEGIN
	SELECT Med.nombre, Med.id_laboratorio, L.laboratorio INTO medicamento_buscado, busca_id_laboratorio 
	FROM medicamento Med 
	INNER JOIN laboratorio L USING(id_laboratorio) WHERE Med.nombre LIKE nombre_medicamento
	AND Med.presentacion LIKE in_presentacion;
	
	IF medicamento_buscado IS NULL THEN
		RAISE EXCEPTION 'No se encontro el medicamento % con presentacion % en la base de datos. Revise sus parametros de busqueda e intente nuevamente :)',nombre_medicamento, in_presentacion;
	ELSEIF in_porcentaje = 0 THEN
		UPDATE medicamento Med SET precio = Med.precio*1.15 
		WHERE Med.id_medicamento IN (SELECT Med.id_medicamento FROM medicamento Med
								 WHERE Med.id_laboratorio = busca_id_laboratorio);
		RETURN QUERY SELECT Med.id_medicamento, Med.nombre, Med.presentacion, Med.precio,
							L.laboratorio FROM medicamento Med INNER JOIN laboratorio L USING(id_laboratorio)
							WHERE L.id_laboratorio = busca_id_laboratorio;
	ELSE
		UPDATE medicamento Med SET precio = Med.precio + (Med.precio * in_porcentaje)
		WHERE Med.id_medicamento = (SELECT Med.id_medicamento FROM medicamento Med
							   	WHERE Med.nombre LIKE medicamento_buscado);
		RETURN QUERY SELECT Med.id_medicamento, Med.nombre, Med.presentacion, Med.precio,
							L.laboratorio FROM medicamento Med INNER JOIN laboratorio L USING(id_laboratorio)
							WHERE Med.nombre LIKE medicamento_buscado;
	END IF;
END;
$$ LANGUAGE plpgsql;

COMMIT;
ROLLBACK;

SELECT * FROM medicamento INNER JOIN laboratorio USING(id_laboratorio) WHERE id_laboratorio = 145;
SELECT * FROM modifica_precio('TARGIFOR', 'CAJA X 20 COMP EFERV', 0.0);

-- Ejercicio 2: Triggers

/*
b)	Cuando se elimine una especialidad o un cargo, debe modificar todos los registros 
de la tabla empleado que hagan referencia al registro borrado. Si se borra un cargo, 
debe modificar el cargo del empleado con “SIN CARGO ASIGNADO”, por lo contrario, si 
lo que se elimina es una función, debe modificar con “SIN ESPECIALIDAD MEDICA”. 
Además de guardar todos los registros modificados en otra tabla llamada empleado_modi, 
la cual tendrá todos los campos de la tabla empleado. Debe escribir una sola función.
*/


CREATE OR REPLACE FUNCTION modifica_empleado() RETURNS TRIGGER AS $$

DECLARE
 emp empleado %ROWTYPE;
BEGIN
	CREATE TABLE IF NOT EXISTS empleado_modificado(
		id_empleado INTEGER,
		id_especialidad INTEGER,
		id_cargo INTEGER,
		fecha_ingreso DATE,
		sueldo NUMERIC(9,2),
		fecha_baja DATE
	);
	
	IF TG_RELNAME LIKE 'especialidad' THEN
		FOR emp IN SELECT id_empleado, id_especialidad, id_cargo, fecha_ingreso, sueldo, fecha_baja FROM empleado WHERE id_especialidad = old.id_especialidad LOOP
			INSERT INTO empleado_modificado(id_empleado, id_especialidad, id_cargo, fecha_ingreso, sueldo, fecha_baja)
			VALUES(emp.id_empleado, emp.id_especialidad, emp.id_cargo, emp.fecha_ingreso, emp.sueldo, emp.fecha_baja);
		END LOOP;
		
		UPDATE empleado SET id_especialidad = (SELECT id_especialidad FROM especialidad WHERE especialidad LIKE 'SIN ESPECIALIDAD MEDICA')
		WHERE id_especialidad = old.id_especialidad;
	ELSEIF TG_RELNAME LIKE 'cargo' THEN 
		FOR emp IN SELECT id_empleado, id_especialidad, id_cargo, fecha_ingreso, sueldo, fecha_baja FROM empleado WHERE id_cargo = old.id_cargo LOOP
			INSERT INTO empleado_modificado(id_empleado, id_especialidad, id_cargo, fecha_ingreso, sueldo, fecha_baja)
			VALUES(emp.id_empleado, emp.id_especialidad, emp.id_cargo, emp.fecha_ingreso, emp.sueldo, emp.fecha_baja);
		END LOOP;
		
		UPDATE empleado SET id_cargo = (SELECT id_cargo FROM cargo WHERE cargo LIKE 'SIN CARGO ASIGNADO')
		WHERE id_cargo = old.id_cargo;
	END IF;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_modifica_empleado BEFORE DELETE ON  cargo 
FOR EACH ROW EXECUTE PROCEDURE modifica_empleado();

CREATE TRIGGER tg_modifica_empleado BEFORE DELETE ON especialidad
FOR EACH ROW EXECUTE PROCEDURE modifica_empleado();

SELECT * FROM especialidad;
DELETE FROM especialidad WHERE especialidad LIKE 'CARDIOLOGÍA';
SELECT * FROM empleado_modificado;
COMMIT;
ROLLBACK;