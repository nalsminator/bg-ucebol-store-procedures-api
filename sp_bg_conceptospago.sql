create procedure sp_bg_conceptospago
as
begin
	select abreviatura, descripcion, estado from conceptospago
end