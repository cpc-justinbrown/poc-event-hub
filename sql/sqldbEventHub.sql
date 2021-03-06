-- Run against master database first:
--CREATE LOGIN [faEventHub] FROM EXTERNAL PROVIDER;
--CREATE LOGIN [brownjl@cpchem.com] FROM EXTERNAL PROVIDER;

/****** Object:  Database [sqldbEventHub]    Script Date: 5/31/2022 9:14:40 AM ******/
--CREATE DATABASE [sqldbEventHub]  (EDITION = 'Basic', SERVICE_OBJECTIVE = 'ElasticPool', MAXSIZE = 1 GB) WITH CATALOG_COLLATION = SQL_Latin1_General_CP1_CI_AS;
--GO
--ALTER DATABASE [sqldbEventHub] SET COMPATIBILITY_LEVEL = 150
--GO
--ALTER DATABASE [sqldbEventHub] SET ANSI_NULL_DEFAULT OFF 
--GO
--ALTER DATABASE [sqldbEventHub] SET ANSI_NULLS OFF 
--GO
--ALTER DATABASE [sqldbEventHub] SET ANSI_PADDING OFF 
--GO
--ALTER DATABASE [sqldbEventHub] SET ANSI_WARNINGS OFF 
--GO
--ALTER DATABASE [sqldbEventHub] SET ARITHABORT OFF 
--GO
--ALTER DATABASE [sqldbEventHub] SET AUTO_SHRINK OFF 
--GO
--ALTER DATABASE [sqldbEventHub] SET AUTO_UPDATE_STATISTICS ON 
--GO
--ALTER DATABASE [sqldbEventHub] SET CURSOR_CLOSE_ON_COMMIT OFF 
--GO
--ALTER DATABASE [sqldbEventHub] SET CONCAT_NULL_YIELDS_NULL OFF 
--GO
--ALTER DATABASE [sqldbEventHub] SET NUMERIC_ROUNDABORT OFF 
--GO
--ALTER DATABASE [sqldbEventHub] SET QUOTED_IDENTIFIER OFF 
--GO
--ALTER DATABASE [sqldbEventHub] SET RECURSIVE_TRIGGERS OFF 
--GO
--ALTER DATABASE [sqldbEventHub] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
--GO
--ALTER DATABASE [sqldbEventHub] SET ALLOW_SNAPSHOT_ISOLATION ON 
--GO
--ALTER DATABASE [sqldbEventHub] SET PARAMETERIZATION SIMPLE 
--GO
--ALTER DATABASE [sqldbEventHub] SET READ_COMMITTED_SNAPSHOT ON 
--GO
--ALTER DATABASE [sqldbEventHub] SET  MULTI_USER 
--GO
--ALTER DATABASE [sqldbEventHub] SET ENCRYPTION ON
--GO
--ALTER DATABASE [sqldbEventHub] SET QUERY_STORE = ON
--GO
--ALTER DATABASE [sqldbEventHub] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 7), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 10, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200)
--GO
/*** The scripts of database scoped configurations in Azure should be executed inside the target database connection. ***/
--GO
-- ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 8;
--GO
/****** Object:  User [faEventHub]    Script Date: 5/31/2022 9:14:40 AM ******/
CREATE USER [faEventHub] FROM  EXTERNAL PROVIDER  WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [brownjl@cpchem.com]    Script Date: 5/31/2022 9:14:40 AM ******/
CREATE USER [brownjl@cpchem.com] FROM  EXTERNAL PROVIDER  WITH DEFAULT_SCHEMA=[dbo]
GO
sys.sp_addrolemember @rolename = N'db_owner', @membername = N'faEventHub'
GO
sys.sp_addrolemember @rolename = N'db_datareader', @membername = N'brownjl@cpchem.com'
GO
/****** Object:  Table [dbo].[Message]    Script Date: 5/31/2022 9:14:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Message](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Message] [nvarchar](max) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[InsertedAt] [datetime] NOT NULL,
 CONSTRAINT [PK_Message] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Message] ADD  CONSTRAINT [DF_Message_InsertedAt]  DEFAULT (getutcdate()) FOR [InsertedAt]
GO
ALTER DATABASE [sqldbEventHub] SET  READ_WRITE 
GO
