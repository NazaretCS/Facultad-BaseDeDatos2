/*  
	1) Muestre el id, nombre, apellido y dni de los pacientes que tienen obra social.

		SELECT id_persona, pe.nombre, apellido,  FROM persona pe
		INNER JOIN paciente ON id_paciente = id_persona
		INNER JOIN obra_social USING(id_obra_social)
		order by(id_persona)
*/ 

/*
	2) Liste todos los pacientes con obra social que fueron atendidos en los consultorios 'CARDIOLOGIA' o 'NEUMONOLOGIA'. Debe 
	   mostrar el nombre, apellido, dni y nombre de la obra social.
	   

		SELECT pe.nombre, pe.apellido, pe.dni, obs.nombre FROM persona pe
		INNER JOIN paciente ON id_persona = id_paciente 
		INNER JOIN obra_social obs USING(id_obra_social)
		INNER JOIN consulta USING (id_paciente)
		INNER JOIN consultorio USING(id_consultorio)
		WHERE id_consultorio IN (
								  SELECT id_consultorio FROM consultorio 
								  WHERE nombre IN ('CARDIOLOGIA', 'NEUMONOLOGIA')
								)
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
															le falta hacer la agrupación	
															
															sabra Dios a que me habre referido con la Agrupacion 

*/


/*

	3) Liste el id, nombre, apellido y sueldo de los empleados, como así también su cargo y especialidad. Ordenado alfabéticamente por 
	   cargo, luego por especialidad y en último término por sueldo de mayor a menor.
	   
	   
		SELECT empl.id_empleado, nombre, apellido, sueldo, cargo, especialidad  FROM empleado empl 
		INNER JOIN persona ON (id_persona = empl.id_empleado)
		INNER JOIN cargo USING(id_cargo)
		INNER JOIN especialidad USING(id_especialidad)
		ORDER BY cargo, especialidad, sueldo DESC

*/


/*

	4) Encuentre el empleado, cargo y turno de todos los empleados cuyo cargo sea AUXILIAR y el turno de trabajo aún se encuentre vigente.
	
	
		SELECT * FROM empleado 
		INNER JOIN cargo USING(id_cargo)
		INNER JOIN trabajan USING(id_empleado)
		--INNER JOIN turno USING(id_turno)
		WHERE cargo LIKE '%AUXILIAR%' AND inicio IS NOT NULL AND fin IS NULL
		
*/		


/*

	5) Muestre la cantidad de compras realizadas por los empleados de la especialidad SIN ESPECIALIDAD MEDICA. Debe mostrar el 
	   nombre del empleado, el cargo que tiene y la cantidad de compras, ordenado por cantidad de mayor a menor.
	   
	   		
			SELECT COUNT(fecha) as CantCompras, pe.nombre, cargo, especialidad FROM empleado emp
			INNER JOIN persona pe ON (id_persona = id_empleado)
			INNER JOIN cargo USING(id_cargo)
			INNER JOIN compra USING(id_empleado)
			INNER JOIN especialidad USING(id_especialidad)
			WHERE especialidad IN ('SIN ESPECIALIDAD MEDICA')
			GROUP BY pe.nombre, cargo, especialidad
			ORDER BY CantCompras DESC
			
	
	6) Muestre los pacientes que tienen obra social, que fueron internados en septiembre del 2019, en el 7mo y 8vo piso. 
	   Ordenados por la fecha de internación de mayor a menor.
	   
	  		SELECT pe.nombre, pe.apellido, sigla, fecha_inicio, piso  from paciente
			INNER JOIN persona pe ON id_persona = id_paciente
			INNER JOIN obra_social USING(id_obra_social)
			INNER JOIN internacion USING(id_paciente)
			INNER JOIN cama USING(id_cama)
			INNER JOIN habitacion USING(id_habitacion)
			WHERE fecha_inicio BETWEEN '2019-09-01' AND '2019-09-30' AND piso IN ('8','9')
			ORDER BY fecha_inicio
	   


	7) Muestre los proveedores a los que no se les compró ningún medicamento.
	
			SELECT * FROM proveedor
			WHERE id_proveedor NOT IN (
										 SELECT id_proveedor FROM compra 	
									   )


	 	 Otra Posible forma de resolverlo
		
			SELECT * FROM proveedor
			LEFT JOIN compra USING(id_proveedor)
			WHERE fecha IS NULL 
			
		
															&&&&&&&&&&&&&&&&&&&&&&&&&&&&
															%%                        %%
															%%          #####         %%
													     	%%       ###     ###      %%      
															%%            ###         %%
															%%           ##           %%
															%%                        %%
															%%           #            %%
															%%    Ver que ondaa       %%
															%%%%%%%%%%%%%%%%%%%%%%%%%%%%
																
												
		
	8) Liste los medicamentos que no fueron prescriptos nunca


	
		SELECT * FROM medicamento
		WHERE id_medicamento NOT IN (
									  SELECT id_medicamento FROM compra 
									)
											
									
															&&&&&&&&&&&&&&&&&&&&&&&&&&&&
															%%                        %%
															%%          #####         %%
													     	%%       ###     ###      %%      
															%%            ###         %%
															%%           ##           %%
															%%                        %%
															%%           #            %%
															%%    Ver que ondaa       %%
															%%%%%%%%%%%%%%%%%%%%%%%%%%%%
															
															
															
															
	9) Muestre los empleados que hayan realizado más internaciones que 'DAVID MASAVEU' antes del 15/02/2019.
	
	
		SELECT COUNT(fecha_inicio) as CantInternaciones, per.nombre, per.apellido FROM empleado
		INNER JOIN persona per ON id_persona = id_empleado
		INNER JOIN internacion ON ordena_internacion = id_empleado
		GROUP BY per.nombre,  per.apellido
		HAVING COUNT(fecha_inicio) > ALL (
										 SELECT COUNT(fecha_inicio) as CantInternaciones FROM empleado
										 INNER JOIN persona pe ON id_persona = id_empleado 
										 INNER JOIN internacion ON ordena_internacion = id_empleado
										 WHERE nombre LIKE '%DAVID%' AND apellido LIKE '%MASAVEU%' AND fecha_inicio < 2019-02-15
										 GROUP BY pe.nombre, pe.apellido
									   )
		ORDER BY CantInternaciones
	
	
	
	
		Si es de la segunda manera esta seria la forma, pero no me devuelve nada... que lo pario
		
		SELECT COUNT(fecha_inicio) as CantInternaciones, per.nombre, per.apellido FROM empleado
		INNER JOIN persona per ON id_persona = id_empleado
		INNER JOIN internacion ON ordena_internacion = id_empleado		
		WHERE fecha_inicio < '2019-02-15'
		GROUP BY per.nombre,  per.apellido
		HAVING COUNT(fecha_inicio) > ALL (
										 SELECT COUNT(fecha_inicio) as CantInternaciones FROM empleado
										 INNER JOIN persona pe ON id_persona = id_empleado 
										 INNER JOIN internacion ON ordena_internacion = id_empleado
										 WHERE nombre LIKE '%DAVID%' AND apellido LIKE '%MASAVEU%'
										 GROUP BY pe.nombre, pe.apellido
									   )
		ORDER BY CantInternaciones DESC
	
	
	10) Muestre los pacientes a los que les hayan facturado más que ‘LAURA MONICA JABALOYES’ desde el 15/05/2022 a la fecha.
	
		
		SELECT SUM(monto) as TotalFacturado, nombre, apellido, id_paciente  FROM paciente
		INNER JOIN persona ON id_persona = id_paciente 
		INNER JOIN factura USING(id_paciente) 
		GROUP BY id_paciente, nombre, apellido
		HAVING SUM(monto) > ALL (
									SELECT SUM(monto) FROM paciente
									INNER JOIN persona ON id_persona = id_paciente 
									INNER JOIN factura USING(id_paciente)
									WHERE 	nombre LIKE '%LAURA MONICA%' 
											AND apellido LIKE '%JABALOYES%' 
											AND fecha BETWEEN  '2022-05-15' AND CURRENT_TIMESTAMP
								    )
		ORDER BY id_paciente	
		
		
		
		
		De nuevo, dependiendo del enfoque q le de partiendo del enunciado...
		
		
		SELECT SUM(monto) as TotalFacturado, nombre, apellido, id_paciente  FROM paciente
		INNER JOIN persona ON id_persona = id_paciente 
		INNER JOIN factura USING(id_paciente) 
		WHERE fecha BETWEEN  '2022-05-15' AND CURRENT_TIMESTAMP
		GROUP BY id_paciente, nombre, apellido
		HAVING SUM(monto) > ALL (
									SELECT SUM(monto) FROM paciente
									INNER JOIN persona ON id_persona = id_paciente 
									INNER JOIN factura USING(id_paciente)
									WHERE 	nombre LIKE '%LAURA MONICA%' 
											AND apellido LIKE '%JABALOYES%' 											
								    )
		ORDER BY id_paciente
	
	
	
	
	11) Liste todos los empleados que no hayan comprado medicamentos del proveedor ‘ARABESA’ entre el 01/02/2018 y el 10/03/2018. 
		Ordénelos alfabéticamente.
		
		
		
			SELECT id_empleado, nombre, apellido, proveedor, fecha FROM empleado
			INNER JOIN persona ON id_persona = id_empleado
			INNER JOIN compra USING(id_empleado)
			INNER JOIN proveedor USING(id_proveedor)
			WHERE id_empleado NOT IN (
										SELECT id_empleado FROM empleado
										INNER JOIN compra USING(id_empleado)
										INNER JOIN proveedor USING(id_proveedor)
										WHERE proveedor LIKE '%ARABESA%' AND fecha BETWEEN '2018-02-01' AND '2018-03-10'
									 )
			GROUP BY id_empleado, nombre, apellido, proveedor, fecha
		
		
		
		
	12) Muestre los 5 medicamentos más recetados y el laboratorio al que pertenecen.
	
		
			SELECT COUNT(id_medicamento) as CantidadTotal, nombre, id_medicamento, id_laboratorio FROM medicamento
			INNER JOIN compra USING(id_medicamento)
			INNER JOIN laboratorio USING(id_laboratorio)
			GROUP BY(id_medicamento)
			ORDER BY CantidadTotal DESC
			LIMIT 5
			
			
			
															&&&&&&&&&&&&&&&&&&&&&&&&&&&&
															%%                        %%
															%%          #####         %%
													     	%%       ###     ###      %%      
															%%            ###         %%
															%%           ##           %%
															%%                        %%
															%%           #            %%
															%%    	     #            %%
															%%%%%%%%%%%%%%%%%%%%%%%%%%%%
															
															Consultar porque me exije que el "laboratorio"
															valla en el group by si o si para mostarlo, pero 
															el nombre del medicamento no.




	13) Muestre (en una sola consulta) el id, fecha de ingreso y estado de todas las camas y equipos que aún no fueron reparadas.
	
	SELECT mc.estado as EstadoCama, me.estado as EstadoEquipo, id_equipo, id_cama FROM empleado
			LEFT JOIN mantenimiento_cama mc USING(id_empleado)
			LEFT JOIN mantenimiento_equipo me USING(id_empleado)
			WHERE mc.estado <> 'reparado'
			
			SELECT id_cama, mc.fecha_ingreso, mc.estado FROM mantenimiento_cama mc
			LEFT JOIN empleado USING(id_empleado)
			LEFT JOIN mantenimiento_equipo me USING(id_empleado)
			WHERE mc.estado <> 'reparado' OR me.estado <> 'reparado'
			
			
			SELECT id_cama, mc.fecha_ingreso, mc.estado, id_equipo FROM mantenimiento_cama mc
			LEFT JOIN empleado USING(id_empleado)
			LEFT JOIN mantenimiento_equipo me USING(id_empleado)
			WHERE mc.estado <> 'reparado' OR me.estado <> 'reparado'
			
			
															&&&&&&&&&&&&&&&&&&&&&&&&&&&&
															%%                        %%
															%%          #####         %%
													     	%%       ###     ###      %%      
															%%            ###         %%
															%%           ##           %%
															%%                        %%
															%%           #            %%
															%%    	     #            %%
															%%%%%%%%%%%%%%%%%%%%%%%%%%%%
															
															Consultar, no le hallo jajajaj
															
															
	14) Modifique el precio, aumentando un 5%, a los medicamentos cuyo laboratorio sea ‘LABOSINRATO’ y la clasificación 
		sea ‘APARATO DIGESTIVO’ o ‘VENDAS’.
		
				UPDATE medicamento				
				INNER JOIN clasificacion USING(id_clasificacion)
				INNER JOIN laboratorio USING(id_laboratorio)
				SET precio = precio + (5 * precio)/100
				WHERE laboratorio LIKE '%LABOSINRATO%' AND clasificacion IN ('APARATO DIGESTIVO', 'VENDAS')
				
				
				
															&&&&&&&&&&&&&&&&&&&&&&&&&&&&
															%%                        %%
															%%          #####         %%
													     	%%       ###     ###      %%      
															%%            ###         %%
															%%           ##           %%
															%%                        %%
															%%           #            %%
															%%    	     #            %%
															%%%%%%%%%%%%%%%%%%%%%%%%%%%%
															
															Porque no me deja actualizar.?
															
	15) Modifique el campo estado de la tabla mantenimiento_equipo, con la palabra “baja” y en la fecha de egreso ponga la fecha del 
		sistema, de aquellos equipos que ingresaron hace más de 100 días (recalcule usando la fecha de ingreso y la del sistema)
		
		
				UPDATE mantenimiento_equipo
				SET estado = 'baja', fecha_egreso = CURRENT_TIMESTAMP
				WHERE DATEDIFF(CURRENT_TIMESTAMP, fecha_ingreso) > 100
				
				
															&&&&&&&&&&&&&&&&&&&&&&&&&&&&
															%%                        %%
															%%          #####         %%
													     	%%       ###     ###      %%      
															%%            ###         %%
															%%           ##           %%
															%%                        %%
															%%           #            %%
															%%    	     #            %%
															%%%%%%%%%%%%%%%%%%%%%%%%%%%%					
									
															Los update no son lo mio
															
															
															
	16) Elimine las clasificaciones que no se usan en los medicamentos.			
	
		DELETE FROM clasificacion
		LEFT JOIN medicamento USING(id_clasificacion)
		WHERE id_medicamento IS NULL
		
		
		DELETE FROM clasificacion
		WHERE id_clasificacion NOT IN (
									SELECT id_clasificacion FROM medicamento
								  )
				
				
	
	
	17) Elimine las compras realizadas entre 01/03/2008 y 15/03/2008, de los medicamentos cuya clasificación es ‘ENERGETICOS’.
	
	
		DELETE FROM compra
		WHERE fecha BETWEEN '2008-03-01' AND '2008-03-15' AND id_medicamento NOT IN (
																					SELECT id_medicamento FROM medicamento
																					INNER JOIN clasificacion USING(id_clasificacion)
																					WHERE clasificacion <> 'ENERGETICOS'
																				   )
*/	

		
		
		
	
				
			
			
			
			
		
		
		
		
		
		
		
		

		