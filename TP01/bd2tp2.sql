/*
!)

2- a) En la tabla persona es mejor tener un indice por apellido y nombre, ya que por lo general los apellidos tendran menor recurrencia
	que los nombres.
	
b) Se podrian crear dos indices para la tabla de factura, uno que apunte a la columna de pagada donde sea 'N' y otro indice que apunte a
	la columna donde pagada sea distinto de 'N'

c) En la tabla de habitacion es mejor tener un indice por piso y numero, ya que una vez ubicado el piso se podra ubicar la habitacion, si
	lo hacemos de la otra manera no tendria sentido puesto que un conjunto de habitaciones se encuentran en un mismo piso.
	
d) No es conveniente tener indices en la tabla de especialidad ya que contiene pocas tuplas y ellas ya tienen un identificador propio.

e) Podria crear un indice usando el apellido y nombre del paciente y asi luego de obtener el paciente hacer la consulta para obtener 
	sus consultas medicas.

f)Podriamos resolverlo creando un indice parcial que nos filtre las especialidades de "odontologo"



PUNTO 4

		a) Tabla carnets
		-idCarnet: integer
		-idContribuyente: integer
		-emitido: date
		-vencido: date
		-importeNeto:  numeric(6,2)
		-idRecibo: integer


		Tabla Contribuyentes
		-idContribuyente: integer
		-cuilCuit: integer
		-domicilioFiscal: varchar(40)

		Tabla personas
		-idPersona: integer
		-nombre: varcha(10)
		-apellido: varchar(15)
		-documento: integer
		-fechaNacimiento: date
		-sexo: char(1) (M = masculino, F = femeninto, X = otro) 
		-telefono: integer
		-localidad: varchar(30)
		-provincia: varchar(30)
		-baja: bool


		Tabla recibos
		-idRecibo: integer
		-idContribuyente: integer
		-idTipoImpuesto: integer
		-Fecha: date
		-importeNeto: real(9,2)
		-importePagado: real(9,2)
		-intereses: real(6,2)
		-descuento: real(6,2)
		-anulado: bool

		Tabla tiposImpuestos
		-idImpuesto: integer
		-tipoImpesto: varchar(20)
		-cuotas: smallInteger

		Tabla tiposCarnet
		-idTipoCarnet: integer
		-categoria: varchar(20)
		-descripcion: varchar(80)
		-vigencia: date
		-monto: real(6,2)

		





*/