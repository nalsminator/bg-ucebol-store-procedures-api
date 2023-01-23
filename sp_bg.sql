create procedure sp_bg
 @tipo int
as
begin
 if @tipo=1 /*gestion y periodo actual*/
 begin
 	select gesact, persem from Cb00parametros where estado=0
 end
 if @tipo=2 /*tipo de cambio*/
 begin
 	select CmbOfi, CmbPar from A25TabTipCa where FecCmb=(SELECT CONVERT (date, GETDATE()))
 end
 if @tipo=3
 begin
	select codreg, desper, numide, fecnac from ba02perso where codreg=584502017
 end
 if @tipo=4
 begin
	select * from conceptospago
 end
end