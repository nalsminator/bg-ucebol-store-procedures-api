create procedure sp_bg_getcapitalorg
	@nromov varchar(20), 
	@nrocuo int,
	@capamr decimal(15,2) output
as
begin
	select @capamr=capamr from Be09cuota where nromov=@nromov and nrocuo=@nrocuo
	if @capamr is null
	begin
		select @capamr=0
		return @capamr
	end
	else
	begin
		return @capamr
	end
end