create procedure sp_bg_grabarbe09
	@nromov nvarchar(20), 
	@periodo int, 
	@monto decimal(15,2),
	@deuda decimal(15,2), 
	@interes decimal(15,2),
	@nrocob nvarchar(20),
	@idtran int,
	@resaldo decimal(15,2) output,
	@vinteresp decimal(15,2) output
as
begin
	declare @saldeu decimal(15,2), 
	@capamr decimal(15,2), 
	@nrocuo int, 
	@intorg decimal(15,2), 
	@caporg decimal(15,2), 
	@fecven date,
	@vcap decimal(15,2),
	@nvoint decimal(15,2),
	@salint decimal(15,2),
	@nvomon decimal(15,2),
	@getinteres decimal(15,2)

	select @resaldo=0
		
	select top 1 @saldeu=saldeu, @capamr=capamr, @nrocuo=nrocuo, @intorg=intorg, @caporg=caporg, @fecven=fecven 
	from be09cuota where saldeu>0 and nromov=@nromov order by nrocuo asc

	if @intorg is null
	begin
		select @intorg=0
	end
	if @intorg=0
	begin
		select @intorg=0
	end
	if @capamr is null
	begin
		select @vcap=0
	end
	else
	begin
		select @vcap=@capamr
	end

	if @monto<=@deuda
	begin
		exec sp_bg_getinteres @saldeu, @fecven, @nrocuo, @periodo, @nvoint output
		if @nvoint<=@intorg
		begin
			select @salint=(@intorg-@interes)
			select @nvomon=(@saldeu-@salint)
		end
		else
		begin
			select @nvomon=@saldeu+(@interes-@intorg)
		end

		/*exec @getinteres=sp_bg_getinteres @saldeu, @fecven, @nrocuo, @periodo*/

		if @monto<=@nvomon
		begin
			if @monto=@nvomon
			begin
				exec sp_bg_actualizabe09 @nrocob, @saldeu, @nrocuo, @nvoint, 1, @intorg, @vcap, @nromov, @idtran, @vinteresp output
			end
			else
			begin
				exec sp_bg_actualizabe09 @nrocob, @monto, @nrocuo, @nvoint, 2, @intorg, @vcap, @nromov, @idtran, @vinteresp output
			end
		end
		else
		begin
			if @nvoint<=@intorg
			begin
				select @resaldo=@monto-@saldeu
			end
			else
			begin
				select @resaldo=@monto-(@saldeu + @nvoint -@intorg)
			end 
			exec sp_bg_actualizabe09 @nrocob, @saldeu, @nrocuo, @nvoint, 3, @intorg, @vcap, @nromov, @idtran, @vinteresp output

			/*si sobra saldo del monto cancelado por el alumno, se lo distribuye entre las siguiente cuotas*/
			while @resaldo > 0.1
			begin
				/*llamar sp_bg_grabarbe09_2
				tiene que devolver el resaldo para saber si continuar llamandolo
				*/
				exec sp_bg_grabarbe09_2 @nromov, @periodo, @interes, @nrocob, @idtran, @resaldo output, @vinteresp output
			end
		end
	end
	return @resaldo
	return @vinteresp
end