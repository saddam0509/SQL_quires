USE [gBankerBUROBD]
GO
/****** Object:  UserDefinedFunction [dbo].[fnc_RPT_MonthlyStatisticsReport_Buro]    Script Date: 5/30/2018 12:57:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Select * From fnc_RPT_MonthlyStatisticsReport_Buro (54,8,'31 Jan 2018')

*/


ALTER function [dbo].[fnc_RPT_MonthlyStatisticsReport_Buro]
					(
					@OrgId int,@OfficeId int,@DateTo Date
					)

returns @Report Table(
ReportType int
,OfficeId int
,ItemHeadID int
,ItemHeadName NVARCHAR(100)
,ItemSubID int
,ItemSubName NVARCHAR(100)
,Data1 numeric(18,0)
,Data2 numeric(18,0)
--,Data1 NVARCHAR(50)
--,Data2 NVARCHAR(50)
)
As
Begin


Declare @OffTbl table(OfficeID int)
DeclaRE @OfficeLevel int,@officeCode varchar(30)
select @OfficeLevel=OfficeLevel from Office where OfficeID=@OfficeId
if @OfficeLevel=4
Begin
	select @officeCode=OfficeCode from Office where OfficeID=@OfficeId
	 Insert into @OffTbl
	 select OfficeID from Office where OfficeCode=@officeCode
End
if @OfficeLevel=3
Begin
	select @officeCode=OfficeCode from Office where OfficeID=@OfficeId
	 Insert into @OffTbl
	 select OfficeID from Office where ThirdLevel=@officeCode
End

if @OfficeLevel=2
Begin
	select @officeCode=OfficeCode from Office where OfficeID=@OfficeId
	 Insert into @OffTbl
	 select OfficeID from Office where SecondLevel=@officeCode
End
if @OfficeLevel=1
Begin
	---select @officeCode=OfficeCode from Office where OfficeID=@Office
	 Insert into @OffTbl
	 select OfficeID from Office where OfficeLevel=4
End


Declare @Table Table(
ReportType int
,OfficeId int
,ItemHeadID int
,ItemHeadName NVARCHAR(100)
,ItemSubID int
,ItemSubName NVARCHAR(100)
,Data1 numeric(18,0)
,Data2 numeric(18,0)
--,Data1 NVARCHAR(50)
--,Data2 NVARCHAR(50)
)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 1 as Reportype,OfficeID,1 as ItemHeadID,'Working Area' as ItemHeadName,0 as ItemSubID,'Working Area' as ItemSubName,0 as Data1,0 as Data2
From Office Where OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 1 as Reportype,f.OfficeID,1 as ItemHeadID,'Working Area' as ItemHeadName,1 as ItemSubID,'Number of District' as ItemSubName,Count(Distinct DistrictCode) as Data1,0 as Data2
From(
Select Distinct m.OfficeID,v.DistrictCode
--Select *
From Member m
Left Join LgVillage v ON m.VillageCode=v.VillageCode
Where m.IsActive=1
AND m.OfficeID In (Select OfficeID From @OffTbl)
AND m.MemberStatus=1
AND m.JoinDate<=@DateTo
) f
Group By OfficeID

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
	--Select Top 10 * From LgVillage
Select 1 as Reportype,f.OfficeID,1 as ItemHeadID,'Working Area' as ItemHeadName,2 as ItemSubID,'Number of Upazilla/Thana' as ItemSubName,Count(Distinct UpozillaCode) as Data,0 as Data2
From(
Select Distinct m.OfficeID,v.UpozillaCode
--Select *
From Member m
Left Join LgVillage v ON m.VillageCode=v.VillageCode
Where m.IsActive=1
AND m.OfficeID In (Select OfficeID From @OffTbl)
AND m.MemberStatus=1
AND m.JoinDate<=@DateTo
) f
Group By OfficeID

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
	--Select Top 10 * From LgVillage
Select 1 as Reportype,f.OfficeID,1 as ItemHeadID,'Working Area' as ItemHeadName,3 as ItemSubID,'Number of Union' as ItemSubName,Count(Distinct UnionCode) as Data,0 as Data2
From(
Select Distinct m.OfficeID,v.UnionCode
--Select *
From Member m
Left Join LgVillage v ON m.VillageCode=v.VillageCode
Where m.IsActive=1
AND m.OfficeID In (Select OfficeID From @OffTbl)
AND m.MemberStatus=1
AND m.JoinDate<=@DateTo
) f
Group By OfficeID

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
	--Select Top 10 * From LgVillage
Select 1 as Reportype,f.OfficeID,1 as ItemHeadID,'Working Area' as ItemHeadName,4 as ItemSubID,'Number of Village' as ItemSubName,Count(Distinct VillageCode) as Data,0 as Data2
From(
Select Distinct m.OfficeID,v.VillageCode
--Select *
From Member m
Left Join LgVillage v ON m.VillageCode=v.VillageCode
Where m.IsActive=1
AND m.OfficeID In (Select OfficeID From @OffTbl)
AND m.MemberStatus=1
AND m.JoinDate<=@DateTo
) f
Group By OfficeID


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 2 as Reportype,OfficeID,1 as ItemHeadID,'Information About Primary Member' as ItemHeadName
--,0 as ItemSubID,'Information About Primary Member' as ItemSubName,CAST('Male' as Numeric) as Data1,'Female' as Data2
,0 as ItemSubID,'Information About Primary Member' as ItemSubName,'0' as Data1,'0' as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 2 as Reportype,OfficeID,1 as ItemHeadID,'Information About Primary Member' as ItemHeadName
,1 as ItemSubID,'a) Number of Customers According to Admission Register' as ItemSubName, SUM(Data1) as Data1, SUM(Data2) as Data2
From (
Select OfficeID,Case When Left(Gender,1)='M' Then Count(Distinct m.MemberCode) Else 0 end as Data1
,Case When Left(Gender,1)='F' Then Count(Distinct m.MemberCode) Else 0 end as Data2
From Member m
Where m.IsActive=1
AND m.OfficeID In (Select OfficeID From @OffTbl)
AND m.MemberStatus Not In (0,5)
AND m.JoinDate<=@DateTo
Group By OfficeID,Gender
) f
Group By OfficeID


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 2 as Reportype,OfficeID,1 as ItemHeadID,'Information About Primary Member' as ItemHeadName
,2 as ItemSubID,'b) Number of Dropout Customers' as ItemSubName, sum(Data1) as Data1, sum(Data2) as Data2
From (
Select OfficeID,Case When Left(Gender,1)='M' Then Count(Distinct m.MemberCode) Else 0 end as Data1
,Case When Left(Gender,1)='F' Then Count(Distinct m.MemberCode) Else 0 end as Data2
From Member m
Where m.IsActive=1
AND m.OfficeID In (Select OfficeID From @OffTbl)
AND m.MemberStatus Not In (2)
AND m.ReleaseDate<=@DateTo
Group By OfficeID,Gender
) f
Group By OfficeID


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 2 as Reportype,OfficeID,1 as ItemHeadID,'Information About Primary Member' as ItemHeadName
,3 as ItemSubID,'c) Number of Dormant Customers (Group/Center Left Customers)' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 2 as Reportype,OfficeID,1 as ItemHeadID,'Information About Primary Member' as ItemHeadName
,4 as ItemSubID,'d) Number of Dormant Customers (Group/Center Not Left Custom)' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 2 as Reportype,OfficeID,1 as ItemHeadID,'Information About Primary Member' as ItemHeadName
,5 as ItemSubID,'e) Number of Active Customers (a-b-c)' as ItemSubName, sum(Data1) as Data1, sum(Data2) as Data2
From (Select OfficeID,Case When Left(Gender,1)='M' Then Count(Distinct m.MemberCode) Else 0 end as Data1
,Case When Left(Gender,1)='F' Then Count(Distinct m.MemberCode) Else 0 end as Data2
From Member m
Where m.IsActive=1
AND m.OfficeID In (Select OfficeID From @OffTbl)
AND m.MemberStatus=1
AND m.JoinDate<=@DateTo
Group By OfficeID,Gender
	Union 
Select OfficeID,Case When Left(Gender,1)='M' Then Count(Distinct m.MemberCode) Else 0 end as Data1
,Case When Left(Gender,1)='F' Then Count(Distinct m.MemberCode) Else 0 end as Data2
From Member m
Where m.IsActive=1
AND m.OfficeID In (Select OfficeID From @OffTbl)
AND m.MemberStatus=2
AND m.JoinDate<=@DateTo AND ReleaseDate>@DateTo
Group By OfficeID,Gender
) f
Group By OfficeID



Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 3 as Reportype,OfficeID,1 as ItemHeadID,'Micro Enterprise Member' as ItemHeadName
,0 as ItemSubID,'Micro Enterprise Member' as ItemSubName,'0' as Data1,'0' as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 3 as Reportype,OfficeID,1 as ItemHeadID,'Micro Enterprise Member' as ItemHeadName
,1 as ItemSubID,'a) Total Number of Micro Enterprise Custome' as ItemSubName,sum(Data1) as Data1,sum(Data2) as Data2
From (
Select OfficeID,Case When Left(Gender,1)='M' Then Count(Distinct m.MemberCode) Else 0 end as Data1
,Case When Left(Gender,1)='F' Then Count(Distinct m.MemberCode) Else 0 end as Data2
From Member m
Where m.IsActive=1
AND m.OfficeID In (Select OfficeID From @OffTbl)
AND m.MemberStatus Not In (0,5)
AND m.JoinDate<=@DateTo
Group By OfficeID,Gender
) f
Group By OfficeID

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 3 as Reportype,OfficeID,1 as ItemHeadID,'Micro Enterprise Member' as ItemHeadName
,2 as ItemSubID,'b) Number of Dropout Customers ' as ItemSubName,sum(Data1) as Data1, sum(Data2) as Data2
From (
Select OfficeID,Case When Left(Gender,1)='M' Then Count(Distinct m.MemberCode) Else 0 end as Data1
,Case When Left(Gender,1)='F' Then Count(Distinct m.MemberCode) Else 0 end as Data2
From Member m
Where m.IsActive=1
AND m.OfficeID In (Select OfficeID From @OffTbl)
AND m.MemberStatus Not In (2)
AND m.ReleaseDate<=@DateTo
Group By OfficeID,Gender
) f
Group By OfficeID



Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 3 as Reportype,OfficeID,1 as ItemHeadID,'Micro Enterprise Member' as ItemHeadName
,3 as ItemSubID,'c) Number of  Dormant Customers' as ItemSubName,0 as Data1,0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 3 as Reportype,OfficeID,1 as ItemHeadID,'Micro Enterprise Member' as ItemHeadName
,4 as ItemSubID,'d) Number of Active Customers (a-b-c)' as ItemSubName,4 as Data1,0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 4 as Reportype,OfficeID,1 as ItemHeadID,'Number of Groups' as ItemHeadName
,1 as ItemSubID,'Number of Groups' as ItemSubName, sum(Data1) as Data1, sum(Data2) as Data2
from(
select m.OfficeID, Case When Left(Gender,1)='M' Then Count(Distinct g.GroupCode) Else 0 end as Data1
,Case When Left(Gender,1)='F' Then Count(Distinct g.GroupCode) Else 0 end as Data2
from [Group] as g
inner join Member m on g.GroupID=m.GroupID
Where m.IsActive=1
AND m.OfficeID In (Select OfficeID From @OffTbl)
AND m.MemberStatus=1
AND m.JoinDate<=@DateTo
group by m.OfficeID, Gender 
) f
Group by OfficeID


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 5 as Reportype,OfficeID,1 as ItemHeadID,'Number of Center & Samitys' as ItemHeadName
,1 as ItemSubID,'Number of Center & Samitys' as ItemSubName,sum(Data1) as Data1, sum(Data2) as Data2
From (
Select m.OfficeID,Case When Left(Gender,1)='M' Then Count(Distinct c.CenterCode) Else 0 end as Data1
,Case When Left(Gender,1)='F' Then Count(Distinct c.CenterCode) Else 0 end as Data2
from Center as c
inner join Member m on c.CenterID=m.CenterID
Where m.IsActive=1
AND m.OfficeID In (Select OfficeID From @OffTbl)
AND m.MemberStatus=1
AND m.JoinDate<=@DateTo
group by m.OfficeID, Gender
) f
Group by OfficeID


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 6 as Reportype,OfficeID,1 as ItemHeadID,'Information About Contractual Savings A/C' as ItemHeadName
,0 as ItemSubID,'Information About Contractual Savings A/C' as ItemSubName,'0' as Data1,'0' as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 6 as Reportype,OfficeID,1 as ItemHeadID,'Information About Contractual Savings A/C' as ItemHeadName
,1 as ItemSubID,'Weekly' as ItemSubName,0 as Data1,0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 6 as Reportype,OfficeID,1 as ItemHeadID,'Information About Contractual Savings A/C' as ItemHeadName
,2 as ItemSubID,'a) Number of Accounts' as ItemSubName,'0' as Data1,Data2 as Data2
From (
select ss.OfficeID, count(ss.SavingSummaryID) as Data2
from SavingSummary as ss
inner join Product p on ss.ProductID = p.ProductID
WHere ss.IsActive=1
AND ss.OfficeID In (Select OfficeID From @OffTbl)
AND OpeningDate<=@DateTo
AND Left(ProductCode,2)='23'
and p.PaymentFrequency='W'
group by ss.OfficeID
) f

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 6 as Reportype,OfficeID,1 as ItemHeadID,'Information About Contractual Savings A/C' as ItemHeadName
,3 as ItemSubID,'b) Number of Dropout Accounts' as ItemSubName,0 as Data1,5798 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 6 as Reportype,OfficeID,1 as ItemHeadID,'Information About Contractual Savings A/C' as ItemHeadName
,4 as ItemSubID,'c) Number of Dormant Accounts' as ItemSubName,0 as Data1,0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 6 as Reportype,OfficeID,1 as ItemHeadID,'Information About Contractual Savings A/C' as ItemHeadName
,5 as ItemSubID,'d) Number of Active Accounts (a-b-c)' as ItemSubName,0 as Data1,904 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 6 as Reportype,OfficeID,1 as ItemHeadID,'Information About Contractual Savings A/C' as ItemHeadName
,6 as ItemSubID,'Monthly' as ItemSubName,0 as Data1,0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 6 as Reportype,OfficeID,1 as ItemHeadID,'Information About Contractual Savings A/C' as ItemHeadName
,7 as ItemSubID,'a) Number of Accounts' as ItemSubName,0 as Data1,9488 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 6 as Reportype,OfficeID,1 as ItemHeadID,'Information About Contractual Savings A/C' as ItemHeadName
,8 as ItemSubID,'b) Number of Dropout Accounts' as ItemSubName,0 as Data1,7069  as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 6 as Reportype,OfficeID,1 as ItemHeadID,'Information About Contractual Savings A/C' as ItemHeadName
,9 as ItemSubID,'c) Number of Dormant Accounts' as ItemSubName,0 as Data1,0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 6 as Reportype,OfficeID,1 as ItemHeadID,'Information About Contractual Savings A/C' as ItemHeadName
,10 as ItemSubID,'d) Number of Active Accounts (a-b-c)' as ItemSubName,0 as Data1,2419 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 6 as Reportype,OfficeID,1 as ItemHeadID,'Information About Contractual Savings A/C' as ItemHeadName
,11 as ItemSubID,'Total Number of Active Weekly/Monthly Contractual Savings A' as ItemSubName,0 as Data1,3323 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 7 as Reportype,OfficeID,1 as ItemHeadID,'Information About General Savings-2 A/C' as ItemHeadName
,0 as ItemSubID,'Information About General Savings-2 A/C' as ItemSubName,0 as Data1,0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 7 as Reportype,OfficeID,1 as ItemHeadID,'Information About General Savings-2 A/C' as ItemHeadName
,1 as ItemSubID,'Weekly' as ItemSubName,0 as Data1,0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 7 as Reportype,OfficeID,1 as ItemHeadID,'Information About General Savings-2 A/C' as ItemHeadName
,2 as ItemSubID,'a) Number of Accounts' as ItemSubName,0 as Data1,3839 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)



Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 7 as Reportype,OfficeID,1 as ItemHeadID,'Information About General Savings-2 A/C' as ItemHeadName
,3 as ItemSubID,'b) Number of Dropout Accounts' as ItemSubName,0 as Data1,3332 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 7 as Reportype,OfficeID,1 as ItemHeadID,'Information About General Savings-2 A/C' as ItemHeadName
,4 as ItemSubID,'c) Number of Dormant Accounts' as ItemSubName,0 as Data1,0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 7 as Reportype,OfficeID,1 as ItemHeadID,'Information About General Savings-2 A/C' as ItemHeadName
,5 as ItemSubID,'d) Number of Active Accounts (a-b-c)' as ItemSubName,0 as Data1,491 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 7 as Reportype,OfficeID,1 as ItemHeadID,'Information About General Savings-2 A/C' as ItemHeadName
,6 as ItemSubID,'Monthly' as ItemSubName,0 as Data1,0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 7 as Reportype,OfficeID,1 as ItemHeadID,'Information About General Savings-2 A/C' as ItemHeadName
,7 as ItemSubID,'a) Number of Accounts' as ItemSubName, 0 as Data1,2 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 7 as Reportype,OfficeID,1 as ItemHeadID,'Information About General Savings-2 A/C' as ItemHeadName
,8 as ItemSubID,'b) Number of Dropout Accounts' as ItemSubName, 0 as Data1,2 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 7 as Reportype,OfficeID,1 as ItemHeadID,'Information About General Savings-2 A/C' as ItemHeadName
,9 as ItemSubID,'c) Number of Dormant Accounts' as ItemSubName,0 as Data1,0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 7 as Reportype,OfficeID,1 as ItemHeadID,'Information About General Savings-2 A/C' as ItemHeadName
,10 as ItemSubID,'d) Number of Active Accounts (a-b-c)' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 7 as Reportype,OfficeID,1 as ItemHeadID,'Information About General Savings-2 A/C' as ItemHeadName
,10 as ItemSubID,'d) Number of Active Accounts (a-b-c)' as ItemSubName,0 as Data1,0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 7 as Reportype,OfficeID,1 as ItemHeadID,'Information About General Savings-2 A/C' as ItemHeadName
,11 as ItemSubID,'Total Number of Active General Savings-2 A/C' as ItemSubName, 0 as Data1,491 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 7 as Reportype,OfficeID,1 as ItemHeadID,'Information About General Savings-2 A/C' as ItemHeadName
,12 as ItemSubID,'Information About Time Deposit' as ItemSubName,0 as Data1,0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)



Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 7 as Reportype,OfficeID,1 as ItemHeadID,'Information About General Savings-2 A/C' as ItemHeadName
,13 as ItemSubID,'a) Number of Accounts' as ItemSubName, 0as Data1,0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)



Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 7 as Reportype,OfficeID,1 as ItemHeadID,'Information About General Savings-2 A/C' as ItemHeadName
,14 as ItemSubID,'b) Number of Dropout Accounts' as ItemSubName, 0 as Data1,0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)



Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 7 as Reportype,OfficeID,1 as ItemHeadID,'Information About General Savings-2 A/C' as ItemHeadName
,15 as ItemSubID,'c) Number of Dormant Accounts' as ItemSubName, 0 as Data1,0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 7 as Reportype,OfficeID,1 as ItemHeadID,'Information About General Savings-2 A/C' as ItemHeadName
,16 as ItemSubID,'d) Number of Active Accounts (a-b-c)' as ItemSubName,0 as Data1,0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 8 as Reportype,OfficeID,1 as ItemHeadID,'Number of Disbursed Borrowers' as ItemHeadName
,1 as ItemSubID, 'a) Number of Disbursed Borrowers' as ItemSubName,0 as Data1,10175 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 8 as Reportype,OfficeID,1 as ItemHeadID,'Number of Disbursed Borrowers' as ItemHeadName
,2 as ItemSubID, 'b) Number of Recovered Borrowers' as ItemSubName, 0 as Data1,8510 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 8 as Reportype,OfficeID,1 as ItemHeadID,'Number of Disbursed Borrowers' as ItemHeadName
,3 as ItemSubID, 'c) Number of Outstanding Borrowers' as ItemSubName, 0 as Data1,1665 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 9 as Reportype,OfficeID,1 as ItemHeadID,'Number of Overdue Borrowers' as ItemHeadName
,1 as ItemSubID, 'Number of Overdue Borrowers' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Information About Financial Security Fund' as ItemHeadName
,0 as ItemSubID, 'Information About Financial Security Fund' as ItemSubName, 0as Data1, 0as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Information About Financial Security Fund' as ItemHeadName
,1 as ItemSubID, 'Financial Security Fund Receipts' as ItemSubName,0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Information About Financial Security Fund' as ItemHeadName
,2 as ItemSubID, ' ' as ItemSubName,39571 as Data1,6147095 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)



Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Information About Financial Security Fund' as ItemHeadName
,3 as ItemSubID,'a) Premium 30 Taka' as ItemSubName,0 as Data1,0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)



Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Information About Financial Security Fund' as ItemHeadName
,4 as ItemSubID,'b) Premium 50 Taka' as ItemSubName,14961 as Data1,748050 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)



Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Information About Financial Security Fund' as ItemHeadName
,5 as ItemSubID,'c) Premium 60 Taka' as ItemSubName,0 as Data1,0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Information About Financial Security Fund' as ItemHeadName
,6 as ItemSubID,'d) Premium 100 Taka' as ItemSubName,9274 as Data1,927400 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Information About Financial Security Fund' as ItemHeadName
,7 as ItemSubID,'e) Premium 150 Taka' as ItemSubName,93 as Data1,13950 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Information About Financial Security Fund' as ItemHeadName
,8 as ItemSubID,'f) Premium 200 Taka' as ItemSubName,73 as Data1,14600 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Information About Financial Security Fund' as ItemHeadName
,9 as ItemSubID,'g) Premium 250 Taka' as ItemSubName,39 as Data1,9750 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Information About Financial Security Fund' as ItemHeadName
,10 as ItemSubID,'h) Premium 300 Taka' as ItemSubName,11 as Data1,3300 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Information About Financial Security Fund' as ItemHeadName
,11 as ItemSubID,'i) Premium 0.50%' as ItemSubName,0 as Data1,0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Information About Financial Security Fund' as ItemHeadName
,12 as ItemSubID,'j) Premium 1.00%' as ItemSubName,12943 as Data1,1779975 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Information About Financial Security Fund' as ItemHeadName
,13 as ItemSubID,'k) Premium 1.25%' as ItemSubName,13 as Data1,2598570 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Information About Financial Security Fund' as ItemHeadName
,14 as ItemSubID,'l) Premium 1.50%' as ItemSubName,0 as Data1,0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)



Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Information About Financial Security Fund' as ItemHeadName
,15 as ItemSubID, 'Financial Security Fund Payments' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)



Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Claim of Customers' as ItemHeadName
,16 as ItemSubID, 'Claim of Customers' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Claim of Customers' as ItemHeadName
,17 as ItemSubID, ' ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Claim of Customers' as ItemHeadName
,18 as ItemSubID, 'a)Number of Premium 30 Taka ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Claim of Customers' as ItemHeadName
,19 as ItemSubID, 'b)Number of Premium 50 Taka ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Claim of Customers' as ItemHeadName
,20 as ItemSubID, 'c)Number of Premium 60 Taka ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Claim of Customers' as ItemHeadName
,21 as ItemSubID, 'd)Number of Premium 100 Taka ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Claim of Customers' as ItemHeadName
,22 as ItemSubID, 'e)Number of Premium 150 Taka ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Claim of Customers' as ItemHeadName
,23 as ItemSubID, 'f)Number of Premium 200 Taka ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Claim of Customers' as ItemHeadName
,24 as ItemSubID, 'g)Number of Premium 250 Taka ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Claim of Customers' as ItemHeadName
,25 as ItemSubID, 'h)Number of Premium 300 Taka ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Claim of Customers' as ItemHeadName
,26 as ItemSubID, 'i)Number of Premium 0.5% ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Claim of Customers' as ItemHeadName
,27 as ItemSubID, 'j)Number of Premium 1.0% ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Claim of Customers' as ItemHeadName
,28 as ItemSubID, 'k)Number of Premium 1.25% ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Claim of Customers' as ItemHeadName
,29 as ItemSubID, 'l)Number of Premium 1.5% ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Claim of Customers Gurantor' as ItemHeadName
,30 as ItemSubID, 'Claim of Customers Gurantor' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Claim of Customers Gurantor' as ItemHeadName
,31 as ItemSubID, ' ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Claim of Customers Gurantor' as ItemHeadName
,32 as ItemSubID, 'a)Number of Premium 30 Taka ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Claim of Customers Gurantor' as ItemHeadName
,33 as ItemSubID, 'b)Number of Premium 50 Taka ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Claim of Customers Gurantor' as ItemHeadName
,34 as ItemSubID, 'c)Number of Premium 60 Taka ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Claim of Customers Gurantor' as ItemHeadName
,35 as ItemSubID, 'd)Number of Premium 100 Taka ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Claim of Customers Gurantor' as ItemHeadName
,36 as ItemSubID, 'e)Number of Premium 150 Taka ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Claim of Customers Gurantor' as ItemHeadName
,37 as ItemSubID, 'f)Number of Premium 200 Taka ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Claim of Customers Gurantor' as ItemHeadName
,38 as ItemSubID, 'g)Number of Premium 250 Taka ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Claim of Customers Gurantor' as ItemHeadName
,39 as ItemSubID, 'h)Number of Premium 300 Taka ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Claim of Customers Gurantor' as ItemHeadName
,40 as ItemSubID, 'i)Number of Premium 0.5% ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Claim of Customers Gurantor' as ItemHeadName
,41 as ItemSubID, 'j)Number of Premium 1.0% ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Claim of Customers Gurantor' as ItemHeadName
,42 as ItemSubID, 'k)Number of Premium 1.25% ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Claim of Customers Gurantor' as ItemHeadName
,43 as ItemSubID, 'l)Number of Premium 1.5% ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Amount Payment Claim of Customers' as ItemHeadName
,44 as ItemSubID, 'Claim of Customers' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Amount Payment Claim of Customers' as ItemHeadName
,45 as ItemSubID, ' ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Amount Payment Claim of Customers' as ItemHeadName
,46 as ItemSubID, 'a)Number of Premium 30 Taka ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Amount Payment Claim of Customers' as ItemHeadName
,47 as ItemSubID, 'b)Number of Premium 50 Taka ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Amount Payment Claim of Customers' as ItemHeadName
,48 as ItemSubID, 'c)Number of Premium 60 Taka ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Amount Payment Claim of Customers' as ItemHeadName
,49 as ItemSubID, 'd)Number of Premium 100 Taka ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Amount Payment Claim of Customers' as ItemHeadName
,50 as ItemSubID, 'e)Number of Premium 150 Taka ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Amount Payment Claim of Customers' as ItemHeadName
,51 as ItemSubID, 'f)Number of Premium 200 Taka ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Amount Payment Claim of Customers' as ItemHeadName
,52 as ItemSubID, 'g)Number of Premium 250 Taka ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Amount Payment Claim of Customers' as ItemHeadName
,53 as ItemSubID, 'h)Number of Premium 300 Taka ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Amount Payment Claim of Customers' as ItemHeadName
,54 as ItemSubID, 'i)Number of Premium 0.5% ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Amount Payment Claim of Customers' as ItemHeadName
,55 as ItemSubID, 'j)Number of Premium 1.0% ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Amount Payment Claim of Customers' as ItemHeadName
,56 as ItemSubID, 'k)Number of Premium 1.25% ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Amount Payment Claim of Customers' as ItemHeadName
,57 as ItemSubID, 'l)Number of Premium 1.5% ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)



Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Amount Payment Claim of Customer’s Guarantor' as ItemHeadName
,58 as ItemSubID, 'Claim of Customers' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Amount Payment Claim of Customer’s Guarantor' as ItemHeadName
,59 as ItemSubID, ' ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Amount Payment Claim of Customer’s Guarantor' as ItemHeadName
,60 as ItemSubID, 'a)Number of Premium 30 Taka ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Amount Payment Claim of Customer’s Guarantor' as ItemHeadName
,61 as ItemSubID, 'b)Number of Premium 50 Taka ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Amount Payment Claim of Customer’s Guarantor' as ItemHeadName
,62 as ItemSubID, 'c)Number of Premium 60 Taka ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Amount Payment Claim of Customer’s Guarantor' as ItemHeadName
,63 as ItemSubID, 'd)Number of Premium 100 Taka ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Amount Payment Claim of Customer’s Guarantor' as ItemHeadName
,64 as ItemSubID, 'e)Number of Premium 150 Taka ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Amount Payment Claim of Customer’s Guarantor' as ItemHeadName
,65 as ItemSubID, 'f)Number of Premium 200 Taka ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Amount Payment Claim of Customer’s Guarantor' as ItemHeadName
,66 as ItemSubID, 'g)Number of Premium 250 Taka ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Amount Payment Claim of Customer’s Guarantor' as ItemHeadName
,67 as ItemSubID, 'h)Number of Premium 300 Taka ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Amount Payment Claim of Customer’s Guarantor' as ItemHeadName
,68 as ItemSubID, 'i)Number of Premium 0.5% ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Amount Payment Claim of Customer’s Guarantor' as ItemHeadName
,69 as ItemSubID, 'j)Number of Premium 1.0% ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Amount Payment Claim of Customer’s Guarantor' as ItemHeadName
,70 as ItemSubID, 'k)Number of Premium 1.25% ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Amount Payment Claim of Customer’s Guarantor' as ItemHeadName
,71 as ItemSubID, 'l)Number of Premium 1.5% ' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Others' as ItemHeadName
,72 as ItemSubID, 'Others' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Others' as ItemHeadName
,73 as ItemSubID, 'Mat' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Others' as ItemHeadName
,74 as ItemSubID, 'Signature Register' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Others' as ItemHeadName
,75 as ItemSubID, 'Pen' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Others' as ItemHeadName
,76 as ItemSubID, 'Sign Board' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Others' as ItemHeadName
,77 as ItemSubID, 'Loan Adjustment' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 10 as Reportype,OfficeID,1 as ItemHeadID,'Others' as ItemHeadName
,78 as ItemSubID, 'Total Payment' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 11 as Reportype,OfficeID,1 as ItemHeadID,'Balance of Financial Security Fund' as ItemHeadName
,79 as ItemSubID, 'Balance of Financial Security Fund' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 11 as Reportype,OfficeID,1 as ItemHeadID,'Balance of Financial Security Fund' as ItemHeadName
,80 as ItemSubID, 'Information About Branch Staff' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 11 as Reportype,OfficeID,1 as ItemHeadID,'Balance of Financial Security Fund' as ItemHeadName
,81 as ItemSubID, 'Male (All)' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 11 as Reportype,OfficeID,1 as ItemHeadID,'Balance of Financial Security Fund' as ItemHeadName
,82 as ItemSubID, 'Female (All)' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 11 as Reportype,OfficeID,1 as ItemHeadID,'Balance of Financial Security Fund' as ItemHeadName
,83 as ItemSubID, 'Male (Program Organizer + Asst. Program Organizer)' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)

Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select 11 as Reportype,OfficeID,1 as ItemHeadID,'Balance of Financial Security Fund' as ItemHeadName
,84 as ItemSubID, 'Female (Program Organizer + Asst. Program Organizer)' as ItemSubName, 0 as Data1, 0 as Data2
From Office
WHere OfficeID In (Select OfficeID From @OffTbl)


--Insert @Table (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
--From Office
--WHere OfficeID In (Select OfficeID From @OffTbl)
---------------Final

Insert @Report (ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2)
Select ReportType,OfficeId,ItemHeadID,ItemHeadName,ItemSubID,ItemSubName,Data1,Data2
From @Table


return


End


/*
Select * From fnc_RPT_MonthlyStatisticsReport_Buro (54,8,'31 Jan 2018')

*/

