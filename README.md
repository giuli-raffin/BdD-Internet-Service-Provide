# Base de Datos: Wireless Internet Service Provider
### El trabajo  consiste en la resolución de un conjunto de controles y servicios sobre una base de datos que mantiene un sistema para un Wireless Internet Service Provider.
- La empresa posee clientes dispersos en diferentes localidades de la provincia; adicionalmente cada cliente puede poseer varios puntos de conexión (equipos).
- De cada punto de conexión a la red, es necesario registrar las características del equipo: nombre (marca, modelo, etc.), tipo de conexión (PPTP, PPPoE) y tipo de asignación IP (DHCP, IP FIJA).
- Es necesario mantener todos los datos de los clientes, a fin de poder registrar los servicios que deberán ser abonados cada mes. En cualquier momento el cliente puede solicitar la baja, quedando inactivo, siempre y cuando no adeude ningún servicio.
- El sistema tiene un catálogo de todos los servicios que ofrece. Estos son de 2 tipos: unos que se cobran en forma periódica y otros que se cobran por única vez cuando se realizan. Por ejemplo, son servicios periódicos los servicios de internet de diferentes anchos de banda, direcciones IP, antivirus, los cuales tendrán un importe por mes; entre los no periódicos están incluidos los de reparación de equipos y el servicio técnico al domicilio de instalación, entre otros.
- El sistema contempla la facturación de los servicios que provee la empresa, estos son: los servicios de cobro periódico y de cobro por única vez.
- El sistema maneja comprobantes de varios tipos, entre los cuales se destacan los siguientes: facturas, recibos y remitos.
  - Una Factura es el documento que se le da al cliente detallando un cobro por parte de la empresa, cada línea de ésta detalla lo que se le está cobrando.
  - Un Recibo es el comprobante que se le da al cliente por el dinero que ingresa a la empresa; este dinero junto con las facturas conformarán la cuenta corriente del mismo. Es decir que, para saber si un cliente debe o no debe, en forma general se deberían sumar todas las facturas y por otro lado todos los recibos, y evaluar la diferencia (el cliente puede deber, no deber, e inclusive tener saldo a su favor).
  - Los Remitos son documentos que se entregan a los clientes por trabajos realizados que luego serán facturados. Por ejemplo, si un técnico va al domicilio de instalación del servicio, generaría un remito potencialmente con dos líneas, una con la visita en sí y otra con la reparación que hizo. El costo de cada servicio deberá estar especificado en el catálogo de servicios.
- El proceso de facturación debe ser el siguiente: a principio de mes se toman todos los servicios periódicos que tenga cada cliente, junto con los remitos generados en el mes anterior y confeccionar una o varias facturas. Vale la pena aclarar que, cuando se genera la factura, los datos son copiados desde los remitos, servicios, etc. a la factura en sí; esto es debido a que, si no se hiciera así, un cambio en el catálogo de servicios produciría un cambio en todas las facturas.