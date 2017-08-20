
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[PowerFactorial] ( @m float,  @u float)
RETURNS float
AS
BEGIN
Declare @counter float --counter
Declare @total float -- return value



SET @counter = 1
SET @total = 0



WHILE @counter <= @u
BEGIN



SET @total = @total + Log(@m/@counter)
Set @counter= @counter + 1



END



RETURN Exp(@total)
END
GO



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: David tigue
-- Create date: 4/12/2013
-- Description: ErlangC
-- =============================================
CREATE FUNCTION [dbo].[ErlangC]
(
-- Add the parameters for the function here
@m float  -- Number of Agents
,@u float -- Traffic intensity
)
RETURNS float
AS
BEGIN
--Source http://www.mitan.co.uk/erlang/elgcmath.htm Number 6



-- Return Variable
DECLARE @Prob Float -- Probability of Call not being answered immediately and having to wait.



-- Variables
Declare @Numerator Float -- Top of Equation
Declare @Denominator Float -- Bottom of Equation
Declare @Summation float -- Summation part of Denominator
Declare @k float -- increment for summation



--Calculate Numerator



SET @Numerator = dbo.PowerFactorial(@u,@m)



-- Start Summation with k starting at 0.
SET @k = 0
SET @Summation = 0



While @k < @m-1
Begin
SET @Summation = @Summation + dbo.PowerFactorial(@u,@k)
SET @k = @k +1
End



--Calculate denominator



SET @Denominator = dbo.PowerFactorial(@u,@m) + (1-@u/@m)*@Summation



SET @Prob = @Numerator/@Denominator



-- Return the result of the function
RETURN @Prob



END
GO



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: David Tigue
-- Create date: 04/15/2013
-- Description: Erlang C Service
-- =============================================
CREATE FUNCTION [dbo].[ErlangCServ]
(
-- Add the parameters for the function here
@m int -- Number of Agents
,@u float -- Traffic Intensity
,@t float -- Target Time
,@ts float -- Average Call Duration
)
RETURNS float
AS
BEGIN



-- Return the result of the function
RETURN  1 - dbo.ErlangC(@m, @u) * Exp(-(@m - @u) * (@t / @ts))



END
GO



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: David Tigue
-- Create date: 04/15/2013
-- Description: Erlang C Service
-- =============================================
CREATE FUNCTION [dbo].[ASA]
(
-- Add the parameters for the function here
@m int -- Number of Agents
,@u float -- Traffic Intensity
,@ts float -- Average Call Duration
)
RETURNS float
AS
BEGIN



-- Return the result of the function
RETURN  dbo.ErlangC(@m, @u) * @ts / (@m - @u)



END
GO



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: David Tigue
-- Create date: 4/15/2013
-- Description: Calc Number of People Required for given Service Level
-- =============================================
CREATE FUNCTION [dbo].[ErlangCRequired]
(
-- Add the parameters for the function here
@A float -- Average Arrival Rate  (second)
,@ts float -- Average Call Duration (seconds)
,@t int -- Time Goal
,@svl float -- Service Level Goal
)
RETURNS float
AS
BEGIN
DECLARE @u float -- Traffic Intensity



Set @u = @A * @ts



DECLARE @m float --number of agents



SET @m = 2



WHILE dbo.ErlangCServ(@m,@u,@t,@ts) <= @svl
Begin
SET @m = @m + 1
END



-- Return the result of the function
RETURN @m



END
GO