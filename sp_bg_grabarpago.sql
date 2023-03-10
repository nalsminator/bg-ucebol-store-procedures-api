create procedure sp_bg_grabarpago
	@idcarr int, 
	@nromov nvarchar(20), 
	@idestu nvarchar(20), 
	@monto decimal(15,2)
as
begin
	declare 
	--grabar cxc
	@nrocob int, 
	@nroact int, 
	@gestion nvarchar(4), 
	@periodo int,
	@deuda decimal(15,2), 
	@idtran int, 
	@interes decimal(15,2),
	@nrocobza nvarchar(20),
	@cencos int,
	@vtc decimal(15,2),
	@maxcor int,
	@codcpt int,
	--grabar caja
	@coding int,
	@descpt varchar(50),
	@ctactb varchar(50),
	@caactb varchar(50),
	@codtip varchar(50),
	@tipdoc varchar(50),
	@gescxc int,
	@percxc int,
	@correl int,
	--grabar contabilidad
	@poriva int, 
	@portra int, 
	@screfis int, 
	@simptra int, 
	@crefis varchar(50), 
	@debfis varchar(50), 
	@imptra varchar(50), 
	@imptpp varchar(50),
	@nro int,
	@descta varchar(20),
	@ctaaux varchar(50), 
	@caaing varchar(50),

	@resaldo decimal(15,2),
	@vinteresp decimal(15,2),

	@exito int

	select @codcpt=grpcta, @gescxc=codges, @percxc=idperi from be08enccc where nromov=@nromov

	select @descpt=descpt, @ctactb=ctactb, @caactb=caactb, @codtip=codtip, @tipdoc=tipdoc from bd19conce where codcpt=@codcpt

	select @poriva=poriva, @portra=portra, @screfis=screfis, @simptra=simptra, @crefis=crefis, @debfis=debfis, @imptra=imptra, @imptpp=imptpp from Bc01param
	
	select @ctaaux=ctaaux, @ctactb=ctactb, @caaing=caaing from Be03grpct where grpcta=@codcpt

	--tipo de cambio ucebol
	select @vtc=cmbpar from a25tabtipca where feccmb=convert(date, getdate())

	--obtengo gestion y periodo de la inscripcion
	select @gestion=codges, @periodo=idperi from Be08enccc where nromov=@nromov

	--obtengo numero de inscripcion
	select @idtran=idtran from Cc08inscriC where idgest=@gestion and idperi=@periodo and idestu=@idestu and estado in (3, 7)
	
	select @nroact=nroact from bc11nroco where coddoc='CI'
	select @nroact=@nroact+1
	--concat(@nroact, '-', @gestion)

	select @nrocob=nrocob from be01param
	select @cencos=cencos from ca16carcc where idcarr=@idcarr
	select @nrocob=@nrocob+1
	--concat(@nrocob, '-', @gestion)

	--deuda + interes al dia
	exec sp_bg_deuda @idestu, @nromov, @deuda output
	exec sp_bg_getinterestotal @nromov, @interes output

	--validación previa de carga de valores de variables
	if @codcpt<>0 and @gescxc<>0 and @percxc<>0 and @vtc is not null
		and @gestion<>0 and @periodo<>0 and @idtran is not null and @nroact<>0 
		and @cencos<>0 and @deuda is not null and @interes is not null 
		and LEN(@descpt)>0 and LEN(@ctactb)>0 and LEN(@caactb)>0 and LEN(@codtip)>0 and LEN(@tipdoc)>0
		and @poriva is not null and @portra is not null and @screfis is not null and @simptra is not null 
		and LEN(@crefis)>0 and LEN(@debfis)>0 and LEN(@debfis)>0 and LEN(@imptra)>0 and LEN(@imptpp)>0
		and LEN(@ctaaux)>0 and LEN(@ctactb)>0 and LEN(@caaing)>0
		begin
			begin try
			set xact_abort on
				---------------actualiza correlativos-----------------
				update bc11nroco set nroact=@nroact where coddoc='CI'
				update be01param set nrocob=@nrocob
				------------------------------------------------------

				--------------GRABAR CXC------------------------------------------------------------------------------------------------------------------------------------------------------
				--grabar be08
				declare @exbe08 int
				exec sp_bg_grabarbe08 @deuda, @monto, @nromov, @gestion, @idestu, @idtran, @exbe08 output
				if @exbe08=0
				begin
					RAISERROR ('first batch failed',16,-1)
					ROLLBACK TRANSACTION
					RETURN
				end

				--grabar be09
				select @nrocobza=concat(@nroact, '-', @gestion)
				declare @vdeuda decimal(15,2)
				select @vdeuda=@deuda+@interes
				exec sp_bg_grabarbe09 @nromov, @periodo, @monto, @vdeuda, @interes, @nrocobza, @idtran, @resaldo output, @vinteresp output

				--grabar be10
				select @maxcor=max(nrocor) from Be10detct where nromov=@nromov
				select @maxcor=@maxcor+1
				insert into be10detct 
				(nromov/*1*/, nrocor/*2*/, nrodoc/*3*/, grpcta/*4*/, tipmon/*5*/, codccs/*6*/, detcta/*7*/, impcta/*8*/, stomna/*9*/, stomex/*10*/, estado/*11*/, fecmov/*12*/, codusu/*13*/) 
				values 
				(@nromov/*1*/, @maxcor/*2*/, concat('CI', @nroact, '-', @gestion)/*3*/, '213'/*4*/, 1/*5*/, @cencos/*6*/, 'Multa por Mora de Pago'/*7*/, @vinteresp/*8*/, @vinteresp/*9*/, (@vinteresp / @vtc)/*10*/, 0/*11*/, convert(date, getdate())/*12*/, 'bg'/*13*/)

				--grabar be11
				insert into Be11encac 
				(nromov/*1*/, tipmov/*2*/, fecmov/*3*/, tipmon/*4*/, tipcmb/*5*/, coddeu/*6*/, codcpt/*7*/, totcap/*8*/, totint/*9*/, codccs/*10*/, codges/*11*/, ntaorg/*12*/, codusr/*13*/, estado/*14*/, idperi/*15*/) 
				values 
				(concat(@nrocob, '-', @gestion)/*1*/, 1/*2*/, convert(date, getdate())/*3*/, 1/*4*/, @vtc/*5*/, @idestu/*6*/, @codcpt/*7*/, (@monto - @vinteresp)/*8*/, @vinteresp/*9*/, @cencos/*10*/, @gestion/*11*/, @nromov/*12*/, 'bg'/*13*/, 0/*14*/, @periodo/*15*/)
				------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

				--------------GRABAR CAJA-----------------------------------------------------------------------------------------------------------------------------------------------------
				select @coding=coding from Bd01param
				select @coding=@coding+1
				update Bd01param set coding=@coding
				--concat(@coding, '-', @gestion)

				select @correl=correl+1 from Bd04cajer where codusr='bg'
				update Bd04cajer set correl=@correl where codusr='bg'

				--grabar bd11
				insert into bd11enccj (
				nromov/*1*/, codges/*2*/, tipdoc/*3*/, fecmov /*4*/, hormov /*5*/, codreg /*6*/, codcpt/*7*/, nrodoc/*8*/, tipmon/*9*/,	tipcmb/*10*/, gructa/*11*/,	ctades/*12*/, detmov/*13*/,
				totmbs/*14*/, totmus/*15*/,	ntaorg/*16*/, gescxc/*17*/,	idperi/*18*/, nrocxc/*19*/,	estado/*20*/, codusr/*21*/, fecreg/*22*/, correl/*23*/) 
				values 
				(concat(@coding, '-', @gestion)/*1*/, @gestion/*2*/, 'CI'/*3*/,	convert(date, getdate())/*4*/, getdate()/*5*/, @idestu/*6*/, @codcpt/*7*/, concat('CI', @nroact, '-', @gestion)/*8*/,
				1/*9*/, @vtc/*10*/,	'1041-077391'/*11*/, 'GND2 Banco Ganadero Bs'/*12*/, 'glosa'/*13*/,	(@monto / @vtc)/*14*/, @monto/*15*/, @nrocobza/*16*/, @gescxc/*17*/, @percxc/*18*/,
				@nromov/*19*/, 0/*20*/,	'bg'/*21*/,	convert(date, getdate())/*22*/, @correl/*23*/)						   
	
				--grabar bd12
				insert into bd12detcj (
				nromov/*1*/, nrocor/*2*/, codcpt/*3*/, codcta/*4*/, codiaa/*5*/, tipccs/*6*/, codccs/*7*/, tipcta/*8*/, nrodoc/*9*/, detmov/*10*/, stombs/*11*/, 
				stomus/*12*/, tipmon/*13*/, forpag/*14*/, estado/*15*/)
				values 
				(concat(@coding, '-', @gestion)/*1*/, 1/*2*/, @codcpt/*3*/, '1102025'/*4*/,	@caactb/*5*/, 1/*6*/, @cencos/*7*/,	2/*8*/,	concat(@nroact, '-', @gestion)/*9*/, @descpt/*10*/,
				(@monto / @vtc)/*11*/, @monto/*12*/, 1/*13*/, 2/*14*/, 0/*15*/)
				------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				--------------GRABAR CONTABILIDAD---------------------------------------------------------------------------------------------------------------------------------------------

				/*grabar bc12*/
				insert into bc12encas 
				(codast/*1*/, codges/*2*/, fecmov/*3*/, hormov/*4*/, tipdoc/*5*/, codreg/*6*/, tipmon/*7*/, tipcmb/*8*/, tipfac/*9*/, detuno/*10*/, totdeb/*11*/, tothab/*12*/, debtbs/*13*/, habtbs/*14*/,	poriva/*15*/, portra/*16*/,	ntaorg/*17*/, fecreg/*18*/,	codusr/*19*/, estado/*20*/) values 
				(concat(@nroact, '-', @gestion)/*1*/, @gestion/*2*/, convert(date, getdate())/*3*/, getdate()/*4*/, @tipdoc/*5*/, @idestu/*6*/, 1/*7*/,	@vtc/*8*/, 0/*9*/, 'glosa'/*10*/, @monto/*11*/, @monto/*12*/, (@monto / @vtc)/*13*/, (@monto / @vtc)/*14*/, @poriva/*15*/, @portra/*16*/, concat(@coding, '-', @gestion)/*17*/, convert(date, getdate())/*18*/, 'bg'/*19*/, 0/*20*/)

				--grabar bc13
				--banco
				select @nro=1
				select @descta=descta from bc05plact where codcta=@ctactb

				insert into bc13detas (codast/*1*/, nrocor/*2*/, codcta/*3*/, detcta/*4*/, codccs/*5*/, deborg/*6*/, debmna/*7*/, debmex/*8*/, tipreg/*9*/, estado/*10*/) values
				(concat(@nroact, '-', @gestion)/*1*/, @nro/*2*/, @ctactb/*3*/, @descta/*4*/, @cencos/*5*/, @monto/*6*/, @monto/*7*/, (@monto / @vtc)/*8*/, 2/*9*/, 0/*10*/)

				if @vinteresp>0
				begin
					--CxC 11201001
					select @nro+=1
					select @descta=descta from bc05plact where codcta=@ctactb
					insert Into bc13detas (codast/*1*/, nrocor/*2*/, codcta/*3*/, detcta/*4*/, codccs/*5*/, codiaa/*6*/, haborg/*7*/, habmna/*8*/, habmex/*9*/, tipreg/*10*/, estado/*11*/) 
					values 
					(concat(@nroact, '-', @gestion)/*1*/, @nro/*2*/, @ctactb/*3*/, @descta/*4*/, @cencos/*5*/, @ctaaux/*6*/, (@monto - @vinteresp)/*7*/, (@monto - @vinteresp)/*8*/,  ((@monto - @vinteresp) / @vtc)/*9*/, 2/*10*/, 0/*11*/)

					--interes x vencimiento de cuota 42102001
					select @nro+=1
					insert into bc13detas (codast/*1*/, nrocor/*2*/, codcta/*3*/, detcta/*4*/, codccs/*5*/, codiaa/*6*/, haborg/*7*/, habmna/*8*/, habmex/*9*/, tipreg/*10*/, estado/*11*/) 
					values 
					(concat(@nroact, '-', @gestion)/*1*/, @nro/*2*/, '42102001'/*3*/, 'Multa por Mora de Pago'/*4*/, @cencos/*5*/, @ctaaux/*6*/, @vinteresp/*7*/, @vinteresp/*8*/, (@vinteresp / @vtc)/*9*/, 2/*10*/, 0/*11*/)
				end
				else
				begin
					if @vinteresp=0
					begin
						--CxC  11201001
						select @nro+=1
						select @descta=descta from bc05plact where codcta=@ctactb
						insert into bc13detas (codast/*1*/, nrocor/*2*/, codcta/*3*/, detcta/*4*/, codccs/*5*/, codiaa/*6*/, haborg/*7*/, habmna/*8*/, habmex/*9*/, tipreg/*10*/, estado/*11*/) 
						values
						(concat(@nroact, '-', @gestion)/*1*/, @nro/*2*/, @ctactb/*3*/, @descta/*4*/, @cencos/*5*/, @ctaaux/*6*/, @monto/*7*/, @monto/*8*/, (@monto / @vtc)/*9*/, 2/*10*/, 0/*11*/)
					end
					else
					begin
						--interes x vencimiento de cuota 42102001
						select @nro+=1
						insert into bc13detas (codast/*1*/, nrocor/*2*/, codcta/*3*/, detcta/*4*/, codccs/*5*/, codiaa/*6*/, haborg/*7*/, habmna/*8*/, habmex/*9*/, tipreg/*10*/, estado/*11*/) 
						values
						(concat(@nroact, '-', @gestion)/*1*/, @nro/*2*/, '42102001'/*3*/, 'Multa por Mora de Pago'/*4*/, @cencos/*5*/, @ctaaux/*6*/, @monto/*7*/, @monto/*8*/, (@monto / @vtc)/*9*/, 2/*10*/, 0/*11*/)
					end
				end
				select @exito=1
				select @exito
			end try
			begin catch
				rollback tran
				select @exito=0
				select @exito
			end catch
			------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		end
		else
		begin
			--por acá sale si no cargan bien la variables
			select @exito=0
			select @exito
		end
	end