create procedure sp_bg_grabarbe09_2
	@nromov nvarchar(20), 
	@periodo int, 
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
		
	select @saldeu=saldeu, @capamr=capamr, @nrocuo=nrocuo, @intorg=intorg, @caporg=caporg, @fecven=fecven 
	from be09cuota where saldeu>0 and nromov=@nromov

	if @intorg is null
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

	exec sp_bg_getinteres @saldeu, @fecven, @nrocuo, @periodo, @getinteres output

	if @resaldo<=@nvomon
	begin
		if @resaldo=@nvomon
		begin
			select @getinteres=@getinteres-@salint
			exec sp_bg_actualizabe09 @nrocob, @resaldo, @nrocuo, @getinteres, 1, @intorg, @vcap, @nromov, @idtran, @vinteresp output
		end
		else
		begin
			select @getinteres=@getinteres-@salint
			exec sp_bg_actualizabe09 @nrocob, @resaldo, @nrocuo, @getinteres, 2, @intorg, @vcap, @nromov, @idtran, @vinteresp output
		end
	end
	else
	begin
		select @getinteres=@getinteres-@salint
		exec sp_bg_actualizabe09 @nrocob, @saldeu, @nrocuo, @getinteres, 3, @intorg, @vcap, @nromov, @idtran, @vinteresp output
	end

	if @nvoint<=@intorg
	begin
		select @resaldo=@resaldo-@saldeu
	end
	else
	begin
		select @resaldo=@resaldo-(@saldeu + @nvoint - @intorg)
	end
	/*select @salint=0*/
	return @resaldo
	return @vinteresp
end