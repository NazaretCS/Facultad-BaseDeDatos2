/*
        a) Escriba una función para realizar altas en las tablas factura o bien, en la tabla pago, según corresponda. Los parámetros que recibe la función son el nombre y apellido de un paciente, la fecha y el monto. 
        Si no existe  en la tabla factura un registro con el paciente y la fecha ingresada,  deberá realizar un nuevo ingreso en la tabla factura
        Por el contrario si existe en la tabla factura un registro con el paciente y la fecha ingresada, debe hacer un alta en la tabla pago con el id_factura correspondiente.  La fecha para el alta en la tabla pago no debe ser la pasada como parámetro, sino la del sistema. 
        Tenga en cuenta que puede existir un registro en la tabla pago con el id_factura, porque se realizan pagos parciales. En ese caso debe actualizar el monto de la tabla pago sumándole al monto existente el monto nuevo. 
        Recuerde realizar todos los controles a los parámetros.


        n PostgreSQL, puedes obtener la fecha actual del sistema utilizando la función CURRENT_DATE. Esta función devuelve la fecha actual en formato DATE. Si deseas obtener también la hora actual, puedes usar la función CURRENT_TIMESTAMP, que devuelve la fecha y hora actual en formato TIMESTAMP.


*/      
        CREATE OR REPLACE FUNCTION fn_alta_factura_o_pago(p_nombre CHARACTER VARYING,
                                                          p_apellido CHARACTER VARYING,
                                                          p_fecha DATE, 
                                                          p_monto NUMERIC)
        RETURNS VOID AS $$
                DECLARE
                        v_id_factura_paciente INT;
                        v_id_paciente INT;
                BEGIN
                        SELECT id_paciente INTO v_id_factura_paciente FROM factura
                        INNER JOIN persona ON id_persona = id_paciente AND fecha = p_fecha;

                        IF v_id_factura_paciente IS NULL THEN
                                SELECT id_paciente INTO v_id_paciente FROM paciente 
                                INNER JOIN persona ON id_persona = id_paciente
                                WHERE nombre = p_nombre AND apellido = p_apellido;
                                IF v_id_paciente IS NULL THEN
                                        RAISE EXCEPTION 'El paciente % % no se encuentra registrado en la base de datos', p_nombre, p_apellido;
                                END IF;
                                INSERT INTO factura 
                                VALUES ((SELECT MAX(id_factura)+1), v_id_paciente, p_fecha, CURRENT_TIME, p_monto, 'N', p_monto)
                        ELSE 
                                INSERT INTO pago
                                VALUES (v_id_factura_paciente, CURRENT_DATE, p_monto)
                        END IF;
                        
                END;
        $$ LANGUAGE plpgsql;