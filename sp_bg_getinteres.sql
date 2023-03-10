create procedure sp_bg_getinteres
	@sal decimal(15,2), @ven date, @cuo int, @periodo int, @valor decimal(15,2) output
as
begin
	declare @nint decimal(15,2), @ndias int
	if @periodo = 99
	begin
		select @nint=0
	end
	else
	begin
		select @nDias=DATEDIFF(day, @ven, getdate())
		if @ndias > 0
		begin
			select @nint=((@ndias * 0.05) * @sal) / 100
		end
		else
		begin
			select @nint=0
		end
	end
	select @valor=@nint
	return @valor
end