/*
	Informes
	
			CREATE ROLE "camposn_Informes" WITH
			NOLOGIN
			NOSUPERUSER
			NOCREATEDB
			NOCREATEROLE
			INHERIT
			NOREPLICATION
			CONNECTION LIMIT -1;


		a) Mostrar datos de los pacientes, si tiene obra social, también el nombre de la misma.

			GRANT SELECT ON TABLE public.paciente TO "camposn_Informes";

			GRANT SELECT ON TABLE public.obra_social TO "camposn_Informes";

			GRANT SELECT ON TABLE public.persona TO "camposn_Informes";


		b) Mostrar las consultas a las que asistió el paciente, también debe mostrar el medico que lo atendió, el 
		diagnóstico y el tratamiento que le suministro.

			GRANT SELECT ON TABLE public.persona TO "camposn_Informes";

			GRANT SELECT ON TABLE public.paciente TO "camposn_Informes";

			GRANT SELECT ON TABLE public.empleado TO "camposn_Informes";

			GRANT SELECT ON TABLE public.consulta TO "camposn_Informes";

			GRANT SELECT ON TABLE public.diagnostico TO "camposn_Informes";

			GRANT SELECT ON TABLE public.tratamiento TO "camposn_Informes";


		c) Mostrar las internaciones que tuvo el paciente, debe mostrar la habitación y la cama en la que estuvo.

			GRANT SELECT ON TABLE public.paciente TO "camposn_Informes";

			GRANT SELECT ON TABLE public.persona TO "camposn_Informes";

			GRANT SELECT ON TABLE public.internacion TO "camposn_Informes";

			GRANT SELECT ON TABLE public.habitacion TO "camposn_Informes";

			GRANT SELECT ON TABLE public.cama TO "camposn_Informes";


		d) Mostrar los estudios que le realizaron, los equipos que se utilizaron y el profesional que le realizo el
		estudio.

			GRANT SELECT ON TABLE public.estudio_realizado TO "camposn_Informes";

			GRANT SELECT ON TABLE public.equipo TO "camposn_Informes";

			GRANT SELECT ON TABLE public.empleado TO "camposn_Informes";
			
			GRANT SELECT ON TABLE public.estudio TO "camposn_Informes";

			GRANT SELECT ON TABLE public.paciente TO "camposn_Informes";

			GRANT SELECT ON TABLE public.persona TO "camposn_Informes";



		e) Mostrar datos de los empleados, horarios que cumple, las consultas y diagnósticos, estudios en los que
		intervino.

			GRANT SELECT ON TABLE public.empleado TO "camposn_Informes";

			GRANT SELECT ON TABLE public.persona TO "camposn_Informes";

			GRANT SELECT ON TABLE public.trabajan TO "camposn_Informes";

			GRANT SELECT ON TABLE public.turno TO "camposn_Informes";

			GRANT SELECT ON TABLE public.estudio TO "camposn_Informes";

			GRANT SELECT ON TABLE public.consulta TO "camposn_Informes";

			GRANT SELECT ON TABLE public.diagnostico TO "camposn_Informes";



	Admisión
	
		CREATE ROLE camposn_admision WITH
		NOLOGIN
		NOSUPERUSER
		NOCREATEDB
		NOCREATEROLE
		INHERIT
		NOREPLICATION
		CONNECTION LIMIT -1;
		
		
		a) Agregar, modificar o eliminar un paciente.
		
			GRANT INSERT, UPDATE ON TABLE public.paciente TO camposn_admision;

			GRANT INSERT, UPDATE ON TABLE public.persona TO camposn_admision;
			
			GRANT DELETE ON TABLE public.paciente TO camposn_admision;


		b) Listar consultas, tratamientos, diagnósticos y estudios realizados de un determinado paciente.
		
			GRANT SELECT ON TABLE public.paciente TO camposn_admision;

			GRANT SELECT ON TABLE public.persona TO camposn_admision;

			GRANT SELECT ON TABLE public.consulta TO camposn_admision;

			GRANT SELECT ON TABLE public.tratamiento TO camposn_admision;

			GRANT SELECT ON TABLE public.diagnostico TO camposn_admision;


		c) Agregar consultas.
		
			GRANT INSERT ON TABLE public.consulta TO camposn_admision;
			
			
		d) Agregar estudios realizados.
			
			GRANT INSERT ON TABLE public.estudio_realizado TO camposn_admision;

		
		e) Listar, agregar, modificar internaciones
		
			GRANT INSERT, SELECT, UPDATE ON TABLE public.internacion TO camposn_admision;  
			
			
	RRHH
	
		CREATE ROLE camposn_rrhh WITH
		NOLOGIN
		NOSUPERUSER
		NOCREATEDB
		NOCREATEROLE
		INHERIT
		NOREPLICATION
		CONNECTION LIMIT -1;


		a) Agregar, modificar o eliminar empleados.
		
			GRANT INSERT, UPDATE ON TABLE public.empleado TO camposn_rrhh;

			GRANT INSERT, UPDATE ON TABLE public.persona TO camposn_rrhh;
			
			GRANT DELETE ON TABLE public.empleado TO camposn_rrhh;

			
		b) Modificar los datos de los empleados, especialidad, cargo, horarios que cumplen.		
			
			GRANT UPDATE ON TABLE public.empleado TO camposn_rrhh;

			GRANT UPDATE ON TABLE public.persona TO camposn_rrhh;

			GRANT UPDATE ON TABLE public.especialidad TO camposn_rrhh;

			GRANT UPDATE ON TABLE public.cargo TO camposn_rrhh;

			GRANT UPDATE ON TABLE public.trabajan TO camposn_rrhh;
			
	
	
	Médicos
		CREATE ROLE camposn_medicos WITH
		NOLOGIN
		NOSUPERUSER
		NOCREATEDB
		NOCREATEROLE
		INHERIT
		NOREPLICATION
		CONNECTION LIMIT -1;
		
		a) Agregar consultas.
		
			GRANT INSERT ON TABLE public.consulta TO camposn_medicos;
			
			
		b) Agregar, modificar o eliminar tratamientos.
		
			GRANT INSERT, UPDATE, DELETE ON TABLE public.tratamiento TO camposn_medicos;
			
			GRANT SELECT (id_empleado, id_especialidad, id_cargo) ON TABLE public.empleado TO camposn_medicos;
			
			GRANT SELECT ON TABLE public.paciente TO camposn_medicos;
			
			GRANT SELECT (id_persona, nombre, apellido) ON TABLE public.persona TO camposn_medicos
			
			
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
															
				La ultima sentencia nose si seria nesesaria, pues si solo se limita a cargar los tratamientos no le deveria 
				importar a quien estan diriguidos ni quienes los imparten (osea datos espesificos mas alla de los id, 
				como ser el nombre, apellido...) 
				
				
				Forma correcta de trabajarla

			
		c) Agregar, modificar o eliminar diagnósticos.
			
			GRANT INSERT, UPDATE, DELETE ON TABLE public.diagnostico TO camposn_medicos;
			
			
		d) Agregar, modificar o eliminar estudios realizados.
		
			GRANT INSERT, UPDATE, DELETE ON TABLE public.estudio_realizado TO camposn_medicos;
		
		e) Puede realizar todas las consultas que se realizan en Informes.
		
			Seria agregar al usuario medico al grupo de informes
			
		
		f) Puede realizar las mismas tareas que Admisión.

			Seria agregar al usuario medico al grupo de Admisión.
			
	
	
	Compras
		
		CREATE ROLE camposn_compras WITH
		NOLOGIN
		NOSUPERUSER
		NOCREATEDB
		NOCREATEROLE
		INHERIT
		NOREPLICATION
		CONNECTION LIMIT -1;
		
		
		a) Listar compras, mostrando proveedores, clasificación y laboratorio de cada insumo adquirido.
		
			GRANT SELECT ON TABLE public.compra TO camposn_compras;

			GRANT SELECT ON TABLE public.proveedor TO camposn_compras;

			GRANT SELECT ON TABLE public.medicamento TO camposn_compras;

			GRANT SELECT ON TABLE public.clasificacion TO camposn_compras;

			GRANT SELECT ON TABLE public.laboratorio TO camposn_compras;



		b) Agregar laboratorios, clasificaciones, proveedores y medicamentos.
		
			GRANT INSERT ON TABLE public.laboratorio TO camposn_compras;

			GRANT INSERT ON TABLE public.clasificacion TO camposn_compras;

			GRANT INSERT ON TABLE public.proveedor TO camposn_compras;

			GRANT INSERT ON TABLE public.medicamento TO camposn_compras;


		c) Modificar laboratorios, clasificaciones, proveedores y medicamentos.
		
			GRANT UPDATE ON TABLE public.laboratorio TO camposn_compras;

			GRANT UPDATE ON TABLE public.proveedor TO camposn_compras;

			GRANT UPDATE ON TABLE public.clasificacion TO camposn_compras;

			GRANT UPDATE ON TABLE public.medicamento TO camposn_compras;


			
		d) Eliminar laboratorios, clasificaciones, proveedores y medicamentos.
		
			GRANT DELETE ON TABLE public.clasificacion TO camposn_compras;

			GRANT DELETE ON TABLE public.laboratorio TO camposn_compras;

			GRANT DELETE ON TABLE public.proveedor TO camposn_compras;

			GRANT DELETE ON TABLE public.medicamento TO camposn_compras;



	Facturación
	
		CREATE ROLE camposn_facturacion WITH
		NOLOGIN
		NOSUPERUSER
		NOCREATEDB
		NOCREATEROLE
		INHERIT
		NOREPLICATION
		CONNECTION LIMIT -1;
	
		a) Listar las facturas, mostrando los pacientes.
			
			GRANT SELECT ON TABLE public.factura TO camposn_facturacion;

			GRANT SELECT ON TABLE public.paciente TO camposn_facturacion;

			GRANT SELECT ON TABLE public.persona TO camposn_facturacion;


		
		b) Agregar, modificar y eliminar facturas.
		
			GRANT INSERT, UPDATE, DELETE ON TABLE public.factura TO camposn_facturacion;

			
		c) Listar los pagos, mostrando el paciente.
			
			GRANT SELECT ON TABLE public.pago TO camposn_facturacion;

			GRANT SELECT ON TABLE public.paciente TO camposn_facturacion;

			GRANT SELECT ON TABLE public.persona TO camposn_facturacion;

			GRANT SELECT ON TABLE public.factura TO camposn_facturacion;


		
		d) Agregar modificar y eliminar pagos.
			
			GRANT INSERT, UPDATE, DELETE ON TABLE public.pago TO camposn_facturacion;
			
			
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
											
														existiria alguna diferencia entre decir:
														Agregar modificar y eliminar pagos.
														  y
														Agregar modificar o eliminar pagos.
														
														No hay diferencia hace referencia a que tenga permiso de hacer las 3 operaciones y ya



	Mantenimiento
		
		CREATE ROLE camposn_mantenimiento WITH
		NOLOGIN
		NOSUPERUSER
		NOCREATEDB
		NOCREATEROLE
		INHERIT
		NOREPLICATION
		CONNECTION LIMIT -1;
	
	
		a) Listar los equipos y el estado de los mismos.
		
			GRANT SELECT ON TABLE public.equipo TO camposn_mantenimiento;

			GRANT SELECT ON TABLE public.mantenimiento_equipo TO camposn_mantenimiento;
			
			
			
													
			
		b) Listar las camas y el estado de las mismas.
		
			GRANT SELECT ON TABLE public.cama TO camposn_mantenimiento;

			GRANT SELECT ON TABLE public.mantenimiento_cama TO camposn_mantenimiento;
		
			
													
		
		c) Agregar nuevos equipos.
		
			GRANT INSERT ON TABLE public.equipo TO camposn_mantenimiento;
			
		
		d) Agregar nuevas camas.
			
			GRANT INSERT ON TABLE public.cama TO camposn_mantenimiento;
			




	Sistemas
				
		CREATE ROLE camposn_sistemas WITH
		NOLOGIN
		NOSUPERUSER
		NOCREATEDB
		NOCREATEROLE
		INHERIT
		NOREPLICATION
		CONNECTION LIMIT -1;						
				
	
		a) Agregar, modificar o eliminar estudios.
		
			GRANT INSERT, UPDATE, DELETE ON TABLE public.estudio TO camposn_sistemas;

		
		b) Agregar, modificar o eliminar cargos.
		
			GRANT INSERT, UPDATE, DELETE ON TABLE public.cargo TO camposn_sistemas;
			
			
		c) Agregar, modificar o eliminar especialidades.
		
			GRANT INSERT, UPDATE, DELETE ON TABLE public.especialidad TO camposn_sistemas;
			
		
		d) Agregar, modificar o eliminar tipos de estudios.
		
			GRANT INSERT, UPDATE, DELETE ON TABLE public.tipo_estudio TO camposn_sistemas;
			
		
		e) Agregar, modificar o eliminar consultorios.
		
			GRANT INSERT, UPDATE, DELETE ON TABLE public.consultorio TO camposn_sistemas;
		
		
		f) Agregar, modificar o eliminar obras sociales.
		
			GRANT INSERT, UPDATE, DELETE ON TABLE public.obra_social TO camposn_sistemas;
		
		
		g) Agregar, modificar o eliminar turnos.
		
			GRANT INSERT, UPDATE, DELETE ON TABLE public.turno TO camposn_sistemas;
			
		
		h) Listar todas las tablas antes mencionadas.

			GRANT SELECT ON TABLE public.estudio TO camposn_sistemas;

			GRANT SELECT ON TABLE public.tipo_estudio TO camposn_sistemas;

			GRANT SELECT ON TABLE public.cargo TO camposn_sistemas;

			GRANT SELECT ON TABLE public.especialidad TO camposn_sistemas;

			GRANT SELECT ON TABLE public.consultorio TO camposn_sistemas;

			GRANT SELECT ON TABLE public.obra_social TO camposn_sistemas;

			GRANT SELECT ON TABLE public.turno TO camposn_sistemas;


		
	Ejercicio nro. 3: 	Con su usuario realice las siguientes consultas.
	
		a) Muestre el nombre, apellido y la obra social de todos los pacientes.
			
			SELECT pe.nombre as Nombre, pe.apellido as Apellido, os.nombre as NombreObraSocial FROM paciente
			INNER JOIN obra_social os USING(id_obra_social)
			INNER JOIN persona pe ON id_persona = id_paciente
				
				
		b) Liste el nombre, apellido, cargo, especialidad y sueldo de todos los empleados.
		
			SELECT pe.nombre AS Nombre, pe.apellido AS Apellido, cargo, especialidad, sueldo FROM empleado
			INNER JOIN persona pe ON id_empleado = id_persona
			INNER JOIN cargo USING(id_cargo)
			INNER JOIN especialidad USING(id_especialidad)


		c) Muestre el nombre, apellido, fecha de internación de todos los pacientes que hayan sido dados de alta
		entre 01/01/2019 y 31/12/2021.
			
			SELECT nombre, apellido, fecha_inicio FROM paciente
			INNER JOIN persona ON id_paciente = id_persona
			INNER JOIN internacion USING(id_paciente)
			WHERE fecha_alta BETWEEN '2019-01-01' and '2021-12-13'


		d) Liste el apellido y nombre de los pacientes, número, fecha y monto de las facturas que fueron pagas en
		su totalidad.
		
			SELECT apellido, nombre, id_factura, monto, fecha FROM paciente
			INNER JOIN persona ON id_paciente = id_persona
			INNER JOIN factura USING(id_paciente)
			WHERE pagada LIKE '%S%'
			
			
		e) Muestre el nombre, apellido de todos los empleados que diagnosticaron “Asma”, también muestre la
		fecha de diagnóstico.
		
			SELECT nombre, apellido, diag.fecha AS FechaDiagnostico FROM empleado
			INNER JOIN persona ON id_empleado = id_persona
			INNER JOIN consulta USING(id_empleado)
			INNER JOIN diagnostico diag USING(id_empleado)	
			WHERE descripcion like '%ASMA'
			
		
		
		
	Ejercicio nro. 4: Con el usuario indicado realice las siguientes consultas (realice el código SQL e 
					  indique con cual usuario la pudo realizar).	
					  
		Creacion del Usuario de informes:
					
			CREATE ROLE camposn_usuarioinformes WITH
				LOGIN
				NOSUPERUSER
				NOCREATEDB
				NOCREATEROLE
				INHERIT
				NOREPLICATION
				CONNECTION LIMIT -1
				PASSWORD 'xxxxxx';   /* informe*/
			GRANT "camposn_Informes" TO camposn_usuarioinformes WITH ADMIN OPTION;
			
			
		Creacion del Usuario de admision:
				
			CREATE ROLE camposn_usuarioadmicion WITH
				LOGIN
				NOSUPERUSER
				NOCREATEDB
				NOCREATEROLE
				INHERIT
				NOREPLICATION
				CONNECTION LIMIT -1
				PASSWORD 'xxxxxx'; /*admicion*/
			GRANT camposn_admision TO camposn_usuarioadmicion WITH ADMIN OPTION;
		
		
		Creacion del Usuario de RRHH:
		
			CREATE ROLE camposn_usuariorrhh WITH
				LOGIN
				NOSUPERUSER
				NOCREATEDB
				NOCREATEROLE
				INHERIT
				NOREPLICATION
				CONNECTION LIMIT -1
				PASSWORD 'xxxxxx';  /*rrhh*/
			GRANT camposn_rrhh TO camposn_usuariorrhh WITH ADMIN OPTION;
		
		
		Creacion del usuario Medico:
		
			CREATE ROLE camposn_usuariomedico WITH
				LOGIN
				NOSUPERUSER
				NOCREATEDB
				NOCREATEROLE
				INHERIT
				NOREPLICATION
				CONNECTION LIMIT -1
				PASSWORD 'xxxxxx';  /* medico */
			GRANT "camposn_Informes", camposn_admision, camposn_medicos TO camposn_usuariomedico WITH ADMIN OPTION;
			
			
			
		Creacion del usuario compras: 
		
			CREATE ROLE camposn_usuariocompras WITH
				LOGIN
				NOSUPERUSER
				NOCREATEDB
				NOCREATEROLE
				INHERIT
				NOREPLICATION
				CONNECTION LIMIT -1
				PASSWORD 'xxxxxx'; /* compra */

			GRANT camposn_compras TO camposn_usuariocompras;
			
		
		creacion del usuario de facturacion:
		
			CREATE ROLE camposn_usuariofacturacion WITH
				LOGIN
				NOSUPERUSER
				NOCREATEDB
				NOCREATEROLE
				INHERIT
				NOREPLICATION
				CONNECTION LIMIT -1
				PASSWORD 'xxxxxx'; /* facturacion */

			GRANT camposn_facturacion TO camposn_usuariofacturacion;


		Creacion del usuario Mantenimiento:
		
			CREATE ROLE camposn_usuariomantenimiento WITH
				LOGIN
				NOSUPERUSER
				NOCREATEDB
				NOCREATEROLE
				INHERIT
				NOREPLICATION
				CONNECTION LIMIT -1
				PASSWORD 'xxxxxx';
			GRANT camposn_mantenimiento TO camposn_usuariomantenimiento WITH ADMIN OPTION;
			
			
			
		Creacion del usuario Sistemas:
		
			CREATE ROLE camposn_usuariosistema WITH
				LOGIN
				NOSUPERUSER
				NOCREATEDB
				NOCREATEROLE
				INHERIT
				NOREPLICATION
				CONNECTION LIMIT -1
				PASSWORD 'xxxxxx';
			GRANT camposn_sistemas TO camposn_usuariosistema WITH ADMIN OPTION;
			
			
			
			
			
	Ejercicio nro. 4: Con el usuario indicado realice las siguientes consultas (realice el código SQL e indique
					  con cual usuario la pudo realizar).
					  
		a) Mostrar todas las consultas realizadas después del ’01-01-2021’.
		
			SELECT * FROM consulta
			WHERE fecha > '2021-01-01'
			
			La puede Realizar los usuarios que esten en los grupos de Informes, Admicion y Medicos.
		
		
		b) Mostrar los tratamientos cuyo número de dosis sea mayor que 2. Debe mostrar el nombre del paciente al
		quien le prescribieron el tratamiento.
		
			SELECT pe.nombre, pe.apellido, trat.nombre FROM tratamiento trat 
			INNER JOIN paciente USING(id_paciente)
			INNER JOIN persona pe ON id_paciente = id_persona
			WHERE dosis > '2'
			
			La puede realizar los usuarios que esten en los grupos de Informes, Admicion y Medico
		
		
		
		c) Muestre todas las facturas emitidas después del ’30-06-2021’
		.
			SELECT * FROM factura 
			WHERE fecha > '2021-06-30'
			
			La puede realizar los usuarios que esten en los grupos de Facturacion
			
			
		d) Mostrar todas las facturas que han sido pagadas parcialmente.
			
			SELECT * FROM factura 
			WHERE saldo > '0'
			
			La puede realizar los usuarios que esten en los grupos de Facturacion
			
			
		
		e) Listar los medicamentos que fueron recetados posterior a ’02-05-2020’, mostrando a que laboratorio y
		clasificación pertenecen.
			
			SELECT med.nombre, clasificacion, laboratorio FROM medicamento med
			INNER JOIN tratamiento USING(id_medicamento)
			INNER JOIN clasificacion USING(id_clasificacion)
			INNER JOIN laboratorio USING(id_laboratorio)
			WHERE fecha_indicacion > '2020-05-02'
			
			La puede realizar los usuarios que esten en los grupos de /* Modificar el grupo de informes */
			
		
		f) Mostrar la historia clínica del paciente ‘CARLOS ALBERTO MARINARO‘ (todas las consultas, tratamientos,
		estudios, internaciones, ordenados por fecha).
			
			SELECT pe.nombre, pe.apellido, resultado AS ResultadoConsulta, tra.prescribe, tra.nombre, tra.descripcion, tra.dosis 
			tra.costo, resEs.resultado AS ResultadoEstudio, inter.orden_internacion, inter.fecha_inicio, inter.fecha_alta, 
			inter.hora, inter.costo FROM paciente
			INNER JOIN persona pe pe ON id_paciente = id_persona
			INNER JOIN tratamiento tra USING(id_paciente)
			INNER JOIN consulta USING(id_paciente)
			INNER JOIN estudio_realizado resEs USING(id_paciente)
			INNER JOIN estudio USING(id_estudio)
			INNER JOIN internacion inter USING(id_paciente)
			WHERE pe.nombre LIKE '%CARLOS ALBERTO%' AND pe.apellido LIKE '%MARINARO%'
			
			
		
		
		g) Mostrar todos los pagos realizados por ‘RODOLFO JULIO URTUBEY’.
		
			SELECT * FROM factura 
			INNER JOIN pago USING(id_factura)
			INNER JOIN paciente USING(id_paciente)
			INNER JOIN persona pe ON id_paciente = id_persona
			WHERE pe.nombre LIKE '%RODOLFO JULIO%' AND pe.apellido LIKE '%URTUBEY%'
		
		
		h) Mostrar todas las consultas que atendió el medico ‘LAURA LEONOR ESTRADA’.
		
			SELECT * FROM consulta 
			INNER JOIN empleado USING(id_empleado)
			INNER JOIN persona pe ON id_empleado = id_persona
			WHERE pe.nombre LIKE '%LAURA LEONOR%' AND pe.apellido LIKE '%ESTRADA%'
		
		
		i) Listar todas las camas que están fuera de servicio.
		
			SELECT * FROM cama
			WHERE estado LIKE '%FUERA DE SERVICIO%'
		
		
		j) Listar todos los equipos que están en mantenimiento.
			
			SELECT * FROM mantenimiento_equipo
		
		
		k) Muestre todas las compras realizadas en el 2020 indicando el medicamento, el proveedor y el empleado
		que realizo la compra.
			
			SELECT * FROM compra
			INNER JOIN medicamento USING(id_medicamento)
			INNER JOIN proveedor USING(id_proveedor)
			INNER JOIN empleado USING(id_empleado)
			INNER JOIN persona pe ON id_empleado = id_persona
			WHERE fecha BETWEEN ('2020-01-01' AND '2020-12-30')
		
		l) Agregar el registro en la tabla compras (1824, 23, ’10-11-2022’, 634, 1443.42, 75).
		
			INSERT INTO compra
			(id_medicamento, id_proveedor, fecha, id_empleado, precio_unitario, cantidad)
			VALUES (1824, 23, '2022-11-10', 634, 1443.42, 75)
			
			ERROR:  llave duplicada viola restricción de unicidad «PK7»
			DETAIL:  Ya existe la llave (id_medicamento, id_proveedor, fecha)=(1824, 23, 2022-11-10).
			SQL state: 23505
		
		m) Agregar el registro en la tabla proveedores (33, "DISTRI MED S.A.”, “AV. COLON 1291", "2411617").
			
			INSERT INTO proveedor
			(id_proveedor, proveedor, direccion, telefono)
			VALUES (33, 'DISTRI MED S.A.', 'AV. COLON 1291', '2411617')
		
		
		n) Agregar el registro en la tabla laboratorios (206, "INDUSTFARM”, “MIGUEL LINCE 124 ", "2416411").
		
			INSERT INTO laboratorio 
			(id_laboratorio, laboratorio, direccion, telefono)
			VALUES (206, 'INDUSTFARM', 'MIGUEL LINCE 124', '2416411')
		
		
		
		o) Modificar el teléfono del proveedor "DISTRI MED S.A.”, por el 22244433.
		
			UPDATE proveedor
			SET telefono = '22244433'
			WHERE proveedor LIKE '%DISTRI MED S.A.%'
		
		
		p) Modificar el horario de trabajo de ‘FABIOLA MELISA PACHECO’ del sábado a la mañana al sábado a la
		noche.
		
			UPDATE turno
			INNER JOIN trabajan USING(id_turno)
			INNER JOIN empleado USING(id_empleado)
			INNER JOIN persona pe ON id_persona = id_empleado
			SET turno = 'Noche'
			WHERE pe.nombre LIKE '%FABIOLA MELISA%' AND pe.apellido LIKE '%PACHECO%'
		

		q) Eliminar el laboratorio “BAYER QUIMICAS UNIDAS S.A.”.
			
			DELETE FROM laboratorio
			WHERE laboratorio LIKE '%BAYER QUIMICAS UNIDAS S.A.%'
			
			ERROR:  el valor null para la columna «id_laboratorio» viola la restricción not null
			DETAIL:  La fila que falla contiene (147, 41, null, ASPIRINA TABLETAS, CAJA X 200 TABLETAS, 1911.65, 100).
			CONTEXT:  sentencia SQL: «UPDATE ONLY "public"."medicamento" SET "id_laboratorio" = DEFAULT WHERE $1 OPERATOR(pg_catalog.=) "id_laboratorio"»
			SQL state: 23502
*/	
				
				
				/*
				
				b) Agregar, modificar o eliminar tratamientos.
		
					GRANT INSERT, UPDATE, DELETE ON TABLE public.tratamiento TO camposn_medicos;

					GRANT SELECT (id_empleado, id_especialidad, id_cargo) ON TABLE public.empleado TO camposn_medicos;

					GRANT SELECT ON TABLE public.paciente TO camposn_medicos;

					GRANT SELECT (id_persona, nombre, apellido) ON TABLE public.persona TO camposn_medicos
					
					
					FORMA CORRECTA
				
				
				Para conectarme con alguno de los usuarios creados ir a la parte superior de donde dice quiery editor, y poner
				en la opcion de new conection.
				*/
				
	

