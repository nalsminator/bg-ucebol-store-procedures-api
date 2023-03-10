create procedure sp_bg_getinterestotal
	@nromov varchar(20), @r_interes decimal(15,2) output
as
begin
	declare @saldeu decimal(15,2), @fecven date, @intorg decimal(15,2), @xInt decimal(15,2),
	@nInt decimal(15,2), @tInt decimal(15,2), @nDias int

	select @tInt=0

	DECLARE MY_CURSOR CURSOR 
	  LOCAL STATIC READ_ONLY FORWARD_ONLY
	FOR 

	select saldeu, fecven, intorg from be09cuota where saldeu>0 and nromov=@nromov

	OPEN MY_CURSOR
	FETCH NEXT FROM MY_CURSOR INTO @saldeu, @fecven, @intorg
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		if @intorg is null
			begin
				select @xInt=0
			end
		else
			begin
				select @xInt=@intorg
			end

		select @nDias=DATEDIFF(day, @fecven,getdate())
		if @nDias>0
			begin
				select @nInt=((@nDias * 0.05) * @saldeu) / 100
			end
		else
			begin
				select @nInt=0
			end

		if @xInt>=@nInt
			begin
				select @tInt=0
			end
		else
			begin
				select @tInt = @tInt + (@nInt - @xInt)
			end

		FETCH NEXT FROM MY_CURSOR INTO @saldeu, @fecven, @intorg
	END
	CLOSE MY_CURSOR
	DEALLOCATE MY_CURSOR

	select @r_interes=@tInt
	return @r_interes
end