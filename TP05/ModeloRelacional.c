/**
 

   Modelo Entidad Relacion: 
   
   *Los campos entre corchetes en realidad son campos compuestos en el entidad relacion.
   *los campos que tienen corches al final de su nombre son arreglos (campos multivaluados en E-R)

    Cunado estoy pasando del entidad realcion al relacional para implemntar con el modelo objeto relacional y quiero generar la herencia se representa de la misma manera que en el entidad relacion con la diferencia de que ya no se puede optar por cualquiera de las 3 formas de representar... sino que si o si va la primera (en la que se crea la tabla para el objeto padre, y otras tablas para los objetos hijos con sus atributos espesificos...)


        Persona(id_persona, nombre dni, {domicilio}, provincia, e-mail[], telefono[])
                   PK

        empleado(id_empleado, cargo, legajo, sueldo, sector)
                    PK-FK

        cliente(id_cliente, cta_cte)
                  PK-FK

        pedido(id_pedido, fecha, total, id_empleado, id_cliente)
                    PK                       FK          FK

        producto(id_producto, nombre, descripcion, precio, categoria, proveedor[])
                      PK

        tiene(idproducto, id_pedido, cantidad, precio)
                        P K




*/