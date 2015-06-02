require "ocs"

local cmdln = require "cmdline"
local fo = require "fo"
local tim = require "tim"
local maps = require "maps"
--local easygetter = require "easygetter"
--local mandator = require "mandator"

local depositId = "20507"
local entryFrom = ""
local entryTo = ""
local log_file = ""
local db_file = ""
local format = "PDF"

cmdln.add{ name="--logFile", descr="", func=function(x) log_file=x end }
cmdln.add{ name="--dbFile", descr="", func=function(x) db_file=x end }
cmdln.add{ name="--depositId", descr="", func=function(x) depositId=x end }
cmdln.add{ name="--from", descr="", func=function(x) entryFrom=x end }
cmdln.add{ name="--to", descr="",  func=function(x) entryTo=x end }

cmdln.parse( arg, true )
print("depositId: " .. depositId)
print("entryFrom: " .. entryFrom)
print("entryTo: " .. entryTo)
print("log_file: " .. log_file)
print("db_file: " .. db_file)
print("format: " .. format)

ocs.createInstance( "LUA" )
local function process()
  local dubi = require "dubi"
  --self defined common module
  local common = require "common"
  local confirmreport = require "confirmreport"

  common.CheckValidTimeRange(entryFrom, entryTo)

  local CallForceMapping = {["Call"]="Call", ["Force"]="Force", ["None"]=""}
  local debug_mode = false

  local sql_column_text = ' TEXT DEFAULT "" '
  local sql_column_integer = ' INTEGER DEFAULT 0'
  local sql_column_real = ' REAL DEFAULT 0.0'
  local table_name_ExportedOrders = "ExportedOrders"
  local database_tables = {
    {table_name_ExportedOrders, {'Order_Status'..sql_column_text,
              'Order_No'..sql_column_text,
              'Limit_Type'..sql_column_text,
              'Deposit'..sql_column_text,
              'Entry_User'..sql_column_real,
              'B/S'..sql_column_text,
              'O/C'..sql_column_text,
              'Custom_Contract_Id'..sql_column_text,
              'Contract_Id'..sql_column_text,
              'Contract_Size'..sql_column_text,
              'Order_Qty'..sql_column_text,
              'Order_Value'..sql_column_text,
              'Open_Qty'..sql_column_text,
              'Open_Value'..sql_column_text,
              'Limit'..sql_column_text,
              'Stop_Limit'..sql_column_text,
              'Stop_Order_Limit'..sql_column_text,
              'Stop_Order_Condition'..sql_column_text,
              'Stop_Order_Security'..sql_column_text,
              'Trigger'..sql_column_text,
              'Peak_Qty'..sql_column_text,
              'Exec_Qty'..sql_column_text,
              'Avg_Exec_Price'..sql_column_text,
              'Exec_Value'..sql_column_text,
              'Comm_Vat'..sql_column_text,
              'Entry_Time'..sql_column_text,
              'Valid_Type'..sql_column_text,
              'Valid_until'..sql_column_text,
              'Trading_Channel_Name'..sql_column_text,
              'Trading_Channel_Type'..sql_column_text,
              'Order_Id'..sql_column_text,
              'Counter_Party'..sql_column_text,
              'Counter_Party_Trader'..sql_column_text,
              }},
}

  common.CreateTables(db_file, log_file,  database_tables, debug_mode)

  local DECIDE_deposit_obj = fo.Deposit( tonumber(depositId) )
  local orders = easygetter.GetOrders( depositId, entryFrom, entryTo )

  local depositItem = {}
  local order_id = 0
  

  for _,no in pairs( orders ) do
    local order = fo.Order( no )

      local depositItem = {}
      
      local orderHandlingType = order:getHandlingType()
      if (orderHandlingType == 'TradingOrder' or orderHandlingType == 'BlockTrade') then
      
      local orderlegs = order:getOrderLegs()
      for _,orderLeg in pairs(orderlegs) do
      
      table.insert (depositItem, {'Order_Status', order:getStatus()})
      table.insert (depositItem, {'Order_No', order:getOrderId()})
      table.insert (depositItem, {'Limit_Type',})
      table.insert (depositItem, {'Deposit',})
      table.insert (depositItem, {'Entry_User',})
      table.insert (depositItem, {'B/S',})
      table.insert (depositItem, {'O/C',})
      table.insert (depositItem, {'Custom_Contract_Id',})
      table.insert (depositItem, {'Contract_Id',})
      table.insert (depositItem, {'Contract_Size',})
      table.insert (depositItem, {'Order_Qty',})
      table.insert (depositItem, {'Open_Qty',})
      table.insert (depositItem, {'Open_Value',})
      table.insert (depositItem, {'Limit',})
      table.insert (depositItem, {'Stop_Limit',})
      table.insert (depositItem, {'Stop_Order_Limit',})
      table.insert (depositItem, {'Stop_Order_Condition',})
      table.insert (depositItem, {'Stop_Order_Security',})
      table.insert (depositItem, {'Trigger',})
      table.insert (depositItem, {'Peak_Qty',})
      table.insert (depositItem, {'Exec_Qty',})
      table.insert (depositItem, {'Avg_Exec_Price',})
      table.insert (depositItem, {'Exec_Value',})
      table.insert (depositItem, {'Comm_Vat',})
      table.insert (depositItem, {'Entry_Time',})
      table.insert (depositItem, {'Valid_Type',})
      table.insert (depositItem, {'Valid_until',})
      table.insert (depositItem, {'Trading_Channel_Name',})
      table.insert (depositItem, {'Trading_Channel_Type',})
      table.insert (depositItem, {'Order_Id',})
      table.insert (depositItem, {'Counter_Party',})
      table.insert (depositItem, {'Counter_Party_Trader',})
      
      table.insert (depositList, depositItem)
      end
      end
  end

  table.insert (depositList, depositItem)


  common.InsertRecords(db_file, log_file, table_name_ExportedOrders, depositList, debug_mode)

end
-- local inst = os.getenv( "OCSINST" )
-- local mand = mandator.Mandator( inst )
-- mandator.changeTo( mand, process )
