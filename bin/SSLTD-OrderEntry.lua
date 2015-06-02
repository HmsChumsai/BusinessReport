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
  local M = require "customOrderData"
--common.CheckValidTimeRange(entryFrom, entryTo)

  local CallForceMapping = {["Call"]="Call", ["Force"]="Force", ["None"]=""}
  local debug_mode = false

  local sql_column_text = ' TEXT DEFAULT "" '
  local sql_column_integer = ' INTEGER DEFAULT 0'
  local sql_column_real = ' REAL DEFAULT 0.0'
  local table_name_order = "ExportedTable"
   local database_tables = {
     {table_name_order, {
              'AFC_ORDER'..sql_column_text,
              'STOCK'..sql_column_text,
              'B_S'..sql_column_text,
              'Volume'..sql_column_text,
              'Price'..sql_column_real,
              'Limit_Type'..sql_column_text,
              'Deposit'..sql_column_text,
              'Account_Type'..sql_column_text,
              'Entry_ID'..sql_column_text,
              'TTF'..sql_column_text,
              'Channel'..sql_column_text,
              'Entry_date'..sql_column_text,
              'Entry_time'..sql_column_text,
              }},
}

   common.CreateTables(db_file, log_file,  database_tables, debug_mode)

  
  local businesscenter = fo.BusinessCenter("THAILAND")
  local tradingCalendar = businesscenter:getTradingCalendar()
  local entryTo = tradingCalendar:addActiveDays( tim.Date.current(),0, isNONE ):toString("%Y-%m-%dT17:00:00")
  local entryFrom = tradingCalendar:addActiveDays( tim.Date.current(),0, isNONE ):toString("%Y-%m-%dT17:00:00")
  
  print(">>.."..entryTo)
  print(">>.."..entryFrom)
  
  

  local order_id = 0
  
  local DECIDE_deposit_obj = fo.Deposit( tonumber(depositId) )
  
  local dep_id = {}
  for word in (depositId .. ","):gmatch("([^,]*),") do 
        dep_id[#dep_id + 1] = word
   
  end
 
   for i= 1 ,#dep_id do
      local Order_obj = dep_id[i]
    print(dep_id[i])

      local depositItem = {}
  local depositList = {}
    
    local order = fo.Order(( tonumber(Order_obj)))
    
    --print(">>"..order:getOrderId())
    
    local orderHandlingType = order:getHandlingType()
    
 --if (orderHandlingType == 'TradingOrder' ) then
    --local depositItem = {}

    local orderlegs = order:getOrderLegs()
    
    
    for i = 1, order:getNumberLegs() do
    
    --local depositItem = {}

    local orderLeg = orderlegs[i]
    
    local order_limit_type = tostring(order:getOrderLimitType())
    
    
    --if(order:getStatus() == " Entered" and order:getAfterCloseOrder() == "Pending")
    print("===============================================================================================")
    
    
    print("AFC_ORDER : "..order:getOrderId())
    table.insert (depositItem, {'AFC_ORDER',order:getOrderId()})
    print("Stock : "..order:getInstrument():getShortName())
    table.insert (depositItem, {'STOCK',order:getInstrument():getShortName()})
    --"::::::::BUYSell:::::::"
    local buy_sell = common.BuySellToBSMapping[orderLeg:getOrderKind()]
    if (buy_sell == "B") then
    local buy_sell = "Buy"
    print("B/S : "..buy_sell)
    table.insert (depositItem, {'B_S',buy_sell})
    end
    if (buy_sell == "S") then
    local buy_sell = "Sell"
    print("B/S : "..buy_sell)
    table.insert (depositItem, {'B_S',buy_sell})
    end
    
    print("Status : "..order:getStatus())
    print("AFC : "..order:getAfterCloseOrder())
    print("Volume : "..orderLeg:getTotalQty())
    table.insert (depositItem, {'Volume',orderLeg:getTotalQty()})
    
    print("Price : "..orderLeg:getPriceLimit())
    table.insert (depositItem, {'Price',orderLeg:getPriceLimit()})
    
    print("Limit Type : "..order:getOrderLimitType())
    table.insert (depositItem, {'Limit_Type',order:getOrderLimitType()})
    
    print("Deposit : "..order:getDeposit():getNumber())
    table.insert (depositItem, {'Deposit',order:getDeposit():getNumber()})
    
    if(order:getDeposit():hasAccountType())then
    print("Account Type : "..order:getDeposit():getAccountType():getName())
    table.insert (depositItem, {'Account_Type',order:getDeposit():getAccountType():getName()})
    else
    print("Account Type : ".." ")
    local blank = " "
    table.insert (depositItem, {'Account_Type',blank})
    end
    
    print("Entry ID : "..order:getEntryUserId())
    table.insert(depositItem,{'Entry_ID',order:getEntryUserId()})
    
    print("TTF : ")
    
    if(order:hasTradingChannel()) then
          --table.insert (orderItem, {'market',order:getExchange():getName()})
          print("Trading Channel : "..order:getTradingChannel():getName())
          table.insert (depositItem,{'Channel',order:getTradingChannel():getName()})
    end
    
    
    print("Entry Date : "..order:getEntryTime():getDateInUtcOffset(common.offsetTimeZoneSecs):toString("%d/%m/%Y"))
    table.insert (depositItem,{'Entry_date',order:getEntryTime():getDateInUtcOffset(common.offsetTimeZoneSecs):toString("%d/%m/%Y")})
    
    print("Entry Time : "..order:getEntryTime():addHours(7):toString("%T"))
    table.insert (depositItem,{'Entry_time',order:getEntryTime():addHours(7):toString("%T")})
    
    print("===============================================================================================")
    --end
    
    end
        table.insert (depositList, depositItem)
    common.InsertRecords(db_file, log_file, table_name_order, depositList, debug_mode)
    
   
--end

    
    
end

end
   local inst = os.getenv( "BROKER_PREFIX" )
   local mand = mandator.Mandator( inst )
   mandator.changeTo( mand, process )
