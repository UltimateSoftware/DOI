IF OBJECT_ID('[DDI].[spRefreshMetadata_User_Databases_InsertData]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_Databases_InsertData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [DDI].[spRefreshMetadata_User_Databases_InsertData]
AS

ALTER TABLE DDI.Tables DROP CONSTRAINT FK_Tables_Databases


DELETE DDI.Databases

INSERT INTO DDI.Databases ( DatabaseName )
VALUES ( N'PaymentReporting')

ALTER TABLE DDI.Tables ADD 
    CONSTRAINT FK_Tables_Databases
        FOREIGN KEY(DatabaseName)
            REFERENCES DDI.Databases(DatabaseName)
GO
