-- Ejercicio nro. 1:
-- Realice las siguientes modificaciones en las tablas indicadas:
-- ● Modifique el tipo de dato del campo dosis (character varying) de la tabla Tratamiento por el tipo
-- integer.

 ALTER TABLE tratamiento ALTER COLUMN dosis SET DATA TYPE integer USING dosis::integer;
 
-- ● Realice una función que modifique el campo saldo de la tabla factura, el mismo debe ser la
-- diferencia entre el monto de la factura y los pagos realizados para dicha factura. 

CREATE OR REPLACE FUNCTION modificar_saldo (p_id_factura BIGINT) RETURNS void
AS $$
DECLARE monto_ NUMERIC(10,2);
BEGIN
	 IF NOT EXISTS (SELECT * FROM factura WHERE id_factura =p_id_factura) THEN
	 	RAISE EXCEPTION 'El id % de la factura es incorrecto.',p_id_factura;
	END IF;
	SELECT SUM(p.monto) INTO monto_ FROM pago p WHERE id_factura=p_id_factura;
	UPDATE factura
	SET saldo = saldo-monto_
	WHERE id_factura=p_id_factura;
END;
$$ LANGUAGE plpgsql;

-- Ejercicio nro. 2:
-- Realice los siguientes triggers analizando con qué acción (INSERT, UPDATE o DELETE), sobre cual tabla y
-- en qué momento (BEFORE o AFTER) se deben disparar los mismos:

-- a) Cada vez que se agregue un registro en la tabla Tratamiento debe modificar el stock del
-- medicamento recetado, de acuerdo a la cantidad de dosis indicada (stock = stock - dosis).

CREATE OR REPLACE FUNCTION modificar_stock () RETURNS TRIGGER 
AS $$
DECLARE reg_medicamento medicamento%ROWTYPE;
BEGIN
	SELECT * INTO reg_medicamento FROM medicamento WHERE id_medicamento = NEW.id_medicamento;
	IF (NEW.dosis > reg_medicamento.stock) THEN
		RAISE EXCEPTION 'No hay stock suficiente del medicamento';
	END IF;
	UPDATE medicamento
	SET stock = stock-dosis
	WHERE id_medicamento=NEW.id_medicamento;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER modificar_stock 
BEFORE INSERT ON tratamiento
FOR EACH ROW
EXECUTE PROCEDURE modificar_stock();


-- b) Cuando se agrega un registro a la tabla Compra debe actualizar el stock del medicamento
-- comprado de acuerdo a la cantidad adquirida (stock = stock + cantidad)

CREATE OR REPLACE FUNCTION actualizar_stock () RETURNS TRIGGER
AS $$
BEGIN
	UPDATE medicamento
	SET stock = stock + NEW.cantidad
	WHERE id_medicamento = NEW.id_medicamento;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER actualizar_stock
AFTER INSERT ON compra
FOR EACH ROW
EXECUTE PROCEDURE actualizar_stock();

-- c) Cada vez que se realice un pago debe modificar los campos saldo y pagada de la tabla Factura.
-- El campo saldo es la diferencia entre el monto de la factura y la suma de los montos de la tabla
-- Pago de la factura correspondiente. La columna pagada será ‘S’ si el saldo es 0 (cero) y ‘N’ en
-- caso contrario.

CREATE OR REPLACE FUNCTION actualizar_saldo_factura () RETURNS TRIGGER
AS $$
BEGIN
	UPDATE factura
	SET saldo = saldo-NEW.monto,
	pagada = CASE 
		WHEN saldo-NEW.monto > 0 THEN 'N'
		ELSE 'S'
		END
	WHERE id_factura = NEW.id_factura;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER nuevo_pago
AFTER INSERT ON pago
FOR EACH ROW
EXECUTE PROCEDURE actualizar_saldo_factura();

-- d) Cada vez que se borre un registro de la tabla Pago debe modificar los campos saldo y pagada de
-- la tabla Factura, el campo saldo tendrá el valor que tenía más el valor del monto del pago
-- eliminado de la factura correspondiente. La columna pagada deberá tener el valor ‘N’, debido a
-- que no está cancelada la deuda. 

CREATE OR REPLACE FUNCTION actualizar_saldo_factura_2 () RETURNS TRIGGER
AS $$
BEGIN
	UPDATE factura
	SET saldo = saldo + OLD.monto,
	pagada = 'N'
	WHERE id_factura = OLD.id_factura;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER pago_borrado
AFTER DELETE ON pago
FOR EACH ROW
EXECUTE PROCEDURE actualizar_saldo_factura_2();
-- e) Cada vez que se modifique el stock de un medicamento, si el mismo es menor a 50 se debe
-- agregar un registro en una nueva tabla llamada medicamento_reponer. La tabla
-- medicamento_reponer debe tener los siguientes campos: id_medicamento, nombre,
-- presentación y el stock del medicamento, también debe tener el último precio que se pagó por
-- el mismo cuando se lo compró y a qué proveedor (solo el nombre). El trigger sólo debe activarse
-- cuando se modifique el campo stock por un valor menor, en caso contrario, no debe realizar
-- ninguna acción. Tenga en cuenta que puede darse el caso que el registro de dicho medicamento
-- ya exista en la tabla medicamento_reponer, en tal caso solo debe actualizar el campo stock.


CREATE TABLE medicamento_reponer (
	id_medicamento integer NOT NULL,
    nombre character varying(50) NOT NULL,
    presentacion character varying(50) NOT NULL,
    precio numeric(8,2),
	proveedor character varying(50),
    stock integer,
    CONSTRAINT "medicamento_reponer_pk" PRIMARY KEY (id_medicamento),
	FOREIGN KEY (id_medicamento) REFERENCES medicamento (id_medicamento)
);

CREATE OR REPLACE FUNCTION reponer_medicamento () RETURNS TRIGGER
AS $$
DECLARE v_data RECORD;
BEGIN
	UPDATE medicamento_reponer
	SET stock = NEW.stock
	WHERE id_medicamento = NEW.id_medicamento;
	IF NOT FOUND THEN
		SELECT * INTO v_data 
		FROM compra
		INNER JOIN medicamento USING (id_medicamento)
		INNER JOIN proveedor USING (id_proveedor)
		WHERE id_medicamento = NEW.id_medicamento
		ORDER BY compra.fecha asc
		LIMIT 1;
		
		INSERT INTO medicamento_reponer VALUES(NEW.id_medicamento,
										 NEW.nombre,
										 NEW.presentacion,
										 v_data.precio_unitario,
										 v_data.proveedor,
										 NEW.stock);
	END IF;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER modificacion_stock
AFTER UPDATE OF stock ON medicamento
FOR EACH ROW
WHEN (NEW.stock<50)
EXECUTE PROCEDURE reponer_medicamento ();


-- f) Cada vez que se modifique el stock de un medicamento, solo si es por un valor mayor (cuando
-- se hace una compra), debe buscar si existe el registro en la tabla medicamento_reponer, y si el
-- nuevo valor del stock (stock + cantidad) es mayor a 50, debe eliminar el registro de dicha tabla,
-- de lo contrario, debe modificar el campo stock de la tabla medicamento_reponer, por el nuevo
-- stock de la tabla medicamento.

CREATE OR REPLACE FUNCTION update_medicamento_reponer() RETURNS TRIGGER
AS $$
BEGIN
	IF (SELECT EXISTS(SELECT * FROM medicamento_reponer WHERE id_medicamento=NEW.id_medicamento)) THEN
		IF (NEW.stock>=50) THEN
			DELETE FROM medicamento_reponer
			WHERE id_medicamento = NEW.id_medicamento;
		ELSE 
			UPDATE medicamento_reponer
			SET stock=NEW.stock
			WHERE id_medicamento = NEW.id_medicamento;
		END IF;
	END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER modifico_stock
AFTER UPDATE OF stock ON medicamento
FOR EACH ROW
WHEN (NEW.stock>OLD.stock)
EXECUTE PROCEDURE update_medicamento_reponer();

-- Ejercicio nro. 3:
-- Realice las siguientes auditorías por trigger.

-- a) Auditoría de medicamento: debe registrar cualquier cambio realizado en la tabla medicamento
-- en una nueva tabla llamada audita_medicamento cuyos camposserán: id (serial), usuario, fecha,
-- operación, estado, más todos los campos de la tabla medicamento (id_medicamento,
-- id_clasificacion, etc).
-- Si se agrega o borra un registro, de guardar el nombre de usuario, la fecha y hora actual, como
-- operación guardará una I ó D según corresponda, y en estado las palabras “alta” o “baja”.
-- Si la operación realizada es una modificación debe guardar dos registros en la tabla
-- audita_medicamento, uno con los valores antes de ser modificados y otro con los valores ya
-- modificados, entonces, en el campo operación guardará U en ambos registros y para el registro
-- “viejo” en el campo estado debe guardar la palabra “antes” y para el registro “nuevo” el estado
-- debe decir “después”

CREATE TABLE audita_medicamento(
id SERIAL NOT NULL,
fecha DATE NOT NULL,
usuario VARCHAR(50) NOT NULL,
operacion CHAR NOT NULL,
estado VARCHAR(10) NOT NULL,
id_medicamento integer NOT NULL,
id_clasificacion smallint NOT NULL,
id_laboratorio smallint NOT NULL,
nombre character varying(50) NOT NULL,
presentacion character varying(50) NOT NULL,
precio numeric(8,2) NOT NULL,
stock integer
)

CREATE OR REPLACE FUNCTION audita_medicamento () RETURNS TRIGGER 
AS $$
BEGIN
	IF (TG_OP = 'DELETE') THEN
		INSERT INTO audita_medicamento VALUES (DEFAULT,NOW(),USER,'D','baja',OLD.id_medicamento,OLD.id_clasificacion,OLD.id_laboratorio,OLD.nombre,OLD.presentacion,OLD.precio,OLD.stock);
		RETURN OLD;
		ELSIF (TG_OP='INSERT') THEN
			INSERT INTO audita_medicamento VALUES (DEFAULT,NOW(),USER,'I','alta',NEW.id_medicamento,NEW.id_clasificacion,NEW.id_laboratorio,NEW.nombre,NEW.presentacion,NEW.precio,NEW.stock);
			RETURN NEW;
			ELSIF (TG_OP = 'UPDATE') THEN
				INSERT INTO audita_medicamento VALUES (DEFAULT,NOW(),USER,'U','antes',OLD.id_medicamento,OLD.id_clasificacion,OLD.id_laboratorio,OLD.nombre,OLD.presentacion,OLD.precio,OLD.stock);
				INSERT INTO audita_medicamento VALUES (DEFAULT,NOW(),USER,'U','despues',NEW.id_medicamento,NEW.id_clasificacion,NEW.id_laboratorio,NEW.nombre,NEW.presentacion,NEW.precio,NEW.stock);
				RETURN NEW;
	END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER audita_medicamento
AFTER DELETE OR INSERT OR UPDATE ON medicamento
FOR EACH ROW
EXECUTE PROCEDURE audita_medicamento();

-- b) Auditoría de empleados: debe guardar los datos en una tabla llamada audita_empleado_sueldo
-- cuyos campos serán: id (serial), usuario, fecha, id_empleado, dni, nombre y apellido del
-- empleado, también debe tener un campo sueldo_v (sueldo antes de modificar), sueldo_n
-- (sueldo después de modificar), un campo diferencia que llevará la diferencia entre el sueldo
-- anterior y el nuevo, y un campo estado, en el cual se guardará “aumento”, si el sueldo nuevo es
-- mayor al anterior o “descuento” en caso contrario.
-- Esta auditoría sólo se debe ejecutar en caso que se realice una modificación en el sueldo del
-- empleado, cualquier otra operación realizada en la tabla Empleado debe ser ignorada por esta
-- auditoría.
CREATE TABLE audita_empleado_sueldo (
	id SERIAL,
	usuario VARCHAR(50),
	fecha DATE,
	id_empleado integer NOT NULL,
	dni varchar(8),
	nombre varchar(100),
	apellido varchar(100),
    sueldo_v numeric(9,2),
	sueldo_n numeric(9,2),
	diferencia numeric(9,2),
	estado VARCHAR(10)
)

CREATE OR REPLACE FUNCTION audita_empleado_sueldo() RETURNS TRIGGER
AS $$
DECLARE v_empleado RECORD;
BEGIN
	SELECT * INTO v_empleado FROM empleado
	INNER JOIN persona ON id_empleado = id_persona
	WHERE id_empleado = NEW.id_empleado;
	INSERT INTO audita_empleado_sueldo VALUES(DEFAULT,
									    USER,
									    NOW(),
									    NEW.id_empleado,
									    v_empleado.nombre,
									    v_empleado.apellido,
									    OLD.sueldo,
									    NEW.sueldo,
									    abs(OLD.sueldo-NEW.sueldo),
									    CASE WHEN(OLD.sueldo < NEW.sueldo) THEN 'aumento'
									    ELSE 'descuento'
										END);
										
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER audita_empleado_sueldo
AFTER UPDATE OF sueldo ON empleado
FOR EACH ROW
EXECUTE PROCEDURE audita_empleado_sueldo();
-- c) Auditoría de tablas: debe guardar los datos en una nueva tabla llamada audita_tablas_sistema
-- cada vez que se elimine una consulta, un estudio realizado o un tratamiento cuyos campos serán:
-- id (serial), usuario y fecha, el id del paciente, la fecha en la que se realizó la consulta, estudio o
-- indicación del tratamiento y el nombre de la tabla a la que corresponde el registro borrado.
-- Ante cualquier otra acción en estas tablas, esta auditoría no se debe ejecutar. También debe
-- guardar el registro borrado en una tabla llamada estudio_borrado, consulta_borrada o
-- tratamiendo_borrado, según corresponda, los campos de las nuevas tablas serán los mismos
-- que los de las tablas originales.

CREATE TABLE consulta_borrada (
	id_paciente integer NOT NULL,
    id_empleado integer NOT NULL,
    fecha date NOT NULL,
    id_consultorio smallint NOT NULL,
    hora time without time zone,
    resultado character varying(100) 
)	
	
CREATE TABLE estudio_borrado(	
	id_paciente integer NOT NULL,
    id_estudio smallint NOT NULL,
    fecha date NOT NULL,
    id_equipo smallint NOT NULL,
    id_empleado integer NOT NULL,
    resultado character varying(50) ,
    observacion character varying(100) ,
    precio numeric(10,2)
)	

CREATE TABLE tratamiento_borrado(
	id_paciente integer NOT NULL,
    id_medicamento integer NOT NULL,
    fecha_indicacion date NOT NULL,
    prescribe integer NOT NULL,
    nombre character varying(50) ,
    descripcion character varying(100) ,
    dosis character varying(50) ,
    costo numeric(10,2)
)	

CREATE TABLE audita_tablas_sistema (
	id SERIAL,
	usuario VARCHAR(50),
	fecha DATE,
	id_paciente INTEGER,
	fecha_registro DATE,
	tabla VARCHAR(20)
);

CREATE OR REPLACE FUNCTION audita_tablas_sistema () RETURNS TRIGGER
AS $$
BEGIN
	IF (TG_TABLE_NAME = 'consulta') THEN
		INSERT INTO audita_tablas_sistema VALUES(DEFAULT,
												 USER,
												 NOW(),
												 OLD.id_paciente,
												 OLD.fecha,
												 TG_TABLE_NAME
												 );
		INSERT INTO consulta_borrada VALUES (OLD.id_paciente ,
											OLD.id_empleado,
											OLD.fecha ,
											OLD.id_consultorio,
											OLD.hora,
											OLD.resultado );
	ELSIF (TG_TABLE_NAME = 'estudio_realizado') THEN
	
		INSERT INTO audita_tablas_sistema VALUES(DEFAULT,
												 USER,
												 NOW(),
												 OLD.id_paciente,
												 OLD.fecha,
												 TG_TABLE_NAME
												 );
		INSERT INTO estudio_borrado VALUES (OLD.id_paciente,
											OLD.id_estudio,
											OLD.fecha,
											OLD.id_equipo,
											OLD.id_empleado,
											OLD.resultado,
											OLD.observacion,
											OLD.precio);
		ELSIF (TG_TABLE_NAME = 'tratamiento') THEN
	
		INSERT INTO audita_tablas_sistema VALUES(DEFAULT,
												 USER,
												 NOW(),
												 OLD.id_paciente,
												 OLD.fecha_indicacion,
												 TG_TABLE_NAME
												 );
		INSERT INTO tratamiento_borrado VALUES (OLD.id_paciente,
												OLD.id_medicamento,
												OLD.fecha_indicacion,
												OLD.prescribe,
												OLD.nombre,
												OLD.descripcion,
												OLD.dosis,
												OLD.costo);		
		END IF;
		RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER audita_tablas_sistema
AFTER DELETE ON consulta
FOR EACH ROW
EXECUTE PROCEDURE audita_tablas_sistema();


CREATE TRIGGER audita_tablas_sistema
AFTER DELETE ON tratamiento
FOR EACH ROW
EXECUTE PROCEDURE audita_tablas_sistema();


CREATE TRIGGER audita_tablas_sistema
AFTER DELETE ON estudio_realizado
FOR EACH ROW
EXECUTE PROCEDURE audita_tablas_sistema();