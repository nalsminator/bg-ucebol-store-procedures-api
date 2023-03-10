create procedure sp_bg_grabarbe08
	@deuda decimal(15,2), @monto decimal(15,2), @nromov nvarchar(20), @gestion int,
	@idestu nvarchar(20), @idtran int, @exbe08 int output
as
begin
	begin try
	set xact_abort on
	begin tran
		if (@deuda - @monto)<=0
		begin
			update be08enccc set totamr=totamr+@monto, estado=0, ultpag=convert(date, getdate()) where nromov=@nromov
			update cc08inscric set estado=0 where idestu=@idestu and idtran=@idtran and idgest=@gestion
			update cc21regegr set estado=0 where idestu=@idestu and nrocor=@idtran
		end
		else
		begin
			update be08enccc set totamr=totamr+@monto, estado=3, ultpag=convert(date, getdate()) where nromov=@nromov
			update cc08inscric set estado=3 where idestu=@idestu and idtran=@idtran and idgest=@gestion
			update cc21regegr set estado=7 where idestu=@idestu and nrocor=@idtran
		end
		commit tran
		select @exbe08=1
		return @exbe08
	end try
	begin catch
		ROLLBACK TRAN  
		select @exbe08=0
		return @exbe08
	end catch
end