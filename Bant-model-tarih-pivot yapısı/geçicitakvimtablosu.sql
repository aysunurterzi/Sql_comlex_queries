
use TarihBant
go
--*takvim tablosu k�sm�*--

-- Ge�ici Takvim TABLOSUNU OLU�TURUDUM

CREATE TABLE #Takvim
(
    id int identity(1,1),
    Tarih DATE
);

--Ba�lang�c ve biti� zaman�n� belirledim
DECLARE @BaslangicTarihi DATE;
DECLARE @BitisTarihi DATE;
SET @BaslangicTarihi = '20221220';
SET @BitisTarihi ='20230401';

--Ad�m ad�m tarihleri ekledimr
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
--y�lba�� tatili
delete #Takvim where Tarih='2023-01-01'
--Ulusal Egemenlik ve �ocuk Bayram� tatili
delete #Takvim where Tarih='2023-04-23'
--Emek ve Dayan��ma G�n� tatili
delete #Takvim where Tarih='2023-05-01'
--Ramazan Bayram� tatili
delete #Takvim where Tarih='2023-04-21'
delete #Takvim where Tarih='2023-04-22'
delete #Takvim where Tarih='2023-04-23'
--Atat�rk'� Anma, Gen�lik ve Spor Bayram� tatili
delete #Takvim where Tarih='2023-05-19'
--Kurban Bayram� tatili
delete #Takvim where Tarih='2023-06-28'
delete #Takvim where Tarih='2023-06-29'
delete #Takvim where Tarih='2023-06-30'
delete #Takvim where Tarih='2023-07-01'
--Demokrasi Bayram� tatili
delete #Takvim where Tarih='2023-07-15'
--Zafer Bayram� tatili
delete #Takvim where Tarih='2023-08-30'
--Cumhuriyet Bayram� tatili
delete #Takvim where Tarih='2023-10-29'

--*****--

--Pivot bant kayd� tablosu k�sm�

--tan�mlamalar� yapt�m
DECLARE @cols AS NVARCHAR(MAX)
DECLARE @query  AS NVARCHAR(MAX)

select @cols = STUFF((SELECT distinct 
           ',' + QUOTENAME(Bant)
               FROM FabrikaTb
               FOR XML PATH(''), TYPE
               ).value('(./text())[1]', 'NVARCHAR(MAX)'),1,1,'')

--tarihlere g�re fabirkatablosununu birle�tirdim	
SET @query = 'SELECT p.tarih as Tarih,  
          ' + @cols + ' ,k.BantSay�s�,k.ToplamAdet from 
         (
            SELECT t.tarih,f.bant,f.model FROM #Takvim as t left join FabrikaTb as f on t.Tarih>=f.IlkGiris and t.tarih<=f.SonGiris
        ) x

        pivot 
        (
            MIN(model)
            for Bant in (' + @cols + ')
        ) p

		 inner join 
		 (SELECT t.tarih, count(bant) as BantSay�s�, SUM(adet) as ToplamAdet FROM #Takvim as t left join FabrikaTb as f on t.Tarih>=f.IlkGiris and t.tarih<=f.SonGiris
          group by Tarih) as k

on p.tarih=k.tarih
		'
		
execute(@query)


