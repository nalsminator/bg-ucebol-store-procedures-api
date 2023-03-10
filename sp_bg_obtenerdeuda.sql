create procedure sp_bg_obtenerdeuda
	@tipo int,
	@CodigoCliente nvarchar(20),
	@nromov1 nvarchar(20) null
as
begin
	declare @interes decimal(15,2), @grpcta int, @nromov nvarchar(20), @gestion int, @AbreviaturaConceptoPago varchar(3)
	if @tipo=1
	begin
		select grpcta, nromov, codges, abreviatura from be08enccc 
		join ConceptosPago on Be08enccc.grpcta=ConceptosPago.cod 
		where be08enccc.estado in (3, 7) and coddeu like @CodigoCliente+'%'
	end
	
	if @tipo=2
	begin
		select @grpcta=grpcta, @nromov=nromov, @gestion=codges, @AbreviaturaConceptoPago=abreviatura from be08enccc 
		join ConceptosPago on Be08enccc.grpcta=ConceptosPago.cod 
		where be08enccc.nromov=@nromov1

		select top 1 @interes=cast(convert(decimal(10,2),(select case when getdate() > fecven then (((SELECT DATEDIFF(day, fecven, getdate()) * 0.05) * round(saldeu, 2)) / 100) else 0 end)) as decimal(15,2))
		from be09cuota where nromov=@nromov1 and saldeu>0 order by nrocuo asc

		select top 1 nromov, @gestion as Gestion, @AbreviaturaConceptoPago as AbreviaturaConceptoPago, 1 as Prioridad, nrocuo as NroCuota, month(fecven) as MesPeriodo, year(fecven) as AnioPeriodo, fecven as FechaVencimiento, 'BOB' as CodigoMoneda,
		Cast(CONVERT(DECIMAL(15,2),saldeu) as decimal(15,2)) as MontoConcepto, @interes as MontoMulta, 0 as MontoDescuento, (saldeu + @interes) as MontoNeto
		from be09cuota where nromov=@nromov1 and saldeu>0 order by nrocuo asc
	end
end
