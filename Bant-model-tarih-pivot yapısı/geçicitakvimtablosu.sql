
use TarihBant
go
--*takvim tablosu kýsmý*--

-- Geçici Takvim TABLOSUNU OLUÞTURUDUM

CREATE TABLE #Takvim
(
    id int identity(1,1),
    Tarih DATE
);

--Baþlangýc ve bitiþ zamanýný belirledim
DECLARE @BaslangicTarihi DATE;
DECLARE @BitisTarihi DATE;
SET @BaslangicTarihi = '20221220';
SET @BitisTarihi ='20230401';

--Adým adým tarihleri ekledimr
WHILE @BaslangicTarihi <= @BitisTarihi
BEGIN
    INSERT INTO #Takvim
    (
        Tarih
    )
    SELECT @BaslangicTarihi;
    SET @BaslangicTarihi = DATEADD(dd, 1, @BaslangicTarihi);
END;

--haftasonu tarihlerini sildim
delete #Takvim where DATENAME(weekday, Tarih) = 'Saturday' 
delete #Takvim where DATENAME(weekday, Tarih) = 'Sunday' 
--yýlbaþý tatili
delete #Takvim where Tarih='2023-01-01'
--Ulusal Egemenlik ve Çocuk Bayramý tatili
delete #Takvim where Tarih='2023-04-23'
--Emek ve Dayanýþma Günü tatili
delete #Takvim where Tarih='2023-05-01'
--Ramazan Bayramý tatili
delete #Takvim where Tarih='2023-04-21'
delete #Takvim where Tarih='2023-04-22'
delete #Takvim where Tarih='2023-04-23'
--Atatürk'ü Anma, Gençlik ve Spor Bayramý tatili
delete #Takvim where Tarih='2023-05-19'
--Kurban Bayramý tatili
delete #Takvim where Tarih='2023-06-28'
delete #Takvim where Tarih='2023-06-29'
delete #Takvim where Tarih='2023-06-30'
delete #Takvim where Tarih='2023-07-01'
--Demokrasi Bayramý tatili
delete #Takvim where Tarih='2023-07-15'
--Zafer Bayramý tatili
delete #Takvim where Tarih='2023-08-30'
--Cumhuriyet Bayramý tatili
delete #Takvim where Tarih='2023-10-29'

--*****--

--Pivot bant kaydý tablosu kýsmý

--tanýmlamalarý yaptým
DECLARE @cols AS NVARCHAR(MAX)
DECLARE @query  AS NVARCHAR(MAX)

select @cols = STUFF((SELECT distinct 
           ',' + QUOTENAME(Bant)
               FROM FabrikaTb
               FOR XML PATH(''), TYPE
               ).value('(./text())[1]', 'NVARCHAR(MAX)'),1,1,'')

--tarihlere göre fabirkatablosununu birleþtirdim	
SET @query = 'SELECT p.tarih as Tarih,  
          ' + @cols + ' ,k.BantSayýsý,k.ToplamAdet from 
         (
            SELECT t.tarih,f.bant,f.model FROM #Takvim as t left join FabrikaTb as f on t.Tarih>=f.IlkGiris and t.tarih<=f.SonGiris
        ) x

        pivot 
        (
            MIN(model)
            for Bant in (' + @cols + ')
        ) p

		 inner join 
		 (SELECT t.tarih, count(bant) as BantSayýsý, SUM(adet) as ToplamAdet FROM #Takvim as t left join FabrikaTb as f on t.Tarih>=f.IlkGiris and t.tarih<=f.SonGiris
          group by Tarih) as k

on p.tarih=k.tarih
		'
		
execute(@query)


