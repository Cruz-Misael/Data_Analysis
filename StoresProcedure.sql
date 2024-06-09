USE [bm_oee_tables]
GO
/****** Object:  StoredProcedure [dbo].[OEE]   ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Description:  OEE calculations.
-- =============================================
ALTER   PROCEDURE [dbo].[OEE]
-- Add the parameters for the stored procedure here
@FromDate datetime = '2023-01-01 00:00:00',
@ToDate datetime = '2023-01-02 00:00:00',
@WorkGroup varchar(20) = '',
@GoalMethod bit = 0,
@AssetID int = 0
AS
BEGIN
  -- SET NOCOUNT ON added to prevent extra result sets from
  -- interfering with SELECT statements.
  SET NOCOUNT ON;
  -- Prevent arithmetic error exceptions like divide by zero.  Return null in these cases.
  SET ARITHABORT OFF
  SET ANSI_WARNINGS OFF

  -- Insert statements for procedure here



  SELECT
    OEEasset.Department AS 'Department',
    OEEasset.WorkGroup AS 'Work Group',
    OEEasset.AssetName AS 'Asset Name',
    ISNULL(production.Quantity + production.rejects, 0) AS 'Total Count',
    ISNULL(production.Quantity, 0) AS 'Count',
    ISNULL(production.Rejects, 0) AS 'Rejects',
    ISNULL(Downtime.Total, 0) AS 'Total Downtime',
	downtime.Count AS 'Fault Count',
	downtime.Total / downtime.Count AS 'MTTR',
	schedule.TotalTime / downtime.Count AS 'MTBF',


    ISNULL(CASE
      WHEN schedule.TotalTime - ISNULL(Downtime.Total, 0) < 0 THEN 0
      ELSE schedule.TotalTime - ISNULL(Downtime.Total, 0)
    END, 0) AS 'Total Uptime',

    ISNULL(schedule.TotalTime, 0) AS 'Total Time',
    ISNULL(breakTime.Minutes, 0) AS 'Total Breaks',

    ISNULL(CASE
      WHEN schedule.TotalTime - ISNULL(Downtime.Total, 0) - ISNULL(breakTime.Minutes, 0) < 0 THEN 0
      ELSE schedule.TotalTime - ISNULL(Downtime.Total, 0) - ISNULL(breakTime.Minutes, 0)
    END, 0) AS 'Total Working Time',

    ISNULL(CASE
      WHEN @GoalMethod = 1 THEN ROUND(OEEasset.ProductionModifier * OEEschedule.ProductionGoal, 0)
      ELSE CASE
          WHEN ROUND((schedule.TotalTime - ISNULL(breakTime.Minutes, 0)) / NULLIF((production.Product / production.Quantity), 0), 0) < 0 THEN NULL
          ELSE ROUND((schedule.TotalTime - ISNULL(breakTime.Minutes, 0)) / NULLIF((production.Product / production.Quantity), 0), 0)
        END
    END, 0) AS 'Production Goal',

    ISNULL(ROUND(
    production.Quantity /
                         CASE
                           WHEN schedule.TotalTime - ISNULL(Downtime.Total, 0) - ISNULL(breakTime.Minutes, 0) < 0 THEN NULL
                           ELSE (schedule.TotalTime - ISNULL(Downtime.Total, 0) - ISNULL(breakTime.Minutes, 0)) / 60.0
                         END, 2), 0) AS 'Production Rate',

    ISNULL(ROUND(
    CASE
      WHEN @GoalMethod = 1 THEN 
	  /*(OEEasset.ProductionModifier * OEEschedule.ProductionGoal) / ((schedule.ShiftTime - ISNULL(breakTime.Minutes, 0)) / 60.0)*/
	  (OEEasset.ProductionModifier * OEEschedule.ProductionGoal) / ((schedule.ShiftTime - ISNULL(breakTime.ShiftMinutes, 0)) / 60.0)
      ELSE 60 / NULLIF((production.Product / production.Quantity), 0)
    END, 2), OEEasset.ProductionRate) AS 'Planned Rate',

    ISNULL(production.Product, 0) AS 'Product',

    ISNULL(CASE
      WHEN @GoalMethod = 1 THEN (ROUND((production.Quantity / OEEasset.ProductionModifier)
        /
        ((NULLIF(CAST(OEEschedule.ProductionGoal AS float), 0)
        /
        (schedule.ShiftTime - ISNULL(breakTime.Minutes, 0)))
        *
         CASE
           WHEN schedule.TotalTime - ISNULL(Downtime.Total, 0) - ISNULL(breakTime.Minutes, 0) < 0 THEN 0
           ELSE schedule.TotalTime - ISNULL(Downtime.Total, 0) - ISNULL(breakTime.Minutes, 0)
         END), 2))
      ELSE (production.product / (CASE
          WHEN schedule.TotalTime - ISNULL(Downtime.Total, 0) - ISNULL(breakTime.Minutes, 0) < 0 THEN 0
          ELSE schedule.TotalTime - ISNULL(Downtime.Total, 0) - ISNULL(breakTime.Minutes, 0)
        END))
    END, 0) AS 'Productivity OEE',

    ISNULL(CASE
      WHEN (schedule.TotalTime - ISNULL(Downtime.Total, 0)) / CAST(schedule.TotalTime AS float) < 0 THEN 0
      ELSE (schedule.TotalTime - ISNULL(Downtime.Total, 0)) / CAST(schedule.TotalTime AS float)
    END, 0) AS 'Availability OEE',

    ISNULL(CAST(production.quantity AS float) / NULLIF((production.quantity + production.rejects), 0), 1) AS 'Quality OEE',

    ISNULL(CASE
      WHEN @GoalMethod = 1 THEN (ROUND((production.Quantity / OEEasset.ProductionModifier)
        /
        ((NULLIF(CAST(OEEschedule.ProductionGoal AS float), 0)
        /
        (schedule.ShiftTime - ISNULL(breakTime.Minutes, 0)))
        *
         CASE
           WHEN schedule.TotalTime - ISNULL(Downtime.Total, 0) - ISNULL(breakTime.Minutes, 0) < 0 THEN 0
           ELSE schedule.TotalTime - ISNULL(Downtime.Total, 0) - ISNULL(breakTime.Minutes, 0)
         END), 2))
      ELSE (production.product / (CASE
          WHEN schedule.TotalTime - ISNULL(Downtime.Total, 0) - ISNULL(breakTime.Minutes, 0) < 0 THEN 0
          ELSE schedule.TotalTime - ISNULL(Downtime.Total, 0) - ISNULL(breakTime.Minutes, 0)
        END))
    END

    *
     CASE
       WHEN (schedule.TotalTime - ISNULL(Downtime.Total, 0)) / CAST(schedule.TotalTime AS float) < 0 THEN 0
       ELSE (schedule.TotalTime - ISNULL(Downtime.Total, 0)) / CAST(schedule.TotalTime AS float)
     END
    *
    CAST(production.quantity AS float) / NULLIF((production.quantity + production.rejects), 0), 0)
    AS 'OEE',

    OEEschedule.ShiftNumber AS 'Shift Number',
    OEEschedule.StartDate AS 'Start Date',
    OEEschedule.EndDate AS 'End Date',
    OEEschedule.ID AS 'ScheduleID',
	schedule.ShiftTime

  FROM OEEasset WITH (NOLOCK)
  INNER JOIN OEEschedule WITH (NOLOCK)
    ON OEEasset.WorkGroup = OEEschedule.WorkGroup



 -- This section sums production and rates
  LEFT JOIN (SELECT
    (SUM(CASE
      WHEN OEEproduction.TimeComplete IS NOT NULL AND
        OEEproduction.TimeComplete BETWEEN OEEschedule.StartDate AND OEEschedule.EndDate AND
        ISNULL(OEEproduction.Reject, 0) = 0 THEN OEErate.ProductionRate
      ELSE 0
    END)) AS Product,
    SUM(CASE
      WHEN OEEproduction.TimeComplete IS NOT NULL AND
        OEEproduction.TimeComplete BETWEEN OEEschedule.StartDate AND OEEschedule.EndDate AND
        ISNULL(OEEproduction.Reject, 0) = 0 THEN 1
      ELSE 0
    END) AS 'Quantity',
    SUM(CASE
      WHEN OEEproduction.TimeComplete IS NOT NULL AND
        OEEproduction.TimeComplete BETWEEN OEEschedule.StartDate AND OEEschedule.EndDate AND
        ISNULL(OEEproduction.Reject, 0) = 1 THEN 1
      ELSE 0
    END) AS 'Rejects',
    OEEasset.AssetID AS 'Asset',
    OEEschedule.ID AS 'ScheduleID'

  FROM OEEproduction WITH (NOLOCK)
  INNER JOIN OEEasset WITH (NOLOCK)
    ON OEEproduction.AssetID = OEEasset.AssetID
  INNER JOIN OEEschedule WITH (NOLOCK)
    ON OEEasset.WorkGroup = OEEschedule.WorkGroup
  /*outer apply instead of left join to prevent double-counting duplicate jobs in OEErate table*/
  OUTER APPLY (SELECT TOP 1
    OEErate.productionrate
  FROM OEErate WITH (NOLOCK)
  WHERE OEErate.Job = OEEproduction.job
  AND OEErate.WorkGroup = OEEasset.WorkGroup) AS OEErate
  WHERE (OEEasset.WorkGroup = @WorkGroup
  OR @WorkGroup = 'ALL')
  AND OEEschedule.StartDate BETWEEN @FromDate AND @ToDate
  AND OEEschedule.StartDate <= GETDATE()
  AND OEEproduction.TimeComplete BETWEEN @FromDate AND @ToDate
  AND OEEproduction.TimeComplete BETWEEN OEEschedule.StartDate AND OEEschedule.EndDate
  AND OEEasset.AssetEnabled = 1
  AND OEEproduction.AssetID =
                        CASE
                          WHEN @AssetID > 0 THEN @AssetID
                          ELSE OEEproduction.AssetID
                        END

  GROUP BY OEEasset.AssetID,
           OEEschedule.ID) AS production
    ON OEEasset.AssetID = production.Asset
    AND OEEschedule.ID = production.ScheduleID
  -- End sum production



  -- This section sums the downtime per asset
  LEFT JOIN (SELECT
    SUM(DATEDIFF(SECOND, OEEschedule.StartDate, OEEschedule.EndDate) -
    (CASE
      WHEN DATEDIFF(SECOND, OEEschedule.StartDate, OEEschedule.EndDate) < DATEDIFF(SECOND, OEEschedule.StartDate, OEEdowntime.StartDate) THEN DATEDIFF(SECOND, OEEschedule.StartDate, OEEschedule.EndDate)
      ELSE CASE
          WHEN DATEDIFF(SECOND, OEEschedule.StartDate, OEEdowntime.StartDate) < 0 THEN 0
          ELSE DATEDIFF(SECOND, OEEschedule.StartDate, OEEdowntime.StartDate)
        END
    END +
    (CASE
      WHEN DATEDIFF(SECOND, OEEschedule.StartDate, OEEschedule.EndDate) < DATEDIFF(SECOND, OEEdowntime.EndDate, OEEschedule.EndDate) THEN DATEDIFF(SECOND, OEEschedule.StartDate, OEEschedule.EndDate)
      ELSE CASE
          WHEN DATEDIFF(SECOND, OEEdowntime.EndDate, OEEschedule.EndDate) < 0 THEN 0
          ELSE DATEDIFF(SECOND, OEEdowntime.EndDate, OEEschedule.EndDate)
        END
    END)))
    / 60 AS 'Total',

    OEEdowntime.AssetID AS 'Asset',
    OEEschedule.ID AS 'ScheduleID',
	SUM(CASE WHEN OEEdowntime.StartDate BETWEEN OEEschedule.StartDate AND OEEschedule.EndDate THEN 1 ELSE 0 END) AS 'Count'

  FROM OEEdowntime WITH (NOLOCK)
  INNER JOIN OEEasset WITH (NOLOCK)
    ON OEEdowntime.AssetID = OEEasset.AssetID
  INNER JOIN OEEschedule WITH (NOLOCK)
    ON OEEasset.WorkGroup = OEEschedule.WorkGroup

  WHERE (OEEasset.WorkGroup = @WorkGroup
  OR @WorkGroup = 'ALL')
  AND (OEEdowntime.StartDate BETWEEN @FromDate AND @ToDate
  OR OEEdowntime.EndDate BETWEEN @FromDate AND @ToDate)
  AND OEEschedule.StartDate BETWEEN @FromDate AND @ToDate
  AND OEEasset.AssetEnabled = 1
  AND OEEdowntime.AssetID =
                        CASE
                          WHEN @AssetID > 0 THEN @AssetID
                          ELSE OEEdowntime.AssetID
                        END

  GROUP BY OEEdowntime.AssetID,
           OEEschedule.ID) AS downtime
    ON OEEasset.AssetID = downtime.Asset
    AND OEEschedule.ID = downtime.ScheduleID
  -- End summing downtime per asset


  
  -- This section sums the break time per shift
  LEFT JOIN (SELECT
  OEEschedule.ID AS 'ScheduleID',
  SUM(CASE
    WHEN OEEbreak.StartDate <= GETDATE() THEN CASE
        WHEN DATEDIFF(MINUTE, OEEbreak.StartDate, OEEbreak.EndDate) < DATEDIFF(MINUTE, OEEbreak.StartDate, GETDATE()) THEN DATEDIFF(MINUTE, OEEbreak.StartDate, OEEbreak.EndDate)
        ELSE DATEDIFF(MINUTE, OEEbreak.StartDate, GETDATE())
      END
    ELSE 0
  END) AS 'Minutes',
  SUM(DATEDIFF(MINUTE, OEEbreak.StartDate, OEEbreak.EndDate)) AS 'ShiftMinutes'
FROM OEEbreak WITH (NOLOCK)
INNER JOIN OEEschedule WITH (NOLOCK)
  ON (@WorkGroup = OEEschedule.WorkGroup
  OR @WorkGroup = 'ALL')
  AND OEEbreak.StartDate BETWEEN OEEschedule.StartDate AND OEEschedule.EndDate
WHERE OEEbreak.StartDate BETWEEN @FromDate AND @ToDate
AND (OEEbreak.WorkGroup = @WorkGroup
OR OEEbreak.WorkGroup = 'ALL'
OR @WorkGroup = 'ALL')
GROUP BY OEEschedule.ID,
         OEEschedule.StartDate,
         OEEschedule.EndDate) AS breakTime
    ON OEEschedule.ID = breakTime.ScheduleID
  -- End summing break time per shift



  -- This section sums the schedule time per shift
  INNER JOIN (SELECT
    OEEschedule.ID AS 'ScheduleID',
    CASE
      WHEN DATEDIFF(MINUTE, OEEschedule.StartDate, OEEschedule.EndDate) < DATEDIFF(MINUTE, OEEschedule.StartDate, GETDATE()) THEN DATEDIFF(MINUTE, OEEschedule.StartDate, OEEschedule.EndDate)
      ELSE DATEDIFF(MINUTE, OEEschedule.StartDate, GETDATE())
    END
    AS 'TotalTime',
    DATEDIFF(MINUTE, OEEschedule.StartDate, OEEschedule.EndDate) AS 'ShiftTime'

  FROM OEEschedule WITH (NOLOCK)
  WHERE OEEschedule.StartDate BETWEEN @FromDate AND @ToDate
  AND (OEEschedule.WorkGroup = @WorkGroup
  OR @WorkGroup = 'ALL')
  AND OEEschedule.StartDate <= GETDATE()
  GROUP BY OEEschedule.ID,
           OEEschedule.StartDate,
           OEEschedule.EndDate) AS schedule
    ON OEEschedule.ID = schedule.ScheduleID
  -- End summing schedule time per shift



  WHERE (OEEasset.WorkGroup = @WorkGroup
  OR @WorkGroup = 'ALL')
  AND OEEschedule.StartDate BETWEEN @FromDate AND @ToDate
  AND OEEschedule.StartDate <= GETDATE()
  AND OEEasset.AssetEnabled = 1

  AND OEEasset.AssetID =
                        CASE
                          WHEN @AssetID > 0 THEN @AssetID
                          ELSE OEEasset.AssetID
                        END


  GROUP BY OEEasset.AssetName,
           OEEasset.Department,
           OEEasset.WorkGroup,
           OEEasset.ProductionRate,
           OEEschedule.StartDate,
           OEEschedule.EndDate,
           OEEschedule.ShiftNumber,
           OEEschedule.ID,
           downtime.Total,
		   downtime.Count,
           breakTime.Minutes,
		   breakTime.ShiftMinutes,
           OEEasset.ProductionModifier,
           OEEschedule.ProductionGoal,
           production.Quantity,
           production.Rejects,
           production.Product,
           schedule.TotalTime,
           schedule.ShiftTime

END