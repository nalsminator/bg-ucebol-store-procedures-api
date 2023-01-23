create procedure sp_bg_deuda
	@CodigoCliente nvarchar(20),
	@nromov1 nvarchar(20),
	@valor decimal(15,2) output
as
begin
	select @valor=sum(saldeu) from be09cuota where saldeu>0 and nromov=@nromov1
	return @valor
end
