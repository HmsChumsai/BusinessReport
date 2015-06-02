require "ocs"

local cmdln = require "cmdline"
local fo = require "fo"
local tim = require "tim"
local maps = require "maps"
-- local easygetter = require "easygetter"
local mandator = require "mandator"

local depositId = ""
local entryFrom = ""
local entryTo = ""
local log_file = ""
local db_file = ""
local format = "CSV"

cmdln.add{ name="--logFile", descr="", func=function(x) log_file=x end }
cmdln.add{ name="--dbFile", descr="", func=function(x) db_file=x end }
-- cmdln.add{ name="--depositId", descr="", func=function(x) depositId=x end }
cmdln.add{ name="--ids", descr="", func=function(x) depositId=x end }
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
  print("Call Process")
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
  local table_name_ExportedOrders = "ExportedOrders"
  local database_tables = {
    {table_name_ExportedOrders, {'Deposit'..sql_column_text,
              'Customer_Contract_ID'..sql_column_text,
              'SL'..sql_column_text,
              'Quantity'..sql_column_text,
              'Orders'..sql_column_real,
              'Last_unchk'..sql_column_text,
              'Avg_Price'..sql_column_text,
              'Avg_Price_net'..sql_column_text,
              'Pos_book_value'..sql_column_text,
              'Market_val_Gross'..sql_column_text,
              'Gross_Exposure'..sql_column_text,
              'UPL_accInt_incl'..sql_column_text,
              'RPL_all_incl'..sql_column_text,
              'TotPL_all_incl'..sql_column_text,
              'Market_Val_Expossed'..sql_column_text,
              'Custodian_Fee'..sql_column_text,
              'Value_Added_Tax'..sql_column_text,
              }},
}

  common.CreateTables(db_file, log_file,  database_tables, debug_mode)

  local DECIDE_deposit_obj = fo.Deposit( tonumber(depositId) )

  local depositItem = {}
  local order_id = 0
  
  table.insert (depositItem, {'Deposit', DECIDE_deposit_obj:getNumber()})

local position_list = DECIDE_deposit_obj:getAccPositions()   -- get a list of positions
  for _,position in pairs ( position_list ) do

      local depositItem = {}

      local contract = position:getContract()
      table.insert (depositItem, {'Customer_Contract_ID', contract:getContractCode()})
      print("-------Test : "..contract:getContractCode())
      local position_short_long = position:getShortLong()
      table.insert (depositItem, {'SL', position_short_long})
      
      table.insert (depositItem, {'quantity', position:getAvailableQuantity()})

      local orders_unmat = 0
      if ( position_short_long == "Long" ) then
          table.insert(orderItem2,{'Orders',position:getOrdersBuy()})
      end
      if ( position_short_long == "Short" ) then
          table.insert(orderItem2,{'Orders',position:getOrdersSell()})
      end
      
      local ok, pe = pcall( fo.PositionEvaluation, { position=position, plview="latest" } )
      local ok2, pe2 = pcall( fo.PositionEvaluation, { position=position } )
      
      table.insert(depositItem,{'Last_unchk',pe:getContractEvaluation():getLastUnchecked()})
      table.insert(depositItem,{'Avg_Price',pe2:getAvgePrice()})
      table.insert(depositItem,{'Avg_Price_net',pe2:getAvgePriceNet()})
      table.insert(depositItem,{'Pos_book_value',pe2:getPosBookValue()})
      table.insert(depositItem,{'Market_val_Gross',pe2:getExposedValue()})
      table.insert(depositItem,{'Gross_Exposure',pe2:getLiqMarketValue()})
      table.insert(depositItem,{'UPL_accInt_incl',pe2:getUplGrossMZ()})
      table.insert(depositItem,{'RPL_all_incl',pe:getRplGrossMZ()})
      table.insert(depositItem,{'TotPL_all_incl',pe2:getTplGrossMZ()})
      table.insert(depositItem,{'Market_Val_Expossed',pe2:getExposedValue()})
      table.insert(depositItem,{'Custodian_Fee',pe2:getFeeSum("Other")})
      table.insert(depositItem,{'Value_Added_Tax',pe2:getFeeSum("Commission")})
      
      table.insert (depositList, depositItem)
  end

  table.insert (depositList, depositItem)


  common.InsertRecords(db_file, log_file, table_name_ExportedOrders, depositList, debug_mode)

end
 local inst = os.getenv( "BROKER_PREFIX" )
 local mand = mandator.Mandator( inst )
 mandator.changeTo( mand, process )
