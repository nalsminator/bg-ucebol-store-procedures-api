create procedure sp_bg_listaclientes
 @TipoConsulta nvarchar(1),
 @CodigoTipoBusqueda nvarchar(3),
 @CodigoCliente nvarchar(30)
as
begin
 declare @idgest int, @idperi int, @estado int, @estado2 int
 /*todos*/
 if (@TipoConsulta='T') begin select @estado=0, @estado2=0 end
 /*con deuda*/
 if (@TipoConsulta='D') begin select @estado=3, @estado2=7 end
 /*por carnet*/
 if (@CodigoTipoBusqueda='DID')
 begin
	select top 1 @idgest=idgest, @idperi=idperi from Cc08inscriC join Ba02Perso on idestu=codreg
	where numide like @CodigoCliente+'%' and Cc08inscriC.estado in (0, 3) order by Cc08inscriC.fecreg desc
	select distinct @CodigoTipoBusqueda, idestu, desper, Cc01perioC.sigla, Ca02carre.sigla from cc08inscric 
	join Ba02Perso on codreg=idestu 
	join Ca02carre on Ca02carre.idcarr=cc08inscric.idcarr
	join Cc01perioC on cc08inscric.idgest=Cc01perioC.idgest and cc08inscric.idperi=Cc01perioC.idperi 
	where cc08inscric.idgest=@idgest and cc08inscric.idperi=@idperi and numide like @CodigoCliente 
	and codreg in (select coddeu from Be08enccc where estado in (@estado, @estado2))
 end 
 /*por registro*/
 if (@CodigoTipoBusqueda='COD')
 begin
	select top 1 @idgest=idgest, @idperi=idperi from Cc08inscriC where idestu like @CodigoCliente+'%' and estado in (0, 3) order by fecreg desc
	select distinct @CodigoTipoBusqueda, idestu, desper, Cc01perioC.sigla, Ca02carre.sigla from cc08inscric 
	join Ba02Perso on codreg=idestu 
	join Ca02carre on Ca02carre.idcarr=cc08inscric.idcarr
	join Cc01perioC on cc08inscric.idgest=Cc01perioC.idgest and cc08inscric.idperi=Cc01perioC.idperi 
	where cc08inscric.idgest=@idgest and cc08inscric.idperi=@idperi and idestu like @CodigoCliente+'%' 
	and codreg in (select coddeu from Be08enccc where estado in (@estado, @estado2))
 end
end