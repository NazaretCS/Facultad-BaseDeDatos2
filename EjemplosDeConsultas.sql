/*

WHERE fecha_envio between  '2019-01-01' AND '2019-12-31'  AND provincia IN ('La Rioja', 'Mendoza')

i. Muestre los expresos que no hayan realizado ningún envío a clientes de México o Brasil en el periodo del 01/06/2015 hasta el 30/06/2016
     
		 SELECT expreso FROM expreso
			WHERE idexpreso NOT IN (
									SELECT idexpreso FROM pedidos
									INNER JOIN clientes USING(idcliente)
									 WHERE  DATE(fechapedido) < '2015-06-01' OR DATE(fechapedido) > '2016-06-30' 
                                     AND pais NOT IN ('México', 'Brasil')
									)

g) Obtenga el socio, el empleado, título y la fecha de todos los artículos que fueron vendidos en ‘Tucumán’, ‘Salta’ y ‘Jujuy’ y 
       tienen el mismo autor del artículo de título ‘Cien Años De Soledad’. Ordenado por título, fecha y empleado.
       
       
		SELECT PERS.nombre AS NombreSocio, PE.nombre AS NombreEmpleado, titulo, fecha FROM articulo
        INNER JOIN detalle_venta USING(id_articulo)
        INNER JOIN venta USING(id_venta)
        
        INNER JOIN socio S USING(id_socio)
        INNER JOIN persona PERS ON (PERS.id_persona = id_socio)
        
        INNER JOIN empleado USING(id_empleado)
        INNER JOIN persona PE ON (PE.id_persona = id_empleado )
        
        INNER JOIN ciudad USING(id_ciudad)
        INNER JOIN provincia USING(id_provincia)
        WHERE provincia IN ('Tucumán', 'Salta', 'Jujuy') AND id_autor IN (
																			SELECT id_autor FROM articulo 
                                                                            WHERE titulo = 'Cien Años De Soledad'
                                                                            GROUP BY id_autor 
																		 )
		ORDER BY titulo, fecha, id_empleado;
        

l) Muestre el id, nombre, la ciudad y la cantidad de artículos comprados por los socios que no sean de 'Chaco', 'Formosa', 
          'Corrientes' ni 'Misiones' y que hayan comprado más artículos que la cantidad total vendida del articulo 'Harry Potter Y 
          La Orden del Fénix'.
          
            SELECT id_socio, nombre, ciudad, SUM(id_venta) AS CantArticulos FROM socio
			INNER JOIN persona ON id_persona = id_socio
			INNER JOIN ciudad USING(id_ciudad)
			INNER JOIN venta USING(id_socio)
			INNER JOIN provincia USING(id_provincia)            
			WHERE provincia NOT IN ('Chaco', 'Formosa', 'Corrientes', 'Misiones') 
            GROUP BY(id_socio) 
            HAVING CantArticulos > ANY (
									   SELECT SUM(id_articulo) FROM detalle_venta
									   INNER JOIN articulo USING(id_articulo)
									   WHERE titulo = 'Harry Poter Y La Orden Del Fenix'
									   )

o) Muestre el id y el nombre de TODAS las empresas de envío, y también mostrar la cantidad de entregas realizadas por c/empresa 
           a cada provincia (de haberlo hecho). Ordenar de mayor a menor por cantidad de envíos.
      
		   SELECT id_envio, envio, SUM(V.id_envio) AS EnviosTotales, provincia FROM envio
		   LEFT JOIN venta V USING(id_envio)
		   LEFT JOIN socio USING(id_socio)
		   LEFT JOIN ciudad USING(id_ciudad)
		   LEFT JOIN provincia USING(id_provincia)
		   GROUP BY(id_envio)
                                
p) Muestre el id, nombre, función y monto total de ventas de los empleados que hayan vendido menos que el 10% del monto
           total de las ventas enviadas por “FedEx”.
           
			SELECT id_empleado, nombre, funcion, SUM(total) AS TotalVentas FROM empleado
			INNER JOIN persona ON id_persona = id_empleado 
			INNER JOIN funcion USING(id_funcion)
			INNER JOIN venta USING(id_empleado)
            group by id_empleado
			HAVING SUM(total)  < (	
								 SELECT SUM(total) FROM venta
								 INNER JOIN envio USING(id_envio)
								 WHERE envio = 'FedEx'
								) /10
                                
                                
s) Elimine las empresas de envío que nunca fueron utilizadas.
                                
			DELETE FROM envio
			WHERE id_envio NOT IN (SELECT distinct id_envio
								   FROM venta);
                                
			DELETE FROM envio
			WHERE id_envio NOT IN (
									SELECT id_envio FROM venta	
									)


CREATE VIEW Info_Venta AS
			SELECT EMP.nombre AS NombreEmpleado, S.nombre AS NombreSocio, provincia, titulo, autor, genero, editorial, DV.precio, 
				   fecha_envio, envio, entregado FROM venta
			INNER JOIN socio USING(id_socio)
			INNER JOIN persona S ON (S.id_persona = id_socio)
			INNER JOIN empleado USING(id_empleado)
			INNER JOIN persona EMP ON (EMP.id_persona = id_empleado)
			INNER JOIN ciudad USING(id_ciudad)
			INNER JOIN provincia USING(id_provincia)
			INNER JOIN detalle_venta DV USING(id_venta)
			INNER JOIN articulo USING(id_articulo)
			INNER JOIN autor USING(id_autor)
			INNER JOIN genero USING(id_genero)
			INNER JOIN editorial USING(id_editorial)
			INNER JOIN envio USING(id_envio) 
			ORDER BY(id_articulo, fecha)

i. Los campos “importe, gastoenvio y total” de la tabla venta debe tener por defecto el valor 0 (cero).
    
		ALTER TABLE venta 
		ALTER importe SET DEFAULT 0,
		ALTER gasto_envio SET DEFAULT 0,
		ALTER total SET DEFAULT 0;
  
ii. El campo “cantidad” de la tabla detalle_venta no puede menor que 1 (uno)
    
		ALTER TABLE detalle_venta 
		ADD CONSTRAINT chkCantidad CHECK (cantidad>0)
	
iii. Los campos “dni y empleado” de la tabla empleado no pueden ser nulos.
    
		ALTER TABLE `persona`
		CHANGE COLUMN `dni` `dni` VARCHAR(8) NOT NULL,
		CHANGE COLUMN `nombre` `nombre` VARCHAR(100) NOT NULL;	
        
	
a) Elimine la empresa de envio “Andreani”.
            
				DELETE FROM envio
				WHERE 'envio' = "Andreani";
                
                
c) Elimine los préstamos de los socios que hayan sido multados entre el 02-01-2015 y 31-03-2015
            
				DELETE FROM prestamo
				WHERE 'inicio_prestamo' BETWEEN '2015-01-02' AND '2015-03-31'
                
                
 a) Modifique el campo sueldo de la tabla empleados, aumentando en un 5%, de aquellos empleados cuyo sueldo supere los $100000.
            
				UPDATE empleado 
				SET sueldo = sueldo + (5 * sueldo)/100
				WHERE sueldo > 100000;
        

c) Modifique la tabla préstamo, el campo estado_multa, con el valor “pagado” y el campo devolución con la fecha del sistema, 
			   a todos los registros que hayan tenido multa entre el 02-01-2018 y el 31-12-2020.
               
                UPDATE prestamo 
				SET estado_multa = "pagado", fecha_devolucion = CURDATE() 
				WHERE multa > 0 AND fin_prestamo BETWEEN "2018-01-02" AND "2020-12-31";

	
	
	INSERT INTO autor (id_autor,autor,tipo)
	VALUES ((SELECT MAX(a.id_autor) FROM autor a)+1,'Dolores Cuadra','autor');
	
	INSERT INTO articulo (id_articulo, id_autor, id_editorial, id_genero, titulo, duracion_paginas, anio,
	precio, id_origen, id_proveedor)	
	VALUES ((SELECT MAX(a.id_articulo) FROM articulo a)+1,(SELECT a.id_autor FROM autor a WHERE
	autor = 'Paul Beynon-Davies'),(SELECT e.id_editorial FROM editorial e WHERE editorial = 'Editorial
	Reventé'),(SELECT g.id_genero FROM genero g WHERE genero = 'Informatica'),'Sistemas de Bases
	de Datos',686,2010,24.954,(SELECT o.id_origen FROM origen o WHERE origen = 'U.K'),10);
	
	
	UPDATE prestamo
	SET estado_multa = 'pagado', fecha_devolucion = curdate()
	WHERE multa IS NOT NULL AND fin_prestamo BETWEEN '2018-01-02' AND '2020-12-31';
	
	
	
	CONSULTAS - FUNCIONES AGREGADAS
	*******************************
	
	• COUNT: Devuelve el número total de filas o tuplas seleccionadas por la consulta.
	• MIN: Devuelve el valor mínimo del atributo que especifiquemos
	• MAX: Devuelve el valor máximo del atributo que especifiquemos
	• SUM: Suma los valores del atributo que especifiquemos. Sólo se puede utilizar en columnas numéricas
	• AVG: Devuelve el valor promedio del campo que especifiquemos. Sólo atributos numéricos
	
	GROUP BY: permite agrupar filas según las columnas que se indiquen como parámetros. Permite funciones de
	agregación para obtener datos resumidos y agrupados por las columnas que se necesiten.
	
	HAVING: Permite un nuevo filtrado, pero sobre las tuplas afectadas por el GROUP BY, en función de una
	condición aplicable a cada grupo de filas.
	
	
	
	Funciones integradas
	********************
	Las funciones integradas son simplemente funciones que ya vienen implementadas en el servidor MySQL.
	Estas funciones nos permiten realizar diferentes tipos de manipulaciones en los datos.
	Las funciones integradas se pueden clasificar básicamente en las siguientes categorías más utilizadas: numéricas, 
	de cadena, de fecha, etc
	
	
	EJ.: Mostrar todos los nombres de Proveedores con Mayúsculas:
		SELECT UPPER(proveedor) FROM Proveedores
		
	EJ.: Mostrar todos los productos con su detalle completo.
		SELECT CONCAT(producto," en ", descripción)
		FROM Productos
		
		
		
	Mostrar el IVA de los montos de la tabla Pedidos, lo que significa el 21% del mismo.
	De acuerdo a cómo se implementa la operación dependerá el tipo de resultado:
	 	SELECT monto*21/100 FROM Pedidos // (devuelve 6 decimales)
		
		SELECT monto*0.21 FROM Pedidos // (devuelve 4 decimales)
		
		SELECT round(monto*0.21, 2) 
		FROM Pedidos
		(para dejar a 2 decimales)
		
		
		
	Mostrar las fechas de pedido sin mostrar el dato hora:
		SELECT DATE(fechapedido) FROM Pedidos
		ORDER BY fechapedido
		
	Mostrar la diferencia en días entre la fecha de entrega y la fecha de envío;
		SELECT DATEDIFF(FECHAENTREGA,FECHAENVIO)
		FROM PEDIDOS
	
	Mostrar la fecha y el monto de cada pedido, de los últimos 5 pedidos
		SELECT date(fechapedido),monto
		FROM Pedidos
		ORDER BY fechapedido DESC
		LIMIT 5
		
	Listar todos los empleados y su edad, a partir de la fecha de nacimiento.
		SELECT empleado,
		timestampdiff(year, fechanacimiento,
		curdate())
		FROM Empleados
	
	
	Mostrar campos numéricos como texto
		SELECT monto from Pedidos
		
		SELECT concat('$ ', cast(monto as char)) FROM Pedidos
		
		SELECT concat(cast(monto as char),'pesos') from Pedidos
		
		
		
		
		
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
*/	
	CREATE OR REPLACE PROCEDURE medicamento_laboratorio_clasificacion( IN p_nombre_laboratorio character varying(500),
																	   IN p_nombre_clasificacion character varying(75))
	AS $$
		DECLARE
			v_id_laboratorio integer;
			v_id_clasificacion integer;
			v_promedio_precio numeric(8, 2);
			v_cursor_row medicamento%ROWTYPE;
			
			cursor_medicamentos CURSOR FOR
											SELECT *
											FROM medicamento
											WHERE id_laboratorio = v_id_laboratorio
											AND id_clasificacion = v_id_clasificacion
											AND precio < v_promedio_precio
											ORDER BY precio ASC;

		BEGIN
			SELECT id_laboratorio INTO v_id_laboratorio
			FROM laboratorio
			WHERE laboratorio = p_nombre_laboratorio;
			
			IF v_id_laboratorio IS NULL THEN
				RAISE NOTICE 'El laboratorio ingresado no existe.';
				RETURN;
			END IF;
			
			SELECT id_clasificacion INTO v_id_clasificacion
			FROM clasificacion
			WHERE clasificacion = p_nombre_clasificacion;
			
			IF v_id_clasificacion IS NULL THEN
				RAISE NOTICE 'La clasificación ingresada no existe.';
				RETURN;
			END IF;
			
			SELECT AVG(precio) INTO v_promedio_precio
			FROM medicamento
			WHERE id_laboratorio = v_id_laboratorio
			AND id_clasificacion = v_id_clasificacion;
			
			IF v_promedio_precio IS NULL THEN
				RAISE NOTICE 'No hay medicamentos disponibles para el laboratorio y clasificación especificados';
				RETURN;
			END IF;
			
			OPEN cursor_medicamentos;
			LOOP
				FETCH cursor_medicamentos INTO v_cursor_row;
				EXIT WHEN NOT FOUND;
				
				RAISE NOTICE 'ID Medicamento: %, Nombre: %, Precio: %', v_cursor_row.id_medicamento, v_cursor_row.nombre, v_cursor_row.precio;
			END LOOP;
			CLOSE cursor_medicamentos;
		END;
	$$ LANGUAGE plpgsql;
