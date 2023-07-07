/*
Ejercicio nro. 1:
    Realice las siguientes modificaciones en las tablas indicadas:

    Modifique el tipo de dato del campo dosis (character varying) de la tabla Tratamiento por el tipo integer.

        ALTER TABLE tratamiento 
        ALTER COLUMN dosis 
        SET DATA TYPE integer USING dosis::integer;
    

    Realice una función que modifique el campo saldo de la tabla factura, el mismo debe ser la diferencia entre el monto de la factura y los pagos realizados para dicha factura.

        CREATE OR REPLACE FUNCTION fn_modifica_saldos_factura()
        RETURNS VOID AS $$
            BEGIN
                UPDATE factura f
                SET saldo = monto - pagado
                FROM (SELECT id_factura, SUM(monto) AS pagado
                    FROM pago
                    GROUP BY id_factura) AS sub;
                WHERE f.id_factura = sub.id_factura;
                IF FOUND THEN
                    RAISE NOTICE 'Monto de Facturas Actualizado con Exito';
                ELSE 
                    RAISE EXCEPTION 'FALLO en la actualizacion del monto de las facturas';
                END IF;
            END;
        $$ LANGUAGE plpgsql;            



Ejercicio nro. 2:

    Realice los siguientes triggers analizando con qué acción (INSERT, UPDATE o DELETE), sobre cual tabla y
    en qué momento (BEFORE o AFTER) se deben disparar los mismos:
    
    a) Cada vez que se agregue un registro en la tabla Tratamiento debe modificar el stock del
    medicamento recetado, de acuerdo a la cantidad de dosis indicada (stock = stock - dosis).
        
        CREATE OR REPLACE FUNCTION fn_modificar_stock_medicamento()
        RETURNS TRIGGER AS $modificar_stock_medicamento$ 
        BEGIN
            UPDATE medicamento
            SET stock = stock - NEW.dosis
            WHERE id_medicamento = NEW.id_medicamento;
            RETURN NEW;
        END;
        $modificar_stock_medicamento$ LANGUAGE plpgsql;

        CREATE TRIGGER modificar_stock_medicamento AFTER INSERT ON tratamiento FOR EACH ROW 
        EXECUTE PROCEDURE fn_modificar_stock_medicamento();
		
		INSERT into tratamiento 
		VALUES (1, 1, '2004-06-11', 1, 'Nazarettt', NULL, 10, NULL)
		
		select * from medicamento 
		WHERE id_medicamento = 1
		stock = 45
		nuevostock = 35
    

    b) Cuando se agrega un registro a la tabla Compra debe actualizar el stock del medicamento
    comprado de acuerdo a la cantidad adquirida (stock = stock + cantidad).

        
        CREATE OR REPLACE FUNCTION fn_stock_medicamento_cantidad()
        RETURNS TRIGGER AS $$
            BEGIN
                UPDATE medicamento 
                SET stock = stock + NEW.cantidad
                WHERE id_medicamento = NEW.id_medicamento;
                RETURN NEW;
            END;
        $$ LANGUAGE plpgsql;

        CREATE TRIGGER tr_restock_x_compras AFTER INSERT ON compra FOR EACH ROW
        EXECUTE PROCEDURE fn_stock_medicamento_cantidad();
		
		INSERT INTO compra
		VALUES (1, 1, '2002-11-01', 1, 100.00, 100)
		
		select * from medicamento
		where id_medicamento = 1
		stock viejo: 35
		stock nuevo: 135
    

     c) Cada vez que se realice un pago debe modificar los campos saldo y pagada de la tabla Factura.
    El campo saldo es la diferencia entre el monto de la factura y la suma de los montos de la tabla
    Pago de la factura correspondiente. La columna pagada será ‘S’ si el saldo es 0 (cero) y ‘N’ en
    caso contrario.

        CREATE OR REPLACE FUNCTION fn_modifcar_factura_saldo_y_pagada()
        RETURNS TRIGGER AS $pago_nuevo$
            BEGIN
                UPDATE factura f
                SET saldo = monto - pagado
                FROM (SELECT id_factura, SUM(monto) AS pagado
                    FROM pago
                    GROUP BY id_factura) AS sub
                WHERE f.id_factura = sub.id_factura;
                IF (SELECT saldo FROM factura WHERE id_factura = NEW.id_factura) <= 0 THEN
                    UPDATE factura
                    SET pagada = 'S'
                    WHERE id_factura = NEW.id_factura;
                ELSE 
                    UPDATE factura
                    SET pagada = 'N'
                    WHERE id_factura = NEW.id_factura;
                END IF;
                RETURN NEW;
            END;
        $pago_nuevo$ LANGUAGE plpgsql;

        CREATE TRIGGER pago_nuevo AFTER INSERT ON pago FOR EACH ROW
        EXECUTE PROCEDURE fn_modifcar_factura_saldo_y_pagada();



     d) Cada vez que se borre un registro de la tabla Pago debe modificar los campos saldo y pagada de
    la tabla Factura, el campo saldo tendrá el valor que tenía más el valor del monto del pago
    eliminado de la factura correspondiente. La columna pagada deberá tener el valor ‘N’, debido a
    que no está cancelada la deuda

        CREATE OR REPLACE FUNCTION fn_pago_borrado()
        RETURNS TRIGGER AS $pago_borrado$
        BEGIN 
            UPDATE factura
            SET saldo = saldo + OLD.monto,
                pagada = 'N'
            WHERE id_factura = OLD.id_factura;
			RETURN OLD;
        END;
        $pago_borrado$ LANGUAGE plpgsql;

        CREATE TRIGGER pago_borrado AFTER DELETE ON pago FOR EACH ROW
        EXECUTE PROCEDURE fn_pago_borrado();
		
		Select * from factura
		where id_factura = 18;
		INNER JOIN pago USING(id_factura)
		
		saldo = 808.00:  monto = 721
		
		delete from pago 
		where id_factura = 18 AND fecha = '2020-12-28' AND monto = 721.00
		saldo luego de la eliminacion = 1529.00

    

    e) Cada vez que se modifique el stock de un medicamento, si el mismo es menor a 50 se debe
    agregar un registro en una nueva tabla llamada medicamento_reponer. La tabla
    medicamento_reponer debe tener los siguientes campos: id_medicamento, nombre,
    presentación y el stock del medicamento, también debe tener el último precio que se pagó por
    el mismo cuando se lo compró y a qué proveedor (solo el nombre). El trigger sólo debe activarse
    cuando se modifique el campo stock por un valor menor, en caso contrario, no debe realizar
    ninguna acción. Tenga en cuenta que puede darse el caso que el registro de dicho medicamento
    ya exista en la tabla medicamento_reponer, en tal caso solo debe actualizar el campo stock.
        
        CREATE OR REPLACE FUNCTION fn_crear_medicamento_reponer()
        RETURNS TRIGGER AS $$
            DECLARE
                v_nombre_proveedor CHARACTER VARYING;
                v_ultimo_precio NUMERIC(10,2);
				v_id_medicamento_reponer INT;
            BEGIN
                CREATE TABLE IF NOT EXISTS public.medicamento_reponer
                (
                    id_medicamento integer NOT NULL,
                    nombre character varying(100) NOT NULL,
                    presentacion character varying(100),
                    stock integer NOT NULL,
                    ultimo_precio numeric(10, 2),
                    nombre_proveedor character varying(100),
                    PRIMARY KEY (id_medicamento),
                    CONSTRAINT fk_id_medicamento FOREIGN KEY (id_medicamento)
                        REFERENCES public.medicamento (id_medicamento) MATCH SIMPLE
                        ON UPDATE CASCADE
                        ON DELETE CASCADE
                        NOT VALID
                );
				
				SELECT id_medicamento INTO v_id_medicamento_reponer FROM medicamento_reponer 
				WHERE id_medicamento = NEW.id_medicamento;
				
                IF v_id_medicamento_reponer IS NULL THEN
                    IF NEW.stock < 50 THEN
                        SELECT proveedor INTO v_nombre_proveedor FROM proveedor 
                        INNER JOIN compra USING(id_proveedor)
                        WHERE id_medicamento = NEW.id_medicamento
                        ORDER BY fecha DESC
                        LIMIT 1;

                        SELECT precio_unitario INTO v_ultimo_precio FROM compra
                        WHERE id_medicamento = NEW.id_medicamento
                        ORDER BY fecha DESC
                        LIMIT 1;

                        INSERT INTO medicamento_reponer
                        VALUES (NEW.id_medicamento, NEW.nombre, NEW.presentacion, NEW.stock, v_ultimo_precio, v_nombre_proveedor);
                    END IF;
                ELSE    
                    UPDATE medicamento_reponer
                    SET stock = NEW.stock
                    WHERE id_medicamento = NEW.id_medicamento;
                END IF;
				RETURN NEW;
            END;
            $$ LANGUAGE plpgsql;

            CREATE TRIGGER crear_medicamento_reponer AFTER UPDATE OF stock ON medicamento
            FOR EACH ROW WHEN (NEW.stock < OLD.stock)
            EXECUTE PROCEDURE fn_crear_medicamento_reponer();
            
            select * from medicamento_reponer
            select * from medicamento
            where id_medicamento = 26
            
            UPDATE medicamento 
            set stock = 45
            WHERE id_medicamento = 26
        
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


        f) Cada vez que se modifique el stock de un medicamento, solo si es por un valor mayor (cuando
        se hace una compra), debe buscar si existe el registro en la tabla medicamento_reponer, y si el
        nuevo valor del stock (stock + cantidad) es mayor a 50, debe eliminar el registro de dicha tabla,
        de lo contrario, debe modificar el campo stock de la tabla medicamento_reponer, por el nuevo
        stock de la tabla medicamento.

            CREATE OR REPLACE FUNCTION fn_borrar_medicamento_reponer()
            RETURNS TRIGGER AS $$
                DECLARE
                    v_stock INT;
                    v_id_medicamento_reponer INT;
                BEGIN
                    SELECT stock INTO v_stock FROM medicamento_reponer 
                    WHERE id_medicamento = NEW.id_medicamento;
                    
                    IF (v_stock + NEW.cantidad) > 50 THEN
                        SELECT id_medicamento INTO v_id_medicamento_reponer FROM medicamento_reponer
                        WHERE id_medicamento = NEW.id_medicamento;
                        IF v_id_medicamento_reponer IS NOT NULL THEN 
                            DELETE FROM medicamento_reponer
                            WHERE id_medicamento = v_id_medicamento_reponer;
                        END IF;
                    ELSE 
                        UPDATE medicamento_reponer
                        SET stock = v_stock + NEW.cantidad
                        WHERE id_medicamento = NEW.id_medicamento;
                    END IF;

                END;
            $$ LANGUAGE plpgsql;

            CREATE TRIGGER borrar_medicamento_reponer AFTER UPDATE compra 

            CREATE TRIGGER crear_medicamento_reponer AFTER UPDATE OF stock ON medicamento
            FOR EACH ROW WHEN (NEW.stock < OLD.stock)
            EXECUTE PROCEDURE fn_crear_medicamento_reponer();


                aqui me confunde por que tabla se activa el trigger:
                PORQUE POR UNA INSERCION DE UNA COMPRA NO DEVERIA FUNCIONAR TAMBIEN.? O ES INDISTINTO.?

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
        
    
    Ejercicio nro. 3:
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
        
        CREATE TABLE public.auditoria_medicamento
        (
            id_auditoria serial NOT NULL,
            "usuario " character varying(100) NOT NULL,
            fecha date NOT NULL,
            operacion "char",
            estado character varying(100),
            id_medicamento integer NOT NULL,
            id_clasificacion integer,
            id_laboratorio integer,
            nombre character varying(50),
            CONSTRAINT id_auditoria PRIMARY KEY (id_auditoria),
            CONSTRAINT id_medicamento FOREIGN KEY (id_medicamento)
                REFERENCES public.medicamento (id_medicamento) MATCH SIMPLE
                ON UPDATE CASCADE
                ON DELETE CASCADE
                NOT VALID,
            CONSTRAINT id_laboratorio FOREIGN KEY (id_laboratorio)
                REFERENCES public.laboratorio (id_laboratorio) MATCH SIMPLE
                ON UPDATE CASCADE
                ON DELETE CASCADE
                NOT VALID,
            CONSTRAINT id_clasificacion FOREIGN KEY (id_clasificacion)
                REFERENCES public.clasificacion (id_clasificacion) MATCH SIMPLE
                ON UPDATE CASCADE
                ON DELETE CASCADE
                NOT VALID
        );

        ALTER TABLE IF EXISTS public.auditoria_medicamento
            OWNER to postgres;


            CREATE OR REPLACE FUNCTION fn_auditoria_medicamentos()
            RETURNS TRIGGER AS $auditoria_medicamentos$
                BEGIN
                    IF (TG_OP = 'INSERT') THEN
                        INSERT INTO auditoria_medicamento 
                        VALUES (DEFAULT, USER, NOW(), 'I', 'alta', NEW.id_medicamento, NEW.id_clasificacion, NEW.id_laboratorio, NEW.nombre);
                        RETURN NEW;
                    END IF;

                    IF (TG_OP = 'DELETE') THEN
                        INSERT INTO auditoria_medicamento 
                        VALUES (DEFAULT, USER, NOW(), 'D', 'baja', OLD.id_medicamento, OLD.id_clasificacion, OLD.id_laboratorio, OLD.nombre);
                        RETURN OLD;
                    END IF;

                    IF (TG_OP = 'UPDATE') THEN
                        INSERT INTO auditoria_medicamento 
                        VALUES (DEFAULT, USER, NOW(), 'U', 'antes', OLD.id_medicamento, OLD.id_clasificacion, OLD.id_laboratorio, OLD.nombre);

                        INSERT INTO auditoria_medicamento 
                        VALUES (DEFAULT, USER, NOW(), 'U', 'despues', NEW.id_medicamento, NEW.id_clasificacion, NEW.id_laboratorio, NEW.nombre);
                        RETURN NEW;
                    END IF;
                END;
            $auditoria_medicamentos$ LANGUAGE plpgsql;

            CREATE TRIGGER auditoria_medicamentos 
            AFTER INSERT OR DELETE OR UPDATE ON medicamento
            FOR EACH ROW EXECUTE PROCEDURE fn_auditoria_medicamentos();
			
			update medicamento 
			set stock = 100
			where id_medicamento = 1
			
			select * from auditoria_medicamento
			delete from auditoria_medicamento
			where id_medicamento = 1
    
*/      
