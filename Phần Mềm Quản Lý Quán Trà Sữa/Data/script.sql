USE [master]
GO

CREATE DATABASE [dtQLTraSua]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'dtQLTraSua', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\dtQLTraSua.mdf' , SIZE = 3136KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'dtQLTraSua_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\dtQLTraSua_log.ldf' , SIZE = 832KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [dtQLTraSua] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [dtQLTraSua].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [dtQLTraSua] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [dtQLTraSua] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [dtQLTraSua] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [dtQLTraSua] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [dtQLTraSua] SET ARITHABORT OFF 
GO
ALTER DATABASE [dtQLTraSua] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [dtQLTraSua] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [dtQLTraSua] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [dtQLTraSua] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [dtQLTraSua] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [dtQLTraSua] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [dtQLTraSua] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [dtQLTraSua] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [dtQLTraSua] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [dtQLTraSua] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [dtQLTraSua] SET  ENABLE_BROKER 
GO
ALTER DATABASE [dtQLTraSua] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [dtQLTraSua] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [dtQLTraSua] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [dtQLTraSua] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [dtQLTraSua] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [dtQLTraSua] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [dtQLTraSua] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [dtQLTraSua] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [dtQLTraSua] SET  MULTI_USER 
GO
ALTER DATABASE [dtQLTraSua] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [dtQLTraSua] SET DB_CHAINING OFF 
GO
ALTER DATABASE [dtQLTraSua] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [dtQLTraSua] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [dtQLTraSua]
GO
/****** Object:  StoredProcedure [dbo].[AddLuongNV]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[AddLuongNV]
@idNhanVien INT,
@cateNew FLOAT
AS
BEGIN
	UPDATE NhanVien
	SET luongUncheck = luongUncheck + @cateNew
	WHERE idNhanVien = @idNhanVien
END

GO
/****** Object:  StoredProcedure [dbo].[AllProductsSale]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[AllProductsSale]
@getIn DATE
AS
SELECT SUM(countD)
	FROM BillInfo as i INNER JOIN Bill as b ON i.idBill = b.idBill
	WHERE b.statusBill = 1 AND cast(getIn as Date) = @getIn

GO
/****** Object:  StoredProcedure [dbo].[BC_DoanhThuNgay]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[BC_DoanhThuNgay]
@date DATE
AS
BEGIN
	SELECT  MaBill , totalPrice*100 /(100 - sale) as tongtien , totalPrice*100 /(100 - sale) - totalPrice as sale, totalPrice , cast(getIn as date) as date
	FROM Bill 
	WHERE statusBill = 1 AND cast(getIn as date) = @date
END

GO
/****** Object:  StoredProcedure [dbo].[BC_DoanhThuThang]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[BC_DoanhThuThang]
@date DATE
AS
BEGIN
	SELECT * FROM BC_DoanhSo
	WHERE dates BETWEEN DATEADD(DAY,1,EOMONTH(@date,-1)) AND EOMONTH(@date)
END

GO
/****** Object:  StoredProcedure [dbo].[BC_DoanhThuTuan]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[BC_DoanhThuTuan]
@days DATE
AS
BEGIN
	SELECT * FROM BC_DoanhSo
	WHERE dates BETWEEN  DATEADD(DAY , -6,  @days)  AND @days
END

GO
/****** Object:  StoredProcedure [dbo].[BC_LuongNV]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[BC_LuongNV]
@date as DATE
AS
BEGIN
	SELECT tenNhanVien , SUM(luongUncheck + luongCashout) as totalLuong,  SUM(luongUncheck) as uncheckLuong, SUM(luongCashout) as checkLuong 
	FROM (NhanVien INNER JOIN ThanhToan ON NhanVien.idNhanVien = ThanhToan.idNhanVien)
	WHERE dateCheckout BETWEEN DATEADD(DAY,1,EOMONTH(@date,-1)) AND EOMONTH(@date)
	GROUP BY tenNhanVien
END

GO
/****** Object:  StoredProcedure [dbo].[DrinkPerWeek]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[DrinkPerWeek]
@days DATE
AS
BEGIN
	SELECT MaDrink , nameDrink ,  Sum(soLuong) as soLuong
	FROM DrinkPerTime 
	WHERE days BETWEEN  DATEADD(DAY , -6,  @days)  AND @days
	GROUP BY nameDrink , MaDrink
	ORDER BY soLuong DESC
END

GO
/****** Object:  StoredProcedure [dbo].[NumberCategoriesOnAll]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[NumberCategoriesOnAll]
@idCategoriesD INT, 
@getIn DATE
AS
BEGIN
	SELECT SUM(countD)
	FROM Drink as d INNER JOIN BillInfo as i ON d.idDrink = i.idDrink INNER JOIN Bill as b ON i.idBill = b.idBill
	WHERE b.statusBill = 1 AND d.idCategoriesD = @idCategoriesD AND cast(getIn as Date) = @getIn
END

GO
/****** Object:  StoredProcedure [dbo].[UpdateBillInfoById]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[UpdateBillInfoById]
@countD INT,
@price FLOAT , 
@idBillInfo INT
AS
BEGIN
	UPDATE BillInfo
	SET countD += @countD , price += @price
	WHERE idBillInfo = @idBillInfo
END

GO
/****** Object:  StoredProcedure [dbo].[UpdateLuongNV]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[UpdateLuongNV]
@idNhanVien INT,
@cateNew FLOAT,
@cateOld FLOAT
AS
BEGIN
	UPDATE NhanVien
	SET luongUncheck = luongUncheck + (@cateNew - @cateOld)
	WHERE idNhanVien = @idNhanVien
END

GO
/****** Object:  StoredProcedure [dbo].[UpdateNVCashout]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[UpdateNVCashout]
@idNhanVien INT
AS
BEGIN
	UPDATE NhanVien
	SET luongUncheck = 0 , luongCashout = luongCashout + luongUncheck
	WHERE idNhanVien = @idNhanVien
END

GO
/****** Object:  StoredProcedure [dbo].[USP_AddAccountByUserName]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[USP_AddAccountByUserName]
@userName NVARCHAR(100),
@displayName NVARCHAR(100),
@idTypeAccount INT,
@password NVARCHAR(1000)
AS
BEGIN
	INSERT AccountD
	(
		userName , displayName , idTypeAccount , password
	)
	VALUES
	(
		@userName , @displayName , @idTypeAccount , @password
	)
END

GO
/****** Object:  StoredProcedure [dbo].[USP_AddBillInfoByIdBill]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[USP_AddBillInfoByIdBill]
@idBill INT , 
@idDrink INT ,
@countD INT,
@price FLOAT
AS
BEGIN
	INSERT BillInfo
	(
		idBill , idDrink , countD , price
	)
	VALUES
	(
		@idBill , @idDrink , @countD , @price
	)
END

GO
/****** Object:  StoredProcedure [dbo].[USP_AddDrinkNoImagge]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[USP_AddDrinkNoImagge]
@nameDrink NVARCHAR(100),
@price FLOAT,
@idCategoriesD INT,
@idSizeDrink INT
AS
BEGIN
	INSERT Drink
	(
		nameDrink , price , idCategoriesD , idSizeDrink
	)
	VALUES
	(
		@nameDrink , @price ,@idCategoriesD , @idSizeDrink
	)
END

GO
/****** Object:  StoredProcedure [dbo].[USP_AddDrinkWithImage]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[USP_AddDrinkWithImage]
@nameDrink NVARCHAR(100),
@price FLOAT,
@idCategoriesD INT,
@idSizeDrink INT,
@picture IMAGE
AS
BEGIN
	INSERT Drink
	(
		nameDrink , price , idCategoriesD , idSizeDrink , picture
	)
	VALUES
	(
		@nameDrink , @price ,@idCategoriesD , @idSizeDrink , @picture
	)
END

GO
/****** Object:  StoredProcedure [dbo].[USP_AddNewCategories]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[USP_AddNewCategories]
@nameCategories NVARCHAR(100)
AS
BEGIN
	INSERT CategoriesD
	(
		nameCategories
	)
	VALUES
	(
		@nameCategories
	)
END

GO
/****** Object:  StoredProcedure [dbo].[USP_AddTable]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[USP_AddTable]
@nameTable NVARCHAR(100)
AS
BEGIN
	INSERT TableD 
	(
		nameTable
	)
	VALUES
	(
		@nameTable
	)
END

GO
/****** Object:  StoredProcedure [dbo].[USP_Cashout]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[USP_Cashout]
@idNhanVien INT,
@luongCheckout FLOAT
AS
BEGIN
	INSERT ThanhToan
	(
		idNhanVien , luongCheckout
	)
	VALUES
	(
		@idNhanVien , @luongCheckout
	)
END

GO
/****** Object:  StoredProcedure [dbo].[USP_CheckLogin]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Create proc
CREATE PROC [dbo].[USP_CheckLogin]
@useName NVARCHAR(100),
@password NVARCHAR(1000)
AS
BEGIN
	SELECT * FROM AccountD WHERE userName = @useName AND password = @password
END

GO
/****** Object:  StoredProcedure [dbo].[USP_CheckOutBill]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[USP_CheckOutBill]
@idBill INT, 
@sale FLOAT, 
@totalPrice FLOAT, 
@getOut DATETIME
AS
BEGIN
	UPDATE Bill
	SET getOut = @getOut , statusBill = 1 , sale = @sale , totalPrice = @totalPrice
	WHERE idBill = @idBill
END

GO
/****** Object:  StoredProcedure [dbo].[USP_CleanTableByIdTable]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[USP_CleanTableByIdTable]
@idTableD INT
AS
BEGIN
	UPDATE TableD
	SET status = 0
	WHERE idTableD = @idTableD
END

GO
/****** Object:  StoredProcedure [dbo].[USP_DeleteBillInfoById]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[USP_DeleteBillInfoById]
@idBillInfo INT
AS
BEGIN
	DELETE FROM BillInfo
	WHERE idBillInfo = @idBillInfo
END

GO
/****** Object:  StoredProcedure [dbo].[USP_EditDrinkNoImage]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[USP_EditDrinkNoImage]
@nameDrink NVARCHAR(100),
@price FLOAT,
@idCategoriesD INT,
@idSizeDrink INT,
@idDrink INT
AS
BEGIN
	UPDATE Drink
	SET nameDrink = @nameDrink , price = @price , idCategoriesD = @idCategoriesD , idSizeDrink = @idSizeDrink
	WHERE idDrink = @idDrink
END

GO
/****** Object:  StoredProcedure [dbo].[USP_EditDrinkWithImage]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[USP_EditDrinkWithImage]
@nameDrink NVARCHAR(100),
@price FLOAT,
@idCategoriesD INT,
@idSizeDrink INT,
@picture IMAGE,
@idDrink INT
AS
BEGIN
	UPDATE Drink
	SET nameDrink = @nameDrink , price = @price , idCategoriesD = @idCategoriesD , idSizeDrink = @idSizeDrink , picture = @picture
	WHERE idDrink = @idDrink
END

GO
/****** Object:  StoredProcedure [dbo].[USP_GetListDrinkByIdCategory]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[USP_GetListDrinkByIdCategory]
@idCategoriesD INT
AS
BEGIN
	SELECT nameDrink FROM Drink WHERE idCategoriesD = @idCategoriesD
	GROUP BY nameDrink
END

GO
/****** Object:  StoredProcedure [dbo].[USP_GetListDrinkByToDtgv]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[USP_GetListDrinkByToDtgv]
AS
BEGIN
	SELECT nameDrink , nameCategories , nameSizeDrink , price
	FROM (Drink INNER JOIN SizeDrink ON Drink.idSizeDrink = SizeDrink.idSizeDrink) INNER JOIN CategoriesD ON Drink.idCategoriesD = CategoriesD.idCategoriesD
END

GO
/****** Object:  StoredProcedure [dbo].[USP_InsertNewBillTable]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [dbo].[USP_InsertNewBillTable]
@idTableD INT,
@nmPeople INT
AS
BEGIN
	INSERT Bill
	(
		idTableD , nmPeople
	)
	VALUES
	(
		@idTableD , @nmPeople
	)
END

GO
/****** Object:  StoredProcedure [dbo].[USP_InsertNgayLuong]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[USP_InsertNgayLuong]
@idNhanVien INT,
@cateL INT,
@luongNgay FLOAT
AS
BEGIN
	INSERT NgayLuong
	(
		idNhanVien , cateL , luongNgay
	)
	VALUES
	(
		@idNhanVien , @cateL , @luongNgay
	)
END

GO
/****** Object:  StoredProcedure [dbo].[USP_InsertNhanvien]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[USP_InsertNhanvien] 
@tenNhanVien NVARCHAR(100), 
@idCateNV INT
AS
BEGIN
	INSERT NhanVien
	(
		tenNhanVien  , idCateNV , maNhanVien
	)
	VALUES
	(
		@tenNhanVien , @idCateNV , N'default'
	)
END

GO
/****** Object:  StoredProcedure [dbo].[USP_TKTakeAway]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[USP_TKTakeAway]
AS
BEGIN
	SELECT t.nmTK , b.nmBill , t.days
	FROM (SELECT COUNT(idBill) as nmTK, CAST(getIn as date) as days
	FROM Bill
	WHERE idTableD = 0
	GROUP BY CAST(getIn as date)) as t INNER JOIN (SELECT COUNT(idBill) as nmBill, CAST(getIn as date) as days
	FROM Bill
	GROUP BY CAST(getIn as date)) as b
	ON t.days = b.days
END

GO
/****** Object:  StoredProcedure [dbo].[USP_UpdateAccountByUserName]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[USP_UpdateAccountByUserName]
@userName NVARCHAR(100),
@displayName NVARCHAR(100),
@idTypeAccount INT,
@password NVARCHAR(1000)
AS
BEGIN
	UPDATE AccountD
	SET displayName = @displayName , idTypeAccount = @idTypeAccount , password = @password
	WHERE userName = @userName
END

GO
/****** Object:  StoredProcedure [dbo].[USP_UpdateAccountByUserNameNoPass]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[USP_UpdateAccountByUserNameNoPass]
@userName NVARCHAR(100) , 
@displayName NVARCHAR(100) , 
@idTypeAccount INT
AS
BEGIN
	UPDATE AccountD
	SET displayName = @displayName , idTypeAccount = @idTypeAccount
	WHERE userName = @userName
END

GO
/****** Object:  StoredProcedure [dbo].[USP_UpdateAccountByUserNameNoType]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[USP_UpdateAccountByUserNameNoType]
@userName NVARCHAR(100),
@displayName NVARCHAR(100),
@password NVARCHAR(1000)
AS
BEGIN
	UPDATE AccountD
	SET displayName = @displayName , password = @password
	WHERE userName = @userName
END

GO
/****** Object:  StoredProcedure [dbo].[USP_UpdateCategoriesName]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[USP_UpdateCategoriesName]
@nameold NVARCHAR(100),
@namenew NVARCHAR(100)
AS
BEGIN
	UPDATE CategoriesD
	SET nameCategories = @namenew
	WHERE nameCategories = @nameold
END

GO
/****** Object:  StoredProcedure [dbo].[USP_UpdateLuongNgay]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[USP_UpdateLuongNgay]
@idNgayLuong INT,
@idNhanVien INT,
@cateL INT,
@luongNgay FLOAT
AS
BEGIN
	UPDATE NgayLuong
	SET idNhanVien = @idNhanVien , cateL = @cateL , luongNgay = @luongNgay 
	WHERE idNhanVien = @idNhanVien
END

GO
/****** Object:  StoredProcedure [dbo].[USP_UpdateStatusTable]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[USP_UpdateStatusTable]
@idTableD INT
AS
BEGIN
	UPDATE TableD
	SET status = 1
	WHERE idTableD = @idTableD
END

GO
/****** Object:  Table [dbo].[AccountD]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AccountD](
	[userName] [nvarchar](100) NOT NULL,
	[displayName] [nvarchar](100) NOT NULL,
	[password] [nvarchar](1000) NOT NULL,
	[idTypeAccount] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[userName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Bill]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Bill](
	[idBill] [int] IDENTITY(1,1) NOT NULL,
	[idTableD] [int] NOT NULL,
	[nmPeople] [int] NOT NULL,
	[getIn] [datetime] NOT NULL,
	[getOut] [datetime] NULL,
	[statusBill] [int] NOT NULL,
	[sale] [float] NOT NULL,
	[totalPrice] [float] NOT NULL,
	[MaBill]  AS (case [idTableD] when (0) then case when [idBill]<(10) then isnull((N'TK00'+CONVERT([nvarchar](10),[idTableD]))+CONVERT([nvarchar](10),[idBill]),'X') else isnull((N'TK0'+CONVERT([nvarchar](10),[idTableD]))+CONVERT([nvarchar](10),[idBill]),'X') end else case when [idBill]<(10) then isnull((N'TB00'+CONVERT([nvarchar](10),[idTableD]))+CONVERT([nvarchar](10),[idBill]),'X') else isnull((N'TB0'+CONVERT([nvarchar](10),[idTableD]))+CONVERT([nvarchar](10),[idBill]),'X') end end),
PRIMARY KEY CLUSTERED 
(
	[idBill] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BillInfo]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BillInfo](
	[idBillInfo] [int] IDENTITY(1,1) NOT NULL,
	[idBill] [int] NOT NULL,
	[idDrink] [int] NOT NULL,
	[countD] [int] NOT NULL,
	[price] [float] NOT NULL,
	[MaBill]  AS (case case when [idBillInfo]>(10) then (1) else (2) end when (1) then isnull((N'MA00'+CONVERT([nvarchar](10),[idDrink]))+CONVERT([nvarchar](10),[idBillInfo]),'X') else isnull((N'BT00'+CONVERT([nvarchar](10),[idDrink]))+CONVERT([nvarchar](10),[idBillInfo]),'X') end),
PRIMARY KEY CLUSTERED 
(
	[idBillInfo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CategoriesD]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CategoriesD](
	[idCategoriesD] [int] IDENTITY(1,1) NOT NULL,
	[nameCategories] [nvarchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[idCategoriesD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[cateNhanvien]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cateNhanvien](
	[idCateNV] [int] IDENTITY(1,1) NOT NULL,
	[cateNhanVien] [nvarchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[idCateNV] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Drink]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Drink](
	[idDrink] [int] IDENTITY(1,1) NOT NULL,
	[nameDrink] [nvarchar](100) NOT NULL,
	[price] [float] NOT NULL,
	[idSizeDrink] [int] NOT NULL,
	[picture] [image] NULL,
	[idCategoriesD] [int] NOT NULL,
	[MaDrink]  AS (case [idCategoriesD] when (1) then case when [idDrink]<(10) then isnull(N'TS0000'+CONVERT([nvarchar](10),[idDrink]),'X') else isnull(N'TS000'+CONVERT([nvarchar](10),[idDrink]),'X') end when (2) then case when [idDrink]<(10) then isnull(N'TD0000'+CONVERT([nvarchar](10),[idDrink]),'X') else isnull(N'TD000'+CONVERT([nvarchar](10),[idDrink]),'X') end when (3) then case when [idDrink]<(10) then isnull(N'BA0000'+CONVERT([nvarchar](10),[idDrink]),'X') else isnull(N'BA000'+CONVERT([nvarchar](10),[idDrink]),'X') end when (4) then case when [idDrink]<(10) then isnull(N'TAN0000'+CONVERT([nvarchar](10),[idDrink]),'X') else isnull(N'TAN000'+CONVERT([nvarchar](10),[idDrink]),'X') end when (5) then case when [idDrink]<(10) then isnull(N'CA0000'+CONVERT([nvarchar](10),[idDrink]),'X') else isnull(N'CA000'+CONVERT([nvarchar](10),[idDrink]),'X') end when (6) then case when [idDrink]<(10) then isnull(N'YO0000'+CONVERT([nvarchar](10),[idDrink]),'X') else isnull(N'YO000'+CONVERT([nvarchar](10),[idDrink]),'X') end when (7) then case when [idDrink]<(10) then isnull(N'SA0000'+CONVERT([nvarchar](10),[idDrink]),'X') else isnull(N'SA000'+CONVERT([nvarchar](10),[idDrink]),'X') end else isnull(N'K000'+CONVERT([nvarchar](10),[idDrink]),'X') end),
PRIMARY KEY CLUSTERED 
(
	[idDrink] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[NgayLuong]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NgayLuong](
	[idNgayLuong] [int] IDENTITY(1,1) NOT NULL,
	[idNhanVien] [int] NOT NULL,
	[ngay] [date] NOT NULL,
	[luongNgay] [float] NULL,
	[cateL] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[idNgayLuong] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[NhanVien]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NhanVien](
	[idNhanVien] [int] IDENTITY(1,1) NOT NULL,
	[maNhanVien] [nvarchar](10) NOT NULL,
	[tenNhanVien] [nvarchar](100) NOT NULL,
	[idCateNV] [int] NOT NULL,
	[luongUncheck] [float] NULL,
	[luongCashout] [float] NULL,
	[MaNV]  AS (case [idCateNV] when (1) then isnull(N'PT0000'+CONVERT([nvarchar](10),[idNhanVien]),'X') else isnull(N'FT000'+CONVERT([nvarchar](10),[idNhanVien]),'X') end),
PRIMARY KEY CLUSTERED 
(
	[idNhanVien] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SizeDrink]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SizeDrink](
	[idSizeDrink] [int] IDENTITY(1,1) NOT NULL,
	[nameSizeDrink] [nvarchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[idSizeDrink] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TableD]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TableD](
	[idTableD] [int] IDENTITY(0,1) NOT NULL,
	[nameTable] [nvarchar](100) NOT NULL,
	[numberPeople] [int] NOT NULL,
	[status] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[idTableD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ThanhToan]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ThanhToan](
	[idThanhToan] [int] IDENTITY(1,1) NOT NULL,
	[idNhanVien] [int] NOT NULL,
	[dateCheckout] [date] NULL,
	[luongCheckout] [float] NOT NULL,
	[MaTT]  AS (isnull(((N'TT0000'+CONVERT([nvarchar](10),[idNhanVien]))+CONVERT([nvarchar](10),datepart(day,[dateCheckout])))+CONVERT([nvarchar](10),[idThanhToan]),'X')),
PRIMARY KEY CLUSTERED 
(
	[idThanhToan] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TypeAccount]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TypeAccount](
	[idTypeAccount] [int] IDENTITY(1,1) NOT NULL,
	[nameTypeAccount] [nvarchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[idTypeAccount] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[BC_DoanhSo]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[BC_DoanhSo]
AS
SELECT Count(idBill) as soBill , cast(getIn as date) as dates  , SUM(totalPrice*100 /(100 - sale)) as tongtien , SUM(totalPrice*100 /(100 - sale) - totalPrice) as sale, SUM(totalPrice) as totalPrice
FROM Bill 
WHERE statusBill = 1
GROUP BY cast(getIn as date)

GO
/****** Object:  View [dbo].[DrinkPerTime]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DrinkPerTime]
AS
SELECT  MaDrink , nameDrink , soLuong , days
FROM Drink INNER JOIN
	(SELECT SUM(countD) as soLuong , idDrink as categories , cast(getIn as date) as days
	FROM Bill INNER JOIN BillInfo
		ON Bill.idBill = BillInfo.idBill
	WHERE Bill.statusBill = 1
	GROUP BY cast(getIn as date) , idDrink) as B
	ON Drink.idDrink = B.categories

GO
/****** Object:  View [dbo].[HD_HoaDon]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[HD_HoaDon]
AS
SELECT i.idBill , b.idTableD , b.getIn , b.getOut , d.nameDrink , d.idSizeDrink , i.countD , d.price , b.sale
FROM Drink as d INNER JOIN BillInfo as i ON d.idDrink = i.idDrink INNER JOIN Bill as b ON i.idBill = b.idBill
WHERE statusBill = 1

GO
INSERT [dbo].[AccountD] ([userName], [displayName], [password], [idTypeAccount]) VALUES (N'admin', N'AD', N'222169221178921913582207772364834422165', 1)
INSERT [dbo].[AccountD] ([userName], [displayName], [password], [idTypeAccount]) VALUES (N'ad', N'AD', N'123', 1)
SET IDENTITY_INSERT [dbo].[CategoriesD] ON 

INSERT [dbo].[CategoriesD] ([idCategoriesD], [nameCategories]) VALUES (1, N'Trà sữa')
INSERT [dbo].[CategoriesD] ([idCategoriesD], [nameCategories]) VALUES (2, N'Trà đào')
INSERT [dbo].[CategoriesD] ([idCategoriesD], [nameCategories]) VALUES (3, N'Bánh')
INSERT [dbo].[CategoriesD] ([idCategoriesD], [nameCategories]) VALUES (4, N'Thức ăn nhanh')
INSERT [dbo].[CategoriesD] ([idCategoriesD], [nameCategories]) VALUES (5, N'Capuchino')
INSERT [dbo].[CategoriesD] ([idCategoriesD], [nameCategories]) VALUES (6, N'Yoshake')
INSERT [dbo].[CategoriesD] ([idCategoriesD], [nameCategories]) VALUES (7, N'Soda')
SET IDENTITY_INSERT [dbo].[CategoriesD] OFF
SET IDENTITY_INSERT [dbo].[cateNhanvien] ON 

INSERT [dbo].[cateNhanvien] ([idCateNV], [cateNhanVien]) VALUES (1, N'Part-Time')
INSERT [dbo].[cateNhanvien] ([idCateNV], [cateNhanVien]) VALUES (2, N'Full-Time')
SET IDENTITY_INSERT [dbo].[cateNhanvien] OFF
SET IDENTITY_INSERT [dbo].[Drink] ON 

INSERT [dbo].[Drink] ([idDrink], [nameDrink], [price], [idSizeDrink], [picture], [idCategoriesD]) VALUES (1, N'Trà sữa trà xanh', 15000, 1, NULL, 1)
INSERT [dbo].[Drink] ([idDrink], [nameDrink], [price], [idSizeDrink], [picture], [idCategoriesD]) VALUES (2, N'Trà sữa Socola', 15000, 1, NULL, 1)
INSERT [dbo].[Drink] ([idDrink], [nameDrink], [price], [idSizeDrink], [picture], [idCategoriesD]) VALUES (3, N'Trà đào có đào', 12000, 1, NULL, 2)
INSERT [dbo].[Drink] ([idDrink], [nameDrink], [price], [idSizeDrink], [picture], [idCategoriesD]) VALUES (4, N'Trà đào không đào', 10000, 1, NULL, 2)
INSERT [dbo].[Drink] ([idDrink], [nameDrink], [price], [idSizeDrink], [picture], [idCategoriesD]) VALUES (5, N'Trà sữa trà xanh', 12000, 3, NULL, 1)
INSERT [dbo].[Drink] ([idDrink], [nameDrink], [price], [idSizeDrink], [picture], [idCategoriesD]) VALUES (6, N'Trà sữa Socola', 12000, 3, NULL, 1)
INSERT [dbo].[Drink] ([idDrink], [nameDrink], [price], [idSizeDrink], [picture], [idCategoriesD]) VALUES (7, N'Phô mai que', 10000, 1, NULL, 4)
INSERT [dbo].[Drink] ([idDrink], [nameDrink], [price], [idSizeDrink], [picture], [idCategoriesD]) VALUES (8, N'Bánh rán Đô rê mon', 10000, 1, NULL, 3)
SET IDENTITY_INSERT [dbo].[Drink] OFF
SET IDENTITY_INSERT [dbo].[NhanVien] ON 

INSERT [dbo].[NhanVien] ([idNhanVien], [maNhanVien], [tenNhanVien], [idCateNV], [luongUncheck], [luongCashout]) VALUES (1, N'P001', N'Trần Thị Thùy Chi', 1, 0, 0)
INSERT [dbo].[NhanVien] ([idNhanVien], [maNhanVien], [tenNhanVien], [idCateNV], [luongUncheck], [luongCashout]) VALUES (2, N'P002', N'Trần Thục Khuê', 1, 0, 0)
INSERT [dbo].[NhanVien] ([idNhanVien], [maNhanVien], [tenNhanVien], [idCateNV], [luongUncheck], [luongCashout]) VALUES (3, N'F001', N'Dương Vũ Hoàng Giang', 2, 0, 0)
INSERT [dbo].[NhanVien] ([idNhanVien], [maNhanVien], [tenNhanVien], [idCateNV], [luongUncheck], [luongCashout]) VALUES (4, N'F002', N'Trần Thị Cẩm Nhung', 2, 0, 0)
SET IDENTITY_INSERT [dbo].[NhanVien] OFF
SET IDENTITY_INSERT [dbo].[SizeDrink] ON 

INSERT [dbo].[SizeDrink] ([idSizeDrink], [nameSizeDrink]) VALUES (1, N'Lớn')
INSERT [dbo].[SizeDrink] ([idSizeDrink], [nameSizeDrink]) VALUES (2, N'Trung bình')
INSERT [dbo].[SizeDrink] ([idSizeDrink], [nameSizeDrink]) VALUES (3, N'Nhỏ')
SET IDENTITY_INSERT [dbo].[SizeDrink] OFF
SET IDENTITY_INSERT [dbo].[TableD] ON 

INSERT [dbo].[TableD] ([idTableD], [nameTable], [numberPeople], [status]) VALUES (0, N'Take away', 0, 0)
INSERT [dbo].[TableD] ([idTableD], [nameTable], [numberPeople], [status]) VALUES (1, N'1', 0, 0)
INSERT [dbo].[TableD] ([idTableD], [nameTable], [numberPeople], [status]) VALUES (2, N'2', 0, 0)
INSERT [dbo].[TableD] ([idTableD], [nameTable], [numberPeople], [status]) VALUES (3, N'3', 0, 0)
INSERT [dbo].[TableD] ([idTableD], [nameTable], [numberPeople], [status]) VALUES (4, N'4', 0, 0)
INSERT [dbo].[TableD] ([idTableD], [nameTable], [numberPeople], [status]) VALUES (5, N'5', 0, 0)
INSERT [dbo].[TableD] ([idTableD], [nameTable], [numberPeople], [status]) VALUES (6, N'6', 0, 0)
INSERT [dbo].[TableD] ([idTableD], [nameTable], [numberPeople], [status]) VALUES (7, N'7', 0, 0)
INSERT [dbo].[TableD] ([idTableD], [nameTable], [numberPeople], [status]) VALUES (8, N'8', 0, 0)
INSERT [dbo].[TableD] ([idTableD], [nameTable], [numberPeople], [status]) VALUES (9, N'9', 0, 0)
INSERT [dbo].[TableD] ([idTableD], [nameTable], [numberPeople], [status]) VALUES (10, N'10', 0, 0)
SET IDENTITY_INSERT [dbo].[TableD] OFF
SET IDENTITY_INSERT [dbo].[TypeAccount] ON 

INSERT [dbo].[TypeAccount] ([idTypeAccount], [nameTypeAccount]) VALUES (1, N'admin')
INSERT [dbo].[TypeAccount] ([idTypeAccount], [nameTypeAccount]) VALUES (2, N'user')
SET IDENTITY_INSERT [dbo].[TypeAccount] OFF
ALTER TABLE [dbo].[Bill] ADD  DEFAULT (getdate()) FOR [getIn]
GO
ALTER TABLE [dbo].[Bill] ADD  DEFAULT ((0)) FOR [statusBill]
GO
ALTER TABLE [dbo].[Bill] ADD  DEFAULT ((0)) FOR [sale]
GO
ALTER TABLE [dbo].[Bill] ADD  DEFAULT ((0)) FOR [totalPrice]
GO
ALTER TABLE [dbo].[BillInfo] ADD  DEFAULT ((1)) FOR [countD]
GO
ALTER TABLE [dbo].[BillInfo] ADD  DEFAULT ((0)) FOR [price]
GO
ALTER TABLE [dbo].[NgayLuong] ADD  DEFAULT (getdate()) FOR [ngay]
GO
ALTER TABLE [dbo].[NgayLuong] ADD  DEFAULT ((0)) FOR [luongNgay]
GO
ALTER TABLE [dbo].[NgayLuong] ADD  DEFAULT ((0)) FOR [cateL]
GO
ALTER TABLE [dbo].[NhanVien] ADD  DEFAULT ((1)) FOR [idCateNV]
GO
ALTER TABLE [dbo].[NhanVien] ADD  DEFAULT ((0)) FOR [luongUncheck]
GO
ALTER TABLE [dbo].[NhanVien] ADD  DEFAULT ((0)) FOR [luongCashout]
GO
ALTER TABLE [dbo].[TableD] ADD  DEFAULT ((0)) FOR [numberPeople]
GO
ALTER TABLE [dbo].[TableD] ADD  DEFAULT ((0)) FOR [status]
GO
ALTER TABLE [dbo].[ThanhToan] ADD  DEFAULT (getdate()) FOR [dateCheckout]
GO
ALTER TABLE [dbo].[AccountD]  WITH CHECK ADD FOREIGN KEY([idTypeAccount])
REFERENCES [dbo].[TypeAccount] ([idTypeAccount])
GO
ALTER TABLE [dbo].[Bill]  WITH CHECK ADD FOREIGN KEY([idTableD])
REFERENCES [dbo].[TableD] ([idTableD])
GO
ALTER TABLE [dbo].[BillInfo]  WITH CHECK ADD FOREIGN KEY([idBill])
REFERENCES [dbo].[Bill] ([idBill])
GO
ALTER TABLE [dbo].[BillInfo]  WITH CHECK ADD FOREIGN KEY([idDrink])
REFERENCES [dbo].[Drink] ([idDrink])
GO
ALTER TABLE [dbo].[Drink]  WITH CHECK ADD FOREIGN KEY([idCategoriesD])
REFERENCES [dbo].[CategoriesD] ([idCategoriesD])
GO
ALTER TABLE [dbo].[Drink]  WITH CHECK ADD FOREIGN KEY([idSizeDrink])
REFERENCES [dbo].[SizeDrink] ([idSizeDrink])
GO
ALTER TABLE [dbo].[NgayLuong]  WITH CHECK ADD FOREIGN KEY([idNhanVien])
REFERENCES [dbo].[NhanVien] ([idNhanVien])
GO
ALTER TABLE [dbo].[NhanVien]  WITH CHECK ADD FOREIGN KEY([idCateNV])
REFERENCES [dbo].[cateNhanvien] ([idCateNV])
GO
USE [master]
GO
ALTER DATABASE [dtQLTraSua] SET  READ_WRITE 
GO
