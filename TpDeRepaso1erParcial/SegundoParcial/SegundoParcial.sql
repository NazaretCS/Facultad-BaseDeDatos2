/*

a) Escriba el procedimiento almacenado sp_calcula_costo, el mismo recibirá como parámetros el id_paciente,
id_cama, fecha_inicio y fecha_alta. El procedimiento debe calcular el costo de la internación multiplicando la
cantidad de días por el precio de la habitación. Para facilitar el trabajo, no realice los controles de existencia de
pacientes, cama ni de fechas, solo haga el cálculo del total.
Nota1: se aconseja usar CREATE PROCEDURE sp_calcula_costo (int, int, date, date, out total Numeric) AS $$
Nota2: para calcular la cantidad de días puede usar dif:= EXTRACT(DAY FROM age(date(fecha2),date(fecha1)))

costo total = costo de la internacion * cantidad de dias * precio de la habitacion 
*/
    		CREATE OR REPLACE PROCEDURE sp_calcula_costo (p_id_paciente int, p_id_cama int, p_fecha_inicio date, p_fecha_alta date, out p_total Numeric) AS $$ 
                DECLARE 
                    v_cant_dias INT;
                    v_costo_internacion REAL;
                    v_precio_habitacion REAL;
                    
                BEGIN
                    v_cant_dias := EXTRACT(DAY FROM age(date(p_fecha_alta),date(p_fecha_inicio)));
                    /*v_cant_dias := 5;*/
                    SELECT costo INTO v_costo_internacion FROM internacion 
                    WHERE id_paciente = p_id_paciente;

                    SELECT precio INTO v_precio_habitacion FROM habitacion 
                    INNER JOIN cama USING(id_habitacion)
                    WHERE id_cama = p_id_cama; 
                    
                    p_total := v_cant_dias * v_costo_internacion * v_precio_habitacion;
                    --RAISE NOTICE 'CAMPOS: v_cant_dias %... v_costo_internacion  %... v_precio_habitacion %', v_cant_dias, v_costo_internacion, v_precio_habitacion;
                    RAISE NOTICE 'El costo final es: %', p_total;
                END;
            $$ LANGUAGE plpgsql;
            
            CALL sp_calcula_costo(26909, 70, '2019-01-31', '2020-02-21', NULL);
            /*
            select * from paciente 
            inner join internacion USING(id_paciente)
            inner join cama USING(id_cama)
            inner join habitacion USING(id_habitacion)
            WHERE id_paciente = 26909;
            */
	
/*
    b) Escriba el procedimiento almacenado sp_internacion; el mismo recibirá como parámetros el nombre y apellido
    de un paciente, id_cama y una fecha. Si en la tabla internación no existe un registro con el paciente, la cama
    ingresada y sin datos de la fecha de alta, deberá realizar un nuevo ingreso usando la fecha recibida como
    parámetro, como fecha_inicio y todos los campos restantes se insertan en null. 
    
    Por el contrario, si hay un registro
    con el paciente, la cama y la fecha de alta no tiene datos, deberá modificar el registro de la siguiente manera:
    
    el campo fecha de alta con la fecha ingresada, el campo hora con la hora del sistema y el campo costo deberá ser
    calculado usando la sp_calcula_costo. Realice todos los controles, y tenga en cuenta que hay camas que están
    fuera de servicio.

    Nota1: se aconseja usar CREATE PROCEDURE sp_internacion(text, text, integer, date) AS $$
    Nota2: se aconseja usar Variable = (SELECT sp_calcula_costo(arg1, arg2, arg3, arg4, NULL))

*/
    	CREATE OR REPLACE PROCEDURE sp_internacion(p_nombre_paciente text, p_apellido_paciente text, p_id_cama integer, p_fecha date) AS $$
        DECLARE
            v_id_paciente INT;
            v_id_paciente_internacion INT;
            v_id_cama INT;
			v_costo NUMERIC;
        BEGIN
            SELECT id_paciente INTO v_id_paciente FROM paciente
            INNER JOIN persona pe ON id_persona = id_paciente
            WHERE nombre = p_nombre_paciente AND apellido = p_apellido_paciente;

            IF v_id_paciente IS NULL THEN 
                RAISE EXCEPTION 'El paciente de nombre: % % no se encuentra registrado en la base de datos', p_nombre, p_apellido;
            END IF;

            SELECT id_paciente INTO v_id_paciente_internacion FROM internacion 
            WHERE id_paciente = v_id_paciente;

            IF p_id_cama IN (Select id_cama from cama WHERE estado NOT IN ('OK') ) THEN
                RAISE EXCEPTION 'La cama ingresada esta feura de servicio';
            END IF;

            SELECT id_cama INTO v_id_cama FROM internacion
            WHERE id_cama = p_id_cama;
            
            IF (v_id_paciente_internacion IS NULL) AND (v_id_cama IS NOT NULL) AND NOT EXISTS(SELECT id_cama FROM internacion WHERE fecha_alta IS null) THEN
                INSERT INTO internacion 
                VALUES (v_id_paciente, p_id_cama, p_fecha, 1, NULL, NULL, NULL);
            END IF;
            
			v_costo := '10000.00';
            --v_costo : = (SELECT sp_calcula_costo(v_id_paciente_internacion, p_id_cama, p_fecha_inicio, p_fecha_alta, NULL))
            --RAISE NOTICE 'v_costo  %', v_costo;

            IF (v_id_paciente_internacion IS NOT NULL) AND (v_id_cama IS NOT NULL) AND NOT EXISTS(SELECT id_cama FROM internacion WHERE fecha_alta IS null) THEN
                UPDATE internacion
                SET fecha_alta = p_fecha,
                    hora = CURRENT_TIME,
                    costo = v_costo;
            END IF;
        END;
    $$ LANGUAGE plpgsql;
	
	
	CALL sp_internacion('CAMILA', 'PONCE DE LEON PINHEIRO', 107, '2019-08-21')
	
	/*Datos aparte
	select * from paciente()
	inner join persona ON id_persona = id_paciente
	inner join internacion USING(id_paciente)
	inner join cama USING(id_cama)
	id: 503
	nombre: "CAMILA"
	apellido: "PONCE DE LEON PINHEIRO"
	id:cama = 107
	fecha_alta: "2019-08-21"
	p_nombre_paciente text, p_apellido_paciente text, p_id_cama integer, p_fecha date) AS $$*/

-- si no nos funciona y nos da error lo dejamos asi y o vemos mas tarde al invocar el sp 1.


/*
    EJERCICIO N° 2: TRIGGERS

        Realice los siguientes triggers, analizando cuidadosamente qué acción (INSERT, UPDATE o DELETE), sobre qué tabla y
        cuándo (BEFORE o AFTER) se deben activar los mismos:

            a) Cada vez que se inserte un registro en la tabla estudiorealizado, se debe insertar un registro en una nueva tabla
            llamada estudios_x_empleados, la misma tendrá los siguientes campos, id_empleado, nombre y apellido del
            empleado, el id y nombre del estudio que realizó y un campo cantidad, el cual guardará la cantidad de estudios
            que realizó el empleado y la fecha en la que se realizó el estudio. 
            
            Si en la tabla estudios_x_empleados existe un
            registro que contenga el id_empleado y el id_estudio, deberá aumentar la cantidad de estudio en 1 y cambiar la
            fecha por la del último estudio realizado, si no coincide alguno de los id, deberá insertar un nuevo registro con los
            nuevos datos.
*/
            CREATE TABLE public.estudios_x_empleados
            (
                id_empleado integer NOT NULL,
                nombre_empleado character varying(100) NOT NULL,
                apellido_empleado character varying(100) NOT NULL,
                id_estudio smallint,
                nombre_estudio character varying(100),
                cantidad integer,
                fecha date,
                PRIMARY KEY (id_empleado)
            );

            ALTER TABLE IF EXISTS public.estudios_x_empleados
                OWNER to postgres;
				
				
	
	        CREATE OR REPLACE FUNCTION fn_estudios_x_empleado2()
            RETURNS TRIGGER AS $tr_crear_estudios_x_empleado$
                DECLARE
                    v_id_empleado INT;
                BEGIN
                    
                    SELECT id_empleado INTO v_id_empleado FROM estudios_x_empleados 
                    WHERE id_empleado = NEW.id_empleado AND id_estudio = NEW.id_estudio;

                    IF v_id_empleado IS NOT NULL THEN
                        UPDATE estudios_x_empleados
                        SET cantidad = cantidad + 1
                        WHERE (id_empleado=NEW.id_empleado) AND (id_estudio=NEW.id_estudio);
                    ELSE
                        INSERT INTO estudios_x_empleados
                        VALUES (NEW.id_empleado, 
								(SELECT nombre FROM persona INNER JOIN empleado ON id_persona = id_empleado WHERE id_empleado = NEW.id_empleado),
                                (SELECT apellido FROM persona INNER JOIN empleado ON id_persona = id_empleado WHERE id_empleado = NEW.id_empleado), 
								NEW.id_estudio, 
                                (SELECT nombre FROM estudio WHERE id_estudio = NEW.id_estudio), 
								1, 
								NEW.fecha);
                    END IF;
					RETURN NEW;
                END;
            $tr_crear_estudios_x_empleado$  LANGUAGE plpgsql;

            CREATE TRIGGER tr_crear_estudios_x_empleado AFTER INSERT ON estudio_realizado
            FOR EACH ROW EXECUTE PROCEDURE fn_estudios_x_empleado2();
			/*
			select * from estudio_realizado
	
			select * from estudios_x_empleados
			
			INSERT INTO estudio_realizado
			VALUES (682, 2, '2019-01-08', 29, 184, 'NAZARETTTTT', 'NAZARET DE NUEVO', 200.00);
            */
			-- id_paciente  id_estudio  fecha  id_equipo  id_empleado  



/*
    b) Audite la tabla empleados solo cuando se modifique el campo sueldo por un sueldo mayor. Se debe guardar un
    registro en la tabla audita_empleado. Los datos que debe almacenar la nueva tabla serán: id, usuario, la fecha
    cuando se produjo la modificación, el id, nombre y apellido del empleado, el sueldo antes de la modificación y el
    sueldo después de la modificación, además de un campo llamado porcentaje, que guardará el porcentaje de
    aumento.
    Nota2: porcentaje = ((sueldo_aumentado - sueldo_sin_aumento) / sueldo_sin_aumento) * 100
*/
