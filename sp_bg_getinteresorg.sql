create procedure sp_bg_getinteresorg
	@nromov varchar(20), 
	@nrocuo int,
	@intorg decimal(15,2) output
as
begin
	select @intorg=intorg from Be09cuota where nromov=@nromov and nrocuo=@nrocuo
	if @intorg is null
	begin
		select @intorg=0
		return @intorg
	end
	else
	begin
		return @intorg
	end
end