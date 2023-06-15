/*
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
		
			/*
			   -- Construir la consulta dinámica
			   v_query := 'UPDATE empleado
						   SET ' || p_campo_modificar || ' = ' || quote_literal(p_fecha) || '
						   WHERE id_empleado = ' || v_id_empleado;

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
	
	
*/
		CREATE OR REPLACE PROCEDURE 
