create procedure sp_bg_nitnombre
	@CodigoCliente nvarchar(20)
as
begin
	declare @reg nvarchar(20)
	select @reg=codreg from Ba02Perso where codreg like @CodigoCliente+'%'
	select nit, nombre from Bd28Cliente where idestu=@reg
end