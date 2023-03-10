create procedure sp_bg_actualizabe09
	@nrocobza nvarchar(20), 
	@mon decimal(15,2), 
	@cuo int, 
	@int decimal(15,2), 
	@i int, 
	@intorg decimal(15,2), 
	@cap decimal(15,2), 
	@nromov varchar(20), 
	@idtran int,
	@vinteresp decimal(15,2) output,
	@exito int output
as
begin
	declare @intx decimal(15,2), @salintx decimal(15,2), @getcaporg decimal(15,2), @getintorg decimal(15,2)
	select @vinteresp=0, @salintx=0
	if (@int - @intorg) > 0
	begin
		select @intx = (@int - @intorg)
	end
	else
	begin
		select @salintx = (@intorg - @int)
		select @int = 0
	end
	begin try
	set xact_abort on
	begin tran
		if @i = 1
		begin
			if @intorg = 0
			begin
				if @cap = 0
				begin
					update be09cuota set fecmov=convert(date, getdate()), saldeu=0, capamr=@mon, intorg=@intx where nromov=@nromov and nrocuo=@cuo
				end
				else
				begin
					update be09cuota set fecmov=convert(date, getdate()), saldeu=0, capamr=capamr+@mon, intorg=@intorg where nromov=@nromov and nrocuo=@cuo
				end
			end
			else
			begin
				if @cap = 0
				begin
					update be09cuota set fecmov=convert(date, getdate()), saldeu=0, capamr=@mon, intorg=intorg+@intx where nromov=@nromov and nrocuo=@cuo
				end
				else
				begin
					update be09cuota set fecmov=convert(date, getdate()), saldeu=0, capamr=capamr+@mon, intorg=intorg+@intx where nromov=@nromov and nrocuo=@cuo
				end
			end
			exec sp_bg_getcapitalorg @nromov, @cuo, @getcaporg output
			exec sp_bg_getinteresorg @nromov, @cuo, @getintorg output
			insert into Be12cuoac (nromov, nrocuo, capamr, intamr, caporg, intorg, ntaorg, estado) values 
			(@nrocobza, @cuo, @mon, @Intx, @getcaporg, @getintorg, @idtran, 0)

			select @vinteresp = @vinteresp + (@int - @intorg)
		end
		if @i = 2
		begin
			if ((@mon + @salintx) - @intx) > 0
			begin
				if @intorg = 0
				begin
					if @cap = 0
					begin
						update be09cuota set fecmov=convert(date, getdate()), saldeu=(saldeu - (@mon - @intx)), capamr=(@mon - @intx), intorg=@intorg where nromov=@nromov and nrocuo=@cuo
					end
					else
					begin
						update be09cuota set fecmov=convert(date, getdate()), saldeu=(saldeu - (@mon - @intx)), capamr=(capamr+(@mon - @intx)), intorg=@intorg where nromov=@nromov and nrocuo=@cuo
					end
				end
				else
				begin
					if @cap = 0
					begin
						update be09cuota set fecmov=convert(date, getdate()), saldeu=(saldeu -(@mon-@intx)), capamr=(@mon-@intx), intorg=intorg+@intx where nromov=@nromov and nrocuo=@cuo
					end
					else
					begin
						update be09cuota set fecmov=convert(date, getdate()), saldeu=(saldeu-((@mon + @salintx) - @intx)), capamr=capamr+((@mon + @salintx) - @intx), intorg=intorg+@intx where nromov=@nromov and nrocuo=@cuo
					end
				end
				exec sp_bg_getcapitalorg @nromov, @cuo, @getcaporg output
				exec sp_bg_getinteresorg @nromov, @cuo, @getintorg output
				insert into Be12cuoac (nromov, nrocuo, capamr, intamr, caporg, intorg, ntaorg, estado) values 
				(@nrocobza, @cuo, ((@mon + @salintx) - @intx) , @intx, @getcaporg, @getintorg, @idtran, 0)
				select @vinteresp = @vinteresp + (@int - @intorg)
			end
			else
			begin
				if @intorg = 0
				begin
					update be09cuota set fecmov=convert(date, getdate()), intorg=@mon where nromov=@nromov and nrocuo=@cuo
				end
				else
				begin
					update be09cuota set fecmov=convert(date, getdate()), intorg=intorg+@mon where nromov=@nromov and nrocuo=@cuo
				end
				exec sp_bg_getcapitalorg @nromov, @cuo, @getcaporg output
				exec sp_bg_getinteresorg @nromov, @cuo, @getintorg output
				insert into Be12cuoac (nromov, nrocuo, capamr, intamr, caporg, intorg, ntaorg, estado) values 
				(@nrocobza, @cuo, 0, @mon, @getcaporg, @getintorg, @idtran, 0)
				select @vinteresp = @vinteresp + (@mon - @intorg)
			end
		end
		if @i =3
		begin
			if @intorg = 0
			begin
				if @cap = 0
				begin
					update be09cuota set fecmov=convert(date, getdate()), saldeu=0, capamr=@mon, intorg=@intx where nromov=@nromov and nrocuo=@cuo
				end
				else
				begin
					update be09cuota set fecmov=convert(date, getdate()), saldeu=0, capamr=capamr+@mon, intorg=@intx where nromov=@nromov and nrocuo=@cuo
				end
			end
			else
			begin
				if @cap = 0
				begin
					update be09cuota set fecmov=convert(date, getdate()), saldeu=0, capamr=@mon, intorg=intorg+@intx where nromov=@nromov and nrocuo=@cuo
				end
				else
				begin
					update be09cuota set fecmov=convert(date, getdate()), saldeu=0, capamr=capamr+@mon, intorg=intorg+@intx where nromov=@nromov and nrocuo=@cuo
				end
			end
			exec sp_bg_getcapitalorg @nromov, @cuo, @getcaporg output
			exec sp_bg_getinteresorg @nromov, @cuo, @getintorg output
			insert into Be12cuoac (nromov, nrocuo, capamr, intamr, caporg, intorg, ntaorg, estado) values 
			(@nrocobza, @cuo, @mon, @intx, @getcaporg, @getintorg, @idtran, 0)
			select @vinteresp = @vinteresp + @intx
		end
		commit tran
		select @exito=1
		return @vinteresp
		return @exito
	end try
	begin catch
		rollback tran
		select @exito=0
		return @vinteresp
		return @exito
	end catch
end