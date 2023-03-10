alter procedure sp_bg_registropagos
	@codigoconvenio int, @fechatransaccion date, @codigotipobusqueda varchar(3), @codigocliente varchar(30),
	@facturanitci int, @facturanombre varchar(30), @nrotransaccion int, @usuario varchar(30), @abreviatura varchar(20), @nrocuota int, 
	@codigomoneda varchar(3), @montoneto decimal(15,2), @datosadicionales varchar(30), @nromovbd11 varchar(30)
as
begin
	insert into BGPagos (fecreg, codigoconvenio, fechatransaccion, codigotipobusqueda, codigocliente, facturanitci, facturanombre, nrotransaccion, 
	usuario, abreviatura, nrocuota, codigomoneda, montoneto, datosadicionales, nromovbd11) values (getdate(), @codigoconvenio, @fechatransaccion, @codigotipobusqueda, 
	@codigocliente, @facturanitci, @facturanombre, @nrotransaccion, @usuario, @abreviatura, @nrocuota, @codigomoneda, @montoneto, @datosadicionales, @nromovbd11)
end