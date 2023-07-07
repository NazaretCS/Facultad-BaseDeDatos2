/*

EJERCICIO 1:

    Modifique el tipo de dato del campo dosis (character varying) de la tabla Tratamiento por el tipo
    integer. ALTER TABLE tratamiento ALTER COLUMN dosis SET DATA TYPE integer USING dosis::integer;

        ALTER TABLE tratamiento ALTER COLUMN dosis SET DATA TYPE integer USING dosis::integer;


    Realice una función que modifique el campo saldo de la tabla factura, el mismo debe ser la
    diferencia entre el monto de la factura y los pagos realizados para dicha factura

        CREATE OR REPLACE FUNCTION factura_modificar_saldo()  RETURNS void AS $BODY$
            BEGIN
                UPDATE factura f
                SET saldo = monto - pagado
                FROM (SELECT id_factura, SUM(monto) AS pagado
                    FROM pago
                    GROUP BY id_factura) AS sub
                WHERE f.id_factura = sub.id_factura;
                RAISE NOTICE 'Facturas actualizadas exitosamente';
            END;
        $BODY$ LANGUAGE plpgsql;

EJERCICIO 2:

    Realice los siguientes triggers analizando con qué acción (INSERT, UPDATE o DELETE), sobre cual tabla y
    en qué momento (BEFORE o AFTER) se deben disparar los mismos

        a) Cada vez que se agregue un registro en la tabla Tratamiento debe modificar el stock del
        medicamento recetado, de acuerdo a la cantidad de dosis indicada (stock = stock - dosis).

            CREATE OR REPLACE FUNCTION medicamento_stock_por_tratamiento() RETURNS TRIGGER AS $stock_por_tratamiento$
                BEGIN
                    UPDATE medicamento SET stock = stock - NEW.dosis
                    WHERE id_medicamento = NEW.id_medicamento;
                    RETURN NEW;
                END
            $stock_por_tratamiento$ LANGUAGE plpgsql

            CREATE TRIGGER stock_por_tratamiento AFTER INSERT ON tratamiento FOR EACH ROW
            EXECUTE PROCEDURE medicamento_stock_por_tratamiento();

        b) Cuando se agrega un registro a la tabla Compra debe actualizar el stock del medicamento
        comprado de acuerdo a la cantidad adquirida (stock = stock + cantidad)  

            CREATE OR REPLACE FUNCTION medicamento_stock_por_compras() RETURNS TRIGGER AS $stock_por_compras$
                BEGIN
                    UPDATE medicamento
                    SET stock = stock + NEW.cantidad
                    WHERE id_medicamento = NEW.id_medicamento;
                    RETURN NEW;
                END
            $stock_por_compras$ LANGUAGE plpgsql

            CREATE TRIGGER stock_por_compras AFTER INSERT ON compras FOR EACH ROW
            EXECUTE PROCEDURE medicamento_stock_por_compras();
        
        d) Cada vez que se borre un registro de la tabla Pago debe modificar los campos saldo y pagada de
        la tabla Factura, el campo saldo tendrá el valor que tenía más el valor del monto del pago
        eliminado de la factura correspondiente. La columna pagada deberá tener el valor ‘N’, debido a
        que no está cancelada la deuda.

            CREATE OR REPLACE FUNCTION factura_borra_pago() RETURNS TRIGGER AS $pago_elimina$
                DECLARE
                    monto_saldo float;
                BEGIN
                    UPDATE factura
                    SET saldo = saldo + OLD.monto, pagada = 'N'
                    WHERE id_factura = OLD.id_factura;
                    RETURN NEW;
                END;
            $pago_elimina$ LANGUAGE plpgsql

            CREATE TRIGGER pago_elimina AFTER DELETE ON pago FOR EACH ROW
            EXECUTE PROCEDURE factura_borra_pago();


        e) Cada vez que se modifique el stock de un medicamento, si el mismo es menor a 50 se debe
        agregar un registro en una nueva tabla llamada medicamento_reponer. La tabla
        medicamento_reponer debe tener los siguientes campos: id_medicamento, nombre,
        presentación y el stock del medicamento, también debe tener el último precio que se pagó por
        el mismo cuando se lo compró y a qué proveedor (solo el nombre). El trigger sólo debe activarse
        cuando se modifique el campo stock por un valor menor, en caso contrario, no debe realizar
        ninguna acción. Tenga en cuenta que puede darse el caso que el registro de dicho medicamento
        ya exista en la tabla medicamento_reponer, en tal caso solo debe actualizar el campo stock.

            CREATE OR REPLACE FUNCTION medicamento_bajo_stock()
            RETURNS TRIGGER AS $stock_bajo$
            DECLARE
                v_precio numeric(8,2);
                v_proveedor varchar(100);
            BEGIN
                IF NEW.stock < 50 THEN
                    IF NOT EXISTS (SELECT * FROM medicamento_reponer WHERE id_medicamento = NEW.id_medicamento) THEN
                        v_precio := (SELECT precio_unitario FROM compras WHERE id_medicamento = NEW.id_medicamento ORDER BY fecha DESC LIMIT 1);
                        v_proveedor := (SELECT proveedor FROM proveedores INNER JOIN compras USING(id_proveedor) WHERE id_medicamento = NEW.id_medicamento ORDER BY fecha DESC LIMIT 1);
                        INSERT INTO medicamento_reponer (id_medicamento, nombre, presentacion, stock, precio, proveedor)
                        VALUES (NEW.id_medicamento, NEW.nombre, NEW.presentacion, NEW.stock, v_precio, v_proveedor);
                    ELSE
                        UPDATE medicamento_reponer SET stock = NEW.stock WHERE id_medicamento = NEW.id_medicamento;
                    END IF;
                END IF;

                RETURN NEW;
            END
            $stock_bajo$ LANGUAGE plpgsql;

            CREATE TRIGGER stock_bajo AFTER UPDATE OF stock ON medicamento
            FOR EACH ROW WHEN (NEW.stock < OLD.stock) EXECUTE PROCEDURE medicamento_bajo_stock();
        

        f) Cada vez que se modifique el stock de un medicamento, solo si es por un valor mayor (cuando
        se hace una compra), debe buscar si existe el registro en la tabla medicamento_reponer, y si el
        nuevo valor del stock (stock + cantidad) es mayor a 50, debe eliminar el registro de dicha tabla,
        de lo contrario, debe modificar el campo stock de la tabla medicamento_reponer, por el nuevo
        stock de la tabla medicamento.

            CREATE OR REPLACE FUNCTION medicamento_bajo_stock()
            RETURNS TRIGGER AS $stock_bajo$
            DECLARE
                v_precio numeric(8,2);
                v_proveedor varchar(100);
            BEGIN
                IF NEW.stock > OLD.stock THEN
                    IF EXISTS(SELECT * FROM medicamento_reponer WHERE id = NEW.id_medicamento) THEN
                        DELETE FROM medicamento_reponer WHERE id = NEW.id_medicamento;
                    END IF;
                ELSE
                    IF NEW.stock + NEW.cantidad <= 50 THEN
                        UPDATE medicamento_reponer
                        SET stock = NEW.stock
                        WHERE id = NEW.id_medicamento;
                    END IF;
                END IF;
                
                RETURN NEW;
            END
            $stock_bajo$ LANGUAGE plpgsql;

            CREATE TRIGGER stock_bajo AFTER UPDATE OF stock ON medicamento
            FOR EACH ROW WHEN (NEW.stock <> OLD.stock) EXECUTE PROCEDURE medicamento_bajo_stock();


EJERCICIO 3:
    Realice las siguientes auditorías por trigger

        a) Auditoría de medicamento: debe registrar cualquier cambio realizado en la tabla medicamento
        en una nueva tabla llamada audita_medicamento cuyos campos serán: id (serial), usuario, fecha,
        operación, estado, más todos los campos de la tabla medicamento (id_medicamento,
        id_clasificacion, etc).
        Si se agrega o borra un registro, de guardar el nombre de usuario, la fecha y hora actual, como
        operación guardará una I ó D según corresponda, y en estado las palabras “alta” o “baja”.
        Si la operación realizada es una modificación debe guardar dos registros en la tabla
        audita_medicamento, uno con los valores antes de ser modificados y otro con los valores ya
        modificados, entonces, en el campo operación guardará U en ambos registros y para el registro
        “viejo” en el campo estado debe guardar la palabra “antes” y para el registro “nuevo” el estado
        debe decir “después”.

            CREATE TABLE audita_medicamento(
                id SERIAL,
                usuario VARCHAR(100),
                fecha DATE,
                id_medicamento INTEGER,
                medicamento VARCHAR(100),
                presentacion VARCHAR(100),
                precio NUMERIC(8,2),
                operacion CHAR,
                estado VARCHAR(10),
                PRIMARY KEY(id) );
            
            CREATE OR REPLACE FUNCTION medicamento_auditoria() RETURNS TRIGGER AS $audita_medicamento$
                BEGIN
                    IF (TG_OP = 'INSERT') THEN
                        INSERT INTO audita_medicamento VALUES
                        (DEFAULT, USER, NOW(), NEW.id_medicamento, NEW.nombre, NEW.presentacion,
                        NEW.precio, 'I','alta');
                        RETURN NEW;
                    END IF;

                    IF (TG_OP = 'DELETE') THEN
                        INSERT INTO audita_medicamento VALUES
                        (DEFAULT, USER, NOW(), OLD.id_medicamento, OLD.nombre, OLD.presentacion,
                        OLD.precio, 'D','baja');
                        RETURN OLD;
                    END IF;

                    IF (TG_OP = 'UPDATE') THEN
                        INSERT INTO audita_medicamento VALUES
                        (DEFAULT, USER, NOW(), OLD.id_medicamento, OLD.nombre, OLD.presentacion,
                        OLD.precio, 'U','antes');
                        INSERT INTO audita_medicamento VALUES
                        (DEFAULT, USER, NOW(), NEW.id_medicamento, NEW.nombre, NEW.presentacion,
                        NEW.precio, 'U','despues');
                        RETURN NEW;
                    END IF;
                END
            $audita_medicamento$ LANGUAGE plpgsql

            CREATE TRIGGER audita_medicamento
            AFTER INSERT OR DELETE OR UPDATE ON medicamento
            FOR EACH ROW EXECUTE PROCEDURE medicamento_auditoria();



        b) Auditoría de empleados: debe guardar los datos en una tabla llamada audita_empleado_sueldo
        cuyos campos serán: id (serial), usuario, fecha, id_empleado, dni, nombre y apellido del
        empleado, también debe tener un campo sueldo_v (sueldo antes de modificar), sueldo_n
        (sueldo después de modificar), un campo diferencia que llevará la diferencia entre el sueldo
        anterior y el nuevo, y un campo estado, en el cual se guardará “aumento”, si el sueldo nuevo es
        mayor al anterior o “descuento” en caso contrario.
        Esta auditoría sólo se debe ejecutar en caso que se realice una modificación en el sueldo del
        empleado, cualquier otra operación realizada en la tabla Empleado debe ser ignorada por esta
        auditoría.

            CREATE TABLE audita_empleado(
                id SERIAL,
                usuario VARCHAR(100),
                fecha DATE,
                id_empleado INTEGER,
                dni VARCHAR(8),
                nombre VARCHAR(100),
                apellido VARCHAR(100),
                sueldo_v NUMERIC(9,2),
                sueldo_n NUMERIC(9,2),
                diferencia NUMERIC(9,2),
                estado VARCHAR(10),
                PRIMARY KEY(id)
            );

            CREATE OR REPLACE FUNCTION empleado_audita_sueldo() RETURNS TRIGGER AS $audita_sueldo$
                BEGIN
                    INSERT INTO audita_empleado VALUES
                        (DEFAULT, USER, NOW(), OLD.id_empleado,
                        (SELECT dni FROM personas WHERE id_persona = OLD.id_empleado),
                        (SELECT nombre FROM personas WHERE id_persona = OLD.id_empleado),
                        (SELECT apellido FROM personas WHERE id_persona = OLD.id_empleado),
                        OLD.sueldo, NEW.sueldo, ABS(NEW.sueldo - OLD.sueldo),
                        CASE
                            WHEN (NEW.sueldo > OLD.sueldo) THEN 'aumento'
                            ELSE 'descuento'
                        END);
                    RETURN NEW;
                END
            $audita_sueldo$ LANGUAGE plpgsql
            CREATE TRIGGER audita_sueldo AFTER UPDATE OF sueldo ON empleado
            FOR EACH ROW WHEN (OLD.sueldo <> NEW.sueldo) EXECUTE PROCEDURE
            empleado_audita_sueldo();

        c) Auditoría de tablas: debe guardar los datos en una nueva tabla llamada audita_tablas_sistema
        cada vez que se elimine una consulta, un estudio realizado o un tratamiento cuyos campos serán:
        id (serial), usuario y fecha, el id del paciente, la fecha en la que se realizó la consulta, estudio o
        indicación del tratamiento y el nombre de la tabla a la que corresponde el registro borrado.
        Ante cualquier otra acción en estas tablas, esta auditoría no se debe ejecutar. También debe
        guardar el registro borrado en una tabla llamada estudio_borrado, consulta_borrada o
        tratamiendo_borrado, según corresponda, los campos de las nuevas tablas serán los mismos
        que los de las tablas originales.
        
*/