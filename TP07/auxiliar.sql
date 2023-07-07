/*
		i) Escriba UNA función que liste todos los registros de alguna de las siguientes tablas: cargo,
        clasificaciones, especialidad, patología y tipo_estudio. No use estructuras de control para
        decidir que tabla mostrar, solo debe averiguar si el parámetro pasado a la función coincide
        con el nombre de alguna de las tablas requeridas.

		*/

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

		
		   
			