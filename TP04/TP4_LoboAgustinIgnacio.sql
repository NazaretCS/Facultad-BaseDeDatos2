/*EJERCICIO 1*/
/*
BEGIN;

INSERT INTO persona(id_persona, nombre, apellido, dni, fecha_nacimiento, domicilio, telefono)
VALUES ((SELECT max(id_persona)+1 FROM persona), 'ALEJANDRA', 'HERRERA', '37366992', '20-06-1992', 'SAN JUAN 258', '54-381-326-1780');

SAVEPOINT personaAgregada;

INSERT INTO paciente(id_paciente, id_obra_social)
VALUES ((SELECT max(id_persona) FROM persona), 137);

SAVEPOINT pacienteAgregado;

INSERT INTO consulta (id_paciente, id_empleado, fecha, id_consultorio, hora, resultado)
VALUES ((SELECT max(id_paciente) FROM paciente), 253, '23-03-2023', 5, '14:14:00', 'SE DIAGNOSTICA
DERMATITIS' );
COMMIT;*/

/*ROLLBACK TO pacienteAgregado;*/

/*=======================================================================================================================*/

/*EJERCICIO 2*/
/*
BEGIN;

SELECT * FROM medicamento INNER JOIN clasificacion Cl USING(id_clasificacion)
INNER JOIN laboratorio L USING(id_laboratorio)
WHERE Cl.clasificacion LIKE '%ANALGESICO%' AND L.laboratorio LIKE '%ABBOTT LABORATORIO%';

UPDATE medicamento SET precio = (precio*1.02) WHERE id_clasificacion IN (
SELECT id_clasificacion FROM clasificacion WHERE clasificacion LIKE '%ANALGESICO%'
) AND id_laboratorio = (
SELECT id_laboratorio FROM laboratorio WHERE laboratorio LIKE '%ABBOTT LABORATORIO%'
);

SAVEPOINT labo1Aumentado;

SELECT * FROM medicamento INNER JOIN clasificacion Cl USING(id_clasificacion)
INNER JOIN laboratorio L USING(id_laboratorio)
WHERE Cl.clasificacion LIKE '%ANALGESICO%' AND L.laboratorio LIKE '%BAYER QUIMICAS UNIDAS S.A.%';

UPDATE medicamento SET precio = (precio - precio*0.035) WHERE id_clasificacion IN (
SELECT id_clasificacion FROM clasificacion WHERE clasificacion LIKE '%ANALGESICO%'
) AND id_laboratorio = (
SELECT id_laboratorio FROM laboratorio WHERE laboratorio LIKE '%BAYER QUIMICAS UNIDAS S.A.%'
);
SAVEPOINT labo2Reducido;

SELECT * FROM medicamento INNER JOIN clasificacion Cl USING(id_clasificacion)
INNER JOIN laboratorio L USING(id_laboratorio)
WHERE Cl.clasificacion LIKE '%ANALGESICO%' AND L.laboratorio LIKE '%COFANA (CONSORCIO FARMACEUTICO NACIONAL)%';

UPDATE medicamento SET precio = (precio*1.08) WHERE id_clasificacion IN (
SELECT id_clasificacion FROM clasificacion WHERE clasificacion LIKE '%ANALGESICO%'
) AND id_laboratorio = (
SELECT id_laboratorio FROM laboratorio WHERE laboratorio LIKE '%COFANA (CONSORCIO FARMACEUTICO NACIONAL)%'
);
SAVEPOINT labo3Aumentado;

SELECT * FROM medicamento INNER JOIN clasificacion Cl USING(id_clasificacion)
INNER JOIN laboratorio L USING(id_laboratorio)
WHERE Cl.clasificacion LIKE '%ANALGESICO%' AND L.laboratorio LIKE '%FARPASA FARMACEUTICA DEL PACIFICO%';

UPDATE medicamento SET precio = (precio - precio*0.04) WHERE id_clasificacion IN (
SELECT id_clasificacion FROM clasificacion WHERE clasificacion LIKE '%ANALGESICO%'
) AND id_laboratorio = (
SELECT id_laboratorio FROM laboratorio WHERE laboratorio LIKE '%FARPASA FARMACEUTICA DEL PACIFICO%'
);
SAVEPOINT labo4Reducido;

SELECT * FROM medicamento INNER JOIN clasificacion Cl USING(id_clasificacion)
INNER JOIN laboratorio L USING(id_laboratorio)
WHERE Cl.clasificacion LIKE '%ANALGESICO%' AND L.laboratorio LIKE '%RHONE POULENC ONCOLOGICOS%';

UPDATE medicamento SET precio = (precio - precio*0.102) WHERE id_clasificacion IN (
SELECT id_clasificacion FROM clasificacion WHERE clasificacion LIKE '%ANALGESICO%'
) AND id_laboratorio = (
SELECT id_laboratorio FROM laboratorio WHERE laboratorio LIKE '%RHONE POULENC ONCOLOGICOS%'
);
SAVEPOINT labo5Reducido;

SELECT * FROM medicamento INNER JOIN clasificacion Cl USING(id_clasificacion)
INNER JOIN laboratorio L USING(id_laboratorio)
WHERE Cl.clasificacion LIKE '%ANALGESICO%' AND L.laboratorio LIKE '%ROEMMERS%';

UPDATE medicamento SET precio = (precio*1.055) WHERE id_clasificacion IN (
	SELECT id_clasificacion FROM clasificacion WHERE clasificacion LIKE '%ANALGESICO%'
	) AND id_laboratorio = (
		SELECT id_laboratorio FROM laboratorio WHERE laboratorio LIKE '%ROEMMERS%'
	);
SAVEPOINT labo6Aumentado;

SELECT * FROM medicamento INNER JOIN clasificacion Cl USING(id_clasificacion)
INNER JOIN laboratorio L USING(id_laboratorio)
WHERE Cl.clasificacion LIKE '%ANALGESICO%' AND L.laboratorio NOT IN('ABBOTT LABORATORIOS','BAYER QUIMICAS UNIDAS S.A.',
																   'COFANA (CONSORCIO FARMACEUTICO NACIONAL)', 'FARPASA FARMACEUTICA DEL PACIFICO',
																   'RHONE POULENC ONCOLOGICOS ', 'ROEMMERS');

UPDATE medicamento SET precio = (precio*1.07) WHERE id_clasificacion IN (
	SELECT id_clasificacion FROM clasificacion WHERE clasificacion LIKE '%ANALGESICO%'
	) AND id_laboratorio IN (
		SELECT id_laboratorio FROM laboratorio WHERE laboratorio NOT IN('ABBOTT LABORATORIOS','BAYER QUIMICAS UNIDAS S.A.',
																   'COFANA (CONSORCIO FARMACEUTICO NACIONAL)', 'FARPASA FARMACEUTICA DEL PACIFICO',
																   'RHONE POULENC ONCOLOGICOS ', 'ROEMMERS')
	);

COMMIT;*/

/*=======================================================================================================================*/

/*Ejercicio 3*/

/*a)*/
/*
BEGIN;

INSERT INTO estudio_realizado(id_paciente, id_estudio, fecha, id_equipo, id_empleado, resultado, observacion, precio)
VALUES (175363, 24, '01-04-2023', 15, 522, 'NORMAL', 'NO SE OBSERVAN IRREGULARIDADES', 3526.00);

COMMIT;*/

/*b)*/
BEGIN;

INSERT INTO tratamiento(id_paciente, id_medicamento, fecha_indicacion, 
						prescribe, nombre, descripcion, dosis, costo) 
			VALUES(175363, 1532, '03-04-2023', 253, ' AFRIN ADULTOS SOL', 'FRASCO X 15 CC', 1, 1821.79);

COMMIT;

BEGIN;

INSERT INTO tratamiento(id_paciente, id_medicamento, fecha_indicacion, 
						prescribe, nombre, descripcion, dosis, costo) 
			VALUES(175363, 1560, '03-04-2023', 253, 'NAFAZOL', 'FRASCO X 15 ML', 2, 1850.96);
SAVEPOINT segundoMedicamento;

SELECT * FROM tratamiento ORDER BY id_paciente DESC;

INSERT INTO tratamiento(id_paciente, id_medicamento, fecha_indicacion, 
						prescribe, nombre, descripcion, dosis, costo) 
			VALUES(175363, 1522, '03-04-2023', 253, 'VIBROCIL GOTAS NASALES', 'FRASCO X 15 CC', 2, 2500.66);

COMMIT;

/*c)*/
BEGIN;

INSERT INTO internacion(id_paciente, id_cama, fecha_inicio, ordena_internacion, 
					   fecha_alta, hora, costo)
			VALUES(175363, 157, '03-04-2023', 253, '06-04-2023', '11:30:00', 160000.00);

COMMIT;

/*Ejercicio 4*/
BEGIN;

INSERT INTO factura(id_factura, id_paciente, fecha, hora, monto, pagada, saldo)
VALUES((SELECT max(id_factura)+1 FROM factura), (SELECT id_paciente FROM paciente INNER JOIN persona Per
ON id_paciente = Per.id_persona WHERE Per.nombre = 'ALEJANDRA' AND Per.apellido = 'HERRERA'),
'06-04-2023', '03:03:03', 169699.41, 'S', 0);

COMMIT;

/*Ejercicio 6*/
/*Mantenimiento Cama*/
BEGIN;

INSERT INTO mantenimiento_cama(id_cama, fecha_ingreso, observacion, estado, fecha_egreso,
demora, id_empleado)
VALUES (53, '25-04-2023', 'sin novedad', 'En reparacion', NULL, 0, NULL);
SAVEPOINT cama53Ingresa;

INSERT INTO mantenimiento_cama(id_cama, fecha_ingreso, observacion, estado, fecha_egreso,
demora, id_empleado)
VALUES (111, '25-04-2023', 'sin novedad', 'En reparacion', NULL, 0, NULL);
SAVEPOINT cama111Ingresa;

INSERT INTO mantenimiento_cama(id_cama, fecha_ingreso, observacion, estado, fecha_egreso,
demora, id_empleado)
VALUES (163, '25-04-2023', 'sin novedad', 'En reparacion', NULL, 0, NULL);
COMMIT;

/*Mantenimiento Equipo*/
BEGIN;
INSERT INTO mantenimiento_equipo(id_equipo, fecha_ingreso, observacion, estado, fecha_egreso,
demora, id_empleado)
VALUES (12, '25-04-2023', 'sin novedad', 'En reparacion', NULL, 0, NULL);

INSERT INTO mantenimiento_equipo(id_equipo, fecha_ingreso, observacion, estado, fecha_egreso,
demora, id_empleado)
VALUES (30, '25-04-2023', 'sin novedad', 'En reparacion', NULL, 0, NULL);
COMMIT;

/*Ejercicio 7*/
BEGIN;

SELECT * FROM compra INNER JOIN medicamento Med USING(id_medicamento)
INNER JOIN proveedor USING(id_proveedor) WHERE proveedor LIKE '%MEDIFARMA%'
AND Med.nombre LIKE '%BILICANTA%';

SELECT * FROM medicamento WHERE nombre LIKE '%BILICANTA%';

SELECT * FROM empleado Em INNER JOIN tratamiento Tr On Tr.prescribe = Em.id_empleado
INNER JOIN medicamento Med USING(id_medicamento);

INSERT INTO compra(id_medicamento, id_proveedor, fecha, id_empleado,
precio_unitario, cantidad)
VALUES ((SELECT id_medicamento FROM medicamento WHERE nombre LIKE '%BILICANTA%'),
(SELECT id_proveedor FROM proveedor WHERE proveedor LIKE '%MEDIFARMA%'),
'25-04-2023', (SELECT min(id_empleado) FROM empleado Em INNER JOIN tratamiento Tr On Tr.prescribe = Em.id_empleado
INNER JOIN medicamento Med USING(id_medicamento)), 
(SELECT precio*0.7 FROM medicamento WHERE nombre LIKE '%BILICANTA%'), 240);
SAVEPOINT ingresaDato1;

INSERT INTO compra(id_medicamento, id_proveedor, fecha, id_empleado,
precio_unitario, cantidad)
VALUES ((SELECT id_medicamento FROM medicamento WHERE nombre LIKE '%IRRITREN 200 MG%'),
(SELECT id_proveedor FROM proveedor WHERE proveedor LIKE '%DIFESA%'),
'19-04-2023', (SELECT min(id_empleado) FROM empleado Em INNER JOIN tratamiento Tr On Tr.prescribe = Em.id_empleado
INNER JOIN medicamento Med USING(id_medicamento)), 
(SELECT precio*0.7 FROM medicamento WHERE nombre LIKE '%IRRITREN 200 MG%'), 90);
SAVEPOINT ingresaDato2;

INSERT INTO compra(id_medicamento, id_proveedor, fecha, id_empleado,
precio_unitario, cantidad)
VALUES ((SELECT id_medicamento FROM medicamento WHERE nombre LIKE '%PEDIAFEN JARABE%'),
(SELECT id_proveedor FROM proveedor WHERE proveedor LIKE '%REYES DROGUERIA%'),
'19-04-2023', (SELECT min(id_empleado) FROM empleado Em INNER JOIN tratamiento Tr On Tr.prescribe = Em.id_empleado
INNER JOIN medicamento Med USING(id_medicamento)), 
(SELECT precio*0.7 FROM medicamento WHERE nombre LIKE '%PEDIAFEN JARABE%'), 150);

COMMIT;
ROLLBACK;

/*Ejercicio 8*/
/*Elimino de los estudios, tratamiento e internacion*/
BEGIN;

DELETE FROM estudio_realizado WHERE id_paciente IN (SELECT id_paciente FROM paciente WHERE id_paciente = 175363);
SAVEPOINT eliminadoDeEstudioRealizado;

DELETE FROM tratamiento WHERE id_paciente IN (SELECT id_paciente FROM paciente WHERE id_paciente = 175363);
SAVEPOINT eliminadoDeTratamiento;

DELETE FROM internacion WHERE id_paciente IN (SELECT id_paciente FROM paciente WHERE id_paciente = 175363);
COMMIT;

/*Elimino de factura y de consulta*/
BEGIN;

DELETE FROM factura WHERE id_paciente = 175363;
SAVEPOINT eliminadaFactura;

DELETE FROM consulta WHERE id_paciente IN (SELECT id_paciente FROM paciente WHERE id_paciente = 175363);
SAVEPOINT eliminaConsulta;

COMMIT;

/*Elimino en su totalidad al paciente*/
BEGIN;

DELETE FROM paciente WHERE id_paciente = 175363;

DELETE FROM persona WHERE id_persona = 175363;
COMMIT;

/*Elimino el medicamento SALBUTOL GOTAS*/
BEGIN;
DELETE FROM tratamiento WHERE id_medicamento IN (SELECT id_medicamento FROM medicamento WHERE nombre LIKE '%SALBUTOL GOTAS%');
SAVEPOINT eliminadoDeTratamiento;
DELETE FROM compra WHERE id_medicamento IN (SELECT id_medicamento FROM medicamento WHERE nombre LIKE '%SALBUTOL GOTAS%');
SAVEPOINT eliminadoDeCompra;
DELETE FROM medicamento WHERE nombre LIKE '%SALBUTOL GOTAS%';
COMMIT;
