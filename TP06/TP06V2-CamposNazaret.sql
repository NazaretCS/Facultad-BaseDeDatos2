
		/*
			EJEMPLO DEL PROFE EN CLASE
			**************************

			CREATE OR REPLACE PROCEDURE internacion_alta(IN p_dni_paciente character varying(8),
														 IN p_id_cama smallint,
														 IN p_fecha_inicio date,
														 IN p_dni_medico character varying(8),
														 IN p_fecha_alta date,
														 IN p_hora time without time zone,
														 IN p_costo numeric(10,2))
			AS $$
			DECLARE
				v_existe_paciente boolean;
			BEGIN
				SELECT EXISTS(SELECT * FROM persona pe 
							  INNER JOIN paciente pa ON pe.id_persona = pa.id_paciente
							  WHERE dni = p_dni_paciente) INTO v_existe_paciente;

				IF NOT v_existe_paciente THEN
					RAISE EXCEPTION 'NO existe el paciente';
				END IF;

				INSERT INTO internacion VALUES(subconsulta, p_id_cama, p_fecha_inicio,
											subconsulta, p_fecha_alta, p_hora, p_costo);
				RAISE NOTICE 'Se insertó bien';
				EXCEPTION
					WHEN OTHERS THEN
					RAISE EXCEPTION 'No se pudo hacer el insert %', SQLERRM;
			END;
			$$ LANGUAGE plpgsql;


			CREATE OR REPLACE PROCEDURE spCuentaPersona(OUT cantidad INT) AS $$
			BEGIN
				SELECT COUNT(*) INTO cantidad FROM persona;
			END;
			$$ LANGUAGE plpgsql;

			CALL spCuentaPersona(NULL);




			EJERCICIO 1:
				Para mejorar y automatizar el funcionamiento de la base de datos “Hospital” realice las siguientes tareas:

				a) Escriba un procedimiento almacenado (SP) para agregar registros a la tabla persona. Reciba
				todos los parámetros necesarios excepto el id (max + 1) que se deberá obtener dentro del SP.
				Muestre un mensaje de error si no se pudo realizar. Nombre sugerido: persona_alta.


					CREATE OR REPLACE PROCEDURE persona_alta (IN p_id_persona INT,
															  IN p_nombre CHARACTER VARYING(100),
															  IN p_apellido CHARACTER VARYING(100),
															  IN p_dni CHARACTER VARYING(8),
															  IN p_fecha_nacimiento DATE,
															  IN p_domicilio CHARACTER VARYING(100),
															  IN p_telefono CHARACTER VARYING(15)) 
					AS $$
						DECLARE
							v_existe_dni INT;
							v_id_persona INT;
						BEGIN

							IF p_dni IS NULL THEN
								RAISE EXCEPTION 'El DNI de la persona no puede ser nulo';
							END IF;

							SELECT dni INTO v_existe_dni FROM persona
							WHERE dni = p_dni;

							IF v_existe_dni IS NOT NULL THEN
								RAISE EXCEPTION 'ya existe la persona con DNI: %',p_dni;
							END IF;

							IF p_nombre IS NULL THEN
								RAISE EXCEPTION 'El nombre de la persona no puede ser nulo';
							END IF;
							IF p_apellido IS NULL THEN
								RAISE EXCEPTION 'El apellido de la persona no puede ser nulo';
							END IF;

							INSERT INTO persona (id_persona, nombre, apellido, dni, fecha_nacimiento, domicilio, telefono)
							VALUES ((SELECT MAX(id_persona) FROM persona)+1, p_nombre, p_apellido, p_dni, p_fecha_nacimiento,
									 p_domicilio, p_telefono)					 
							 RETURNING id_persona INTO v_id_persona; --Devuelve el id_persona de la operacion anterior

							 IF v_id_persona IS NOT NULL THEN
								RAISE NOTICE 'La persona se inserto correctamente';
							 ELSE 
								RAISE EXCEPTION 'La persona no se pudo insertar en la base de datos';
							 END IF;						

						END;
					$$ LANGUAGE plpgsql;

					CALL persona_alta('43709133', 'Nestor Nazaret', 'Campos', '43709133', NULL, NULL, NULL)

					select * from persona where dni = '43709133';


					b) Escriba un SP para agregar registros en la tabla empleado, pase todos los campos por
					parámetro, respecto a los campos que son FK pase el DNI de la persona, el nombre de la
					especialidad y el nombre del cargo. Verifique que dichos datos existan para poder hacer el alta.
					Nombre sugerido: empleado_alta.

							CREATE OR REPLACE PROCEDURE empleado_alta(p_dni CHARACTER VARYING,
																	  p_especialidad CHARACTER VARYING,
																	  p_cargo CHARACTER VARYING,
																	  p_fecha_ingreso DATE,
																	  p_sueldo NUMERIC(9,2),
																	  p_fecha_baja DATE)
							AS $$
								DECLARE
									v_id_empleado INT;
									v_id_especialidad INT;
									v_id_cargo INT;
									v_id_empleadoRet INT;

								BEGIN
									SELECT id_persona INTO v_id_empleado FROM persona 
									WHERE dni = p_dni;

									IF v_id_empleado IS NULL THEN
										RAISE EXCEPTION 'No existe la persona con DNI: %... %', p_dni,SQLERRM;
									END IF;

									SELECT id_especialidad INTO v_id_especialidad FROM especialidad 
									WHERE especialidad = p_especialidad;

									IF v_id_especialidad IS NULL THEN
										RAISE EXCEPTION 'No existe la especcialidad espesificada en la base de datos. ';
									END IF;

									SELECT id_cargo INTO v_id_cargo FROM cargo
									WHERE cargo = p_cargo;

									IF v_id_cargo IS NULL THEN
										RAISE EXCEPTION 'No existe el cargo espesificado.';
									END IF;

									INSERT INTO empleado (id_empleado, id_especialidad, id_cargo, fecha_ingreso, sueldo, fecha_baja)
									VALUES(v_id_empleado, v_id_especialidad, v_id_cargo, p_fecha_ingreso, p_sueldo, p_fecha_baja)
									RETURNING id_empleado INTO v_id_empleadoRet;

									IF v_id_empleadoRet IS NOT NULL THEN
										RAISE NOTICE 'La insercion del empleado se realizo de manera correcta';
									ELSE
										RAISE EXCEPTION 'El empleado no se pudo insertar';
									END IF; 

									EXCEPTION
										WHEN OTHERS THEN
										RAISE EXCEPTION 'El empleado no se pudo insertar... %', SQLERRM;

								END;
							$$ LANGUAGE plpgsql;

							select * from cargo
							--1 = Director
							select * from especialidad		
							--37 Nutricion

							CALL empleado_alta('43709133',  'CLINICA', 'DIRECTOR', NULL, NULL, NULL);

							select * from empleado
							inner join persona on id_persona = id_empleado
							inner join cargo USING(id_cargo)
							inner join especialidad using(id_especialidad)
							where dni = '43709133'



					c) Realice un SP que permita modificar el saldo de una factura. Debe recibir como parámetro el
					id de la factura y el monto que se pagó que deberá ser descontado del saldo. Verifique que el
					número de factura exista (de momento no es necesario ningún otro control). Nombre suerido:
					factura_modifica_saldo.

						CREATE OR REPLACE PROCEDURE factura_modifica_saldo(
																			IN p_id_factura INT,
																			IN p_monto NUMERIC
																		   )
						AS $$ 
							DECLARE
								v_id_factura INT;
							BEGIN

								SELECT id_factura INTO v_id_factura FROM factura
								WHERE id_factura = p_id_factura;
								IF v_id_factura IS NULL THEN
									RAISE EXCEPTION 'No existe la factura con id: %', p_id_factura;
								END IF;

								UPDATE factura 
								SET saldo = (saldo - p_monto)
								WHERE id_factura = p_id_factura;

								RAISE NOTICE 'Saldo de la factura id % modificado correctamente.', p_id_factura;

								EXCEPTION
									WHEN OTHERS THEN
									RAISE EXCEPTION 'No se pudo hacer la actualizacion del saldo... %', SQLERRM;	
							END;
						$$ LANGUAGE plpgsql

						select * from factura
						where id_factura = 939590
						-- saldo = 132.00

						CALL factura_modifica_saldo(939590, 130.00)

						--Nuevo saldo: $2.00

					d) Escriba un SP para modificar el precio de la tabla medicamento. La función debe recibir por
					parámetro, el nombre de un laboratorio y el porcentaje de aumento. Verifique que el
					laboratorio exista y modifique todos los medicamentos de ese laboratorio. Nombre sugerido:
					medicamento_modifica_por_laboratorio

					 El UPDATE afectará a todas las filas cuyo id_laboratorio sea igual a v_id_labo. En una consulta de 
					 actualización, si no se especifica ninguna cláusula LIMIT o WHERE adicional, la actualización se aplicará 
					 a todas las filas que cumplan con la condición especificada en la cláusula WHERE.

					 La construcción IF FOUND THEN ... ELSE ... END IF se utiliza comúnmente después de una consulta en PostgreSQL
					  para verificar si se encontraron filas en el resultado de la consulta. Puede ser utilizado no solo en 
					  actualizaciones (UPDATE), sino también en otras consultas como inserciones (INSERT), eliminaciones (DELETE) 
					  y consultas de selección (SELECT).

					En general, FOUND es una variable booleana especial en PostgreSQL que indica si la última operación de consulta 
					encontró al menos una fila en el resultado. La variable FOUND es TRUE si se encontraron filas y FALSE si no se 
					encontraron.


							CREATE OR REPLACE PROCEDURE medicamento_modifica_por_laboratorio(
																							p_nombre_labo CHARACTER VARYING,
																							p_aumento numeric(4,2)--Puede aumentar hasta un 99.99 nomas
																							)
							AS $$
								DECLARE
								v_id_labo INT;

								BEGIN
									SELECT id_laboratorio INTO v_id_labo FROM laboratorio
									WHERE laboratorio = p_nombre_labo;
									IF v_id_labo IS NULL THEN 
										RAISE EXCEPTION 'No se encontro ningun laboratorio de nombre: %', p_nombre_labo;
									END IF;

									IF p_aumento IS NULL OR p_aumento < 0 THEN
										RAISE EXCEPTION 'Por favor ingresar un porcentaje de aumento positivo';
									END IF;

									UPDATE medicamento 
									SET precio = (precio * p_aumento ) / 100
									WHERE id_laboratorio = v_id_labo;

									IF FOUND THEN
										RAISE NOTICE 'Las actualizaciones se realizacon con exito';
									ELSE
										RAISE NOTICE 'Las actualizaciones fallaron. %', SQLERRM;
									END IF;

									EXCEPTION
										WHEN OTHERS THEN
										RAISE EXCEPTION 'Las actualizaciones fallaron... %', SQLERRM;
								END;
							$$ LANGUAGE plpgsql;

							SELECT * from medicamento
							inner join laboratorio using(id_laboratorio)
							where id_laboratorio = 205
							order by(precio)
							limit 10

							nombre: "LABOSINRATO" id: 205

							CALL medicamento_modifica_por_laboratorio('LABOSINRATO', 100.00)



					e) Realice un SP para eliminar un medicamento según su nombre. Recuerde que puede estar
					referenciado en otras tablas por lo que deberá hacer los delete necesarios para poder eliminar
					el medicamento. Nombre sugerido: medicamento_eliminar

						CREATE OR REPLACE PROCEDURE medicamento_eliminar(
																		p_medicamento CHARACTER VARYING
																		)
						AS $$
						DECLARE
							v_id_medicamento INT;

						BEGIN
							SELECT id_medicamento INTO v_id_medicamento FROM medicamento
							WHERE nombre = p_medicamento;
							IF v_id_medicamento IS NULL THEN 
								RAISE EXCEPTION 'No existe el medicamento de nombre %', p_medicamento;
							END IF;

							DELETE FROM tratamiento 
							WHERE id_medicamento = v_id_medicamento;

							DELETE FROM compra 
							WHERE id_medicamento = v_id_medicamento;

							DELETE FROM medicamento 
							WHERE id_medicamento = v_id_medicamento;

							IF FOUND THEN
								RAISE NOTICE 'Eliminacion del medicamento: % exitosa', p_medicamento;
							ELSE 
								RAISE EXCEPTION 'Fallo en la eliminacion del medicamento.';
							END IF;

							EXCEPTION
								WHEN OTHERS THEN
								RAISE EXCEPTION 'Fallo en la eliminacion del medicamento %', SQLERRM;
						END;
						$$ LANGUAGE plpgsql;

						SELECT * from medicamento
						"DORIXINA"
						CALL medicamento_eliminar('DORIXINA')
						CALL medicamento_eliminar('DORIsXINA')
						CALL medicamento_eliminar('')

			EJERCICIO 2:
				Realice los siguientes procedimientos almacenados para que muestren la información solicitada.

				a) Un SP que muestre el nombre y apellido de un paciente según un DNI ingresado. Nombre
				sugerido: paciente_obtener.


						CREATE OR REPLACE PROCEDURE paciente_obtener2( p_dni_paciente CHARACTER VARYING,
																	 OUT p_nombre CHARACTER VARYING,
																	 OUT p_apellido CHARACTER VARYING)
						AS $$
						DECLARE
							v_fila_persona persona%ROWTYPE;
						BEGIN
							SELECT * INTO v_fila_persona FROM persona 
							INNER JOIN paciente ON id_persona = id_paciente
							WHERE dni = p_dni_paciente;
							IF v_fila_persona IS NULL THEN
								RAISE EXCEPTION 'No existe el paciente con DNI: %', p_dni_paciente;
							END IF;
							RAISE NOTICE 'INFORMACION DE PACIENTE: ';
							RAISE NOTICE 'DNI: %, NOMBRE: %, APELLIDO: %', v_fila_persona.dni, v_fila_persona.nombre, v_fila_persona.apellido;

							p_nombre := v_fila_persona.nombre;
							p_apellido := v_fila_persona.apellido;
							EXCEPTION
								WHEN OTHERS THEN
								RAISE EXCEPTION 'ERROR INESPERADO. %', SQLERRM;
						END;
						$$ LANGUAGE plpgsql

						CALL paciente_obtener2('36839130', NULL, NULL)
						select * from empleado inner join persona on id_persona = id_empleado


				 b) Un SP que muestre el precio y stock de un medicamente. Debe recibir como parámetro el
				nombre del medicamento. Nombre sugerido: medicamento_precio_stock

						CREATE OR REPLACE PROCEDURE medicamento_precio_stock(
																			p_nombre CHARACTER VARYING,
																			OUT p_precio NUMERIC,
																			OUT p_stock INT
																			)
						AS $$ 
							DECLARE
								v_id_medicamento INT;

							BEGIN
								SELECT id_medicamento INTO v_id_medicamento FROM medicamento 
								WHERE nombre = p_nombre;
								IF v_id_medicamento IS NULL THEN
									RAISE EXCEPTION 'El medicamento % no se encuentra registrado en la base de datos.',p_nombre;
								END IF;

								SELECT precio, stock INTO p_precio, p_stock FROM medicamento 
								WHERE id_medicamento = v_id_medicamento;

								RAISE NOTICE 'INFORMACION DEL MEDICAMENTO %',  p_nombre;
								RAISE NOTICE 'PRECIO: %. STOCK: %',p_precio, p_stock;

							END;
						$$ LANGUAGE plpgsql;



				c) Escriba un SP que muestre el total adeudado (campo saldo de las facturas) por un paciente,
				según un número de DNI ingresado. Nombre sugerido: paciente_deuda	

						CREATE OR REPLACE PROCEDURE paciente_deuda( p_dni_paciente CHARACTER VARYING,
																 OUT p_deuda_total NUMERIC)
						AS $$ 
						DECLARE
							v_id_paciente INT;

						BEGIN
							SELECT id_paciente INTO v_id_paciente FROM paciente
							INNER JOIN persona ON id_persona = id_paciente
							WHERE dni =p_dni_paciente;
							IF v_id_paciente IS NULL THEN
								RAISE EXCEPTION 'El DNI % no corresponde a ninguna persona registrada', p_dni_paciente;
							END IF;

							SELECT SUM(saldo) INTO p_deuda_total FROM factura
							WHERE id_paciente = v_id_paciente;

							RAISE NOTICE 'PACIENTE ID: %', v_id_paciente;
							RAISE NOTICE 'Deuda Total: %', p_deuda_total;

							EXCEPTION
								WHEN OTHERS THEN
								RAISE EXCEPTION 'ERROR. %',SQLERRM;
						END;
						$$ LANGUAGE plpgsql;

						CALL paciente_deuda('62240506', NULL)

						SELECT saldo FROM factura
						WHERE id_paciente = 100787;

						select * from paciente
						INNER JOIN persona ON id_persona = id_paciente
						WHERE id_persona = 100787
						Deuda total: 563502.00	



				d) Realice un SP que muestre la cantidad de veces que una cama estuvo en mantenimiento, se
				debe mandar como parámetro el id de la cama. Nombre sugerido: cama_cantidad_mantenimiento


						CREATE OR REPLACE PROCEDURE cama_cantidad_mantenimiento(p_id_cama INT,
																			  OUT p_cant_mantenimientos smallint)
						AS $$
							DECLARE
								v_id_cama INT;

							BEGIN
								SELECT id_cama INTO v_id_cama FROM cama 
								WHERE id_cama = p_id_cama;
								IF v_id_cama IS NULL THEN   
									RAISE EXCEPTION 'El id: % no corresponde a ninguna cama registrada', p_id_cama;
								END IF;

								SELECT COUNT(id_cama) INTO p_cant_mantenimientos FROM mantenimiento_cama
								WHERE id_cama = v_id_cama;

								RAISE NOTICE 'Cantidad de veces que la cama estuvo en mantenimiento = %', p_cant_mantenimientos;

								EXCEPTION 
									WHEN OTHERS THEN
									RAISE EXCEPTION 'ERROR. %', SQLERRM;
							END;
						$$ LANGUAGE plpgsql;

						CALL cama_cantidad_mantenimiento(20, NULL)
						select * from mantenimiento_cama


			EJERCICIO 3:
				Realice los siguientes procedimientos almacenados utilizando cursores.

					a) Realice un SP donde se listen todas las obras sociales con toda su información. Nombre
					sugerido: obra_social_listado.		

					   CREATE OR REPLACE PROCEDURE obra_social_listado()
					   AS $$
							DECLARE
								cursor_obras_sociales CURSOR FOR select * from obra_social;
								filaObraSocial obra_social%ROWTYPE;

							BEGIN
								RAISE NOTICE 'INFORMACION SOBRE LAS OBRAS SOCIALES:';
								OPEN cursor_obras_sociales;
								LOOP
									FETCH cursor_obras_sociales INTO filaObraSocial;
									EXIT WHEN NOT FOUND;
									RAISE NOTICE 'ID: %.  Sigla: %.  Nombre: %.  Dirección: %.  Localidad: %.  Provincia: %.  Telefono: %.', 
												 filaObraSocial.id_obra_social, filaObraSocial.sigla, filaObraSocial.nombre, filaObraSocial.direccion, filaObraSocial.localidad, filaObraSocial.provincia, filaObraSocial.telefono;
								END LOOP;
								CLOSE cursor_obras_sociales;

							END;
					   $$ LANGUAGE plpgsql;

					   CALL obra_social_listado();



					b) Realice un SP donde se listen todas las camas cuyo estado sea “OK”. Nombre sugerido:
					cama_listado_ok

						CREATE OR REPLACE PROCEDURE cama_listado_ok()
						 AS $$
							DECLARE
								cursor_camas_ok CURSOR FOR SELECT * FROM cama
														   WHERE estado = 'OK';
								filaCamasOK cama%ROWTYPE;
							BEGIN
								RAISE NOTICE 'LISTADO DE CAMAS EN BUEN ESTADO';
								OPEN cursor_camas_ok;
								LOOP
									FETCH cursor_camas_ok INTO filaCamasOK;
									EXIT WHEN NOT FOUND;
									RAISE NOTICE 'ID: %.  Tipo: %.  Estado: %', filaCamasOK.id_cama, filaCamasOK.tipo, filaCamasOK.estado;
								END LOOP;
								CLOSE cursor_camas_ok;
							END;
						 $$ LANGUAGE plpgsql;

						CALL cama_listado_ok()


					c) Realice un SP que liste todos los medicamentos cuyo stock sea menor que 50. Nombre
				sugerido: medicamentos_poco_stock.

						CREATE OR REPLACE PROCEDURE medicamentos_poco_stock()
						AS $$
							DECLARE
								cursor_medicamentos CURSOR FOR SELECT * FROM medicamento
																WHERE stock <= 50;
								filaMedicamento medicamento%ROWTYPE;

								BEGIN
									RAISE NOTICE 'MEDICAMENTOS CON STOCK BAJO';
									OPEN cursor_medicamentos;
									LOOP
										FETCH cursor_medicamentos INTO filaMedicamento;
										EXIT WHEN NOT FOUND;
										RAISE NOTICE 'ID: %.  Nombre: %.  Presentacion: %.  Precio: %.  Stock: % ',
													filaMedicamento.id_medicamento, filaMedicamento.nombre, filaMedicamento.presentacion, filaMedicamento.precio, filaMedicamento.stock;
									END LOOP;
									CLOSE cursor_medicamentos;
								END;
						$$ LANGUAGE plpgsql;

						CALL medicamentos_poco_stock()
				
				d) Escriba un SP que muestre todas las consultas realizadas en determinada fecha (no haga
				JOINS). Debe recibir por parámetro la fecha. Nombre sugerido: consulta_listado_por_fecha.
	
					CREATE OR REPLACE PROCEDURE consulta_listado_por_fecha(p_fecha DATE)
					AS $$
						DECLARE
							cursor_consultas CURSOR FOR SELECT * FROM consulta
														WHERE fecha = p_fecha;
							filaConsultas consulta%ROWTYPE;

						BEGIN
							RAISE NOTICE 'CONSULTAS DEL DIA: %',p_fecha;
							OPEN cursor_consultas;
							LOOP
								FETCH cursor_consultas INTO filaConsultas;
								EXIT WHEN NOT FOUND;
								RAISE NOTICE 'ID Paciente: %.  ID Empleado: %.  Fecha: %.  Hora: %.  Resultado: %.', 
											  filaConsultas.id_paciente, filaConsultas.id_empleado, filaConsultas.fecha, filaConsultas.hora, filaConsultas.resultado ;
							END LOOP;
							CLOSE cursor_consultas;
						END;

					$$ LANGUAGE plpgsql;
					
					CALL consulta_listado_por_fecha('2019-01-01')
					SELECT COUNT(*) FROM consulta
					WHERE fecha ='2019-01-01'

				e) Realice un SP que muestre el nombre y apellido de un paciente, la fecha y nombre de los
				estudios que se realizó. Debe recibir como parámetro el DNI del paciente. Nombre sugerido:
				estudio_por_paciente.
				

					CREATE OR REPLACE PROCEDURE estudio_por_paciente(p_dni CHARACTER VARYING)
					AS $$
						DECLARE
							cursor_paciente_datos CURSOR FOR SELECT pe.nombre, pe.apellido, fecha,e.nombre  FROM paciente
															 INNER JOIN persona pe ON id_persona = id_paciente
															 INNER JOIN estudio_realizado USING(id_paciente)
															 INNER JOIN estudio e USING(id_estudio)
															 WHERE dni = p_dni;
							v_nombre CHARACTER VARYING;
							v_apellido CHARACTER VARYING;
							v_fecha DATE;
							v_nombre_estudio CHARACTER VARYING;

						BEGIN
							RAISE NOTICE 'ESTUDIOS DEL PACIENTE CON DNI: %', p_dni;
							OPEN cursor_paciente_datos;
							LOOP
								FETCH cursor_paciente_datos INTO v_nombre, v_apellido, v_fecha, v_nombre_estudio;
								EXIT WHEN NOT FOUND;
								RAISE NOTICE 'Nombre: % %.  Fehca: %.  Estudio: %.',v_nombre, v_apellido, v_fecha, v_nombre_estudio;
							END LOOP;
							CLOSE cursor_paciente_datos;
						END;
					$$ LANGUAGE plpgsql;

					CALL estudio_por_paciente('6171789')
			
					SELECT pe.nombre, pe.apellido, fecha,e.nombre, pe.dni  FROM paciente
                    INNER JOIN persona pe ON id_persona = id_paciente
                    INNER JOIN estudio_realizado USING(id_paciente)
                    INNER JOIN estudio e USING(id_estudio)
                    WHERE dni = '6171789';
													 
		
			f) Realice un SP que muestre el nombre, apellido y teléfono de los empleados que trabajan en
			un determinado turno. Debe recibir por parámetro el nombre del turno. Nombre sugerido:
			empleado_por_turno.
			
			
				 CREATE OR REPLACE PROCEDURE empleado_por_turno(p_nombre_turno CHARACTER VARYING)
				AS $$
					DECLARE
						cursor_empleados_turno CURSOR FOR SELECT nombre, apellido, telefono FROM empleado
														  INNER JOIN persona ON id_persona = id_empleado    
														  INNER JOIN trabajan USING(id_empleado)
														  INNER JOIN turno USING(id_turno)
                                                          WHERE turno = p_nombre_turno;
						v_nombre CHARACTER VARYING;
						v_apellido CHARACTER VARYING;
						v_telefono CHARACTER VARYING;
						v_turno CHARACTER VARYING;
						v_id_turno INT;

					BEGIN
						SELECT id_turno INTO v_id_turno FROM turno
						WHERE turno = p_nombre_turno;
						IF v_id_turno IS NULL THEN
							RAISE EXCEPTION 'No existe el turno espesificado';
						END IF;

						RAISE NOTICE 'Lista de los empleados del turno: %', p_nombre_turno;
						OPEN cursor_empleados_turno;
						LOOP
							FETCH cursor_empleados_turno INTO v_nombre, v_apellido, v_telefono, v_turno;
							EXIT WHEN NOT FOUND;
							RAISE NOTICE 'Nombre: % %.  Telefono: %.  Turno: %', v_nombre, v_apellido, v_telefono, v_turno;
						END LOOP;
						CLOSE cursor_empleados_turno;
						
						EXCEPTION 
						WHEN OTHERS THEN
						RAISE EXCEPTION 'ERROR.  %',SQLERRM;
					END;
				$$ LANGUAGE plpgsql
				
				select * from turno
				
				CALL empleado_por_turno('Gaurdia dí­a sabado')
	
	EJERCICIO 4:
		También usando cursores, realice los siguientes procedimientos almacenados con consultas más
		complejas.
		
		a) Un SP con los datos de los medicamentos, de un determinado laboratorio y clasificación,
		cuyo precio sea menor que el promedio de precios de todos los medicamentos de ese
		laboratorio y clasificación. Debe recibir por parámetro el nombre del laboratorio y el
		nombre de la clasificación. Nombre sugerido: medicamento_laboratorio_clasificacion
	

				CREATE OR REPLACE PROCEDURE medicamento_laboratorio_clasificacion(p_laboratorio CHARACTER VARYING,
                                                                                  p_clasificacion CHARACTER VARYING)
                AS $$
                    DECLARE
                        cursor_medicamentos CURSOR FOR SELECT nombre, presentacion, precio, stock FROM medicamento
                                                       INNER JOIN clasificacion USING(id_clasificacion)
                                                       INNER JOIN laboratorio USING(id_laboratorio)
                                                       WHERE clasificacion = p_clasificacion AND laboratorio = p_laboratorio AND
                                                             precio < (
                                                                        SELECT AVG(precio) FROM medicamento
                                                                        INNER JOIN laboratorio USING(id_laboratorio)
                                                                        INNER JOIN clasificacion USING(id_clasificacion)
                                                                        WHERE clasificacion = p_clasificacion AND laboratorio = p_laboratorio
                                                                      );
                        v_nombre character varying;
                        v_presentacion character varying;
                        v_precio numeric;
                        v_stock INT;
                        v_id_laboratorio INT;
                        v_id_clasificacion INT;
                    BEGIN
                        SELECT id_laboratorio INTO v_id_laboratorio FROM laboratorio
                        WHERE laboratorio = p_laboratorio;
                        IF v_id_laboratorio IS NULL THEN
                            RAISE EXCEPTION 'El laboratorio de nombre % no se encuentra registrado en la base de datos', p_laboratorio;
                        END IF;

                        SELECT id_clasificacion INTO v_id_clasificacion FROM clasificacion
                        WHERE clasificacion = p_clasificacion;
                        IF v_id_clasificacion IS NULL THEN
                            RAISE EXCEPTION 'La clasificacion de nombre % no se encuentra registrada en la base de datos', p_clasificacion;
                        END IF;

                        OPEN cursor_medicamentos;
                        LOOP
                            FETCH cursor_medicamentos INTO v_nombre, v_presentacion, v_precio, v_stock;
                            RAISE NOTICE 'Nombre: %, Presentación: %, Precio: %, Stock: %', 
                                         v_nombre, v_presentacion, v_precio, v_stock;
                            
                        END LOOP;
                        CLOSE cursor_medicamentos;
                        EXCEPTION
                            WHEN OTHERS THEN 
                            RAISE EXCEPTION 'ERROR.  %', SQLERRM;
                    END;
                $$ LANGUAGE plpgsql;
				
				
			b) Un SP que muestre los datos de los 10 pacientes a los cuales más se le facturó (tome en
			cuenta el monto de las facturas). Nombre sugerido: factura_top_ten
*/		