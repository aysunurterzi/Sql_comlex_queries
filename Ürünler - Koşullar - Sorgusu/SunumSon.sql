declare @Marka varchar(50)
declare @Sezon varchar(50)
declare @UrunGrubu varchar(50)
declare @Tema varchar(50)
declare @DepoSayisi int
declare @StokSayisi int
declare @yenitablo table ( id int PRIMARY KEY IDENTITY(1,1), 
                            UrunBarkodu varchar(100), 
							Marka varchar(100),  
							Sezon varchar(100), 
							UrunGrubu varchar(100), 
							Tema varchar(100), 
							DepoSayýsý int, 
							StokSayýsý int)

declare @stoktablo table ( id int PRIMARY KEY IDENTITY(1,1),
                           TopUrun int,
                           GercekStok int)

declare UrunlerCursor cursor for 
select MarkaKosul,SezonKosul,UrunGrubuKosul,TemaKosul,DepoSayisiKosul,StokSayisiKosul from KosulTb 
 open UrunlerCursor

 fetch next from UrunlerCursor into @Marka,@Sezon,@UrunGrubu,@Tema,@DepoSayisi,@StokSayisi

 while (@@FETCH_STATUS=0)
 begin
 

--****--	    
if (@Marka='all' and @Sezon='all'and @UrunGrubu='all' and @Tema='all') -- hiç bir koþul belirtilmediðinde
begin 
--eðer bu koþulu saðlayan ürüler nulll deðerse ...
  IF not EXISTS (select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
    where DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi )as b)

-- @yenitablo daki bu koþulu saðlayan tüm ürünlri sil
 DELETE FROM @yenitablo;

-- eðer koþulu saðlayan ürünler null dðilse 
ELSE
  WITH urunler AS
 (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi )

--@yenitablo ya farklý olan ürnleri ekle (ayný ürünleri 2 defa eklememek için yaptým)
INSERT INTO @yenitablo ( UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSayýsý,StokSayýsý)
SELECT UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSayýsý,StokSayýsý
FROM  urunler
where not exists (select * from @yenitablo where UrunBarkodu=urunler.UrunBarkodu)

--stok sayýsý için ayrý bir tablo oluþturdum (@stoktablo) buraya da ayný ürünleri ekle toplam ürün ve stok sayýsýný çek
  INSERT INTO @stoktablo (TopUrun,GercekStok)
select count(*)TopUrun, sum(StokSayýsý) GerçekStok from 
(
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu)as b
end

else if (@Marka='all' and @Sezon='all'and @UrunGrubu='all' ) -- tema koþulu deðiþtirildiðinde
begin
  IF not EXISTS (select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where u.Tema=@Tema and  DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi )as b)

 DELETE FROM @yenitablo WHERE tema=@Tema;

ELSE
  WITH urunler AS
 (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
    where u.Tema=@Tema and  DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi )

INSERT INTO @yenitablo ( UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSayýsý,StokSayýsý)
SELECT UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSayýsý,StokSayýsý
FROM  urunler
where not exists (select * from @yenitablo where UrunBarkodu=urunler.UrunBarkodu)
  INSERT INTO @stoktablo (TopUrun,GercekStok)
  select COUNT(*) TopUrun, sum(StokSayýsý) GerçekStok from
(
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where u.Tema=@Tema)as b
end

else if  (@Marka='all' and @Sezon='all' and @Tema='all' ) -- urun grubu koþulu deðiþtirildiðinde
begin
  IF not EXISTS (select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where u.UrunGrubu=@UrunGrubu and  DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi)as b)

 DELETE FROM @yenitablo WHERE UrunGrubu=@UrunGrubu;

ELSE
  WITH urunler AS
 (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
     where u.UrunGrubu=@UrunGrubu and  DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi)

INSERT INTO @yenitablo ( UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSayýsý,StokSayýsý)
output inserted.UrunBarkodu, inserted.Marka, inserted.Sezon, inserted.UrunGrubu, inserted.tema, inserted.DepoSayýsý, inserted.StokSayýsý
SELECT UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSayýsý,StokSayýsý
FROM  urunler
where not exists (select * from @yenitablo where UrunBarkodu=urunler.UrunBarkodu)
  INSERT INTO @stoktablo (TopUrun, GercekStok)
  select count(*) TopUrun, sum(StokSayýsý) GerçekStok from  (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where u.UrunGrubu=@UrunGrubu )as b
end

else if  (@Marka='all'and @UrunGrubu='all' and @Tema='all') --sezon koþulu deðiþtirildiðinde
begin
  IF not EXISTS (select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where  u.Sezon=@Sezon and  DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi)as b)

 DELETE FROM @yenitablo WHERE Sezon=@Sezon;

ELSE
  WITH urunler AS
 (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
    where  u.Sezon=@Sezon and  DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi)

INSERT INTO @yenitablo ( UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSayýsý,StokSayýsý)
SELECT UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSayýsý,StokSayýsý
FROM  urunler
where not exists (select * from @yenitablo where UrunBarkodu=urunler.UrunBarkodu)
  INSERT INTO @stoktablo (TopUrun,GercekStok)
  select count(*) TopUrun, sum(StokSayýsý) GerçekStok from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where  u.Sezon=@Sezon )as b
end

else if  (@Sezon='all'and @UrunGrubu='all' and @Tema='all') -- marka koþulu deðiþtirildiðine
begin
  IF not EXISTS (select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where  u.Marka=@Marka and  DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi)as b)

 DELETE FROM @yenitablo WHERE Marka=@Marka;

ELSE
  WITH urunler AS
 (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where  u.Marka=@Marka and  DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi)

INSERT INTO @yenitablo ( UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSayýsý,StokSayýsý)
SELECT UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSayýsý,StokSayýsý
FROM  urunler
where not exists (select * from @yenitablo where UrunBarkodu=urunler.UrunBarkodu)
  INSERT INTO @stoktablo (TopUrun, GercekStok)
  select count(*)TopUrun, sum(StokSayýsý) GerçekStok from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where  u.Marka=@Marka )as b
end

else if (@Marka='all' and @Sezon='all') -- hem ürün grubu hem tema deðiþtirildiðinde
begin
  IF not EXISTS (select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where u.UrunGrubu=@UrunGrubu and u.Tema=@Tema and DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi)as b)

 DELETE FROM @yenitablo WHERE UrunGrubu=@UrunGrubu and Tema=@Tema;

ELSE
  WITH urunler AS
 (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
 where u.UrunGrubu=@UrunGrubu and u.Tema=@Tema and  DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi)

INSERT INTO @yenitablo ( UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSayýsý,StokSayýsý)
SELECT UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSayýsý,StokSayýsý
FROM  urunler
where not exists (select * from @yenitablo where UrunBarkodu=urunler.UrunBarkodu)
  INSERT INTO @stoktablo (TopUrun,GercekStok)
  select count(*)TopUrun, sum(StokSayýsý) GerçekStok from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where u.UrunGrubu=@UrunGrubu and u.Tema=@Tema )as b
end

else if (@Marka='all' and @UrunGrubu='all') --hem sezon hem tema deðiþtirildiðinde
begin
  IF not EXISTS (select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where u.Sezon=@Sezon and u.Tema=@Tema and  DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi)as b)

 DELETE FROM @yenitablo WHERE Sezon=@Sezon and Tema=@Tema;

ELSE
  WITH urunler AS
 (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
  where u.Sezon=@Sezon and u.Tema=@Tema and  DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi)

INSERT INTO @yenitablo ( UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSayýsý,StokSayýsý)
SELECT UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSayýsý,StokSayýsý
FROM  urunler
where not exists (select * from @yenitablo where UrunBarkodu=urunler.UrunBarkodu)
  INSERT INTO @stoktablo (TopUrun,GercekStok)
  select count(*)TopUrun, sum(StokSayýsý) GerçekStok from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where u.Sezon=@Sezon and u.Tema=@Tema )as b
end

else if (@Marka='all' and @Tema='all') -- hem sezon hem urun grubu deðiþtirildiðinde
begin
  IF not EXISTS (select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
  where u.Sezon=@Sezon and u.UrunGrubu=@UrunGrubu and  DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi
   )as b)

 DELETE FROM @yenitablo WHERE Sezon=@Sezon and UrunGrubu=@UrunGrubu;

ELSE
  WITH urunler AS
 (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
  where u.Sezon=@Sezon and u.UrunGrubu=@UrunGrubu and  DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi
   )
INSERT INTO @yenitablo ( UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSayýsý,StokSayýsý)
SELECT UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSayýsý,StokSayýsý
FROM  urunler
where not exists (select * from @yenitablo where UrunBarkodu=urunler.UrunBarkodu)
  INSERT INTO @stoktablo (TopUrun,GercekStok)
  select count(*)TopUrun, sum(StokSayýsý) GerçekStok from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
  where u.Sezon=@Sezon and u.UrunGrubu=@UrunGrubu )as b 
end

else if (@Sezon='all'and @UrunGrubu='all') -- hem marka hem tema deðiþtirildiðinde 
begin
  IF not EXISTS (select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
 where u.Marka=@Marka and u.Tema=@Tema and  DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi)as b)

 DELETE FROM @yenitablo WHERE Marka=@Marka and Tema=@Tema;

ELSE
  WITH urunler AS
 (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
 where u.Marka=@Marka and u.Tema=@Tema and  DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi)

INSERT INTO @yenitablo ( UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSayýsý,StokSayýsý)
SELECT UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSayýsý,StokSayýsý
FROM  urunler
where not exists (select * from @yenitablo where UrunBarkodu=urunler.UrunBarkodu)
  INSERT INTO @stoktablo (TopUrun,GercekStok)
  select count(*)TopUrun, sum(StokSayýsý) GerçekStok from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
 where u.Marka=@Marka and u.Tema=@Tema )as b
end

else if (@Sezon='all'and @Tema='all') -- hem marka hem urun grubu deðiþtirildiðinde
begin
  IF not EXISTS (select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
  where u.Marka=@Marka and u.UrunGrubu=@UrunGrubu and  DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi)as b)

 DELETE FROM @yenitablo WHERE Marka=@Marka and UrunGrubu=@UrunGrubu ;

ELSE
  WITH urunler AS
 (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
  where u.Marka=@Marka and u.UrunGrubu=@UrunGrubu and  DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi)

INSERT INTO @yenitablo ( UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSayýsý,StokSayýsý)
SELECT UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSayýsý,StokSayýsý
FROM  urunler
where not exists (select * from @yenitablo where UrunBarkodu=urunler.UrunBarkodu)
  INSERT INTO @stoktablo (TopUrun,GercekStok)
  select count(*) TopUrun, sum(StokSayýsý) GerçekStok from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
  where u.Marka=@Marka and u.UrunGrubu=@UrunGrubu )as b
end

else if (@UrunGrubu='all' and @Tema='all') -- hem marka hem sezon deðiþtirildiðinde
begin
  IF not EXISTS (select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where u.Marka=@Marka and u.Sezon=@Sezon and  DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi)as b)

 DELETE FROM @yenitablo WHERE Marka=@Marka and Sezon=@Sezon ;

ELSE
  WITH urunler AS
 (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where u.Marka=@Marka and u.Sezon=@Sezon and  DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi)

INSERT INTO @yenitablo ( UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSayýsý,StokSayýsý)
SELECT UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSayýsý,StokSayýsý
FROM  urunler
where not exists (select * from @yenitablo where UrunBarkodu=urunler.UrunBarkodu)
  INSERT INTO @stoktablo (TopUrun,GercekStok)
  select count(*)TopUrun, sum(StokSayýsý) GerçekStok from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where u.Marka=@Marka and u.Sezon=@Sezon)as b
end

else if (@Marka='all') -- marka dýþýnda tüm deðerler deðiþtirildiðinde
begin
  IF not EXISTS (select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
    where u.Sezon=@Sezon and u.UrunGrubu=@UrunGrubu and u.Tema=@Tema and  DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi)as b)

 DELETE FROM @yenitablo WHERE  Sezon=@Sezon and UrunGrubu=@UrunGrubu and Tema=@Tema ;

ELSE
  WITH urunler AS
 (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where u.Sezon=@Sezon and u.UrunGrubu=@UrunGrubu and u.Tema=@Tema and  DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi)
INSERT INTO @yenitablo ( UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSayýsý,StokSayýsý)
SELECT UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSayýsý,StokSayýsý
FROM  urunler
where not exists (select * from @yenitablo where UrunBarkodu=urunler.UrunBarkodu)
  INSERT INTO @stoktablo (TopUrun,GercekStok)
  select count(*) TopUrun, sum(StokSayýsý) GerçekStok from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
    where u.Sezon=@Sezon and u.UrunGrubu=@UrunGrubu and u.Tema=@Tema)as b
end

else if (@Sezon='all') -- sezon dýþýnda tüm deðerler deðiþtirildiðinde
begin
  IF not EXISTS (select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
    where u.Marka=@Marka and u.UrunGrubu=@UrunGrubu and u.Tema=@Tema and  DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi)as b)

 DELETE FROM @yenitablo WHERE  Marka=@Marka and UrunGrubu=@UrunGrubu and Tema=@Tema ;

ELSE
  WITH urunler AS
 (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
    where u.Marka=@Marka and u.UrunGrubu=@UrunGrubu and u.Tema=@Tema and  DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi)
INSERT INTO @yenitablo ( UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSayýsý,StokSayýsý)
SELECT UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSayýsý,StokSayýsý
FROM  urunler
where not exists (select * from @yenitablo where UrunBarkodu=urunler.UrunBarkodu)
  INSERT INTO @stoktablo (TopUrun,GercekStok)
  select count(*) TopUrun, sum(StokSayýsý) GerçekStok from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
    where u.Marka=@Marka and u.UrunGrubu=@UrunGrubu and u.Tema=@Tema )as b
end

else if (@UrunGrubu='all') -- urun grubu dýþýnda tüm deðerler deðiþtirildiðinde 
begin
  IF not EXISTS (select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
       where u.Marka=@Marka and u.Sezon=@Sezon and u.Tema=@Tema and  DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi)as b)

 DELETE FROM @yenitablo WHERE  Marka=@Marka and Sezon=@Sezon and Tema=@Tema ;

ELSE
  WITH urunler AS
 (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
       where u.Marka=@Marka and u.Sezon=@Sezon and u.Tema=@Tema and  DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi)

INSERT INTO @yenitablo ( UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSayýsý,StokSayýsý)
SELECT UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSayýsý,StokSayýsý
FROM  urunler
where not exists (select * from @yenitablo where UrunBarkodu=urunler.UrunBarkodu)
  INSERT INTO @stoktablo (TopUrun,GercekStok)
  select count(*) TopUrun, sum(StokSayýsý) GerçekStok from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
       where u.Marka=@Marka and u.Sezon=@Sezon and u.Tema=@Tema and  DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi)as b
end

else if (@Tema='all') -- tema dýþýnda tüm deðerler deðiþtirildiðinde
begin
  IF not EXISTS (select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
      where u.Marka=@Marka and u.Sezon=@Sezon and u.UrunGrubu=@UrunGrubu and  DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi
   )as b)

 DELETE FROM @yenitablo WHERE Marka=@Marka and Sezon=@Sezon and UrunGrubu=@UrunGrubu ;

ELSE
  WITH urunler AS
 (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
       where u.Marka=@Marka and u.Sezon=@Sezon and u.UrunGrubu=@UrunGrubu and  DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi
   )
INSERT INTO @yenitablo ( UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSayýsý,StokSayýsý)
SELECT UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSayýsý,StokSayýsý
FROM  urunler
where not exists (select * from @yenitablo where UrunBarkodu=urunler.UrunBarkodu)
  INSERT INTO @stoktablo (TopUrun,GercekStok)
  select count(*) TopUrun, sum(StokSayýsý) GerçekStok from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
      where u.Marka=@Marka and u.Sezon=@Sezon and u.UrunGrubu=@UrunGrubu )as b
end

else if (@Marka=@Marka and @Sezon=@Sezon and @UrunGrubu=@UrunGrubu and @Tema=@Tema) -- tüm koþullar belirtilirse
begin
  IF not EXISTS (select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
      where u.Marka=@Marka and u.Sezon=@Sezon and u.UrunGrubu=@UrunGrubu and u.Tema=@Tema and DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi

   )as b)

 DELETE FROM @yenitablo WHERE Marka=@Marka and Sezon=@Sezon and UrunGrubu=@UrunGrubu and Tema=@Tema  ;

ELSE
  WITH urunler AS
 (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
       where u.Marka=@Marka and u.Sezon=@Sezon and u.UrunGrubu=@UrunGrubu and u.Tema=@Tema and DepoSayýsý>@DepoSayisi and StokSayýsý>@StokSayisi)

INSERT INTO @yenitablo ( UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSayýsý,StokSayýsý)
SELECT UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSayýsý,StokSayýsý
FROM  urunler
where not exists (select * from @yenitablo where UrunBarkodu=urunler.UrunBarkodu)
  INSERT INTO @stoktablo (TopUrun,GercekStok)
  select count(*)TopUrun, sum(StokSayýsý) GerçekStok from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
      where u.Marka=@Marka and u.Sezon=@Sezon and u.UrunGrubu=@UrunGrubu and u.Tema=@Tema)as b
end


 fetch next from UrunlerCursor into @Marka,@Sezon,@UrunGrubu,@Tema,@DepoSayisi,@StokSayisi

 
 end 


 --topürün ve gercektok sayýsýný kosul tablosyla birleþtirme
 select A.KosulId,A.MarkaKosul,A.SezonKosul,A.UrunGrubuKosul,A.TemaKosul,A.DepoSayisiKosul,A.StokSayisiKosul, B.TopUrun, B.GercekStok
from(
    SELECT *,row_number() over (order by KosulId) as row_num
    FROM KosulTb)A
join
    (SELECT *,row_number() over (order by id) as row_num
    FROM @stoktablo)B
on  A.row_num=B.row_num
ORDER BY A.KosulId,B.id

select * from @yenitablo

 close UrunlerCursor
 deallocate UrunlerCursor



 ------Test-------
--Tüm ürünler olucak fakat taký ürünler olmayacak
select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSayýsý,tablo.StokSayýsý 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSayýsý, sum(d.StokSayisi) StokSayýsý from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu where not exists (select * from KosulTb where UrunGrubu='taký'))as b
    