alter procedure sp_bg_listanivel
as
begin
	select sigla, descar, estado from Ca02carre where tipcar=0 and estado=0 and idfacu<>0
	--select sigla, descri, estado from Cc01perioC where idgest=(select gesact from Cb00parametros where estado=0)
end