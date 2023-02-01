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
							DepoSay�s� int, 
							StokSay�s� int)

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
if (@Marka='all' and @Sezon='all'and @UrunGrubu='all' and @Tema='all') -- hi� bir ko�ul belirtilmedi�inde
begin 
--e�er bu ko�ulu sa�layan �r�ler nulll de�erse ...
  IF not EXISTS (select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
    where DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi )as b)

-- @yenitablo daki bu ko�ulu sa�layan t�m �r�nlri sil
 DELETE FROM @yenitablo;

-- e�er ko�ulu sa�layan �r�nler null d�ilse 
ELSE
  WITH urunler AS
 (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi )

--@yenitablo ya farkl� olan �rnleri ekle (ayn� �r�nleri 2 defa eklememek i�in yapt�m)
INSERT INTO @yenitablo ( UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSay�s�,StokSay�s�)
SELECT UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSay�s�,StokSay�s�
FROM  urunler
where not exists (select * from @yenitablo where UrunBarkodu=urunler.UrunBarkodu)

--stok say�s� i�in ayr� bir tablo olu�turdum (@stoktablo) buraya da ayn� �r�nleri ekle toplam �r�n ve stok say�s�n� �ek
  INSERT INTO @stoktablo (TopUrun,GercekStok)
select count(*)TopUrun, sum(StokSay�s�) Ger�ekStok from 
(
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu)as b
end

else if (@Marka='all' and @Sezon='all'and @UrunGrubu='all' ) -- tema ko�ulu de�i�tirildi�inde
begin
  IF not EXISTS (select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where u.Tema=@Tema and  DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi )as b)

 DELETE FROM @yenitablo WHERE tema=@Tema;

ELSE
  WITH urunler AS
 (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
    where u.Tema=@Tema and  DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi )

INSERT INTO @yenitablo ( UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSay�s�,StokSay�s�)
SELECT UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSay�s�,StokSay�s�
FROM  urunler
where not exists (select * from @yenitablo where UrunBarkodu=urunler.UrunBarkodu)
  INSERT INTO @stoktablo (TopUrun,GercekStok)
  select COUNT(*) TopUrun, sum(StokSay�s�) Ger�ekStok from
(
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where u.Tema=@Tema)as b
end

else if  (@Marka='all' and @Sezon='all' and @Tema='all' ) -- urun grubu ko�ulu de�i�tirildi�inde
begin
  IF not EXISTS (select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where u.UrunGrubu=@UrunGrubu and  DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi)as b)

 DELETE FROM @yenitablo WHERE UrunGrubu=@UrunGrubu;

ELSE
  WITH urunler AS
 (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
     where u.UrunGrubu=@UrunGrubu and  DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi)

INSERT INTO @yenitablo ( UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSay�s�,StokSay�s�)
output inserted.UrunBarkodu, inserted.Marka, inserted.Sezon, inserted.UrunGrubu, inserted.tema, inserted.DepoSay�s�, inserted.StokSay�s�
SELECT UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSay�s�,StokSay�s�
FROM  urunler
where not exists (select * from @yenitablo where UrunBarkodu=urunler.UrunBarkodu)
  INSERT INTO @stoktablo (TopUrun, GercekStok)
  select count(*) TopUrun, sum(StokSay�s�) Ger�ekStok from  (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where u.UrunGrubu=@UrunGrubu )as b
end

else if  (@Marka='all'and @UrunGrubu='all' and @Tema='all') --sezon ko�ulu de�i�tirildi�inde
begin
  IF not EXISTS (select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where  u.Sezon=@Sezon and  DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi)as b)

 DELETE FROM @yenitablo WHERE Sezon=@Sezon;

ELSE
  WITH urunler AS
 (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
    where  u.Sezon=@Sezon and  DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi)

INSERT INTO @yenitablo ( UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSay�s�,StokSay�s�)
SELECT UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSay�s�,StokSay�s�
FROM  urunler
where not exists (select * from @yenitablo where UrunBarkodu=urunler.UrunBarkodu)
  INSERT INTO @stoktablo (TopUrun,GercekStok)
  select count(*) TopUrun, sum(StokSay�s�) Ger�ekStok from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where  u.Sezon=@Sezon )as b
end

else if  (@Sezon='all'and @UrunGrubu='all' and @Tema='all') -- marka ko�ulu de�i�tirildi�ine
begin
  IF not EXISTS (select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where  u.Marka=@Marka and  DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi)as b)

 DELETE FROM @yenitablo WHERE Marka=@Marka;

ELSE
  WITH urunler AS
 (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where  u.Marka=@Marka and  DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi)

INSERT INTO @yenitablo ( UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSay�s�,StokSay�s�)
SELECT UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSay�s�,StokSay�s�
FROM  urunler
where not exists (select * from @yenitablo where UrunBarkodu=urunler.UrunBarkodu)
  INSERT INTO @stoktablo (TopUrun, GercekStok)
  select count(*)TopUrun, sum(StokSay�s�) Ger�ekStok from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where  u.Marka=@Marka )as b
end

else if (@Marka='all' and @Sezon='all') -- hem �r�n grubu hem tema de�i�tirildi�inde
begin
  IF not EXISTS (select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where u.UrunGrubu=@UrunGrubu and u.Tema=@Tema and DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi)as b)

 DELETE FROM @yenitablo WHERE UrunGrubu=@UrunGrubu and Tema=@Tema;

ELSE
  WITH urunler AS
 (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
 where u.UrunGrubu=@UrunGrubu and u.Tema=@Tema and  DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi)

INSERT INTO @yenitablo ( UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSay�s�,StokSay�s�)
SELECT UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSay�s�,StokSay�s�
FROM  urunler
where not exists (select * from @yenitablo where UrunBarkodu=urunler.UrunBarkodu)
  INSERT INTO @stoktablo (TopUrun,GercekStok)
  select count(*)TopUrun, sum(StokSay�s�) Ger�ekStok from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where u.UrunGrubu=@UrunGrubu and u.Tema=@Tema )as b
end

else if (@Marka='all' and @UrunGrubu='all') --hem sezon hem tema de�i�tirildi�inde
begin
  IF not EXISTS (select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where u.Sezon=@Sezon and u.Tema=@Tema and  DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi)as b)

 DELETE FROM @yenitablo WHERE Sezon=@Sezon and Tema=@Tema;

ELSE
  WITH urunler AS
 (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
  where u.Sezon=@Sezon and u.Tema=@Tema and  DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi)

INSERT INTO @yenitablo ( UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSay�s�,StokSay�s�)
SELECT UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSay�s�,StokSay�s�
FROM  urunler
where not exists (select * from @yenitablo where UrunBarkodu=urunler.UrunBarkodu)
  INSERT INTO @stoktablo (TopUrun,GercekStok)
  select count(*)TopUrun, sum(StokSay�s�) Ger�ekStok from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where u.Sezon=@Sezon and u.Tema=@Tema )as b
end

else if (@Marka='all' and @Tema='all') -- hem sezon hem urun grubu de�i�tirildi�inde
begin
  IF not EXISTS (select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
  where u.Sezon=@Sezon and u.UrunGrubu=@UrunGrubu and  DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi
   )as b)

 DELETE FROM @yenitablo WHERE Sezon=@Sezon and UrunGrubu=@UrunGrubu;

ELSE
  WITH urunler AS
 (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
  where u.Sezon=@Sezon and u.UrunGrubu=@UrunGrubu and  DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi
   )
INSERT INTO @yenitablo ( UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSay�s�,StokSay�s�)
SELECT UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSay�s�,StokSay�s�
FROM  urunler
where not exists (select * from @yenitablo where UrunBarkodu=urunler.UrunBarkodu)
  INSERT INTO @stoktablo (TopUrun,GercekStok)
  select count(*)TopUrun, sum(StokSay�s�) Ger�ekStok from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
  where u.Sezon=@Sezon and u.UrunGrubu=@UrunGrubu )as b 
end

else if (@Sezon='all'and @UrunGrubu='all') -- hem marka hem tema de�i�tirildi�inde 
begin
  IF not EXISTS (select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
 where u.Marka=@Marka and u.Tema=@Tema and  DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi)as b)

 DELETE FROM @yenitablo WHERE Marka=@Marka and Tema=@Tema;

ELSE
  WITH urunler AS
 (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
 where u.Marka=@Marka and u.Tema=@Tema and  DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi)

INSERT INTO @yenitablo ( UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSay�s�,StokSay�s�)
SELECT UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSay�s�,StokSay�s�
FROM  urunler
where not exists (select * from @yenitablo where UrunBarkodu=urunler.UrunBarkodu)
  INSERT INTO @stoktablo (TopUrun,GercekStok)
  select count(*)TopUrun, sum(StokSay�s�) Ger�ekStok from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
 where u.Marka=@Marka and u.Tema=@Tema )as b
end

else if (@Sezon='all'and @Tema='all') -- hem marka hem urun grubu de�i�tirildi�inde
begin
  IF not EXISTS (select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
  where u.Marka=@Marka and u.UrunGrubu=@UrunGrubu and  DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi)as b)

 DELETE FROM @yenitablo WHERE Marka=@Marka and UrunGrubu=@UrunGrubu ;

ELSE
  WITH urunler AS
 (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
  where u.Marka=@Marka and u.UrunGrubu=@UrunGrubu and  DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi)

INSERT INTO @yenitablo ( UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSay�s�,StokSay�s�)
SELECT UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSay�s�,StokSay�s�
FROM  urunler
where not exists (select * from @yenitablo where UrunBarkodu=urunler.UrunBarkodu)
  INSERT INTO @stoktablo (TopUrun,GercekStok)
  select count(*) TopUrun, sum(StokSay�s�) Ger�ekStok from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
  where u.Marka=@Marka and u.UrunGrubu=@UrunGrubu )as b
end

else if (@UrunGrubu='all' and @Tema='all') -- hem marka hem sezon de�i�tirildi�inde
begin
  IF not EXISTS (select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where u.Marka=@Marka and u.Sezon=@Sezon and  DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi)as b)

 DELETE FROM @yenitablo WHERE Marka=@Marka and Sezon=@Sezon ;

ELSE
  WITH urunler AS
 (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where u.Marka=@Marka and u.Sezon=@Sezon and  DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi)

INSERT INTO @yenitablo ( UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSay�s�,StokSay�s�)
SELECT UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSay�s�,StokSay�s�
FROM  urunler
where not exists (select * from @yenitablo where UrunBarkodu=urunler.UrunBarkodu)
  INSERT INTO @stoktablo (TopUrun,GercekStok)
  select count(*)TopUrun, sum(StokSay�s�) Ger�ekStok from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where u.Marka=@Marka and u.Sezon=@Sezon)as b
end

else if (@Marka='all') -- marka d���nda t�m de�erler de�i�tirildi�inde
begin
  IF not EXISTS (select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
    where u.Sezon=@Sezon and u.UrunGrubu=@UrunGrubu and u.Tema=@Tema and  DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi)as b)

 DELETE FROM @yenitablo WHERE  Sezon=@Sezon and UrunGrubu=@UrunGrubu and Tema=@Tema ;

ELSE
  WITH urunler AS
 (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
   where u.Sezon=@Sezon and u.UrunGrubu=@UrunGrubu and u.Tema=@Tema and  DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi)
INSERT INTO @yenitablo ( UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSay�s�,StokSay�s�)
SELECT UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSay�s�,StokSay�s�
FROM  urunler
where not exists (select * from @yenitablo where UrunBarkodu=urunler.UrunBarkodu)
  INSERT INTO @stoktablo (TopUrun,GercekStok)
  select count(*) TopUrun, sum(StokSay�s�) Ger�ekStok from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
    where u.Sezon=@Sezon and u.UrunGrubu=@UrunGrubu and u.Tema=@Tema)as b
end

else if (@Sezon='all') -- sezon d���nda t�m de�erler de�i�tirildi�inde
begin
  IF not EXISTS (select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
    where u.Marka=@Marka and u.UrunGrubu=@UrunGrubu and u.Tema=@Tema and  DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi)as b)

 DELETE FROM @yenitablo WHERE  Marka=@Marka and UrunGrubu=@UrunGrubu and Tema=@Tema ;

ELSE
  WITH urunler AS
 (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
    where u.Marka=@Marka and u.UrunGrubu=@UrunGrubu and u.Tema=@Tema and  DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi)
INSERT INTO @yenitablo ( UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSay�s�,StokSay�s�)
SELECT UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSay�s�,StokSay�s�
FROM  urunler
where not exists (select * from @yenitablo where UrunBarkodu=urunler.UrunBarkodu)
  INSERT INTO @stoktablo (TopUrun,GercekStok)
  select count(*) TopUrun, sum(StokSay�s�) Ger�ekStok from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
    where u.Marka=@Marka and u.UrunGrubu=@UrunGrubu and u.Tema=@Tema )as b
end

else if (@UrunGrubu='all') -- urun grubu d���nda t�m de�erler de�i�tirildi�inde 
begin
  IF not EXISTS (select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
       where u.Marka=@Marka and u.Sezon=@Sezon and u.Tema=@Tema and  DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi)as b)

 DELETE FROM @yenitablo WHERE  Marka=@Marka and Sezon=@Sezon and Tema=@Tema ;

ELSE
  WITH urunler AS
 (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
       where u.Marka=@Marka and u.Sezon=@Sezon and u.Tema=@Tema and  DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi)

INSERT INTO @yenitablo ( UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSay�s�,StokSay�s�)
SELECT UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSay�s�,StokSay�s�
FROM  urunler
where not exists (select * from @yenitablo where UrunBarkodu=urunler.UrunBarkodu)
  INSERT INTO @stoktablo (TopUrun,GercekStok)
  select count(*) TopUrun, sum(StokSay�s�) Ger�ekStok from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
       where u.Marka=@Marka and u.Sezon=@Sezon and u.Tema=@Tema and  DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi)as b
end

else if (@Tema='all') -- tema d���nda t�m de�erler de�i�tirildi�inde
begin
  IF not EXISTS (select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
      where u.Marka=@Marka and u.Sezon=@Sezon and u.UrunGrubu=@UrunGrubu and  DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi
   )as b)

 DELETE FROM @yenitablo WHERE Marka=@Marka and Sezon=@Sezon and UrunGrubu=@UrunGrubu ;

ELSE
  WITH urunler AS
 (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
       where u.Marka=@Marka and u.Sezon=@Sezon and u.UrunGrubu=@UrunGrubu and  DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi
   )
INSERT INTO @yenitablo ( UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSay�s�,StokSay�s�)
SELECT UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSay�s�,StokSay�s�
FROM  urunler
where not exists (select * from @yenitablo where UrunBarkodu=urunler.UrunBarkodu)
  INSERT INTO @stoktablo (TopUrun,GercekStok)
  select count(*) TopUrun, sum(StokSay�s�) Ger�ekStok from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
      where u.Marka=@Marka and u.Sezon=@Sezon and u.UrunGrubu=@UrunGrubu )as b
end

else if (@Marka=@Marka and @Sezon=@Sezon and @UrunGrubu=@UrunGrubu and @Tema=@Tema) -- t�m ko�ullar belirtilirse
begin
  IF not EXISTS (select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
      where u.Marka=@Marka and u.Sezon=@Sezon and u.UrunGrubu=@UrunGrubu and u.Tema=@Tema and DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi

   )as b)

 DELETE FROM @yenitablo WHERE Marka=@Marka and Sezon=@Sezon and UrunGrubu=@UrunGrubu and Tema=@Tema  ;

ELSE
  WITH urunler AS
 (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
       where u.Marka=@Marka and u.Sezon=@Sezon and u.UrunGrubu=@UrunGrubu and u.Tema=@Tema and DepoSay�s�>@DepoSayisi and StokSay�s�>@StokSayisi)

INSERT INTO @yenitablo ( UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSay�s�,StokSay�s�)
SELECT UrunBarkodu, Marka, Sezon, UrunGrubu, Tema, DepoSay�s�,StokSay�s�
FROM  urunler
where not exists (select * from @yenitablo where UrunBarkodu=urunler.UrunBarkodu)
  INSERT INTO @stoktablo (TopUrun,GercekStok)
  select count(*)TopUrun, sum(StokSay�s�) Ger�ekStok from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu
      where u.Marka=@Marka and u.Sezon=@Sezon and u.UrunGrubu=@UrunGrubu and u.Tema=@Tema)as b
end


 fetch next from UrunlerCursor into @Marka,@Sezon,@UrunGrubu,@Tema,@DepoSayisi,@StokSayisi

 
 end 


 --top�r�n ve gercektok say�s�n� kosul tablosyla birle�tirme
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
--T�m �r�nler olucak fakat tak� �r�nler olmayacak
select * from (
select 
  u.UrunBarkodu, u.Marka, u.Sezon, u.UrunGrubu,u.Tema, tablo.DepoSay�s�,tablo.StokSay�s� 
   from UrunTb as u 
   inner join (select d.UrunBarkodu, count(d.DepoKodu) DepoSay�s�, sum(d.StokSayisi) StokSay�s� from UrunTb as u 
   full join DepoTb as d on d.UrunBarkodu=u.UrunBarkodu group by d.UrunBarkodu) as tablo on 
   tablo.UrunBarkodu= u.UrunBarkodu where not exists (select * from KosulTb where UrunGrubu='tak�'))as b
    