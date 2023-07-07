-- TP 8

-- Ej 1)

ALTER TABLE tratamiento 
ALTER COLUMN dosis SET DATA TYPE integer USING dosis::integer;

CREATE FUNCTION modifica_saldo(idfactura int) RETURNS VOID AS $$
BEGIN
UPDATE factura SET saldo = monto - (SELECT sum(monto) FROM pago WHERE id_factura = $1);
END;
$$ LANGUAGE plpgsql;

-- Ej 2) a)

CREATE FUNCTION calcula_stock() RETURNS TRIGGER AS $$
BEGIN
UPDATE medicamento SET stock = stock - NEW.dosis WHERE id_medicamento = NEW.id_medicamento;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER repone_stock AFTER INSERT ON tratamiento FOR EACH ROW EXECUTE PROCEDURE calcula_stock();

--prueba

INSERT INTO tratamiento VALUES (503, 594, '2019-03-13', 278, 'NICOXANTINA', 'CAJA X 30 TABLETAS', 14, 450.22);

SELECT * FROM medicamento WHERE id_medicamento = 594;

-- b)

CREATE FUNCTION agrega_stock() RETURNS TRIGGER AS $$
BEGIN
UPDATE medicamento SET stock = stock + NEW.cantidad WHERE id_medicamento = NEW.id_medicamento;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER agregar_stock AFTER INSERT ON compra FOR EACH ROW EXECUTE PROCEDURE agrega_stock();

-- prueba

INSERT INTO compra VALUES (5, 2, '2008-02-05', 205, 190.20, 60);

SELECT * FROM medicamento WHERE id_medicamento = 5;

-- c)

CREATE FUNCTION pago_factura() RETURNS TRIGGER AS $$
DECLARE
	nuevo_saldo numeric(10,2);
BEGIN
SELECT saldo-NEW.monto INTO nuevo_saldo FROM factura WHERE id_factura = NEW.id_factura;
IF nuevo_saldo > 0 THEN
	UPDATE factura SET saldo = nuevo_saldo WHERE id_factura = NEW.id_factura;
	RETURN NEW;
ELSE 
	UPDATE factura SET saldo = 0, pagada = 'S' WHERE id_factura = NEW.id_factura;
	RETURN NEW;
END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER actualizar_factura BEFORE INSERT ON pago FOR EACH ROW EXECUTE PROCEDURE pago_factura();

-- prueba

INSERT INTO pago VALUES (939590, '2023-02-06', 856.86);

SELECT * FROM factura WHERE id_factura = 939590;

SELECT * FROM pago WHERE id_factura = 939590;

-- d)

CREATE FUNCTION actualiza_pago_eliminado() RETURNS TRIGGER AS $$
BEGIN -- siempre que se elimine un pago, la columna pagada pasará a N asi sea que ya estaba en N o en S.
UPDATE factura SET saldo = saldo + old.monto, pagada = 'N' WHERE id_factura = old.id_factura;
RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER pago_eliminado AFTER DELETE ON pago FOR EACH ROW EXECUTE PROCEDURE actualiza_pago_eliminado();

-- prueba

SELECT * FROM factura WHERE id_factura = 939590;

SELECT * FROM pago WHERE id_factura = 939590;

DELETE FROM pago WHERE id_factura = 939590 AND fecha = '2023-02-06';

-- e)

CREATE OR REPLACE FUNCTION  agregar_a_reponer() RETURNS TRIGGER AS $$
DECLARE
	prov varchar; existe boolean;
BEGIN
SELECT EXISTS(SELECT id_medicamento FROM medicamento_reponer WHERE id_medicamento = OLD.id_medicamento) INTO existe;
IF NEW.stock < 50 THEN
	IF NOT existe THEN
		SELECT proveedor INTO prov FROM compra INNER JOIN proveedor USING (id_proveedor) WHERE id_medicamento = NEW.id_medicamento LIMIT 1;
		INSERT INTO medicamento_reponer VALUES (NEW.id_medicamento, NEW.nombre, NEW.presentacion, NEW.stock, NEW.precio, prov);
		RETURN NEW;
	ELSE 
		UPDATE medicamento_reponer SET stock = NEW.stock WHERE id_medicamento = NEW.id_medicamento;
		RETURN NEW;
	END IF;
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER modifica_stock AFTER UPDATE OF stock ON medicamento FOR EACH ROW WHEN (NEW.stock < OLD.stock) EXECUTE PROCEDURE agregar_a_reponer()

-- prueba

SELECT * FROM medicamento WHERE id_medicamento = 594;
SELECT * FROM medicamento_reponer WHERE id_medicamento = 594;
UPDATE medicamento SET stock = 40 WHERE id_medicamento = 594;


-- f)

CREATE OR REPLACE FUNCTION quitar_de_reponer() RETURNS TRIGGER AS $$
DECLARE
	existe boolean;
BEGIN
	SELECT EXISTS(SELECT * FROM medicamento_reponer WHERE id_medicamento = NEW.id_medicamento) INTO existe;
	IF (NEW.stock > 50) THEN
		IF existe THEN
			DELETE FROM medicamento_reponer WHERE id_medicamento = NEW.id_medicamento;
			RAISE NOTICE 'Medicamento eliminado de la tabla reponer.';
			RETURN NEW;
		ELSE
			UPDATE medicamento_reponer SET stock = NEW.stock
			RETURN NEW;
		END IF;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER modifica_stock2 AFTER UPDATE OF stock ON medicamento FOR EACH ROW WHEN (NEW.stock > OLD.stock) EXECUTE PROCEDURE quitar_de_reponer();

-- Ejercicio 3

CREATE FUNCTION auditoria_medicamentos() RETURN TRIGGER AS $$
BEGIN
	IF (TG_OP = 'DELETE') THEN 
		INSERT INTO audita_medicamento VALUES (default, user, now(),
											  'D', 'Baja', old.id_medicamento,
											  old.id_clasificacion, old.id_laboratorio,
											  old.nombre, old.presentacion, old.precio,
											  old.stock);
		RETURN OLD;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO audita_medicamento VALUES (default, user, now(),
											  'I', 'Alta', old.id_medicamento,
											  old.id_clasificacion, old.id_laboratorio,
											  old.nombre, old.presentacion, old.precio,
											  old.stock);
		RETURN NEW;
	ELSE 
		INSERT INTO audita_medicamento VALUES (default, user, now(),
											  'U', 'antes', old.id_medicamento,
											  old.id_clasificacion, old.id_laboratorio,
											  old.nombre, old.presentacion, old.precio,
											  old.stock);
		INSERT INTO audita_medicamento VALUES (default, user, now(),
											  'U', 'despues', new.id_medicamento,
											  new.id_clasificacion, new.id_laboratorio,
											  new.nombre, new.presentacion, new.precio,
											  new.stock);
		RETURN NEW;
$$ LANGUAGE plpgsql;

CREATE TRIGGER audi_medicamento AFTER INSERT OR UPDATE OR DELETE ON medicamento FOR EACH ROW EXECUTE PROCEDURE auditoria_medicamentos();

-- b)

CREATE FUNCTION audita_empleado_sueldo() RETURN TRIGGER AS $$
DECLARE
	tipo_modificacion varchar;
BEGIN
	IF (old.sueldo > new.sueldo) THEN
		tipo_modificacion := 'descuento';
	ELSE 
		tipo_modificacion := 'aumento';
	INSERT INTO audita_empleado_sueldo VALUES (default, user, now(),
												  old.id_empleado, old.dni,
												  old.nombre, old.apellido,
												  old.sueldo, new.sueldo, abs(old.sueldo-new.sueldo),
											  	tipo_modificacion);
	RETURN NEW;
$$ LANGUAGE plpgsql;

CREATE TRIGGER audi_empleado_sueldo AFTER UPDATE ON empleado FOR EACH ROW EXECUTE PROCEDURE audita_empleado_sueldo() WHEN OLD.sueldo != NEW.sueldo;

-- c)

CREATE FUNCTION audita_tablas_sistemas() RETURN TRIGGER AS $$
BEGIN
IF (TG_TABLE_NAME = 'tratamiento') THEN 
	INSERT INTO audita_tablas_sistema VALUES (default, user, now(),
										 old.id_paciente, old.fecha_indicacion,
										 TG_TABLE_NAME);
	INSERT INTO tratamiento_borrado VALUES (old.id_paciente, old.id_medicamento, old.fecha_indicacion,
										   old.prescribe, old.nombre, old.descripcion,
										   old.dosis, old.costo);
	RETURN OLD;
ELSIF (TG_TABLE_NAME = 'estudio_realizado') THEN
	INSERT INTO audita_tablas_sistema VALUES (default, user, now(),
										 old.id_paciente, old.fecha,
										 TG_TABLE_NAME);
	INSERT INTO estudio_borrado VALUES (old.id_paciente, old.id_estudio, old.fecha
									   old.id_equipo, old.id_empleado, old.resultado,
									   old.observacion, old.precio);
	RETURN OLD;
ELSIF (TG_TABLE_NAME = 'consulta') THEN
	INSERT INTO audita_tablas_sistema VALUES (default, user, now(),
										 old.id_paciente, old.fecha,
										 TG_TABLE_NAME);
	INSERT INTO estudio_borrado VALUES (old.id_paciente, old.id_empleado, old.fecha
									   old.id_consultorio, old.hora, old.resultado);
	RETURN OLD;
END IF;								 
$$ LANGUAGE plpgsql;

CREATE TRIGGER audi_tablas_sistema AFTER DELETE ON estudio_realizado, consulta, tratamiento FOR EACH ROW EXECUTE PROCEDURE audita_tablas_sistemas();