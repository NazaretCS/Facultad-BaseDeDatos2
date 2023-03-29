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
															le falta hacer la agrupacion

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
	   
	   		

*/
