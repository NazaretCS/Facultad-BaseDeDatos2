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
	
		
		
		
	
*/

		SELECT * FROM paciente
		INNER JOIN persona ON id_persona = id_paciente 
		WHERE nombre LIKE '%LAURA MONICA%' AND apellido LIKE '%JABALOYES%' AND BETWEEN ('2022-05-15' AND '')

		
		
		
		

		