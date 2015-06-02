require "ocs"

local cmdln = require "cmdline"
local fo = require "fo"
local tim = require "tim"
local maps = require "maps"
local easygetter = require "easygetter"
local mandator = require "mandator"

local depositId = ""
--local entryFrom = ""
--local entryTo = ""
local log_file = ""
local db_file = ""
local format = "CSV"

cmdln.add{ name="--logFile", descr="", func=function(x) log_file=x end }
cmdln.add{ name="--dbFile", descr="", func=function(x) db_file=x end }
cmdln.add{ name="--ids", descr="", func=function(x) depositId=x end }
cmdln.add{ name="--from", descr="", func=function(x) entryFrom=x end }
cmdln.add{ name="--to", descr="",  func=function(x) entryTo=x end }

cmdln.parse( arg, true )
depositId = depositId:gsub("{", "")
depositId = depositId:gsub("}", "")
print("depositId: " .. depositId)
--print("entryFrom: " .. "2015-04-20T11:00:00")
--print("entryTo: " .. "2015-04-20T15:00:00")
print("log_file: " .. log_file)
print("db_file: " .. db_file)
print("format: " .. format)

ocs.createInstance( "LUA" )
local function process()
  local dubi = require "dubi"
  --self defined common module
  local common = require "common"
  local confirmreport = require "confirmreport"

--common.CheckValidTimeRange(entryFrom, entryTo)

  local CallForceMapping = {["Call"]="Call", ["Force"]="Force", ["None"]=""}
  local debug_mode = false

  local sql_column_text = ' TEXT DEFAULT "" '
  local sql_column_integer = ' INTEGER DEFAULT 0'
  local sql_column_real = ' REAL DEFAULT 0.0'
  local table_name_order = "ExportedTable"
   local database_tables = {
     {table_name_order, {
               'Deposit'..sql_column_text,
               'Cash_Balance'..sql_column_integer,
               'Floating_PL_or_Unrealized'..sql_column_text,
               'EE_Balance'..sql_column_real,
               'Margin_Balance'..sql_column_text,
               'Unrealized_Margin_Balance'..sql_column_text,
               'Equity_Balance'..sql_column_text,
               'Total_MM'..sql_column_text,
               'Call_Amount'..sql_column_text,
               'Force_Amount'..sql_column_text
              }},
}

  common.CreateTables(db_file, log_file,  database_tables, debug_mode)


  local dep_id = {}
  for word in (depositId .. ","):gmatch("([^,]*),") do 
      dep_id[#dep_id + 1] = word
    
  end
  for i= 1 ,#dep_id do
      local Order_obj = dep_id[i]
       print(dep_id[i])
  
  
  
  
  
  local DECIDE_deposit_obj = fo.Deposit( tonumber(Order_obj) )
  local depositItem = {}
  local depositList = {}
  local order_id = 0
  

  --print(">>>"..DECIDE_deposit_obj)
  table.insert (depositItem, {'Deposit', DECIDE_deposit_obj:getNumber()})
  
  
  local orderVolLimit = easygetter.GetFirstActiveOVL(Order_obj)

    if (orderVolLimit ~= nil) then
    orderVolumeRisk = orderVolLimit:getUniqueRisk()
    end
    
    if ( orderVolLimit ~= nil ) then

  end
  
    if(orderVolumeRisk ~= nil) then
    table.insert (depositItem, {'Cash_Balance', easygetter.EvenAmountToDouble(orderVolumeRisk:getCashBalance())})
    table.insert (depositItem, {'Floating_PL_or_Unrealized', easygetter.EvenAmountToDouble(orderVolumeRisk:getTotalFutureUPLGross())})
    table.insert (depositItem, {'EE_Balance', easygetter.EvenAmountToDouble(orderVolumeRisk:getExcessEquityBalance())})
    table.insert (depositItem, {'Margin_Balance', easygetter.EvenAmountToDouble(orderVolumeRisk:getPositionMargin())})
    table.insert (depositItem, {'Unrealized_Margin_Balance', easygetter.EvenAmountToDouble(orderVolumeRisk:getPositionMargin())-easygetter.EvenAmountToDouble(orderVolumeRisk:getDailyFutureUPLGross())})
    table.insert (depositItem, {'Equity_Balance', easygetter.EvenAmountToDouble(orderVolumeRisk:getEquityBalance())})
    table.insert (depositItem, {'Total_MM', easygetter.EvenAmountToDouble(orderVolumeRisk:getMaintenanceMargin())})
    table.insert (depositItem, {'Call_Amount', easygetter.EvenAmountToDouble(orderVolumeRisk:getCallAmount())})
    table.insert (depositItem, {'Force_Amount', easygetter.EvenAmountToDouble(orderVolumeRisk:getForceAmount())})
  end
  
  
  
  
  
  

  table.insert (depositList, depositItem)


  common.InsertRecords(db_file, log_file, table_name_order, depositList, debug_mode)

end
end
  local inst = os.getenv( "BROKER_PREFIX" )
  local mand = mandator.Mandator( inst )
  mandator.changeTo( mand, process )

